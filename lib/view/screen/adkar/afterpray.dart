// views/adkar/adkar_after_salat_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/adkar/afterpraycontroller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class AdkarAfterSalatView extends StatelessWidget {
  // استخدام Get.find() للحصول على الكنترولر الذي تم تهيئته مسبقًا
  final AdkarAfterSalatController _controller = Get.put(
    AdkarAfterSalatController(),
  );

  AdkarAfterSalatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      title: 'أذكار بعد الصلاة',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _controller.resetAllCounters,
          tooltip: 'إعادة تعيين كل العدادات',
          color: Colors.white,
        ),
      ],
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
          GetX<AdkarAfterSalatController>(
            builder: (_) => ListView.builder(
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
    final theme = Get.theme;
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5), // ظل خفيف
          ),
        ],
        border: Border.all(color: theme.dividerColor, width: 0.5),
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
                        color: scheme.onSurface.withOpacity(0.7),
                        fontFamily: 'Amiri',
                        height: 1.5,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                Text(
                  dhikr['name'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                    fontFamily: 'Amiri',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                Divider(color: scheme.onSurface.withOpacity(0.15), thickness: 1),
                if (dhikr['meaning'].toString().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'معنى وفضل الذكر:',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: scheme.secondary,
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
                          color: scheme.onSurface.withOpacity(0.8),
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
                            color: scheme.onSurface.withOpacity(0.5),
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
    final theme = Get.theme;
    final scheme = theme.colorScheme;
    return GetX<AdkarAfterSalatController>(
      builder: (_) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 22),
            onPressed: () => _controller.resetCount(index),
            color: scheme.onSurface.withOpacity(0.7),
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
                          ? [scheme.primary, scheme.secondary]
                          : [
                            scheme.onSurface.withOpacity(0.25),
                            scheme.onSurface.withOpacity(0.18),
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color:
                        dhikr['count'].value > 0
                            ? scheme.primary.withOpacity(0.4)
                            : Colors.black.withOpacity(0.25),
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
    final theme = Get.theme;
    final scheme = theme.colorScheme;
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.only(
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
                          color: scheme.onSurface.withOpacity(0.2),
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
                            color: scheme.onSurface.withOpacity(0.75),
                            fontFamily: 'Amiri',
                            height: 1.5,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    Text(
                      dhikr['name'],
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
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
                          Text(
                            'معنى وفضل الذكر:',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: scheme.secondary,
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
                              color: scheme.onSurface.withOpacity(0.85),
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
                              color: scheme.onSurface.withOpacity(0.6),
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
                            color: scheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'أذكار بعد الصلاة', // نص ثابت لأن 'category' غير موجود
                            style: TextStyle(
                              fontSize: 14,
                              color: scheme.primary,
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
