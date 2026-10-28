// ignore_for_file: prefer_const_declarations

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SleepTrackerService {
  static final SleepTrackerService _instance = SleepTrackerService._internal();
  factory SleepTrackerService() => _instance;
  SleepTrackerService._internal();

  final DatabaseReference _ref =
      FirebaseDatabase.instance.ref('BoblEponge/en_sommeil');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _collection = 'Spongbob';
  final String _document = 'weekly';
  final String _sessionDoc = 'currentSession';
  final Map<String, double> _weeklySleepData = {};

  StreamSubscription<DatabaseEvent>? _subscription;
  DateTime? _startSleep;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _loadSleepData();
    await _resetTodayIfNeeded();
    await _recoverStartSleepIfNeeded(); // 🔄 récupération si l'app a été redémarrée
    _listenSleepState();
  }

  Future<void> _loadSleepData() async {
    final doc = await _firestore.collection(_collection).doc(_document).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['weeklySleepData'] != null) {
        final raw = Map<String, dynamic>.from(data['weeklySleepData']);
        _weeklySleepData.clear();
        _weeklySleepData.addAll(
          raw.map((k, v) => MapEntry(k, (v as num).toDouble())),
        );
      }
    }

    for (int i = 1; i <= 7; i++) {
      _weeklySleepData.putIfAbsent(i.toString(), () => 0.0);
    }
  }

  Future<void> _resetTodayIfNeeded() async {
    final now = DateTime.now();
    final todayKey = now.weekday.toString();
    final lastUpdateKey = 'lastResetDate';

    final doc = await _firestore.collection(_collection).doc(_document).get();
    final data = doc.data();
    final lastResetString = data?[lastUpdateKey];
    final lastResetDate = lastResetString != null
        ? DateTime.tryParse(lastResetString)
        : null;

    if (lastResetDate == null ||
        lastResetDate.day != now.day ||
        lastResetDate.month != now.month ||
        lastResetDate.year != now.year) {
      _weeklySleepData[todayKey] = 0;
      for (int i = now.weekday + 1; i <= 7; i++) {
        _weeklySleepData[i.toString()] = 0;
      }

      await _firestore.collection(_collection).doc(_document).set({
        'weeklySleepData': _weeklySleepData,
        lastUpdateKey: now.toIso8601String(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _recoverStartSleepIfNeeded() async {
    final sessionDoc =
        await _firestore.collection(_collection).doc(_sessionDoc).get();

    if (sessionDoc.exists) {
      final data = sessionDoc.data();
      if (data != null && data['startTime'] != null && data['status'] == 'en cours') {
        _startSleep = DateTime.tryParse(data['startTime']);
      }
    }
  }

  void _listenSleepState() {
    _subscription = _ref.onValue.listen((event) async {
      final value = event.snapshot.value;
      final now = DateTime.now();
      final dayKey = now.weekday.toString();


      if (value == true || value == 1) {
        if (_startSleep == null) {
          _startSleep = now;
          await _firestore.collection(_collection).doc(_sessionDoc).set({
            'startTime': _startSleep!.toIso8601String(),
            'status': 'en cours',
          });
        }
      } else {
        if (_startSleep != null) {
          final duration = now.difference(_startSleep!);
          final hoursSlept = duration.inMinutes / 60;


          _weeklySleepData[dayKey] =
              (_weeklySleepData[dayKey] ?? 0) + hoursSlept;

          await _saveSleepData();

          await _firestore.collection(_collection).doc(_sessionDoc).set({
            'startTime': _startSleep!.toIso8601String(),
            'endTime': now.toIso8601String(),
            'durationInMinutes': duration.inMinutes,
            'status': 'terminé',
          });

          _startSleep = null;
        }
      }
    });
  }

  Future<void> _saveSleepData() async {
    await _firestore.collection(_collection).doc(_document).set({
      'weeklySleepData': _weeklySleepData,
    }, SetOptions(merge: true));
  }

  Map<String, double> getSleepData() => _weeklySleepData;

  void dispose() {
    _subscription?.cancel();
  }
}
