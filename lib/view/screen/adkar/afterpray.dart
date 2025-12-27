// views/adkar/adkar_after_salat_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/adkar/afterpraycontroller.dart';

class AdkarAfterSalatView extends StatelessWidget {
  // استخدام Get.find() للحصول على الكنترولر الذي تم تهيئته مسبقًا
  final AdkarAfterSalatController _controller = Get.put(
    AdkarAfterSalatController(),
  );

  AdkarAfterSalatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      extendBodyBehindAppBar: true, // لجعل الـ body يمتد خلف الـ appbar
      appBar: AppBar(
        title: const Text(
          'أذكار بعد الصلاة',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Amiri', // تأكد من وجود هذا الخط
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // لجعل الـ appbar شفافًا
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // لون الأيقونات في الـ appbar
        flexibleSpace: Container(
          // تدرج لوني للـ appbar
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1B5E20),
                Color(0xFF388E3C),
              ], // درجات اللون الأخضر
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.resetAllCounters,
            tooltip: 'إعادة تعيين كل العدادات',
            color: Colors.white,
          ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية معتمة
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/مسبحة.png', // تأكد من وجود هذه الصورة في assets
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          // قائمة الأذكار
          Obx(
            () => ListView.builder(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 40, // لإعطاء مساحة أسفل الـ appbar
                bottom: 20,
              ),
              itemCount: _controller.items.length,
              itemBuilder: (context, index) {
                final dhikr = _controller.items[index];
                return FadeIn(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: index * 50),
                  child: _buildDhikrCard(dhikr, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة الذكر
  Widget _buildDhikrCard(Map<String, dynamic> dhikr, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900], // لون خلفية البطاقة
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5), // ظل خفيف
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent, // لجعل تأثير الـ InkWell مرئياً
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDhikrDetails(dhikr), // عند الضغط، عرض التفاصيل
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (dhikr['start'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      dhikr['start'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: 'Amiri',
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                Text(
                  dhikr['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Amiri',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                if (dhikr['meaning'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'معنى وفضل الذكر:',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF388E3C),
                            fontFamily: 'Amiri',
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Text(
                        dhikr['meaning'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Amiri',
                          height: 1.6,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 0),
                        child: Text(
                          dhikr['ayah'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                            fontFamily: 'Amiri',
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                    _buildCounter(dhikr, index), // العداد
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء العداد التفاعلي
  Widget _buildCounter(Map<String, dynamic> dhikr, int index) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 22),
            onPressed: () => _controller.resetCount(index),
            color: Colors.white.withOpacity(0.7),
            tooltip: 'إعادة تعيين العداد',
          ),
          GestureDetector(
            onTap: () => _controller.decrementCount(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      dhikr['count'].value > 0
                          ? [const Color(0xFF388E3C), const Color(0xFF1B5E20)]
                          : [Colors.grey[700]!, Colors.grey[600]!],
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
                  tween: Tween(begin: 0.8, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Text(
                        '${dhikr['count'].value}',
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

  // عرض تفاصيل الذكر في BottomSheet
  void _showDhikrDetails(Map<String, dynamic> dhikr) {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
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
                    'assets/images/مسبحة.png',
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
                    if (dhikr['start'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          dhikr['start'],
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.black.withOpacity(0.7),
                            fontFamily: 'Amiri',
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
                        fontFamily: 'Amiri',
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 25),
                    if (dhikr['meaning'].toString().isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'معنى وفضل الذكر:',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                              fontFamily: 'Amiri',
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            dhikr['meaning'],
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black.withOpacity(0.85),
                              fontFamily: 'Amiri',
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
                              fontFamily: 'Amiri',
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF388E3C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'أذكار بعد الصلاة', // نص ثابت لأن 'category' غير موجود
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1B5E20),
                              fontFamily: 'Amiri',
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // لتحديد ارتفاع الـ bottom sheet
    );
  }
}

// FadeIn Widget (لتحسين تجربة المستخدم بظهور تدريجي للعناصر)
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
