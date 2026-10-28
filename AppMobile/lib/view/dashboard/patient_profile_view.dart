import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_button.dart'; // Assurez-vous que vous avez importé votre RoundButton

class PatientProfileView extends StatefulWidget {
  const PatientProfileView({super.key});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView> {
  Map<String, String> patientData = {};
  final _realtimeRef = FirebaseDatabase.instance.ref('BoblEponge'); // Accès à BoblEponge

  @override
  void initState() {
    super.initState();
    _loadPatientDetails();
  }

  Future<void> _loadPatientDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('Spongbob')
        .doc('patient')
        .get();
    final snapshot = await _realtimeRef.get();

    if (doc.exists || snapshot.exists) {
      final firestoreData = doc.data() ?? {};
      final realtimeData = snapshot.value as Map? ?? {};

      setState(() {
        patientData = {
          "name": firestoreData["name"] ?? "Nom inconnu",
          "age": realtimeData["Age"]?.toString() ?? "Âge inconnu",
          "weight": realtimeData["Weight"]?.toString() ?? "Poids inconnu",
          "height": realtimeData["Height"]?.toString() ?? "Taille inconnue",
          "gender": realtimeData["Gender"]?.toString() ?? "Genre inconnu",
          "blood_type": firestoreData["blood_type"] ?? "Groupe sanguin inconnu",
          "address": firestoreData["address"] ?? "Adresse inconnue",
          "phone": firestoreData["phone"] ?? "Numéro inconnu",
        };
      });
    }
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: patientData['name']);
    final ageController = TextEditingController(text: patientData['age']);
    final genderController = TextEditingController(text: patientData['gender']);
    final bloodTypeController = TextEditingController(text: patientData['blood_type']);
    final weightController = TextEditingController(text: patientData['weight']);
    final heightController = TextEditingController(text: patientData['height']);
    final addressController = TextEditingController(text: patientData['address']);
    final phoneController = TextEditingController(text: patientData['phone']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier les informations"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(nameController, "Nom"),
                _buildTextField(ageController, "Âge"),
                _buildTextField(genderController, "Genre"),
                _buildTextField(bloodTypeController, "Groupe sanguin"),
                _buildTextField(weightController, "Poids", icon: Icons.accessibility),
                _buildTextField(heightController, "Taille", icon: Icons.height),
                _buildTextField(addressController, "Adresse"),
                _buildTextField(phoneController, "Numéro", icon: Icons.phone),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Annuler"),
              onPressed: () => Navigator.pop(context),
            ),
            RoundButton(
              title: "Enregistrer",
              onPressed: () async {
                // MAJ Firestore
                await FirebaseFirestore.instance
                    .collection('Spongbob')
                    .doc('patient')
                    .set({
                  "name": nameController.text,
                  "age": ageController.text,
                  "gender": genderController.text,
                  "blood_type": bloodTypeController.text,
                  "weight": weightController.text,
                  "height": heightController.text,
                  "address": addressController.text,
                  "phone": phoneController.text,
                });

                // MAJ Realtime Database
                await _realtimeRef.update({
                  "age": ageController.text,
                  "weight": weightController.text,
                  "height": heightController.text,
                });

                Navigator.pop(context);
                _loadPatientDetails(); // Refresh UI
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: TColor.primaryColor1) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: TColor.primaryColor1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: TColor.primaryColor1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: TColor.primaryColor1),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TColor.primaryColor1),
        color: TColor.white, // Fond blanc
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: TColor.primaryColor1,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: TColor.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profil du Patient",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: TColor.black,
            fontSize: 16,
          ),
        ),
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              "assets/img/Back-Navs.png",
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      backgroundColor: TColor.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de profil du patient
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/img/Latest-Pic.png'), // Assurez-vous que vous avez ajouté l'image dans assets
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileDetail("Nom", patientData['name'] ?? "Nom inconnu"),
            _buildProfileDetail("Âge", patientData['age'] ?? "Âge inconnu"),
            _buildProfileDetail("Genre", patientData['gender'] ?? "Genre inconnu"),
            _buildProfileDetail("Groupe sanguin", patientData['blood_type'] ?? "Groupe sanguin inconnu"),
            _buildProfileDetail("Poids", patientData['weight'] ?? "Poids inconnu"),
            _buildProfileDetail("Taille", patientData['height'] ?? "Taille inconnue"),
            _buildProfileDetail("Adresse", patientData['address'] ?? "Adresse inconnue"),
            _buildProfileDetail("Numéro", patientData['phone'] ?? "Numéro inconnu"),
            const SizedBox(height: 20),
            Center(
              child: RoundButton(
                title: "Modifier",
                onPressed: _showEditDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
