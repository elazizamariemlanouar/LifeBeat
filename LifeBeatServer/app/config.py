

import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent


class Config:
    """Configuration de base, commune à tous les environnements."""

    # --- Flask ---
    SECRET_KEY = os.environ.get("SECRET_KEY", "change-me-in-production")
    DEBUG = False
    TESTING = False

    # --- Firebase ---
    FIREBASE_CREDENTIALS_PATH = os.environ.get(
        "FIREBASE_CREDENTIALS_PATH",
        str(BASE_DIR / "credentials" / "firebase-key.json"),
    )
    FIREBASE_DATABASE_URL = os.environ.get("FIREBASE_DATABASE_URL", "")

    # --- Machine Learning ---
    ML_MODEL_PATH = os.environ.get(
        "ML_MODEL_PATH",
        str(BASE_DIR / "ml_models" / "decision_tree_model1.pkl"),
    )

    # --- Surveillance des patients ---
    MONITORED_PATIENT = os.environ.get("MONITORED_PATIENT", "BoblEponge")
    MONITOR_INTERVAL_SECONDS = int(os.environ.get("MONITOR_INTERVAL_SECONDS", "2"))

    # --- Seuils médicaux (utilisés par les services d'alerte) ---
    TEMPERATURE_HIGH_THRESHOLD = float(os.environ.get("TEMPERATURE_HIGH_THRESHOLD", "38.5"))
    HEART_RATE_LOW_THRESHOLD = int(os.environ.get("HEART_RATE_LOW_THRESHOLD", "60"))
    HEART_RATE_HIGH_THRESHOLD = int(os.environ.get("HEART_RATE_HIGH_THRESHOLD", "100"))
    SPO2_LOW_THRESHOLD = int(os.environ.get("SPO2_LOW_THRESHOLD", "70"))

    # --- Détection de pas / de chute ---
    STEP_DETECTION_THRESHOLD = float(os.environ.get("STEP_DETECTION_THRESHOLD", "200"))
    FALL_DETECTION_THRESHOLD = float(os.environ.get("FALL_DETECTION_THRESHOLD", "15"))


class DevelopmentConfig(Config):
    DEBUG = True


class ProductionConfig(Config):
    DEBUG = False


class TestingConfig(Config):
    TESTING = True
    DEBUG = True
    # En test, on évite de démarrer le thread de surveillance automatiquement.
    MONITOR_INTERVAL_SECONDS = 0


CONFIG_BY_NAME = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
    "testing": TestingConfig,
}


def get_config(env_name: str | None = None):
    """Retourne la classe de configuration correspondant à l'environnement."""
    env_name = env_name or os.environ.get("FLASK_ENV", "development")
    return CONFIG_BY_NAME.get(env_name, DevelopmentConfig)
