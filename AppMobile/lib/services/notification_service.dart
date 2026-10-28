import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final DatabaseReference _alertRef =
      FirebaseDatabase.instance.ref("BoblEponge/alertes");

  StreamSubscription<DatabaseEvent>? _subscription;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    

    _listenToRealtimeAlerts();
  }

  void _listenToRealtimeAlerts() {
    _subscription = _alertRef.onChildAdded.listen((event) {
      final data = event.snapshot.value as Map?;

      if (data == null) return;

      final message = data['message'] ?? 'Nouvelle alerte';
      final type = data['type'] ?? 'inconnue';

      _showNotification(message.toString(), "Type: $type");
    });
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'realtime_alerts_channel',
      'Alertes en temps réel',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ID unique
      title,
      body,
      platformChannelSpecifics,
    );
  }

  void dispose() {
    _subscription?.cancel();
  }
}
