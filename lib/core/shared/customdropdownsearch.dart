import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomDropDownSearch extends StatelessWidget {
  final String name;
  final List<String> listdata;
  final TextEditingController dropdownselectedname;
  final TextEditingController dropdownselectedid;
  final Function(String?) onChanged;
  final bool enabled;
  final String? hintText;
  final VoidCallback? onDataChanged;
  final Color? primaryColor;
  final Color? accentColor;
  final bool showLabel;
  final double elevation;
  final Duration animationDuration;

  const CustomDropDownSearch({
    required this.name,
    required this.listdata,
    required this.dropdownselectedname,
    required this.dropdownselectedid,
    required this.onChanged,
    this.enabled = true,
    this.hintText,
    this.onDataChanged,
    this.primaryColor,
    this.accentColor,
    this.showLabel = true,
    this.elevation = 4,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = primaryColor ?? theme.primaryColor;
    final accent = accentColor ?? theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        AnimatedContainer(
          duration: animationDuration,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: elevation,
                offset: Offset(0, elevation / 2),
              ),
            ],
          ),
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap:
                  enabled
                      ? () {
                        HapticFeedback.lightImpact();
                        FocusScope.of(context).unfocus();
                      }
                      : null,
              child: DropdownButtonFormField<String>(
                value:
                    dropdownselectedname.text.isEmpty
                        ? null
                        : dropdownselectedname.text,
                items:
                    listdata.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: AnimatedContainer(
                          duration: animationDuration,
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color:
                                    dropdownselectedname.text == value
                                        ? accent
                                        : Colors.transparent,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  value,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color:
                                        isDark
                                            ? Colors.white
                                            : Colors.grey[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                onChanged:
                    enabled
                        ? (newValue) {
                          if (newValue != null) {
                            dropdownselectedname.text = newValue;
                            onChanged(newValue);
                            if (onDataChanged != null) onDataChanged!();
                          }
                        }
                        : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primary, width: 1.5),
                  ),
                  hintText: hintText ?? 'اختر $name',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.arrow_drop_down_rounded,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                      size: 28,
                    ),
                  ),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
                dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                icon: const SizedBox.shrink(),
                isExpanded: true,
                menuMaxHeight: 350,
                selectedItemBuilder: (BuildContext context) {
                  return listdata.map<Widget>((String value) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        value,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                itemHeight: 56,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
