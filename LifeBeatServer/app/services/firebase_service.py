
from firebase_admin import db

from app.models.patient import Patient


class FirebaseService:
    """Repository encapsulant les lectures/écritures Firebase pour un patient."""

    def get_patient(self, patient_name: str) -> Patient | None:
        raw = db.reference(patient_name).get()
        if not raw:
            return None
        return Patient.from_dict(patient_name, raw)

    def set_status(self, patient_name: str, status: str) -> None:
        db.reference(f"{patient_name}/Status").set(status)

    def get_alerts(self, patient_name: str) -> dict:
        return db.reference(f"{patient_name}/alertes").get() or {}

    def set_alerts(self, patient_name: str, alerts: dict) -> None:
        db.reference(f"{patient_name}/alertes").set(alerts)

    def get_previous_acceleration(self, patient_name: str) -> tuple[float, float, float]:
        prev_x = db.reference(f"{patient_name}/prev_x").get() or 0
        prev_y = db.reference(f"{patient_name}/prev_y").get() or 0
        prev_z = db.reference(f"{patient_name}/prev_z").get() or 0
        return prev_x, prev_y, prev_z

    def set_previous_acceleration(self, patient_name: str, x: float, y: float, z: float) -> None:
        db.reference(f"{patient_name}/prev_x").set(x)
        db.reference(f"{patient_name}/prev_y").set(y)
        db.reference(f"{patient_name}/prev_z").set(z)

    def get_steps(self, patient_name: str) -> int:
        return db.reference(f"{patient_name}/steps").get() or 0

    def set_steps(self, patient_name: str, steps: int) -> None:
        db.reference(f"{patient_name}/steps").set(steps)

    def set_fall_detected(self, patient_name: str, fall_detected: bool) -> None:
        db.reference(f"{patient_name}/FallDetected").set(fall_detected)
