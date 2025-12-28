import 'package:flutter/material.dart';

class AppPalette {
  static const Color lightBackground = Color(0xFFF0F2F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF7F9FC);
  static const Color lightInk = Color(0xFF1B262C);
  static const Color lightMuted = Color(0xFF6A7B83);
  static const Color lightOutline = Color(0xFFE3E8EF);

  static const Color darkBackground = Color(0xFF0F151A);
  static const Color darkSurface = Color(0xFF182127);
  static const Color darkSurfaceAlt = Color(0xFF1E2A31);
  static const Color darkInk = Color(0xFFE6EEF2);
  static const Color darkMuted = Color(0xFF9FB0B8);
  static const Color darkOutline = Color(0xFF24313A);

  static const Color green = Color(0xFF2FB36B);
  static const Color greenSoft = Color(0xFF5AD889);
  static const Color gold = Color(0xFFE4C067);
  static const Color goldSoft = Color(0xFFF2D79A);
  static const Color accentBlue = Color(0xFF8FB5FF);

  static const LinearGradient lightCanvas = LinearGradient(
    colors: [Color(0xFFF0F2F6), Color(0xFFE9EDF3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkCanvas = LinearGradient(
    colors: [Color(0xFF0F151A), Color(0xFF121C22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
