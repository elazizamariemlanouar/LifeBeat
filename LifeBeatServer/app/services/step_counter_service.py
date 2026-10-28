

import math

from app.models.patient import Acceleration


class StepCounterService:
    def __init__(self, step_detection_threshold: float):
        self.step_detection_threshold = step_detection_threshold

    def detect_step(self, current: Acceleration, previous: Acceleration) -> bool:
        """Retourne True si un pas est détecté entre deux lectures successives."""
        diff_x = current.x - previous.x
        diff_y = current.y - previous.y
        diff_z = current.z - previous.z
        magnitude_diff = math.sqrt(diff_x**2 + diff_y**2 + diff_z**2)
        return magnitude_diff > self.step_detection_threshold
