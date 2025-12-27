// lib/views/alrugi_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/alrugicontroller.dart';

class AlrugiView extends StatelessWidget {
  final AlrugiController controller = Get.put(AlrugiController());
  AlrugiView({super.key});

  // Helper UI widgets (moved from controller for better separation of concerns,
  // but can be kept in controller or a dedicated UI_helpers file as per preference)
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
                color: const Color(0xFFFFD700),
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

  Widget _buildContentCard(
    String content, {
    double fontSize = 18,
    bool isArabic = true,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            content,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: fontSize,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.7,
            ),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      ),
    );
  }

  Widget _buildElegantDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        height: 3,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFFFFD700).withValues(alpha: 0.5),
              Colors.transparent,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AlrugiController controller =
        Get.find(); // Find the already initialized controller

    final double appBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'الرقية الشرعية',
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
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10001C).withValues(alpha: 0.7),
                    const Color(0xFF2A0040).withValues(alpha: 0.7),
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
            colors: [Color(0xFF10001C), Color(0xFF2A0040), Color(0xFF4D0060)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.only(
            top: appBarHeight + 10,
            left: 20.0,
            right: 20.0,
            bottom: 20.0,
          ),
          children: [
            _buildSectionTitle(
              "الرُّقية الشرعية من القرآن والسنة",
              icon: Icons.auto_stories,
              isCentered: true,
            ),
            _buildElegantDivider(),
            _buildContentCard(
              "الرقية الشرعية أسباب شرعية للعلاج والاستشفاء والشفاء من الله سبحانه وتعالى ولا يملك أحد من الخلق ضراً ولا نفعاً، ولذلك يجب اللجوء إلى الله سبحانه وتعالى دون سائر الخلق.",
            ),
            _buildElegantDivider(),
            _buildSectionTitle(
              "إرشادات عامة يجب أن تُراعى عند الرقية الشرعية :",
              icon: Icons.checklist_rtl,
            ),
            _buildContentCard(
              "* أن لا يعتقد الراقي أن الرقية تؤثر بذاتها بل بذات الله سبحانه وتعالى.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* كون الراقي والمرقي على طهارة تامة.",
              fontSize: 17,
            ),
            _buildContentCard("* استقبال الراقي القبلة.", fontSize: 17),
            _buildContentCard(
              "* لزوم تدبر الراقي والمرقي لنصوص الرقية، فلا يقولها الراقي دون تفكر بمعانيها، ولا يستمعها المرقي إلا وقد اجتهد في تدبرها، واستحضر كلاهما الخشوع في أثناء الرقية بتعلق القلب بعظيم قدرة الله -تعالى- وحسن الاستعانة به سبحانه.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* بإمكان الراقي الاقتصار في الرقية على الآيات القرآنية أو التعوذات النبوية، لكن الأكمل في ذلك أن يجمع بينها.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* بإمكان الراقي أن يختار ما يناسب حسبما يتسع له وللمرقي الوقت، كما أن له الاختصار في الرقية، بحيث يختار منها ما يناسب حال المرقي، وللراقي كذلك قراءة الرقية على مراحل، بحيث يستريح المريض بينها.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* النفث - وهو نفخ لطيف مع بعض ريق - في أثناء القراءة وبعدها، ولا بأس بتركه.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* استحسان وضع اليد في أثناء القراءة على الناصية أو على موضع الألم، مع ملاحظة عدم جواز مس النساء من غير المحارم.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* إن لاحظ الراقي تأثر المريض ببعض الآيات في أثناء الرقية، فلا بأس بتكرارها ثلاثًا، أو خمسًا، أو سبع مرار، حسب الحاجة وملاحظة درجة الاستجابة.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* أن ينوي الراقي برقيته نفع أخيه، ومحبة أن يشفيه الله ويخفف عنه، وكذلك توخي هدايته، بل إن تيقن الراقي وجود جني متلبس، حرص عندئذ على تخليص المرقي من ذلك التلبس، مع حرصه كذلك على دعوة ذلك الجني إلى التقوى والاستقامة، وهذا مطلب مهم جدًا ينبغي للراقي ملاحظته؛ ذلك أن همَّ المسلم الأعظم الدعوة إلى الله -تعالى- لقول المولى - عز وجل -: ﴿ قُلْ هَذِهِ سَبِيلِي أَدْعُو إِلَى اللَّهِ عَلَى بَصِيرَةٍ أَنَا وَمَنِ اتَّبَعَنِي ﴾ [يوسف: 108]، فالمسلم داعية في المقام الأول؛ فحري به أن يباشر رقيته وهو يحمل في صدره هاتين النيتين (الشفاء، ومحبة الهداية)، وليتنبه الراقي إلى أنه لا ينبغي له أن يسعى إلى أذية الجني ابتداءً، إلا إذا استعصت عليه سبل هدايته، فكم من جني متلبس تاب وأناب على يد راق، بل كم من شيطان مارد أسلم على يديه، فكتب الله -تعالى- شفاءً للمريض وهداية للجني.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* مراعاة لفظ الرقية المناسب للمقام عند القراءة فيقول: (أرقي نفسي)، (أرقيكَ) أو (أرقيكِ)، أو (أرقيكم)، وذلك بحسب الحال.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* قد تستمر الرقية لمدة أسبوع كامل، وربما كانت أقل من ذلك، أو أكثر، وذلك بحسب حال المريض ومدى استجابته للعلاج، حتى يتم الشفاء بإذن الله.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* إذا جزم الراقي بأن المرقي يعاني من سحر - والعياذ بالله - فإنه من المهم للغاية أن يركز في رقيته على الآيات التي ذكر فيها السحر، مع تكرار قراءتها على المسحور، وبخاصة المعوذتين، ففي ذلك تأثير بالغ على فك السحر، ودفع الأذى، بإذن الله.",
              fontSize: 17,
            ),
            _buildContentCard(
              "* إن للراقي القراءة جهرًا أو سرًّا، والجهر أولى، وذلك بصوت معتدل يتمكن معه المرقي من سماعه؛ فيزداد بذلك تأثره بالرقية وانتفاعه بها.",
              fontSize: 17,
            ),
            _buildElegantDivider(),
            _buildSectionTitle(
              "اختيار الرقية :",
              icon: Icons.playlist_add_check,
            ),
            const SizedBox(height: 20),

            // Sunnah Ruqyah Button
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                // Pass the actual list of Map<String, dynamic> from the controller
                controller.showRuqyahBottomSheet(
                  context,
                  "الرُّقية الشرعية من السنة النبوية",
                  controller.sunnahRuqyahs
                      .toList(), // Use .toList() to pass a static copy
                );
              },
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4D0060).withValues(alpha: 0.8),
                      const Color(0xFF2A0040).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "الرُّقية الشرعية من السنة النبوية",
                    style: TextStyle(
                      color: const Color(0xFFFFD700),
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quranic Ruqyah Button
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                // Pass the actual list of Map<String, dynamic> from the controller
                controller.showRuqyahBottomSheet(
                  context,
                  "الرُّقية الشرعية من القرآن الكريم",
                  controller.quranicRuqyahs
                      .toList(), // Use .toList() to pass a static copy
                );
              },
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4D0060).withValues(alpha: 0.8),
                      const Color(0xFF2A0040).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "الرُّقية الشرعية من القرآن الكريم",
                    style: TextStyle(
                      color: const Color(0xFFFFD700),
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
