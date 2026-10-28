

import joblib
import pandas as pd

from app.models.patient import Patient, FEATURE_COLUMNS

LOW_RISK_LABEL = "Low Risk"
HIGH_RISK_LABEL = "High Risk"


class PredictionService:
    """Charge le modèle `.pkl` et expose une méthode de prédiction simple."""

    def __init__(self, model_path: str):
        self._model_path = model_path
        self._model = joblib.load(model_path)

    def predict_risk(self, patient: Patient) -> str:
        """Prédit le niveau de risque ("Low Risk" / "High Risk") d'un patient."""
        features_df = pd.DataFrame([patient.to_feature_list()], columns=FEATURE_COLUMNS)
        raw_prediction = self._model.predict(features_df)[0]
        return LOW_RISK_LABEL if raw_prediction == 0 else HIGH_RISK_LABEL
