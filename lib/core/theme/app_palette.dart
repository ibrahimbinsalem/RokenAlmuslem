import 'package:flutter/material.dart';

class AppPalette {
  static const Color sand = Color(0xFFF7F2EA);
  static const Color sandSoft = Color(0xFFF1EAE0);
  static const Color mint = Color(0xFF63C1A2);
  static const Color emerald = Color(0xFF1D6B5A);
  static const Color emeraldDeep = Color(0xFF134C41);
  static const Color gold = Color(0xFFD9B76C);
  static const Color goldSoft = Color(0xFFE9D6A3);
  static const Color ink = Color(0xFF0E2A24);
  static const Color muted = Color(0xFF6F7F77);
  static const Color outline = Color(0xFFE2D9C9);

  static const Color night = Color(0xFF0B1A17);
  static const Color nightSurface = Color(0xFF132622);
  static const Color nightSurfaceAlt = Color(0xFF0F201D);
  static const Color nightInk = Color(0xFFE6F3EE);
  static const Color nightMuted = Color(0xFF9CB0A7);
  static const Color nightOutline = Color(0xFF1F3B34);

  static const LinearGradient lightBackground = LinearGradient(
    colors: [Color(0xFFF7F2EA), Color(0xFFEAF4EE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkBackground = LinearGradient(
    colors: [Color(0xFF0B1A17), Color(0xFF0F2420)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
