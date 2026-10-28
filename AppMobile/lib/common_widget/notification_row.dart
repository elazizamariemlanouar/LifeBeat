import 'package:flutter/material.dart';
import 'package:lifebeat/common/color_extension.dart';

class NotificationRow extends StatelessWidget {
  final Map nObj;
  final VoidCallback onDelete;

  const NotificationRow({super.key, required this.nObj, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              nObj["image"].toString(),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nObj["title"].toString(),
                  style: TextStyle(
                      color: TColor.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
                Text(
                  nObj["time"].toString(),
                  style: TextStyle(
                    color: TColor.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Supprimer cette notification"),
                  content: const Text("Voulez-vous supprimer cette alerte ?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete(); // Appelle la fonction de suppression
                      },
                      child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            icon: Image.asset(
              "assets/img/Icon-More.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          )
        ],
      ),
    );
  }
}
