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
    final gradient = isDark ? AppPalette.darkCanvas : AppPalette.lightCanvas;

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        children: [
          if (showOrnaments) ...[
            Positioned(
              top: -80,
              left: -60,
              child: _OrnamentCircle(
                size: 170,
                color: AppPalette.gold.withOpacity(isDark ? 0.08 : 0.18),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -40,
              child: _OrnamentCircle(
                size: 220,
                color: AppPalette.greenSoft.withOpacity(isDark ? 0.1 : 0.2),
              ),
            ),
            Positioned(
              top: 160,
              right: -70,
              child: _OrnamentCircle(
                size: 140,
                color: AppPalette.accentBlue.withOpacity(isDark ? 0.1 : 0.16),
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
