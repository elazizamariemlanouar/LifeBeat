

import logging
import threading
import time

from app.models.patient import Acceleration
from app.services.firebase_service import FirebaseService
from app.services.prediction_service import PredictionService
from app.services.alert_service import AlertService
from app.services.step_counter_service import StepCounterService
from app.services.fall_detection_service import FallDetectionService

logger = logging.getLogger(__name__)


class PatientMonitor:
    """Orchestrateur de la surveillance d'un patient donné."""

    def __init__(
        self,
        firebase_service: FirebaseService,
        prediction_service: PredictionService,
        alert_service: AlertService,
        step_counter_service: StepCounterService,
        fall_detection_service: FallDetectionService,
    ):
        self.firebase_service = firebase_service
        self.prediction_service = prediction_service
        self.alert_service = alert_service
        self.step_counter_service = step_counter_service
        self.fall_detection_service = fall_detection_service

    def process_patient(self, patient_name: str) -> None:
        """Traite un cycle complet de surveillance pour un patient."""
        try:
            patient = self.firebase_service.get_patient(patient_name)
            if patient is None:
                logger.warning("Patient '%s' introuvable.", patient_name)
                return

            # 1. Prédiction du risque
            risk = self.prediction_service.predict_risk(patient)
            self.firebase_service.set_status(patient_name, risk)

            # 2. Alertes
            existing_alerts = self.firebase_service.get_alerts(patient_name)
            alerts = self.alert_service.build_alerts(patient, risk, existing_alerts)
            if alerts:
                self.firebase_service.set_alerts(patient_name, alerts)

            # 3. Pas et chute (si l'accéléromètre renvoie des données valides)
            if patient.acceleration.is_valid():
                self._process_motion(patient_name, patient.acceleration)

        except Exception:  # noqa: BLE001 - on log et on continue la boucle
            logger.exception("Erreur lors du traitement du patient '%s'.", patient_name)

    def _process_motion(self, patient_name: str, acceleration: Acceleration) -> None:
        prev_x, prev_y, prev_z = self.firebase_service.get_previous_acceleration(patient_name)
        previous = Acceleration(prev_x, prev_y, prev_z)

        if self.step_counter_service.detect_step(acceleration, previous):
            current_steps = self.firebase_service.get_steps(patient_name)
            self.firebase_service.set_steps(patient_name, current_steps + 1)
            logger.info("Pas détecté ! Total : %s", current_steps + 1)

        self.firebase_service.set_previous_acceleration(
            patient_name, acceleration.x, acceleration.y, acceleration.z
        )

        fall_detected = self.fall_detection_service.detect_fall(
            acceleration.x, acceleration.y, acceleration.z
        )
        self.firebase_service.set_fall_detected(patient_name, fall_detected)

    def run_forever(self, patient_name: str, interval_seconds: float) -> None:
        """Boucle infinie de surveillance (à exécuter dans un thread)."""
        while True:
            self.process_patient(patient_name)
            time.sleep(interval_seconds)


def start_monitoring_thread(monitor: PatientMonitor, patient_name: str, interval_seconds: float) -> threading.Thread:
    """Démarre la surveillance dans un thread daemon et le retourne."""
    thread = threading.Thread(
        target=monitor.run_forever,
        args=(patient_name, interval_seconds),
        daemon=True,
    )
    thread.start()
    return thread
