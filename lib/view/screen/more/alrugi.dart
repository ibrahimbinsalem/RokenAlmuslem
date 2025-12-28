import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/alrugicontroller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class AlrugiView extends StatelessWidget {
  final AlrugiController controller = Get.put(AlrugiController());
  AlrugiView({super.key});

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
            Icon(icon, color: scheme.secondary, size: 28),
          ],
        ],
      ),
    );
  }

  Widget _buildContentCard(
    String content, {
    required ColorScheme scheme,
    double fontSize = 16,
    bool isArabic = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
        textAlign: isArabic ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: fontSize,
          color: scheme.onSurface,
          height: 1.7,
        ),
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      ),
    );
  }

  Widget _buildElegantDivider(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        height: 3,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              scheme.secondary.withOpacity(0.5),
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

  Widget _buildChoiceCard({
    required String title,
    required VoidCallback onTap,
    required ColorScheme scheme,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withOpacity(0.9),
              scheme.secondary.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: scheme.onPrimary, size: 26),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AlrugiController controller = Get.find();
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'الرقية الشرعية',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        children: [
          _buildSectionTitle(
            "الرُّقية الشرعية من القرآن والسنة",
            icon: Icons.auto_stories,
            isCentered: true,
            scheme: scheme,
          ),
          _buildElegantDivider(scheme),
          _buildContentCard(
            "الرقية الشرعية أسباب شرعية للعلاج والاستشفاء والشفاء من الله سبحانه وتعالى ولا يملك أحد من الخلق ضراً ولا نفعاً، ولذلك يجب اللجوء إلى الله سبحانه وتعالى دون سائر الخلق.",
            scheme: scheme,
          ),
          _buildElegantDivider(scheme),
          _buildSectionTitle(
            "إرشادات عامة يجب أن تُراعى عند الرقية الشرعية :",
            icon: Icons.checklist_rtl,
            scheme: scheme,
          ),
          _buildContentCard(
            "* أن لا يعتقد الراقي أن الرقية تؤثر بذاتها بل بذات الله سبحانه وتعالى.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* كون الراقي والمرقي على طهارة تامة.",
            scheme: scheme,
          ),
          _buildContentCard("* استقبال الراقي القبلة.", scheme: scheme),
          _buildContentCard(
            "* لزوم تدبر الراقي والمرقي لنصوص الرقية، فلا يقولها الراقي دون تفكر بمعانيها، ولا يستمعها المرقي إلا وقد اجتهد في تدبرها، واستحضر كلاهما الخشوع في أثناء الرقية بتعلق القلب بعظيم قدرة الله -تعالى- وحسن الاستعانة به سبحانه.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* بإمكان الراقي الاقتصار في الرقية على الآيات القرآنية أو التعوذات النبوية، لكن الأكمل في ذلك أن يجمع بينها.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* بإمكان الراقي أن يختار ما يناسب حسبما يتسع له وللمرقي الوقت، كما أن له الاختصار في الرقية، بحيث يختار منها ما يناسب حال المرقي، وللراقي كذلك قراءة الرقية على مراحل، بحيث يستريح المريض بينها.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* النفث - وهو نفخ لطيف مع بعض ريق - في أثناء القراءة وبعدها، ولا بأس بتركه.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* استحسان وضع اليد في أثناء القراءة على الناصية أو على موضع الألم، مع ملاحظة عدم جواز مس النساء من غير المحارم.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* إن لاحظ الراقي تأثر المريض ببعض الآيات في أثناء الرقية، فلا بأس بتكرارها ثلاثًا، أو خمسًا، أو سبع مرار، حسب الحاجة وملاحظة درجة الاستجابة.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* أن ينوي الراقي برقيته نفع أخيه، ومحبة أن يشفيه الله ويخفف عنه، وكذلك توخي هدايته، بل إن تيقن الراقي وجود جني متلبس، حرص عندئذ على تخليص المرقي من ذلك التلبس، مع حرصه كذلك على دعوة ذلك الجني إلى التقوى والاستقامة، وهذا مطلب مهم جدًا ينبغي للراقي ملاحظته؛ ذلك أن همَّ المسلم الأعظم الدعوة إلى الله -تعالى- لقول المولى - عز وجل -: ﴿ قُلْ هَذِهِ سَبِيلِي أَدْعُو إِلَى اللَّهِ عَلَى بَصِيرَةٍ أَنَا وَمَنِ اتَّبَعَنِي ﴾ [يوسف: 108]، فالمسلم داعية في المقام الأول؛ فحري به أن يباشر رقيته وهو يحمل في صدره هاتين النيتين (الشفاء، ومحبة الهداية)، وليتنبه الراقي إلى أنه لا ينبغي له أن يسعى إلى أذية الجني ابتداءً، إلا إذا استعصت عليه سبل هدايته، فكم من جني متلبس تاب وأناب على يد راق، بل كم من شيطان مارد أسلم على يديه، فكتب الله -تعالى- شفاءً للمريض وهداية للجني.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* مراعاة لفظ الرقية المناسب للمقام عند القراءة فيقول: (أرقي نفسي)، (أرقيكَ) أو (أرقيكِ)، أو (أرقيكم)، وذلك بحسب الحال.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* قد تستمر الرقية لمدة أسبوع كامل، وربما كانت أقل من ذلك، أو أكثر، وذلك بحسب حال المريض ومدى استجابته للعلاج، حتى يتم الشفاء بإذن الله.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* إذا جزم الراقي بأن المرقي يعاني من سحر - والعياذ بالله - فإنه من المهم للغاية أن يركز في رقيته على الآيات التي ذكر فيها السحر، مع تكرار قراءتها على المسحور، وبخاصة المعوذتين، ففي ذلك تأثير بالغ على فك السحر، ودفع الأذى، بإذن الله.",
            scheme: scheme,
          ),
          _buildContentCard(
            "* إن للراقي القراءة جهرًا أو سرًّا، والجهر أولى، وذلك بصوت معتدل يتمكن معه المرقي من سماعه؛ فيزداد بذلك تأثره بالرقية وانتفاعه بها.",
            scheme: scheme,
          ),
          _buildElegantDivider(scheme),
          _buildSectionTitle(
            "اختيار الرقية :",
            icon: Icons.playlist_add_check,
            scheme: scheme,
          ),
          const SizedBox(height: 12),
          _buildChoiceCard(
            title: "الرُّقية الشرعية من السنة النبوية",
            icon: Icons.auto_fix_high,
            scheme: scheme,
            onTap: () {
              controller.showRuqyahBottomSheet(
                context,
                "الرُّقية الشرعية من السنة النبوية",
                controller.sunnahRuqyahs.toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildChoiceCard(
            title: "الرُّقية الشرعية من القرآن الكريم",
            icon: Icons.book,
            scheme: scheme,
            onTap: () {
              controller.showRuqyahBottomSheet(
                context,
                "الرُّقية الشرعية من القرآن الكريم",
                controller.quranicRuqyahs.toList(),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
