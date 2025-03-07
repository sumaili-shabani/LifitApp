import 'dart:math';

import 'package:flutter/material.dart';

class ConfigurationApp {
  static const colorInput = Color.fromARGB(255, 0, 96, 100);
  static const colorBtn = Color.fromARGB(255, 0, 96, 100);
  // static const primaryColor = Color(0xFF390da0);
  static const primaryColor = Color.fromARGB(255, 12, 109, 174);
  // static const successColor = Color.fromARGB(255, 0, 96, 100);
  static const successColor = Color.fromARGB(255, 12, 174, 101);

  static const backgroundColor = Color(0xFFcfe0fa);
  static const whiteColor = Colors.white;
  // static const blackColor = Colors.black;
  static const blackColor = Color.fromARGB(255, 16, 17, 17);
  static const dangerColor = Colors.red;
  static const warningColor = Colors.orange;

  static randomColor() {
    return Color(Random().nextInt(0xffffffff));
  }
}
