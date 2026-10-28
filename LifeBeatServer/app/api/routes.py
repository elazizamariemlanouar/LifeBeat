
from flask import Blueprint, jsonify, current_app

api_bp = Blueprint("api", __name__)


@api_bp.route("/health", methods=["GET"])
def health_check():
    """Endpoint simple pour vérifier que le serveur est en ligne."""
    return jsonify(status="ok"), 200


@api_bp.route("/patients/<patient_name>/status", methods=["GET"])
def get_patient_status(patient_name: str):
    """Placeholder : à implémenter selon les besoins du frontend.

    Exemple d'implémentation possible : lire `patient_name/Status` depuis
    Firebase via `FirebaseService` et le retourner en JSON.
    """
    return jsonify(message=f"Endpoint non implémenté pour '{patient_name}'."), 501
