import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui'; // For BackdropFilter
import 'package:rokenalmuslem/controller/more/alarbouncontroller.dart'; // تأكد من المسار الصحيح للكنترولر

class FortyHadithView extends StatelessWidget {
  final FortyHadithController controller = Get.put(FortyHadithController());
  FortyHadithView({super.key});

  /// Builds a section title with a distinct font and icon.
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
                fontFamily: 'Tajawal',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD700), // Golden color
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

  /// Builds an individual card for each Hadith.
  Widget _buildHadithCard(
    BuildContext context, // Added BuildContext to pass to modal
    Map<String, String> hadith,
  ) {
    return InkWell(
      // Added InkWell for tap interaction and visual feedback
      onTap: () {
        _showHadithDetail(context, hadith); // Show full Hadith details on tap
      },
      borderRadius: BorderRadius.circular(20),
      splashColor: const Color(
        0xFFFFD700,
      ).withOpacity(0.2), // Golden splash effect
      highlightColor: Colors.white.withOpacity(0.05), // Subtle highlight
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8,
            sigmaY: 8,
          ), // Frosted glass effect
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 10.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                0.08,
              ), // Semi-transparent background
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
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Align text to the right
              children: [
                // Hadith title
                Text(
                  hadith["title"] ?? "",
                  style: const TextStyle(
                    color: Color(0xFFFFD700), // Golden color
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                    height: 1.5,
                    shadows: [
                      BoxShadow(
                        color: Color(0xFFFFD700),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const Divider(color: Colors.white30, height: 20), // Divider
                // Hadith text (truncated for card view)
                Text(
                  (hadith["text"] ?? "").length >
                          200 // Show a shorter text in card view
                      ? "${(hadith["text"] ?? "").substring(0, 200)}..."
                      : hadith["text"] ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Tajawal',
                    height: 1.7,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  maxLines: 4, // Limit lines in card view
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis if text overflows
                ),
                const SizedBox(height: 15),

                // Hadith source
                Text(
                  "المصدر: ${hadith["source"] ?? ""}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'Tajawal',
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                // Removed explanation from card view to show it in modal for cleaner look
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows a modal bottom sheet with full Hadith details.
  void _showHadithDetail(BuildContext context, Map<String, String> hadith) {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ), // Stronger blur for modal
          child: Container(
            color: const Color(
              0xFF10001C,
            ).withOpacity(0.8), // Darker, semi-transparent background
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                Expanded(
                  // Make content scrollable
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Hadith Title in Modal
                        Text(
                          hadith["title"] ?? "",
                          style: const TextStyle(
                            color: Color(0xFFFFD700), // Golden color
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Tajawal',
                            height: 1.5,
                            shadows: [
                              BoxShadow(
                                color: Color(0xFFFFD700),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        const Divider(
                          color: Colors.white54,
                          height: 30,
                        ), // Stronger divider
                        // Hadith Text in Modal
                        Text(
                          hadith["text"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontFamily: 'Tajawal',
                            height: 1.8,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 20),

                        // Hadith Source in Modal
                        Text(
                          "المصدر: ${hadith["source"] ?? ""}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontFamily: 'Tajawal',
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        const Divider(
                          color: Colors.white54,
                          height: 30,
                        ), // Stronger divider
                        // Hadith Explanation in Modal
                        Text(
                          "الشرح:\n${hadith["explanation"] ?? ""}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontFamily: 'Tajawal',
                            height: 1.7,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 30), // Padding at bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled:
          true, // Make bottom sheet take full height when needed
      backgroundColor: Colors.transparent, // Allow backdrop filter to show
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the GetX controller instance.
    final FortyHadithController controller = Get.find();
    // Calculate AppBar height for proper spacing.
    final double appBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor:
          Colors
              .transparent, // Make Scaffold background transparent for gradient
      extendBodyBehindAppBar: true, // Extend body behind AppBar

      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove AppBar shadow
        title: const Text(
          'الأربعون النووية',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Tajawal',
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
        ), // Back button icon color
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ), // Blur effect on AppBar
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
              Color(0xFF10001C), // Gradient background colors
              Color(0xFF2A0040),
              Color(0xFF4D0060),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: appBarHeight + 10), // Space below AppBar
            // Main section title
            _buildSectionTitle(
              "مختارات من الأحاديث النبوية",
              icon: Icons.bookmark_border, // Book/bookmark icon
              isCentered: true,
            ),
            Expanded(
              // Obx observes and automatically rebuilds when hadithList in the Controller changes.
              child: Obx(() {
                // Show a loading indicator if the list is empty
                if (controller.hadithList.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }
                // Build the list of Hadith using ListView.builder
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                  ), // Padding at the bottom of the list
                  itemCount: controller.hadithList.length,
                  itemBuilder: (context, index) {
                    final hadith = controller.hadithList[index];
                    return _buildHadithCard(
                      context, // Pass context to _buildHadithCard
                      hadith,
                    ); // Build Hadith card
                  },
                );
              }),
            ),
          ],
        ),
      ),
      // No floating action button for counters here as Hadith do not have counters.
    );
  }
}
