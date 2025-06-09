import 'package:flutter/material.dart';
import 'package:rokenalmuslem/core/constant/color.dart';


ThemeData themeEnglish = ThemeData(
  
  
  textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 22, color: ColorsApp.titles),
      displayMedium: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 26, color: ColorsApp.subtitles),
      bodyLarge: TextStyle(
          height: 2,
          color: ColorsApp.subtitles,
          fontWeight: FontWeight.bold,
          fontSize: 14),
      bodyMedium: TextStyle(height: 2, color: ColorsApp.titles, fontSize: 14)),
  primarySwatch: Colors.blue,
);

ThemeData themeArabic = ThemeData(
  textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 22, color: ColorsApp.titles),
      displayMedium: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 26, color: ColorsApp.subtitles),
      bodyLarge: TextStyle(
          height: 2,
          color: ColorsApp.subtitles,
          fontWeight: FontWeight.bold,
          fontSize: 14),
      bodyMedium: TextStyle(height: 2, color: ColorsApp.titles, fontSize: 14)),
  primarySwatch: Colors.blue,
);