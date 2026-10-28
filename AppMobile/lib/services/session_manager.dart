import 'package:firebase_auth/firebase_auth.dart';
import 'sleep_tracker_service.dart';
import 'notification_service.dart'; // <-- si tu as un service de notifications

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  void start() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // 🔴 Déconnecté → tout arrêter
        SleepTrackerService().dispose();
        NotificationService().dispose(); // si tu en as un
        print("🔒 Utilisateur déconnecté, services arrêtés.");
      } else {
        // 🟢 Connecté → démarrer les services
        SleepTrackerService().init();
        NotificationService().init(); // si tu en as un
        print("🔓 Utilisateur connecté, services démarrés.");
      }
    });
  }
}
