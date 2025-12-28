import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/adayatalanbyacontroller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class AdayaAlanbiaView extends StatelessWidget {
  final AdayaAlanbiaController controller = Get.put(AdayaAlanbiaController());
  AdayaAlanbiaView({super.key});

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
            Icon(
              icon,
              color: scheme.secondary,
              size: 28,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentCard(
    Map<String, dynamic> item,
    BuildContext context,
    AdayaAlanbiaController controller,
    ColorScheme scheme,
  ) {
    int currentCount = item['currentCount'] as int;

    return Container(
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
          if (item["start"] != null && item["start"].isNotEmpty)
            Text(
              "${item["start"]}",
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.85),
                fontSize: 16,
                fontFamily: 'Amiri',
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          const SizedBox(height: 10),
          Text(
            "${item["name"]}",
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Amiri',
              height: 1.7,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          Divider(color: scheme.onSurface.withOpacity(0.15), height: 20),
          Text(
            "${item["ayah"]}",
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.65),
              fontSize: 13,
              fontFamily: 'Amiri',
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          Divider(color: scheme.onSurface.withOpacity(0.12), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  controller.resetDuaaCountToInitial(item['id'] as int);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "إعادة",
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 13,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (currentCount > 0) {
                        controller.updateDuaaCount(
                          item['id'] as int,
                          currentCount - 1,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "تم استكمال عدد مرات الذكر",
                              style: TextStyle(
                                color: scheme.onPrimary,
                                fontFamily: 'Amiri',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: scheme.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: currentCount > 0
                            ? scheme.primary
                            : scheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "$currentCount",
                          style: TextStyle(
                            color: currentCount > 0
                                ? scheme.onPrimary
                                : scheme.onError,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Amiri',
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "عداد الذكر : ",
                    style: TextStyle(
                      color: scheme.onSurface.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Amiri',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AdayaAlanbiaController controller = Get.find();
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'أدعية الأنبياء',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.resetAllDuaaCounts();
        },
        label: const Text(
          "تصفير العدادات",
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 14,
          ),
        ),
        icon: const Icon(Icons.refresh),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          _buildSectionTitle(
            "أدعية من قصص الأنبياء",
            icon: Icons.auto_stories,
            isCentered: true,
            scheme: scheme,
          ),
          Expanded(
            child: GetX<AdayaAlanbiaController>(
              builder: (controller) {
                if (controller.adayaList.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: controller.adayaList.length,
                  itemBuilder: (context, index) {
                    final item = controller.adayaList[index];
                    return _buildContentCard(item, context, controller, scheme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
