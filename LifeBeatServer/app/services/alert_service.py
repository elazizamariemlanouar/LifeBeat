

from app.models.patient import Patient
from app.models.alert import Alert
from app.services.prediction_service import HIGH_RISK_LABEL


class AlertService:
    """Construit la liste des alertes à partir des seuils configurés."""

    def __init__(
        self,
        temperature_high_threshold: float,
        heart_rate_low_threshold: float,
        heart_rate_high_threshold: float,
        spo2_low_threshold: float,
    ):
        self.temperature_high_threshold = temperature_high_threshold
        self.heart_rate_low_threshold = heart_rate_low_threshold
        self.heart_rate_high_threshold = heart_rate_high_threshold
        self.spo2_low_threshold = spo2_low_threshold

    def build_alerts(self, patient: Patient, risk_prediction: str, existing_alerts: dict) -> dict:
        """Retourne le dictionnaire d'alertes mis à jour (format Firebase).

        Une alerte n'est ajoutée que si un message identique n'existe pas
        déjà, afin d'éviter les doublons (comportement repris de la version
        d'origine).
        """
        alerts = dict(existing_alerts)
        counter = len(alerts)

        candidates = []

        if risk_prediction == HIGH_RISK_LABEL:
            candidates.append(
                Alert(f"⚠️ {patient.name} est en risque élevé.", "stable")
            )

        if patient.temperature > self.temperature_high_threshold:
            candidates.append(
                Alert(
                    f"{patient.name} a une température élevée : {patient.temperature:.1f}°C.",
                    "temp",
                )
            )

        if patient.heart_rate < self.heart_rate_low_threshold:
            candidates.append(
                Alert(
                    f"⚠️ {patient.name} a une fréquence cardiaque trop basse : "
                    f"{patient.heart_rate} bpm.",
                    "heart",
                )
            )
        elif patient.heart_rate > self.heart_rate_high_threshold:
            candidates.append(
                Alert(
                    f"⚠️ {patient.name} a une fréquence cardiaque trop élevée : "
                    f"{patient.heart_rate} bpm.",
                    "heart",
                )
            )

        if patient.spo2 < self.spo2_low_threshold:
            candidates.append(
                Alert(
                    f"⚠️ {patient.name} a une saturation en oxygène trop basse : "
                    f"{patient.spo2}%.",
                    "oxygen",
                )
            )

        for alert in candidates:
            counter = self._add_unique_alert(alerts, counter, alert)

        return alerts

    @staticmethod
    def _add_unique_alert(alerts: dict, counter: int, alert: Alert) -> int:
        already_exists = any(a.get("message") == alert.message for a in alerts.values())
        if already_exists:
            return counter
        alerts[f"alert{counter}"] = alert.to_dict()
        return counter + 1
