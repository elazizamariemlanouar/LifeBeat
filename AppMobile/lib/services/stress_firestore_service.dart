import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StressService {
  final _collection = FirebaseFirestore.instance.collection('Sbongbob');
  final String _docId = 'data'; // ID fixe pour simplifier

  /// Sauvegarder une liste de FlSpot dans Firestore
  Future<void> saveStressData(List<FlSpot> stressData) async {
    Map<String, double> dataMap = {
      for (var spot in stressData) spot.x.toInt().toString(): spot.y
    };

    await _collection.doc(_docId).set(dataMap);
  }

  /// Charger une liste de FlSpot depuis Firestore
  Future<List<FlSpot>> loadStressData() async {
    final doc = await _collection.doc(_docId).get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>;

    return data.entries
        .map((e) => FlSpot(double.parse(e.key), (e.value as num).toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  /// Mettre à jour un seul point (à une heure donnée)
  Future<void> updateStressAtHour(int hour, double value) async {
    await _collection.doc(_docId).set(
      {hour.toString(): value},
      SetOptions(merge: true),
    );
  }
}
