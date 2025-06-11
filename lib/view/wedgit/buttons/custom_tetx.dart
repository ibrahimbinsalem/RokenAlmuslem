import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  CustomText({
    super.key,
    required this.title,
    this.fontSize,
    this.Aligntxt,
    this.color,
    this.fontFamily,
  });
  final String? title;
  final double? fontSize;
  final TextAlign? Aligntxt;
  final Color? color;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return Text(
      "$title",
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.bold,
      ),
      textAlign: Aligntxt,
    );
  }
}
