import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String? iconPath;
  final IconData? icon;
  final String? label;
  final VoidCallback onTap;
  const SocialLoginButton({
    Key? key,
    this.iconPath,
    this.icon,
    this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final Widget iconWidget = iconPath != null
        ? Image.asset(iconPath!, height: 26)
        : Icon(icon ?? Icons.mail_outline, color: scheme.primary, size: 26);
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            if (label != null) ...[
              const SizedBox(width: 10),
              Text(
                label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
