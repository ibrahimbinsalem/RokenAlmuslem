// lib/views/adaya_quraniya_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/adayhqurancontroller.dart';
import 'dart:ui'; // For BackdropFilter

class AdayaQuraniyaView extends StatelessWidget {
  final AdayaQuraniyaController controller = Get.put(AdayaQuraniyaController());
  AdayaQuraniyaView({super.key});

  /// تبني عنوان القسم بخط مميز وأيقونة
  Widget _buildSectionTitle(
    String title, {
    IconData? icon,
    bool isCentered = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 25.0),
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
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD700), // لون ذهبي مميز
                shadows: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.7),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 15),
            Icon(
              icon,
              color: const Color(0xFFFFD700),
              size: 32,
              shadows: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// يبني بطاقة المحتوى الفردية لكل دعاء
  Widget _buildContentCard(
    Map<String, dynamic> item,
    BuildContext context,
    AdayaQuraniyaController controller,
  ) {
    int currentCount = item['currentCount'] as int; // العداد الحالي
    int initialCount = item['initialCount'] as int; // العداد الأولي

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // تأثير ضبابي شفاف
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08), // خلفية شبه شفافة
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end, // محاذاة النص لليمين
            children: [
              // نص البداية (إذا وجد)
              if (item["start"] != null && item["start"].isNotEmpty)
                Text(
                  "${item["start"]}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Amiri',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              const SizedBox(height: 10),
              // نص الدعاء الرئيسي
              Text(
                "${item["name"]}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                  height: 1.7,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const Divider(color: Colors.white30, height: 20), // فاصل
              // مصدر الآية/الحديث
              Text(
                "${item["ayah"]}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'Amiri',
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              const Divider(color: Colors.white30, height: 20), // فاصل
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر إعادة تعيين العداد لهذا الدعاء فقط
                  InkWell(
                    onTap: () {
                      controller.resetDuaaCountToInitial(item['id'] as int);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(
                          0.7,
                        ), // لون أزرق جذاب
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        "إعادة",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // عداد الذكر
                      InkWell(
                        onTap: () {
                          if (currentCount > 0) {
                            // تحديث العداد بتقليله
                            controller.updateDuaaCount(
                              item['id'] as int,
                              currentCount - 1,
                            );
                          } else {
                            // عرض رسالة عند انتهاء العداد
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Container(
                                  padding: const EdgeInsets.all(16),
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.deepPurple, // لون مميز للرسالة
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "تم استكمال عدد مرات الذكر",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Amiri',
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      Text(
                                        "اضغط على زر 'إعادة' لتصفير العداد",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontFamily: 'Amiri',
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                ),
                                behavior:
                                    SnackBarBehavior
                                        .floating, // تظهر فوق المحتوى
                                backgroundColor:
                                    Colors
                                        .transparent, // لجعل الحاوية هي التي تظهر اللون
                                elevation:
                                    0, // إزالة الظل الافتراضي للـ SnackBar
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                currentCount > 0
                                    ? Colors.green
                                    : Colors
                                        .red, // لون أخضر عند وجود عداد، أحمر عند الانتهاء
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "$currentCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Amiri',
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // تسمية العداد
                      const Text(
                        "عداد الذكر : ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // الحصول على الـ Controller المُدار بواسطة GetX
    final AdayaQuraniyaController controller = Get.find();
    // حساب ارتفاع شريط التطبيق لتعديل المسافات
    final double appBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor:
          Colors
              .transparent, // لجعل خلفية Scaffold شفافة للسماح بالخلفية المتدرجة
      extendBodyBehindAppBar: true, // لتمديد جسم الصفحة خلف شريط التطبيق

      appBar: AppBar(
        backgroundColor: Colors.transparent, // لجعل شريط التطبيق شفافًا
        elevation: 0, // إزالة الظل من شريط التطبيق
        title: const Text(
          'الْأدْعِيَةُ القرآنية',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Amiri',
            fontSize: 26,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black54,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // لون أيقونة الرجوع
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ), // تأثير ضبابي على شريط التطبيق
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10001C).withOpacity(0.7),
                    const Color(0xFF2A0040).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF10001C), // ألوان متدرجة للخلفية
              Color(0xFF2A0040),
              Color(0xFF4D0060),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: appBarHeight + 10), // مسافة أسفل شريط التطبيق
            // عنوان القسم الرئيسي
            _buildSectionTitle(
              "أدعية من القرآن الكريم",
              icon: Icons.menu_book, // أيقونة كتاب للدلالة على القرآن
              isCentered: true,
            ),
            Expanded(
              // Obx يستخدم للمراقبة والتحديث التلقائي عند تغيير adayaList في الـ Controller
              child: Obx(() {
                // عرض مؤشر تحميل إذا كانت القائمة فارغة
                if (controller.adayaList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }
                // بناء قائمة الأدعية باستخدام ListView.builder
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                  ), // مسافة في أسفل القائمة
                  itemCount: controller.adayaList.length,
                  itemBuilder: (context, index) {
                    final item = controller.adayaList[index];
                    return _buildContentCard(
                      item,
                      context,
                      controller,
                    ); // بناء بطاقة الدعاء
                  },
                );
              }),
            ),
          ],
        ),
      ),
      // زر عائم لتصفير جميع العدادات
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.resetAllDuaaCounts(); // استدعاء دالة تصفير جميع العدادات
        },
        label: const Text(
          "تصفير العدادات",
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.refresh, color: Colors.white),
        backgroundColor: Colors.amber[700], // لون مميز للزر
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // شكل زر دائري
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // وضع الزر في منتصف الأسفل
    );
  }
}
