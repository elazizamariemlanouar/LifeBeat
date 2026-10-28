import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../common/color_extension.dart';
import '../../common_widget/notification_row.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<Map<String, String>> notificationArr = [];

  @override
  void initState() {
    super.initState();
    _loadInitialAlerts();
  }

  void _loadInitialAlerts() async {
    final snapshot = await FirebaseDatabase.instance
        .ref("BoblEponge/alertes")
        .get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, String>> loadedNotifications = [];

      data.forEach((key, value) {
        String title = value["message"] ?? "Alerte inconnue";
        String type = value["type"] ?? "heart";
        String imagePath = _getImageForType(type);

        loadedNotifications.add({
          "id": key, // 🔑 Pour suppression future
          "image": imagePath,
          "title": title,
          "time": "Il y a quelques instants"
        });
      });

      setState(() {
        notificationArr = loadedNotifications.reversed.toList();
      });
    }
  }

  String _getImageForType(String type) {
    switch (type) {
      case 'temp':
        return "assets/img/temp_alert.png";
      case 'oxygen':
        return "assets/img/oxygen_drop.png";
      case 'movement':
        return "assets/img/movement_alert.png";
      case 'sensor':
        return "assets/img/sensor_offline.png";
      case 'stable':
        return "assets/img/stable_status.png";
      case 'heart':
      default:
        return "assets/img/heart_alert.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
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
        title: Text(
          "Notification",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Supprimer toutes les alertes"),
        content: const Text("Voulez-vous vraiment supprimer toutes les alertes ?"),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("Supprimer"),
            onPressed: () async {
              // Supprimer toutes les alertes de Firebase
              await FirebaseDatabase.instance
                  .ref("BoblEponge/alertes")
                  .remove();

              // Vider la liste locale
              setState(() {
                notificationArr.clear();
              });

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Toutes les notifications ont été supprimées.")),
              );
            },
          ),
        ],
      );
    },
  );
}, // tu peux ajouter un bouton global plus tard ici
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
                "assets/img/Detail-Navs.png",
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        itemBuilder: (context, index) {
          final nObj = notificationArr[index];
          return NotificationRow(
            nObj: nObj,
            onDelete: () async {
              await FirebaseDatabase.instance
                  .ref("BoblEponge/alertes/${nObj['id']}")
                  .remove();

              setState(() {
                notificationArr.removeAt(index);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Notification supprimée.")),
              );
            },
          );
        },
        separatorBuilder: (context, index) => Divider(
          color: TColor.grey.withOpacity(0.5),
          height: 1,
        ),
        itemCount: notificationArr.length,
      ),
    );
  }
}
