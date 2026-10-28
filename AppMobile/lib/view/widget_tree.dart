import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifebeat/view/main_tab/main_tab_view.dart';
import 'package:lifebeat/view/on_boarding/started_view.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Attente chargement
        }
        if (snapshot.hasData) {
          return const MainTabView(); // Utilisateur connecté
        } else {
          return const StartedView(); // Utilisateur déconnecté
        }
      },
    );
  }
}
