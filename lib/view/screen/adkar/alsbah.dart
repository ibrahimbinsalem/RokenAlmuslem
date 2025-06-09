import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/adkar/alsbahcontroller.dart'; // تأكد من المسار الصحيح

class Alsbah extends StatelessWidget {
  // استخدام Get.put هنا مناسب إذا كانت هذه أول مرة يتم فيها تهيئة الكنترولر
  final AdkarSabahController _controller = Get.put(AdkarSabahController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800], // Consistent background
      extendBodyBehindAppBar: true, // Allow body to extend behind app bar
      appBar: AppBar(
        title: const Text(
          'أذكار الصباح',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          // Gradient background for the app bar
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
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
          // Background decoration (optional, but adds depth)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/مسبحة.png', // Replace with your own Islamic pattern image
                fit: BoxFit.cover,
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
          Obx(
            () => ListView.builder(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 40,
                bottom: 20,
              ), // Adjust padding for app bar
              itemCount: _controller.items.length,
              itemBuilder: (context, index) {
                final dhikr = _controller.items[index];
                return FadeIn(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(
                    milliseconds: index * 50,
                  ), // Staggered animation
                  child: _buildDhikrCard(dhikr, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrCard(Map<String, dynamic> dhikr, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Darker background for the card
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // More prominent shadow
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ), // Subtle border
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDhikrDetails(dhikr),
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
                        fontFamily: 'Tajawal',
                        height: 1.5, // Improved line height
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                Text(
                  dhikr['name'],
                  style: const TextStyle(
                    fontSize: 22, // Slightly smaller for better fit
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 20),
                Divider(
                  color: Colors.white.withOpacity(0.2),
                  thickness: 1,
                ), // Thinner divider
                if (dhikr['mang']
                    .toString()
                    .isNotEmpty) // Changed from 'meaning' to 'mang' to match your data structure
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
                            color: Color(
                              0xFF388E3C,
                            ), // Green accent for heading
                            fontFamily: 'Tajawal',
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Text(
                        dhikr['mang'], // Changed from 'meaning' to 'mang'
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontFamily: 'Tajawal',
                          height: 1.6, // Improved line height
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                      CrossAxisAlignment.end, // Align items to the bottom
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 0),
                        child: Text(
                          dhikr['ayah'],
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
                    _buildCounter(dhikr, index),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(Map<String, dynamic> dhikr, int index) {
    return Obx(
      () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reset button (moved inside counter for better grouping)
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 22),
            onPressed: () => _controller.resetCount(index),
            color: Colors.white.withOpacity(0.7),
            tooltip: 'إعادة تعيين العداد',
          ),
          GestureDetector(
            onTap: () => _controller.decrementCount(index), // Tap to decrease
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      dhikr['count'].value > 0
                          ? [
                            const Color(0xFF388E3C),
                            const Color(0xFF1B5E20),
                          ] // Green gradient when active
                          : [
                            Colors.grey[700]!,
                            Colors.grey[600]!,
                          ], // Grey gradient when count is 0
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
                  tween: Tween(begin: 0.8, end: 1.0), // Pop animation
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Text(
                        '${dhikr['count'].value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900, // Extra bold
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

  void _showDhikrDetails(Map<String, dynamic> dhikr) {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          // Use a Stack for background image
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/مسبحة.png', // Same pattern for consistency
                    fit: BoxFit.cover,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              // Content of the bottom sheet
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  25,
                  25,
                  25,
                  40,
                ), // Adjusted padding
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
                    if (dhikr['mang']
                        .toString()
                        .isNotEmpty) // Changed from 'meaning' to 'mang'
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
                            dhikr['mang'], // Changed from 'meaning' to 'mang'
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
                        // **الجزء الذي تم تعديله أو إزالته - لا يوجد عمود 'category' الآن**
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF388E3C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          // بدلاً من dhikr['category']، يمكنك وضع نص ثابت أو إزالة هذا الجزء
                          child: const Text(
                            'أذكار الصباح', // هنا وضعنا نص ثابت
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1B5E20),
                              fontFamily: 'Tajawal',
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
        ),
      ),
      isScrollControlled: true, // Allow bottom sheet to be full height
    );
  }
}

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
