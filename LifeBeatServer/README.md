# LifeBeat Server

Serveur backend de LifeBeat : surveillance en temps réel des signes vitaux
d'un patient (fréquence cardiaque, température, SpO2), prédiction du niveau
de risque via un modèle de machine learning, génération d'alertes, comptage
de pas et détection de chute — le tout synchronisé avec **Firebase Realtime
Database**.

Ce projet a été réorganisé selon une architecture Flask professionnelle
(pattern *Application Factory* + couches *Models / Services / API /
Monitoring*), au lieu d'un unique fichier monolithique.

---

## 📁 Architecture du projet

```
LifeBeatServer/
├── app/
│   ├── __init__.py            # Application factory (create_app)
│   ├── config.py              # Configuration (dev / prod / test) via variables d'env
│   ├── extensions.py          # Initialisation Firebase (singleton)
│   │
│   ├── api/                   # Couche présentation (routes HTTP Flask)
│   │   ├── __init__.py
│   │   └── routes.py
│   │
│   ├── models/                # Structures de données (dataclasses)
│   │   ├── __init__.py
│   │   ├── patient.py
│   │   └── alert.py
│   │
│   ├── services/               # Logique métier, un service = une responsabilité
│   │   ├── __init__.py
│   │   ├── firebase_service.py       # Accès à Firebase (repository)
│   │   ├── prediction_service.py     # Modèle ML (arbre de décision)
│   │   ├── alert_service.py          # Règles de génération d'alertes
│   │   ├── step_counter_service.py   # Comptage de pas (accéléromètre)
│   │   └── fall_detection_service.py # Détection de chute
│   │
│   ├── monitoring/             # Orchestration : boucle de surveillance en thread
│   │   ├── __init__.py
│   │   └── monitor.py
│   │
│   └── utils/                  # Utilitaires transverses (logging, etc.)
│       ├── __init__.py
│       └── logger.py
│
├── ml_models/
│   └── decision_tree_model1.pkl   # Modèle de prédiction entraîné
│
├── credentials/                   # Secrets (JAMAIS commités, voir .gitignore)
│   ├── firebase-key.json
│   └── google-services.json
│
├── tests/                         # Tests unitaires (squelette, pytest)
│   ├── __init__.py
│   ├── test_alert_service.py
│   ├── test_prediction_service.py
│   └── test_monitor.py
│
├── run.py                # Point d'entrée de l'application
├── requirements.txt       # Dépendances Python
├── .env.example            # Modèle de configuration d'environnement
├── .gitignore
└── README.md
```

### Pourquoi cette architecture ?

| Couche         | Rôle                                                                 |
|----------------|-----------------------------------------------------------------------|
| `models/`      | Décrit *la forme* des données (Patient, Alert) — aucune logique métier |
| `services/`    | Contient *la logique métier* : un service = une responsabilité unique  |
| `monitoring/`  | *Orchestre* les services dans la boucle de surveillance en arrière-plan |
| `api/`         | Expose les routes HTTP (couche présentation), reste fine               |
| `config.py`    | Centralise toute la configuration, lue depuis l'environnement          |
| `extensions.py`| Initialise les services externes (Firebase) une seule fois             |

Cette séparation permet de tester chaque service indépendamment (avec des
mocks), de faire évoluer une couche sans impacter les autres, et de retrouver
facilement où se trouve chaque partie du code.

---

## ⚙️ Prérequis

- Python 3.10 ou supérieur
- Un projet Firebase avec Realtime Database activé
- Un fichier de clé de service Firebase (`firebase-key.json`)

---

## 🚀 Installation

### 1. Cloner / récupérer le projet

```bash
cd LifeBeatServer
```

### 2. Créer un environnement virtuel

**Sur macOS / Linux :**

```bash
python3 -m venv venv
source venv/bin/activate
```

**Sur Windows (PowerShell) :**

```powershell
python -m venv venv
venv\Scripts\Activate.ps1
```

**Sur Windows (cmd) :**

```cmd
python -m venv venv
venv\Scripts\activate.bat
```

Une fois activé, votre invite de commande doit afficher `(venv)` au début
de la ligne.

### 3. Installer les dépendances

```bash
pip install -r requirements.txt
```

### 4. Configurer les variables d'environnement

Copiez le fichier d'exemple :

```bash
cp .env.example .env        # macOS / Linux
copy .env.example .env      # Windows
```

Puis éditez `.env` et renseignez au minimum :

```
FIREBASE_DATABASE_URL=https://<votre-projet>-default-rtdb.<region>.firebasedatabase.app/
FIREBASE_CREDENTIALS_PATH=credentials/firebase-key.json
```

> ℹ️ Le fichier `.env` n'est **jamais** versionné (voir `.gitignore`). Chaque
> développeur ou environnement de déploiement doit créer le sien.

### 5. Placer les fichiers de credentials

Déposez votre clé de service Firebase dans :

```
credentials/firebase-key.json
```

Ce fichier est déjà exclu de Git via `.gitignore` — ne le partagez jamais
publiquement (dépôt GitHub, etc.).

### 6. Lancer le serveur

```bash
python run.py
```

Le serveur démarre sur `http://localhost:5000` et lance en parallèle un
thread de surveillance qui interroge Firebase toutes les
`MONITOR_INTERVAL_SECONDS` secondes pour le patient défini par
`MONITORED_PATIENT`.

Vérifiez que tout fonctionne via :

```bash
curl http://localhost:5000/health
```

---

## 🧪 Lancer les tests

```bash
pytest
```

Les tests présents sont des **squelettes** destinés à être complétés au fur
et à mesure du développement (voir les `TODO` dans `tests/`).

---

## ⚠️ Compatibilité du modèle ML

Le fichier `ml_models/decision_tree_model1.pkl` a été entraîné avec
**scikit-learn 1.6.1**. `requirements.txt` fixe cette version pour éviter les
avertissements (voire des erreurs) de désérialisation. Si vous devez utiliser
une autre version de scikit-learn, il est recommandé de ré-entraîner et de
resauvegarder le modèle avec la version cible.

---

## 🔐 Sécurité

- Ne commitez jamais `firebase-key.json`, `google-services.json` ou `.env`.
- En production, changez impérativement `SECRET_KEY` dans vos variables
  d'environnement.
- Le mode `debug=True` de Flask ne doit **jamais** être actif en production
  (contrôlé automatiquement via `FLASK_ENV=production`).

---

## 🗺️ Évolutions possibles

- Compléter les routes de `app/api/routes.py` pour exposer un vrai statut
  patient en JSON (actuellement un placeholder).
- Ajouter une base de données relationnelle pour l'historique des mesures.
- Remplacer le thread de surveillance par un worker planifié (Celery, APScheduler)
  pour une meilleure scalabilité.
- Ajouter une authentification sur les routes API.
