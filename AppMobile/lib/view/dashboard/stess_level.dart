import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../common/color_extension.dart';

class StresslevelView extends StatefulWidget {
  const StresslevelView({super.key});

  @override
  State<StresslevelView> createState() => _StresslevelViewState();
}

class _StresslevelViewState extends State<StresslevelView> {
  List<int> showingTooltipOnSpots = [3];
  List<FlSpot> stressData = [
    const FlSpot(0, 0),
    const FlSpot(4, 0),
    const FlSpot(8, 0),
    const FlSpot(12, 0),
    const FlSpot(16, 0),
    const FlSpot(20, 0),
  ];

  @override
  void initState() {
    super.initState();
    _fetchAndStoreStressValue();
    _loadStressDataFromFirestore();
  }

  /// ✅ Étape 1 : Lire depuis Realtime DB et sauvegarder dans Firestore
  Future<void> _fetchAndStoreStressValue() async {
    final now = DateTime.now();
    final hour = now.hour;
    final validHours = [0, 4, 8, 12, 16, 20];

    if (!validHours.contains(hour)) return;

    try {
      final dbRef = FirebaseDatabase.instance.ref('BoblEponge/stress');
      final snapshot = await dbRef.get();
      final stressValue = snapshot.value;

      if (stressValue != null && stressValue is num) {
          await FirebaseFirestore.instance
              .collection('Spongbob')
              .doc('data')
              .set({
            hour.toString(): stressValue
          }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Erreur de sauvegarde stress : $e');
    }
  }

  /// ✅ Étape 2 : Charger depuis Firestore et afficher dans FlChart
  Future<void> _loadStressDataFromFirestore() async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    try {
          final doc = await FirebaseFirestore.instance.collection('Spongbob').doc('data').get();
    if (doc.exists && doc.data() != null) {
      final Map<String, dynamic> rawData = Map<String, dynamic>.from(doc.data()!);
      final List<FlSpot> loadedData = [0, 4, 8, 12, 16, 20].map((h) {
        final value = rawData[h.toString()];
        return FlSpot(h.toDouble(), (value is num) ? value.toDouble() : 0);
      }).toList();

      setState(() => stressData = loadedData);
    }

    } catch (e) {
      debugPrint('Erreur de chargement Firestore : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Stress Level",
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              icon: Image.asset("assets/img/Dropdown1.png", width: 70, height: 70),
              onPressed: () {},
            ),
          ],
        ),
        Container(
          height: media.width * 0.6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                return ShowingTooltipIndicators([
                  LineBarSpot(
                    lineBarsData[0],
                    0,
                    lineBarsData[0].spots[index],
                  ),
                ]);
              }).toList(),
              lineTouchData: const LineTouchData(enabled: true),
              lineBarsData: lineBarsData,
              minY: 0,
              maxY: 120,
              titlesData: FlTitlesData(
                show: true,
                leftTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(sideTitles: bottomTitles),
                rightTitles: AxisTitles(sideTitles: rightTitles),
              ),
              gridData: const FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 20,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.transparent)),
            ),
          ),
        ),
      ],
    );
  }

  List<LineChartBarData> get lineBarsData => [
        LineChartBarData(
          isCurved: true,
          color: TColor.primaryColor1,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                TColor.primaryColor2,
                TColor.primaryColor1.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          spots: stressData,
        ),
      ];

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: (value, meta) {
          String text;
          switch (value.toInt()) {
            case 0:
              text = '0%';
              break;
            case 20:
              text = '20%';
              break;
            case 40:
              text = '40%';
              break;
            case 60:
              text = '60%';
              break;
            case 80:
              text = '80%';
              break;
            case 100:
              text = '100%';
              break;
            default:
              return Container();
          }
          return Text(text, style: const TextStyle(color: Colors.blueGrey, fontSize: 12));
        },
        showTitles: true,
        interval: 20,
        reservedSize: 50,
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 4,
        getTitlesWidget: (value, meta) {
          const style = TextStyle(color: Colors.blueGrey, fontSize: 12);
          switch (value.toInt()) {
            case 0:
              return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: const Text('0h', style: style));
            case 4:
              return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: const Text('4h', style: style));
            case 8:
              return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: const Text('8h', style: style));
            case 12:
              return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: const Text('12h', style: style));
            case 16:
              return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: const Text('16h', style: style));
            case 20:
              return SideTitleWidget(axisSide: meta.axisSide, space: 10, child: const Text('20h', style: style));
            default:
              return const SizedBox.shrink();
          }
        },
      );
}
