import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/fadelaldekrcontroller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class FadelAlDuaaPage extends StatelessWidget {
  const FadelAlDuaaPage({super.key});

  IconData? _getIconData(String? iconName) {
    if (iconName == null) return null;
    switch (iconName) {
      case "lightbulb_outline":
        return Icons.lightbulb_outline;
      case "check_circle_outline":
        return Icons.check_circle_outline;
      case "self_improvement":
        return Icons.self_improvement;
      case "star_border":
        return Icons.star_border;
      case "gpp_good_outlined":
        return Icons.gpp_good_outlined;
      case "fitness_center_outlined":
        return Icons.fitness_center_outlined;
      case "shield_outlined":
        return Icons.shield_outlined;
      case "waving_hand":
        return Icons.waving_hand;
      case "mosque_rounded":
        return Icons.account_balance;
      case "nightlight_round":
        return Icons.nightlight_round;
      case "people_outline":
        return Icons.people_outline;
      default:
        return null;
    }
  }

  Widget _buildSectionTitle(
    String title,
    ColorScheme scheme, {
    String? iconName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: scheme.secondary,
              ),
            ),
          ),
          if (iconName != null) ...[
            const SizedBox(width: 12),
            Icon(
              _getIconData(iconName),
              color: scheme.secondary,
              size: 26,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentCard(
    String content,
    ColorScheme scheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
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
      child: Text(
        content,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: 15,
          color: scheme.onSurface,
          height: 1.7,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadelAlDuaaGetXController());
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'فضل الدعاء',
      body: GetX<FadelAlDuaaGetXController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: scheme.primary),
            );
          }

          if (controller.duas.isEmpty) {
            return Center(
              child: Text(
                'لا توجد بيانات متاحة الآن',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            itemCount: controller.duas.length,
            itemBuilder: (context, index) {
              final item = controller.duas[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSectionTitle(
                  item['title'] ?? '',
                  scheme,
                  iconName: item['iconName'],
                ),
                _buildContentCard(item['content'] ?? '', scheme),
              ],
            );
            },
          );
        },
      ),
    );
  }
}
