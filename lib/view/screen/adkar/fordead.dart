// views/adkar/adayah_for_dead_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/adkar/fordeadcontroller.dart';

class AdayahForDeadView extends StatelessWidget {
  final AdayahForDeadController _controller = Get.put(
    AdayahForDeadController(),
  );

  AdayahForDeadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'أدعية للميّت',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Amiri',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
        ),
        // No refresh button as there are no counters to reset
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/images/مسبحة.png', // Ensure this image exists
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

  Widget _buildDhikrCard(Map<String, dynamic> dhikr, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
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
                if (dhikr['meaning'].toString().isNotEmpty &&
                    dhikr['meaning'] != "مرة واحدة")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'معنى وفضل الدعاء:', // Changed "الذكر" to "الدعاء"
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
                    // Removed the counter as it's not applicable
                    _buildReadButton(index), // Added a simple "Read" button
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadButton(int index) {
    return GestureDetector(
      onTap:
          () => _controller.decrementCount(
            index,
          ), // This will trigger the bottom sheet
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'تمت القراءة',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Amiri',
            ),
          ),
        ),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(Icons.arrow_back),
                              ),
                            ),
                            Text(
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
                          ],
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
                    if (dhikr['meaning'].toString().isNotEmpty &&
                        dhikr['meaning'] != "مرة واحدة")
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'معنى وفضل الدعاء:', // Changed to "الدعاء"
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
                            'أذكار للميّت',
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
      isScrollControlled: true,
    );
  }
}

// FadeIn Widget (re-used for smooth transitions)
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
