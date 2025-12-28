import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/fadelaldekarcontroller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class FadelAlDkerView extends StatelessWidget {
  final FadelAlDkerController controller = Get.put(FadelAlDkerController());
  FadelAlDkerView({super.key});

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

  Widget _buildGenericText(
    String text, {
    required ColorScheme scheme,
    Color? color,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.6,
  }) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? scheme.onSurface,
        fontSize: fontSize,
        fontFamily: 'Amiri',
        fontWeight: fontWeight,
        height: height,
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildDivider(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(color: scheme.onSurface.withOpacity(0.15), height: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'فضل الذكر',
      body: Column(
        children: [
          _buildSectionTitle(
            "فضل الذكر في الإسلام",
            icon: Icons.lightbulb_outline,
            isCentered: true,
            scheme: scheme,
          ),
          Expanded(
            child: GetX<FadelAlDkerController>(builder: (state) {
              if (state.contentList.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: scheme.primary),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 24,
                  left: 18,
                  right: 18,
                ),
                itemCount: state.contentList.length,
                itemBuilder: (context, index) {
                  final item = state.contentList[index];
                  switch (item["type"]) {
                    case "intro_text":
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: _buildGenericText(
                          item["content"] ?? '',
                          scheme: scheme,
                          fontSize: 16,
                          color: scheme.onSurface.withOpacity(0.85),
                        ),
                      );
                    case "subsection_title":
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: _buildGenericText(
                          item["content"] ?? '',
                          scheme: scheme,
                          color: scheme.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    case "verse":
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: _buildGenericText(
                          "قال تعالى : ${item["content"] ?? ''}",
                          scheme: scheme,
                          fontSize: 16,
                          height: 1.8,
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    case "hadith":
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: _buildGenericText(
                          item["content"] ?? '',
                          scheme: scheme,
                          fontSize: 16,
                          height: 1.8,
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    case "point_title":
                      return Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                        child: _buildGenericText(
                          item["content"] ?? '',
                          scheme: scheme,
                          color: scheme.secondary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    case "point":
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: _buildGenericText(
                          "• ${item["content"] ?? ''}",
                          scheme: scheme,
                          fontSize: 15,
                          color: scheme.onSurface.withOpacity(0.85),
                        ),
                      );
                    case "divider":
                      return _buildDivider(scheme);
                    default:
                      return const SizedBox.shrink();
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
