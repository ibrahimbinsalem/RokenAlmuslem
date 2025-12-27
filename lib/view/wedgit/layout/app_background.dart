import 'package:flutter/material.dart';
import 'package:rokenalmuslem/core/theme/app_palette.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showOrnaments;

  const AppBackground({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.showOrnaments = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient =
        isDark ? AppPalette.darkBackground : AppPalette.lightBackground;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          if (showOrnaments) ...[
            Positioned(
              top: -80,
              left: -60,
              child: _OrnamentCircle(
                size: 180,
                color: AppPalette.gold.withOpacity(isDark ? 0.12 : 0.2),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -40,
              child: _OrnamentCircle(
                size: 220,
                color: AppPalette.mint.withOpacity(isDark ? 0.14 : 0.22),
              ),
            ),
            Positioned(
              top: 160,
              right: -70,
              child: _OrnamentCircle(
                size: 140,
                color: AppPalette.emerald.withOpacity(isDark ? 0.12 : 0.16),
              ),
            ),
          ],
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _OrnamentCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _OrnamentCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
