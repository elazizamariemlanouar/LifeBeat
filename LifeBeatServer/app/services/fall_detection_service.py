
import math


class FallDetectionService:
    def __init__(self, fall_detection_threshold: float):
        self.fall_detection_threshold = fall_detection_threshold

    def detect_fall(self, x: float, y: float, z: float) -> bool:
        magnitude = math.sqrt(x**2 + y**2 + z**2)
        return magnitude > self.fall_detection_threshold
