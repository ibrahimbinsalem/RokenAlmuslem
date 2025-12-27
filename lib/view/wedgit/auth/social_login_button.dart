import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;
  const SocialLoginButton({Key? key, required this.iconPath, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(width: 1, color: theme.dividerColor),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Image.asset(iconPath, height: 30),
      ),
    );
  }
}
