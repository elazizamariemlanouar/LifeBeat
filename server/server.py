from flask import Flask, jsonify  # type: ignore
import firebase_admin  # type: ignore
from firebase_admin import credentials, db  # type: ignore
import numpy as np
import joblib  # Remplace pickle par joblib

app = Flask(_name_)

# === 1. Initialiser Firebase ===
cred = credentials.Certificate("firebase-key.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://lifebeat-ee7aa-default-rtdb.europe-west1.firebasedatabase.app/'
})

# === 2. Charger ton modèle entraîné avec joblib ===
model = joblib.load("decision_tree_model.pkl")  # Utilisation de joblib à la place de pickle

# === 3. Créer une route pour prédire ===
@app.route('/predict', methods=['GET'])
def predict():
    try:
        ref = db.reference('BoblEponge')
        patient = ref.get()

        # Récupérer les données
        heart_rate = patient['beatsPerMinute']
        body_temp = patient['temperature']
        oxygen = patient['spo2']
        age = patient['Age']
        weight = patient['Weight']
        height = patient['Height']
        gender = 1  # suppose que c'est un homme (ou récupère depuis Firebase si tu as un champ "Gender")

        # Construire l'entrée
        entree = np.array([[heart_rate, body_temp, oxygen, age, gender, weight, height]])

        # Faire la prédiction
        prediction = model.predict(entree)[0]

        # Écrire le résultat dans Firebase
        db.reference('BoblEponge/Status').set(prediction)

        return jsonify({
            'Etat du patient prédit': prediction,
            'Données utilisées': {
                'Heart Rate': heart_rate,
                'Body Temperature': body_temp,
                'SpO2': oxygen,
                'Age': age,
                'Gender': gender,
                'Weight': weight,
                'Height': height
            }
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# === 4. Lancer le serveur ===
if _name_ == '_main_':
    app.run(debug=True)