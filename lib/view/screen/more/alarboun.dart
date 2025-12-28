import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/alarbouncontroller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class FortyHadithView extends StatelessWidget {
  final FortyHadithController controller = Get.put(FortyHadithController());
  FortyHadithView({super.key});

  Widget _buildSectionTitle(
    String title, {
    IconData? icon,
    bool isCentered = false,
    required ColorScheme scheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 10.0),
      child: Row(
        mainAxisAlignment:
            isCentered ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              title,
              textAlign: isCentered ? TextAlign.center : TextAlign.right,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: scheme.secondary,
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 12),
            Icon(icon, color: scheme.secondary, size: 28),
          ],
        ],
      ),
    );
  }

  Widget _buildHadithCard(
    BuildContext context,
    Map<String, String> hadith,
    ColorScheme scheme,
  ) {
    return InkWell(
      onTap: () => _showHadithDetail(context, hadith, scheme),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18.0),
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              hadith["title"] ?? "",
              style: TextStyle(
                color: scheme.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Amiri',
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              (hadith["text"] ?? "").length > 200
                  ? "${(hadith["text"] ?? "").substring(0, 200)}..."
                  : hadith["text"] ?? "",
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.8),
                fontSize: 15,
                fontFamily: 'Amiri',
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "المصدر: ${hadith["source"] ?? ""}",
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                  fontFamily: 'Amiri',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHadithDetail(
    BuildContext context,
    Map<String, String> hadith,
    ColorScheme scheme,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            hadith["title"] ?? "",
            style: TextStyle(
              color: scheme.secondary,
              fontFamily: 'Amiri',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hadith["text"] ?? "",
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontFamily: 'Amiri',
                    fontSize: 15,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),
                Text(
                  "المصدر: ${hadith["source"] ?? ""}",
                  style: TextStyle(
                    color: scheme.onSurface.withOpacity(0.6),
                    fontFamily: 'Amiri',
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
                if ((hadith["explanation"] ?? "").isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "الشرح:\n${hadith["explanation"] ?? ""}",
                    style: TextStyle(
                      color: scheme.onSurface.withOpacity(0.85),
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إغلاق',
                style: TextStyle(
                  color: scheme.primary,
                  fontFamily: 'Amiri',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'الأربعون النووية',
      body: Column(
        children: [
          _buildSectionTitle(
            "مختارات الإمام النووي",
            icon: Icons.menu_book,
            isCentered: true,
            scheme: scheme,
          ),
          Expanded(
            child: GetX<FortyHadithController>(builder: (state) {
              if (state.hadithList.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: state.hadithList.length,
                itemBuilder: (context, index) {
                  final hadith = state.hadithList[index];
                  return _buildHadithCard(context, hadith, scheme);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
