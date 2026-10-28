// ignore_for_file: avoid_print

import 'package:firebase_database/firebase_database.dart';

class StressService {
  static final StressService _instance = StressService._internal();

  factory StressService() => _instance;

  StressService._internal();

  // Récupérer le niveau de stress actuel
  Future<int?> getStressValue() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('BoblEponge/stress');

    try {
      final event = await ref.once();
      final value = event.snapshot.value;
      return value is int ? value : int.tryParse(value.toString());
    } catch (e) {
      print('Erreur lors de la lecture du niveau de stress : $e');
      return null;
    }
  }

  // Mettre à jour le niveau de stress
  Future<void> setStressValue(int value) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('BoblEponge/stress');

    try {
      await ref.set(value);
      print('Niveau de stress mis à jour : $value');
    } catch (e) {
      print('Erreur lors de la mise à jour du niveau de stress : $e');
    }
  }
}
