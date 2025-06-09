import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomMultiSelectDropDownTeam extends StatefulWidget {
  final String name;
  final List<String> listdata; // تغيير إلى List<String> بدلاً من List<String?>
  final List<String> selectedItems; // تغيير إلى List<String>
  final Function(List<String>) onSelectionChanged;
  final bool enabled;
  final String? hintText;
  final Color? primaryColor;
  final Color? accentColor;
  final bool showLabel;
  final double elevation;
  final Duration animationDuration;

  const CustomMultiSelectDropDownTeam({
    Key? key,
    required this.name,
    required this.listdata,
    required this.selectedItems,
    required this.onSelectionChanged,
    this.enabled = true,
    this.hintText,
    this.primaryColor,
    this.accentColor,
    this.showLabel = true,
    this.elevation = 4,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _CustomMultiSelectDropDownTeamState createState() =>
      _CustomMultiSelectDropDownTeamState();
}

class _CustomMultiSelectDropDownTeamState
    extends State<CustomMultiSelectDropDownTeam> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = widget.primaryColor ?? theme.primaryColor;
    final accent = widget.accentColor ?? theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    // تصفية القيم الفارغة أو null من القوائم
    final filteredListData =
        widget.listdata.where((item) => item.isNotEmpty).toList();
    final filteredSelectedItems =
        widget.selectedItems.where((item) => item.isNotEmpty).toList();
    final hintText = widget.hintText ?? 'اختر ${widget.name}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              widget.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        AnimatedContainer(
          duration: widget.animationDuration,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: widget.elevation,
                offset: Offset(0, widget.elevation / 2),
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
                  widget.enabled
                      ? () {
                        HapticFeedback.lightImpact();
                        setState(() => isExpanded = !isExpanded);
                        FocusScope.of(context).unfocus();
                      }
                      : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              filteredSelectedItems.isEmpty
                                  ? hintText
                                  : filteredSelectedItems.join(', '),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color:
                                    filteredSelectedItems.isEmpty
                                        ? (isDark
                                            ? Colors.white54
                                            : Colors.grey[600])
                                        : (isDark
                                            ? Colors.white
                                            : Colors.grey[900]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_rounded,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    if (isExpanded && widget.enabled)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 350),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[850] : Colors.white,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child:
                            filteredListData.isEmpty
                                ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('لا توجد عناصر متاحة'),
                                  ),
                                )
                                : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredListData.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredListData[index];
                                    final isSelected = filteredSelectedItems
                                        .contains(item);

                                    return CheckboxListTile(
                                      value: isSelected,
                                      onChanged: (bool? value) {
                                        if (value != null) {
                                          setState(() {
                                            final newSelection =
                                                List<String>.from(
                                                  filteredSelectedItems,
                                                );
                                            if (value) {
                                              newSelection.add(item);
                                            } else {
                                              newSelection.remove(item);
                                            }
                                            widget.onSelectionChanged(
                                              newSelection,
                                            );
                                          });
                                        }
                                      },
                                      title: Text(
                                        item,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.grey[900],
                                            ),
                                      ),
                                      activeColor: accent,
                                      checkColor: Colors.white,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                    );
                                  },
                                ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
