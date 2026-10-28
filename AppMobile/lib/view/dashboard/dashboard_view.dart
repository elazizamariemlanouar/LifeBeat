import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lifebeat/common/color_extension.dart';
import 'package:lifebeat/view/dashboard/health_overview.dart';
import 'package:lifebeat/view/dashboard/heart_avg.dart';
import 'package:lifebeat/view/dashboard/heartbeat.dart';
import 'package:lifebeat/view/dashboard/sleep_tracker.dart';
import 'package:lifebeat/view/dashboard/stess_level.dart';
import 'package:lifebeat/view/dashboard/patient_profile_view.dart';
import 'package:lifebeat/view/home/home_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required Patient patient});

  // Fonction pour récupérer le nom du patient depuis Firestore
  Future<String> _fetchPatientName() async {
    final doc = await FirebaseFirestore.instance
        .collection('Spongbob')
        .doc('patient')
        .get();

    if (doc.exists) {
      final data = doc.data();
      return data?['name'] ?? 'Nom inconnu';  // Si le nom n'existe pas, retourner "Nom inconnu"
    } else {
      return 'Nom inconnu';  // Si le document n'existe pas
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
              children: [
                // 👤 Header bien aligné
                Row(
                  children: [
                    // 🔙 Bouton retour
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 36,
                        width: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 📄 Textes patient
                    Expanded(
                      child: FutureBuilder<String>(
                        future: _fetchPatientName(),  // Charger le nom du patient
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              "Chargement...",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Text(
                              "Erreur de chargement",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "This is",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  snapshot.data ?? 'Nom inconnu',  // Affichage du nom récupéré
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const Text(
                              "Nom inconnu",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    // 📋 Icône du profil à droite
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PatientProfileView(),
                          ),
                        );
                      },
                      child: Container(
                        height: 36,
                        width: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.article_outlined,
                            size: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ✅ Widgets inchangés
                const HeartbeatView(),
                const SizedBox(height: 20),
                const HealthOverviewPage(),
                const SizedBox(height: 20),
                const HeartAvg(),
                const SizedBox(height: 20),
                const SleepTrackerView(),
                const SizedBox(height: 20),
                const StresslevelView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}