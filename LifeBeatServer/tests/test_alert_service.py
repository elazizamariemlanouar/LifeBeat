
from app.models.patient import Patient, Acceleration
from app.services.alert_service import AlertService


def make_patient(**overrides) -> Patient:
    defaults = dict(
        name="TestPatient",
        heart_rate=75,
        temperature=36.8,
        spo2=98,
        age=30,
        weight=70,
        height=175,
        acceleration=Acceleration(0, 0, 0),
    )
    defaults.update(overrides)
    return Patient(**defaults)


def test_no_alerts_when_all_vitals_normal():
    service = AlertService(
        temperature_high_threshold=38.5,
        heart_rate_low_threshold=60,
        heart_rate_high_threshold=100,
        spo2_low_threshold=70,
    )
    patient = make_patient()

    alerts = service.build_alerts(patient, risk_prediction="Low Risk", existing_alerts={})

    assert alerts == {}


def test_alert_created_for_high_temperature():
    service = AlertService(
        temperature_high_threshold=38.5,
        heart_rate_low_threshold=60,
        heart_rate_high_threshold=100,
        spo2_low_threshold=70,
    )
    patient = make_patient(temperature=39.2)

    alerts = service.build_alerts(patient, risk_prediction="Low Risk", existing_alerts={})

    assert len(alerts) == 1
    assert "température élevée" in list(alerts.values())[0]["message"]


# TODO: ajouter des tests pour PredictionService, FirebaseService (avec mocks),
# StepCounterService et FallDetectionService.
