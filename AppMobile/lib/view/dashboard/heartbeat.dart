import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lifebeat/common/color_extension.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';

class HeartbeatView extends StatefulWidget {
  const HeartbeatView({super.key});

  @override
  State<HeartbeatView> createState() => _HeartbeatViewState();
}

class _HeartbeatViewState extends State<HeartbeatView> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('BoblEponge/beatsPerMinute');
  final GetStorage box = GetStorage(); // 🔵 Ajouté

  List<FlSpot> spots = [];
  List<int> showingTooltipOnSpots = [];
  double latestHeartbeat = 0;
  int currentIndex = 0;

  @override
  void initState()  {
    super.initState();

    // 🔵 Charger les données sauvegardées au démarrage
    List stored = box.read<List>('bpm_values') ?? [];
    spots = List.generate(
      stored.length,
      (i) => FlSpot(i.toDouble(), stored[i] as double),
    );
    currentIndex = spots.length;

    _databaseReference.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        final bpm = (event.snapshot.value as num).toDouble();

        setState(() {
          latestHeartbeat = bpm;
          spots.add(FlSpot(currentIndex.toDouble(), bpm));
          showingTooltipOnSpots = [spots.isNotEmpty ? spots.length - 1 : 0];

          currentIndex++;

          if (spots.length > 30) {
          spots.removeAt(0);
          for (int i = 0; i < spots.length; i++) {
            spots[i] = FlSpot(i.toDouble(), spots[i].y);
          }
          currentIndex = spots.length;
          showingTooltipOnSpots = [spots.length - 1];
        }

          // 🔵 Enregistrer les valeurs localement
          box.write('bpm_values', spots.map((e) => e.y).toList());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: spots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              TColor.primaryColor2.withOpacity(0.4),
              TColor.primaryColor1.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: const FlDotData(show: false),
        gradient: LinearGradient(colors: TColor.primaryG),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Column(
      children: [
        SizedBox(height: media.width * 0.02),
        ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: media.width * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: TColor.primaryColor2.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Heart Rate",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            colors: TColor.primaryG,
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(
                              Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                        },
                        child: Text(
                          "${latestHeartbeat.toInt()} BPM",
                          style: TextStyle(
                            color: TColor.white.withOpacity(0.7),
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: LineChart(
                      LineChartData(
                        showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                          return ShowingTooltipIndicators([
                            LineBarSpot(
                              tooltipsOnBar,
                              lineBarsData.indexOf(tooltipsOnBar),
                              tooltipsOnBar.spots[index],
                            ),
                          ]);
                        }).toList(),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: false,
                          touchCallback: (event, response) {
                            if (response == null || response.lineBarSpots == null) return;

                            if (event is FlTapUpEvent) {
                              final spotIndex = response.lineBarSpots!.first.spotIndex;
                              setState(() {
                                showingTooltipOnSpots = [spotIndex];
                              });
                            }
                          },
                          mouseCursorResolver: (event, response) {
                            if (response == null || response.lineBarSpots == null) {
                              return SystemMouseCursors.basic;
                            }
                            return SystemMouseCursors.click;
                          },
                          getTouchedSpotIndicator: (barData, spotIndexes) {
                            return spotIndexes.map((index) {
                              return TouchedSpotIndicatorData(
                                const FlLine(color: Colors.red),
                                FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, barData, index) =>
                                      FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.white,
                                    strokeWidth: 3,
                                    strokeColor: TColor.secondaryColor1,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: TColor.secondaryColor1,
                            tooltipRoundedRadius: 20,
                            getTooltipItems: (lineBarsSpot) {
                              return lineBarsSpot.map((spot) {
                                return LineTooltipItem(
                                  "${spot.x.toInt()} Min : ${spot.y.toStringAsFixed(0)} BPM",
                                  const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        lineBarsData: lineBarsData,
                        minY: 0,
                        maxY: 130,
                        titlesData: const FlTitlesData(show: false),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
