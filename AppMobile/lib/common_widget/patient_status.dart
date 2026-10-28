import 'package:flutter/material.dart';

class PatientStatus extends StatelessWidget {
  final String name;
  final String status;
  final Color statusColor;
  final String heartRate;
  final String temperature;
  final String oxygen;

  const PatientStatus({
    super.key,
    required this.name,
    required this.status,
    required this.statusColor,
    required this.heartRate,
    required this.temperature,
    required this.oxygen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name & status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Chip(
                label: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: statusColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: const StadiumBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset("assets/img/Heart.png", width: 24, height: 24),
              const SizedBox(width: 10),
              Text(
                "Heart Beat: $heartRate",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Image.asset("assets/img/Tempature.png", width: 24, height: 24),
              const SizedBox(width: 10),
              Text(
                "Temperature: $temperature",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Image.asset("assets/img/Blood.png", width: 24, height: 24),
              const SizedBox(width: 10),
              Text(
                "Oxygen Saturation: $oxygen",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
