// lib/wave_widget.dart

import 'package:flutter/material.dart';
import 'dart:math';

class WaveWidgett extends StatefulWidget {
  // ignore: use_super_parameters
  const WaveWidgett({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WaveWidgettState createState() => _WaveWidgettState();
}

class _WaveWidgettState extends State<WaveWidgett> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DoubleWavePainter(animation: _controller),
      size: const Size(double.infinity, 72),
    );
  }
}

class DoubleWavePainter extends CustomPainter {
  final Animation<double> animation;

  DoubleWavePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Créer 3 Paints bleus
    final List<Paint> bluePaints = List.generate(3, (index) => Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6 + 0.1 * index)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 + index.toDouble());

    // Créer 3 Paints violets
    final List<Paint> violetPaints = List.generate(3, (index) => Paint()
      ..color = Colors.purpleAccent.withOpacity(0.2 + 0.09 * index)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 + index.toDouble());

    // Créer les Paths pour chaque vague
    final List<Path> bluePaths = List.generate(3, (_) => Path());
    final List<Path> violetPaths = List.generate(3, (_) => Path());

    for (double i = 0; i <= size.width; i++) {
      for (int j = 0; j < 2; j++) {
        double yBlue = sin((i / size.width * 2 * pi) + (animation.value * 2 * pi) + j) * (15 + 5 * j) + size.height / 2;
        double yViolet = cos((i / size.width * 2 * pi) + (animation.value * 2 * pi) + j) * (12 + 5 * j) + size.height / 2;

        if (i == 0) {
          bluePaths[j].moveTo(i, yBlue);
          violetPaths[j].moveTo(i, yViolet);
        } else {
          bluePaths[j].lineTo(i, yBlue);
          violetPaths[j].lineTo(i, yViolet);
        }
      }
    }

    // Dessiner toutes les vagues
    for (int j = 0; j < 3; j++) {
      canvas.drawPath(bluePaths[j], bluePaints[j]);
      canvas.drawPath(violetPaths[j], violetPaints[j]);
    }
  }

  @override
  bool shouldRepaint(covariant DoubleWavePainter oldDelegate) => true;
}
