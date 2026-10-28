

from dataclasses import dataclass, field


@dataclass
class Acceleration:
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0

    @classmethod
    def from_dict(cls, data: dict | None) -> "Acceleration":
        data = data or {}
        return cls(
            x=data.get("x", 0.0),
            y=data.get("y", 0.0),
            z=data.get("z", 0.0),
        )

    def is_valid(self) -> bool:
        return all(isinstance(v, (int, float)) for v in (self.x, self.y, self.z))


@dataclass
class Patient:
    """Représente un patient et ses signes vitaux tels que stockés dans
    Firebase Realtime Database.
    """

    name: str
    heart_rate: float
    temperature: float
    spo2: float
    age: float
    weight: float
    height: float
    acceleration: Acceleration = field(default_factory=Acceleration)

    @classmethod
    def from_dict(cls, name: str, data: dict) -> "Patient":
        """Construit un Patient à partir des données brutes issues de Firebase."""
        return cls(
            name=name,
            heart_rate=data["beatsPerMinute"],
            temperature=data["temperature"],
            spo2=data["spo2"],
            age=data["Age"],
            weight=data["Weight"],
            height=data["Height"],
            acceleration=Acceleration.from_dict(data.get("acceleration")),
        )

    def to_feature_list(self) -> list:
        """Retourne les caractéristiques dans l'ordre attendu par le modèle ML."""
        return [
            self.heart_rate,
            self.temperature,
            self.spo2,
            self.age,
            self.weight,
            self.height,
        ]


FEATURE_COLUMNS = ["HeartRate", "Temperature", "Spo2", "Age", "Weight", "Height"]
