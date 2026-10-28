import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lifebeat/common/Color_extension.dart';// Assurez-vous que le chemin est correct
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifebeat/common_widget/wave_widget.dart';
import 'package:lifebeat/common_widget/wave_widget1.dart';
class HealthOverviewPage extends StatefulWidget {
  const HealthOverviewPage({super.key});

  @override
  State<HealthOverviewPage> createState() => _HealthOverviewPageState();
}

class _HealthOverviewPageState extends State<HealthOverviewPage> with SingleTickerProviderStateMixin {
  double spo2 = 0;
  double temperature = 0;
  String sleepDuration = "0h00m"; // Valeur initiale
  int steps = 0; // Variable pour stocker les pas
    // Chargement des données depuis Firebase pour les pas
  void _loadStepsFromFirebase() {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('BoblEponge/steps');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      setState(() {
        steps = (data ?? 0) as int; // Mettre à jour les pas depuis Firebase
      });
    });
  }
  void _loadTodaySleepFromWeekly() async {
  final DateTime now = DateTime.now();
  final int weekday = now.weekday; // 1 = lundi, 7 = dimanche

  final doc = await FirebaseFirestore.instance
      .collection('Spongbob')
      .doc('weekly')
      .get();

  if (doc.exists) {
    final data = doc.data();
    if (data != null && data['weeklySleepData'] != null) {
      final weeklyData = Map<String, dynamic>.from(data['weeklySleepData']);
      final rawValue = weeklyData[weekday.toString()];

      if (rawValue != null) {
        double hours = (rawValue as num).toDouble();
        int h = hours.floor();
        int m = ((hours - h) * 60).round();

        setState(() {
          sleepDuration = "${h}h${m.toString().padLeft(2, '0')}m";
        });
      }
    }
  }
}

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _listenToFirebase();

    _listenToFirebase();
   _loadTodaySleepFromWeekly();
   _loadStepsFromFirebase(); // Charger les pas au démarrage

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // start a bit lower
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  void _listenToFirebase() {
    final DatabaseReference ref = FirebaseDatabase.instance.ref('BoblEponge');

    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          spo2 = double.tryParse(data['spo2'].toString()) ?? 0;
          temperature = double.tryParse(data['temperature'].toString()) ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget animatedBox(Widget child) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: media.width * 0.05),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: animatedBox(
                      buildSpO2Card(media),
                    ),
                  ),
                  SizedBox(width: media.width * 0.05),
                  Expanded(
                    child: animatedBox(
                      buildTemperatureCard(media),
                    ),
                  ),
                ],
              ),
              SizedBox(height: media.width * 0.05),
              Row(
                children: [
                  Expanded(
                    child: animatedBox(
                      buildStepsCard(media),
                    ),
                  ),
                  SizedBox(width: media.width * 0.05),
                  Expanded(
                    child: animatedBox(
                      buildSleepCard(media),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSpO2Card(Size media) {
    return Container(
      width: double.maxFinite,
      height: media.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWithIcon("SpO2", "assets/img/SPO2-icon.png"),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: TColor.primaryG,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
            },
            child: Text(
              "${spo2.toStringAsFixed(0)}%",
              style: TextStyle(
                color: TColor.white.withOpacity(0.7),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          /*Image.asset(
            "assets/img/Spo2-Graph.png",
            width: double.maxFinite,
            fit: BoxFit.fitWidth,
          ),*/
          // ignore: prefer_const_constructors
          WaveWidget()
        ],
      ),
    );
  }

  Widget buildTemperatureCard(Size media) {
    return Container(
      width: double.maxFinite,
      height: media.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWithIcon("Temp", "assets/img/temperature-icon.png"),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Padding(
            padding: const EdgeInsets.only(bottom: 20), 
              child: Text(
                temperature.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: TColor.primaryColor1,
                ),
            )),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Text(
                  "C°",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryColor1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStepsCard(Size media) {
    return Container(
      width: double.maxFinite,
      height: media.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleWithIcon("Steps", "assets/img/directions_walk.png"),
          const Spacer(),
          Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
            padding: const EdgeInsets.only(bottom: 1), // Espacement entre les deux
            child :Text(
              "$steps",
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: TColor.primaryColor1,
              ),
            ),),
            Padding(
              padding: const EdgeInsets.only(bottom: 15), // Espacement entre les deux
              child: Text(
                "steps",
                style: TextStyle(
                  fontSize: 12, // Taille réduite
                  fontWeight: FontWeight.bold,
                  color: TColor.primaryColor1,
                ),
              ),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget buildSleepCard(Size media) {
    return Container(
      width: double.maxFinite,
      height: media.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: TColor.primaryColor1,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This day Sleep",
            style: TextStyle(
              color: TColor.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            sleepDuration,
            style: TextStyle(
              color: TColor.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: WaveWidgett(),
          ),
          
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildTitleWithIcon(String title, String iconPath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.black,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Image.asset(
          iconPath,
          width: 20,
          height: 20,
        ),
      ],
    );
  }
}
