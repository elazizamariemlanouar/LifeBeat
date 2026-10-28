"""
Application factory Flask (pattern `create_app`).

Ce pattern est l'architecture standard recommandée par Flask pour les
applications de taille moyenne à grande : il permet de créer plusieurs
instances de l'application (utile pour les tests), d'éviter les imports
circulaires, et de garder une séparation nette entre la configuration,
les services et les routes.
"""

import logging

from flask import Flask

from app.config import get_config
from app.extensions import init_firebase
from app.api import api_bp
from app.services import (
    FirebaseService,
    PredictionService,
    AlertService,
    StepCounterService,
    FallDetectionService,
)
from app.monitoring import PatientMonitor, start_monitoring_thread
from app.utils.logger import setup_logging

logger = logging.getLogger(__name__)


def create_app(env_name: str | None = None, start_monitoring: bool = True) -> Flask:
    """Crée et configure l'instance Flask de l'application.

    Args:
        env_name: "development", "production" ou "testing". Si None, lu
            depuis la variable d'environnement FLASK_ENV.
        start_monitoring: si False, désactive le démarrage automatique du
            thread de surveillance (utile pour les tests unitaires).
    """
    app = Flask(__name__)
    config_class = get_config(env_name)
    app.config.from_object(config_class)

    setup_logging(debug=app.config["DEBUG"])

    # --- Extensions externes ---
    init_firebase(app.config)

    # --- Blueprints / routes ---
    app.register_blueprint(api_bp)

    # --- Services métier ---
    firebase_service = FirebaseService()
    prediction_service = PredictionService(app.config["ML_MODEL_PATH"])
    alert_service = AlertService(
        temperature_high_threshold=app.config["TEMPERATURE_HIGH_THRESHOLD"],
        heart_rate_low_threshold=app.config["HEART_RATE_LOW_THRESHOLD"],
        heart_rate_high_threshold=app.config["HEART_RATE_HIGH_THRESHOLD"],
        spo2_low_threshold=app.config["SPO2_LOW_THRESHOLD"],
    )
    step_counter_service = StepCounterService(app.config["STEP_DETECTION_THRESHOLD"])
    fall_detection_service = FallDetectionService(app.config["FALL_DETECTION_THRESHOLD"])

    monitor = PatientMonitor(
        firebase_service=firebase_service,
        prediction_service=prediction_service,
        alert_service=alert_service,
        step_counter_service=step_counter_service,
        fall_detection_service=fall_detection_service,
    )

    # Rendre les services accessibles depuis les routes via `current_app`
    app.extensions["firebase_service"] = firebase_service
    app.extensions["patient_monitor"] = monitor

    # --- Thread de surveillance en arrière-plan ---
    if start_monitoring and app.config["MONITOR_INTERVAL_SECONDS"] > 0:
        start_monitoring_thread(
            monitor,
            patient_name=app.config["MONITORED_PATIENT"],
            interval_seconds=app.config["MONITOR_INTERVAL_SECONDS"],
        )
        logger.info(
            "Surveillance démarrée pour le patient '%s' (intervalle : %ss).",
            app.config["MONITORED_PATIENT"],
            app.config["MONITOR_INTERVAL_SECONDS"],
        )

    return app
