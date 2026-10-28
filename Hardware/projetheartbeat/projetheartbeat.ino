#include <Wire.h>
#include <MPU6050.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include <ESP8266WiFi.h>
#include <Firebase.h>
#include <WiFiUdp.h>
#include <time.h>
#include "MAX30105.h"
#include "heartRate.h"

// DS18B20
#define ONE_WIRE_BUS D3
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// MPU6050
MPU6050 mpu;
int16_t ax, ay, az;
int16_t gx, gy, gz;
float temperature;

// MAX30105
MAX30105 particleSensor;
long lastBeat = 0;
float beatsPerMinute ;
float spO2 = 0.0;
const long MIN_IR_VALUE = 5000;

// Firebase
Firebase fb("https://lifebeat-ee7aa-default-rtdb.europe-west1.firebasedatabase.app/", "AIzaSyAmuZi5czBX3U-WeuH5eeIz6inh4Sxixc4");

// Wi-Fi
const char* ssid = "houssem soudana";
const char* password = "M47AE7JUM7KRH";

void setup() {
  Serial.begin(9600);

  // MPU6050
  Wire.begin(D2, D1);
  mpu.initialize();
  if (mpu.testConnection()) {
    Serial.println("✅ MPU6050 connecté.");
  } else {
    Serial.println("❌ Erreur MPU6050.");
    while (1);
  }

  // DS18B20
  sensors.begin();

  // MAX30105
  if (!particleSensor.begin(Wire, I2C_SPEED_FAST)) {
    Serial.println("❌ MAX30105 non détecté.");
    while (1);
  }
  particleSensor.setup(0x1F, 8, 3, 100, 411, 4096);
  particleSensor.enableDIETEMPRDY();
  Serial.println("🩺 MAX30105 prêt. Placez votre doigt.");

  // Wi-Fi
  Serial.println("Connexion au Wi-Fi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\n✅ Wi-Fi connecté.");

  // Configuration de l'heure via NTP
  configTime(3600, 0, "pool.ntp.org", "time.nist.gov");  // UTC+1 pour Tunisie
  while (time(nullptr) < 100000) {
    Serial.print("⏳ Sync time...");
    delay(500);
  }
  Serial.println("🕒 Heure synchronisée.");
}

String getTimeStamp() {
  time_t now = time(nullptr);
  struct tm* timeInfo = localtime(&now);

  char buffer[25];
  snprintf(buffer, sizeof(buffer), "%02d-%02d-%04d_%02d:%02d:%02d",
           timeInfo->tm_mday,
           timeInfo->tm_mon + 1,
           timeInfo->tm_year + 1900,
           timeInfo->tm_hour,
           timeInfo->tm_min,
           timeInfo->tm_sec);

  return String(buffer);
}

void loop() {
  // Lecture DS18B20
  sensors.requestTemperatures();
  temperature = sensors.getTempCByIndex(0);

  // Lecture MPU6050
  mpu.getAcceleration(&ax, &ay, &az);
  mpu.getRotation(&gx, &gy, &gz);

  // Lecture MAX30105-coeur-oxy
  long irValue = particleSensor.getIR();
  long redValue = particleSensor.getRed();
  bool fingerDetected = (irValue > MIN_IR_VALUE);

  if (fingerDetected) {
    if (checkForBeat(irValue)) {
      long delta = millis() - lastBeat;
      if (delta > 300) {
        lastBeat = millis();
        float bpm = 60 / (delta / 1000.0);
        if (bpm > 40 && bpm < 180) {
          beatsPerMinute = bpm;
          Serial.println(beatsPerMinute);
        }
      }
    }
    spO2 = calculateSpO2Simple(redValue, irValue);
  } else {
    
    beatsPerMinute = 0.0;
    spO2 = 0.0;
    Serial.println("❗ Doigt non détecté.");
  }
  delay(500);
  // Affichage série
  Serial.print("🌡 Température: "); Serial.print(temperature); Serial.println(" °C");
  Serial.print("📈 Acc X: "); Serial.print(ax); Serial.print(" | Y: "); Serial.print(ay); Serial.print(" | Z: "); Serial.println(az);
  Serial.print("💓 BPM: "); Serial.println(beatsPerMinute);
  Serial.print("🩸 SpO2: "); Serial.print(spO2, 1); Serial.println(" %");
  
  // Horodatage
  String timeStamp = getTimeStamp();

  // Envoi à Firebase
  fb.setFloat("sensors1/" + timeStamp + "/temperature", temperature);
  fb.setInt("sensors1/" + timeStamp + "/acceleration/x", ax);
  fb.setInt("sensors1/" + timeStamp + "/acceleration/y", ay);
  fb.setInt("sensors1/" + timeStamp + "/acceleration/z", az);
  fb.setFloat("sensors1/" + timeStamp + "/bpm", beatsPerMinute);
  fb.setFloat("sensors1/" + timeStamp + "/spo2", spO2);

  Serial.println("✅ Données envoyées à Firebase à : " + timeStamp);
  Serial.println("--------------------------------------------------");

  delay(500);
}

// Fonctions du MAX30105-coeur-oxy
boolean checkForBeat(long irValue) {
  static long prevIrValue = 0;
  static boolean prevState = false;

  boolean beatDetected = (irValue > prevIrValue + 20) && prevState && (millis() - lastBeat > 300);
  prevIrValue = irValue;
  prevState = (irValue > MIN_IR_VALUE);
  return beatDetected;
}

float calculateSpO2Simple(long redValue, long irValue) {
  float ratio = (float)redValue / irValue;
  float spO2 = 110.0 - (25.0 * ratio);
  return constrain(spO2, 0.0, 100.0);
}