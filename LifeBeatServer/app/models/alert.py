
from dataclasses import dataclass


@dataclass
class Alert:
    message: str
    type: str

    def to_dict(self) -> dict:
        return {"message": self.message, "type": self.type}
