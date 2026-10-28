// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lifebeat/services/sleep_tracker_service.dart';

import '../../common/color_extension.dart';


class SleepTrackerView extends StatefulWidget {
  const SleepTrackerView({super.key});

  @override
  State<SleepTrackerView> createState() => _SleepTrackerViewState();
}

class _SleepTrackerViewState extends State<SleepTrackerView> {
  final Map<String, double> _weeklySleepData = {};

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  void _loadSleepData() {
    final data = SleepTrackerService().getSleepData();
    _weeklySleepData.clear();
    _weeklySleepData.addAll(data);
    setState(() {});
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
              "Sleep Tracker",
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              icon: Image.asset("assets/img/Dropdown.png", width: 70, height: 70),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          height: media.width * 0.6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(16),
          child: BarChart(
            BarChartData(
              maxY: 12,
              alignment: BarChartAlignment.spaceBetween,
              barTouchData: BarTouchData(enabled: true),
              gridData: const FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 2,
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(),
                leftTitles: const AxisTitles(),
                rightTitles: AxisTitles(sideTitles: rightTitles),
                bottomTitles: AxisTitles(sideTitles: bottomTitles),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barData,
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> get barData => List.generate(7, (index) {
        final day = index + 1;
        final y = _weeklySleepData[day.toString()] ?? 0;
        return makeGroupData(index, y);
      });

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 16,
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              TColor.primaryColor2,
              TColor.primaryColor1.withOpacity(0.1),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ],
    );
  }

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 2,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    final labels = {
      0: '0h',
      2: '2h',
      4: '4h',
      6: '6h',
      8: '8h',
      10: '10h',
    };

    return Text(
      labels[value.toInt()] ?? '',
      style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final int index = value.toInt();
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: Text(
        index >= 0 && index < days.length ? days[index] : '',
        style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
      ),
    );
  }
}
