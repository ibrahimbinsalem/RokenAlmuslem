import 'package:flutter/material.dart';
import 'package:rokenalmuslem/core/theme/app_palette.dart';

class AppTheme {
  static ThemeData light(double fontScale) {
    return _build(fontScale, Brightness.light);
  }

  static ThemeData dark(double fontScale) {
    return _build(fontScale, Brightness.dark);
  }

  static ThemeData _build(double fontScale, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppPalette.greenSoft : AppPalette.green,
      onPrimary: Colors.white,
      secondary: AppPalette.gold,
      onSecondary: isDark ? AppPalette.darkInk : AppPalette.lightInk,
      error: const Color(0xFFB42318),
      onError: Colors.white,
      background: isDark ? AppPalette.darkBackground : AppPalette.lightBackground,
      onBackground: isDark ? AppPalette.darkInk : AppPalette.lightInk,
      surface: isDark ? AppPalette.darkSurface : AppPalette.lightSurface,
      onSurface: isDark ? AppPalette.darkInk : AppPalette.lightInk,
    );

    final baseTextTheme = ThemeData(brightness: brightness).textTheme;
    final textTheme = baseTextTheme
        .copyWith(
          displayLarge: baseTextTheme.displayLarge?.copyWith(
            fontSize: 34 * fontScale,
            fontWeight: FontWeight.w700,
            fontFamily: 'Amiri',
          ),
          displayMedium: baseTextTheme.displayMedium?.copyWith(
            fontSize: 30 * fontScale,
            fontWeight: FontWeight.w700,
            fontFamily: 'Amiri',
          ),
          displaySmall: baseTextTheme.displaySmall?.copyWith(
            fontSize: 26 * fontScale,
            fontWeight: FontWeight.w700,
            fontFamily: 'Amiri',
          ),
          headlineLarge: baseTextTheme.headlineLarge?.copyWith(
            fontSize: 22 * fontScale,
            fontWeight: FontWeight.w600,
            fontFamily: 'Amiri',
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            fontSize: 20 * fontScale,
            fontWeight: FontWeight.w600,
            fontFamily: 'Amiri',
          ),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w600,
            fontFamily: 'Amiri',
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontSize: 17 * fontScale,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            fontSize: 15 * fontScale,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: baseTextTheme.titleSmall?.copyWith(
            fontSize: 14 * fontScale,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            fontSize: 15 * fontScale,
            height: 1.6,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            fontSize: 13.5 * fontScale,
            height: 1.55,
          ),
          bodySmall: baseTextTheme.bodySmall?.copyWith(
            fontSize: 12 * fontScale,
            height: 1.5,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontSize: 13 * fontScale,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: baseTextTheme.labelMedium?.copyWith(
            fontSize: 12 * fontScale,
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(
          fontFamily: 'Lemonada',
      fontFamilyFallback: const ['Amiri', 'ArefRuqaa', 'Ruluko'],
      bodyColor: isDark ? AppPalette.darkInk : AppPalette.lightInk,
      displayColor: isDark ? AppPalette.darkInk : AppPalette.lightInk,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme,
      fontFamily: 'Lemonada',
      fontFamilyFallback: const ['Amiri', 'ArefRuqaa', 'Ruluko'],
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onBackground,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerColor: isDark ? AppPalette.darkOutline : AppPalette.lightOutline,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppPalette.darkSurfaceAlt : AppPalette.lightSurfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppPalette.darkOutline : AppPalette.lightOutline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.primary.withOpacity(0.7),
            width: 1.5,
          ),
        ),
        hintStyle: TextStyle(
          color: isDark ? AppPalette.darkMuted : AppPalette.lightMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return isDark ? AppPalette.darkMuted : AppPalette.lightMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.35);
          }
          return isDark
              ? AppPalette.darkOutline
              : AppPalette.lightOutline.withOpacity(0.8);
        }),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: colorScheme.surface,
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.primary,
      ),
    );
  }
}
