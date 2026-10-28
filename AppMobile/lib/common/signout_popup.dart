import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifebeat/common/auth_state.dart';
import 'package:lifebeat/view/login/login_view.dart';
void showSignOutPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Sign Out"),
      content: const Text("Are you sure you want to sign out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pushReplacement(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginView()),
                                );
            try {
              await FirebaseAuth.instance.signOut();
              AuthState.isLoggedIn.value = false;
            } catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error signing out")),
              );
            }
          },
          child: const Text("Sign Out"),
        ),
      ],
    ),
  );
}
