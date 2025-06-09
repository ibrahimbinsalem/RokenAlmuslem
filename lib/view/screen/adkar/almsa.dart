// view/screen/adkar_almsa_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// تأكد من المسار الصحيح للكنترولر
import 'package:rokenalmuslem/controller/adkar/almsacontroller.dart';

// ويدجت FadeIn (يمكنك وضعها في ملف منفصل مثل utilities/widgets.dart لتجنب التكرار)
class FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeIn({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
  }) : super(key: key);

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

class AdkarAlmsaPage extends StatelessWidget {
  // تهيئة الكنترولر وتخزينه في GetX
  final AdkarAlmsaController controller = Get.put(AdkarAlmsaController());

  AdkarAlmsaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800], // خلفية متناسقة وداكنة
      extendBodyBehindAppBar: true, // للسماح للخلفية بالتمدد خلف الـ AppBar
      appBar: AppBar(
        title: const Text(
          "أذكار المساء",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Tajawal', // استخدام نفس الخط
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // لجعل الخلفية شفافة لرؤية التدرج
        elevation: 0, // إزالة الظل
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // لون أيقونة الرجوع
        flexibleSpace: Container(
          // تدرج لوني لشريط التطبيق
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1B5E20),
                Color(0xFF388E3C),
              ], // نفس التدرج الأخضر
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        actions: <Widget>[
          // زر إعادة تعيين كل العدادات
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetAllCounters, // استدعاء من الكنترولر
            tooltip: 'إعادة تعيين جميع العدادات',
            color: Colors.white,
          ),
        ],
      ),
      body: Stack(
        children: [
          // زخرفة الخلفية (مطابقة لصفحة أذكار الصباح)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/مسبحة.png', // تأكد من هذا المسار
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // قائمة الأذكار
          Obx(
            () => ListView.builder(
              padding: const EdgeInsets.only(
                top:
                    kToolbarHeight +
                    40, // تعديل الـ padding بسبب الـ AppBar الشفاف
                bottom: 20,
              ),
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final dhikrItem = controller.items[index];

                // تخطي عرض العناصر الفارغة
                if (dhikrItem["name"].isEmpty &&
                    dhikrItem["start"].isEmpty &&
                    dhikrItem["ayah"].isEmpty &&
                    dhikrItem["mang"].isEmpty) {
                  return const SizedBox.shrink();
                }

                return FadeIn(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: index * 50), // تأثير ظهور متدرج
                  child: _buildDhikrCard(dhikrItem, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // دالة لبناء بطاقة الذكر الواحدة
  Widget _buildDhikrCard(Map<String, dynamic> dhikr, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900], // خلفية داكنة للبطاقة
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // ظل بارز
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ), // حدود خفيفة
      ),
      child: Material(
        color: Colors.transparent, // لجعل InkWell يعمل بشكل صحيح
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDhikrDetails(dhikr), // عند النقر، عرض التفاصيل
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // نص البداية (إن وجد)
                if (dhikr['start'] != null &&
                    dhikr['start'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      dhikr['start'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: 'Tajawal',
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                // نص الذكر الرئيسي
                Text(
                  dhikr['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                // نص الفضل/المعنى (إن وجد)
                if (dhikr['mang'] != null &&
                    dhikr['mang'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'فضل الذكر:',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF388E3C), // لون أخضر مميز
                            fontFamily: 'Tajawal',
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Text(
                        dhikr['mang'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Tajawal',
                          height: 1.6,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                // صف العداد والمصدر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 0),
                        child: Text(
                          dhikr['ayah'], // مصدر الذكر
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'Tajawal',
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                    _buildCounter(
                      dhikr,
                      index,
                    ), // بناء العداد وزر إعادة التعيين الخاص به
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لبناء العداد
  Widget _buildCounter(Map<String, dynamic> dhikr, int index) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر إعادة تعيين العداد الفردي
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 22),
            onPressed:
                () => controller.resetCount(index), // استدعاء من الكنترولر
            color: Colors.white.withOpacity(0.7),
            tooltip: 'إعادة تعيين هذا العداد',
          ),
          // زر العداد نفسه
          GestureDetector(
            onTap:
                () => controller.decrementCount(index), // استدعاء من الكنترولر
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      dhikr['count'].value >
                              0 // لاحظ استخدام .value هنا
                          ? [
                            const Color(0xFF388E3C), // أخضر داكن (نشط)
                            const Color(0xFF1B5E20), // أخضر أغمق (نشط)
                          ]
                          : [
                            Colors.grey[700]!, // رمادي (غير نشط)
                            Colors.grey[600]!, // رمادي أغمق (غير نشط)
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color:
                        dhikr['count'].value > 0
                            ? const Color(0xFF1B5E20).withOpacity(0.5)
                            : Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  tween: Tween(begin: 0.8, end: 1.0), // تأثير "الانبثاق"
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Text(
                        '${dhikr['count'].value}', // لاحظ استخدام .value هنا
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة عرض التفاصيل في BottomSheet
  void _showDhikrDetails(Map<String, dynamic> dhikr) {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white, // خلفية بيضاء للـ BottomSheet
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/مسبحة.png', // نفس النمط الخلفي
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 25),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    if (dhikr['start'] != null &&
                        dhikr['start'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          dhikr['start'],
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.black.withOpacity(0.7),
                            fontFamily: 'Tajawal',
                            height: 1.5,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    Text(
                      dhikr['name'],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 25),
                    if (dhikr['mang'] != null &&
                        dhikr['mang'].toString().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'فضل الذكر:',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                              fontFamily: 'Tajawal',
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            dhikr['mang'],
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black.withOpacity(0.85),
                              fontFamily: 'Tajawal',
                              height: 1.6,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            dhikr['ayah'],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              fontFamily: 'Tajawal',
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        // لا يوجد 'category' في بيانات أذكار المساء التي عرفناها
                        // لذلك تم حذف الجزء الخاص بها هنا.
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
