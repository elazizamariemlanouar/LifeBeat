import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lifebeat/common/Color_extension.dart';
import 'package:lifebeat/common_widget/patient_status.dart';
import './notification_view.dart';
import 'package:lifebeat/view/dashboard/dashboard_view.dart';
// Classe Patient pour définir les informations d'un patient
class Patient {
  final String name;
  final String status;
  final Color statusColor;
  String heartRate;
  String temperature;
  String oxygen;

  Patient({
    required this.name,
    required this.status,
    required this.statusColor,
    required this.heartRate,
    required this.temperature,
    required this.oxygen,
  });
}

class PatientManager {
  static List<Patient> patients = [
    Patient(
      name: "David Richard ",
      status: "Safe",
      statusColor: Colors.green,
      heartRate: "75 Bpm",   // Valeurs par défaut, avant la mise à jour
      temperature: "36.5°C", // Valeurs par défaut, avant la mise à jour
      oxygen: "98%",         // Valeurs par défaut, avant la mise à jour
    ),
  ];

  // Fonction pour mettre à jour un patient spécifique
  static void updatePatient(String name, String heartRate, String temperature, String oxygen) {
    // Chercher le patient par son nom
    for (var patient in patients) {
      if (patient.name == name) {
        patient.heartRate = heartRate;
        patient.temperature = temperature;
        patient.oxygen = oxygen;
      }
    }
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  

  @override
  State<HomeView> createState() => _HomeViewState();

  static void addPatient(String fullName) {
    PatientManager.patients.add(Patient(
      name: fullName,
      status: "Stable",
      statusColor: Colors.blue,
      heartRate: "75 Bpm",
      temperature: "37°C",
      oxygen: "95%",
    ));
  }
}

class _HomeViewState extends State<HomeView> {
  // ignore: unused_field
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('BoblEponge');  // Référence vers le nœud 'BoblEponge' dans Realtime Database
  String? userFullName;

  @override
  void initState() {
    super.initState();
    fetchUserFullName();
  }
void fetchUserFullName() async {
    final ref = FirebaseDatabase.instance.ref('BoblEponge/Nom&Preanom');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      setState(() {
        userFullName = snapshot.value.toString();
      });
    } else {
      setState(() {
        userFullName = "Nom introuvable";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Welcome,",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Dr . $userFullName " ?? "chargement....",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(
                        "assets/img/Notification-Icon.png",
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationView(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Afficher les informations du patient depuis Realtime Database
                // Remplace le StreamBuilder unique par ceci :
                Column(
                  children: PatientManager.patients.map((patient) {
                    final patientRef = FirebaseDatabase.instance.ref("BoblEponge");

                    return StreamBuilder<DatabaseEvent>(
                        stream: patientRef.onValue,
                        builder: (context, snapshot) {
                          String heartRate = patient.heartRate;
                          String temperature = patient.temperature;
                          String oxygen = patient.oxygen;
                          String status = patient.status;
                          Color statusColor = patient.statusColor;

                          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                            final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                            heartRate = "${data['beatsPerMinute'] ?? 'N/A'} Bpm";
                            temperature = "${data['temperature'] ?? 'N/A'} °C";
                            oxygen = "${data['spo2'] ?? 'N/A'} %";

                            // Récupération du champ 'status' depuis Firebase
                         final String firebaseStatus = data['Status'].toString();

                        if (firebaseStatus == "High Risk") {
                          status = "Danger";
                          statusColor = Colors.red;
                        } else {
                          status = "Safe";
                          statusColor = Colors.green;
                        }


                            // Mettre à jour le patient
                            PatientManager.updatePatient(patient.name, heartRate, temperature, oxygen);
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardView(
                                    patient: Patient(
                                      name: patient.name,
                                      status: status,
                                      statusColor: statusColor,
                                      heartRate: heartRate,
                                      temperature: temperature,
                                      oxygen: oxygen,
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: PatientStatus(
                              name: patient.name,
                              status: status,
                              statusColor: statusColor,
                              heartRate: heartRate,
                              temperature: temperature,
                              oxygen: oxygen,
                            ),
                          );
                        },
                      );

                  }).toList(),
                ),


                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
