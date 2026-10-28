
import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class TitleSubtitleCell extends StatelessWidget {
  final String title;
  final String subtitle;
  const TitleSubtitleCell({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
          gradient: LinearGradient(
      colors: TColor.primaryG,),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
      child: Column(
        children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: TColor.white,
            fontSize: 12,
          ),
        ),
      ],

      ),
    );
  }
}