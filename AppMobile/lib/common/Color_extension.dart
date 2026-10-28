// ignore: duplicate_ignore
// ignore: file_names, duplicate_ignore
// ignore: file_names
// ignore_for_file: file_names

import 'package:flutter/material.dart';

class TColor {
  static Color get primaryColor1 => const Color(0xff6DCEFF);
  static Color get primaryColor2 => const Color(0xff55B0FF);
  static Color get secondaryColor1 => const Color(0xffA389BF);
  static Color get secondaryColor2 => const Color(0xff9A7CB7);

  static List<Color> get primaryG => [ primaryColor1 , primaryColor2 ];
  static List<Color> get secondaryG => [ secondaryColor1, secondaryColor2 ];
  static Color get black => const Color(0xff000000);
  static Color get grey => const Color.fromARGB(255, 125, 124, 124);
  static Color get white => Colors.white;
  static Color get lightGray => const Color(0xffF7F8FB);
}