import 'package:flutter/material.dart';

class CustomAuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomAuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: inputTheme.hintStyle,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor,
        contentPadding: inputTheme.contentPadding,
        border: inputTheme.border,
        enabledBorder: inputTheme.enabledBorder,
        focusedBorder: inputTheme.focusedBorder,
      ),
    );
  }
}
