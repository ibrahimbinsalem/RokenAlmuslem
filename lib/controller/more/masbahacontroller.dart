import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // لضمان وجودها إذا كنت تستخدم DateFormat

class TasbeehController extends GetxController {
  RxInt counter = 0.obs;
  RxInt targetCount = 33.obs;
  RxString currentDhikr = "سبحان الله".obs;
  RxInt dailyTasbeehCount = 0.obs;

  // ===== جديد لأسماء الله الحسنى =====
  // يتم تهيئته بخريطة فارغة لتجنب أخطاء null مبدئياً
  RxMap<String, String> currentAsmaAllah = <String, String>{}.obs;
  final List<Map<String, String>> asmaAllahList = [
    {"name": "الرحمن", "dis": "الذي وسعت رحمته كل شيء، فهو يشمل المؤمن والكافر، والبر والفاجر، والإنس والجن، والحيوانات والطير، وكل المخلوقات."},
    {"name": "الرحيم", "dis": "الذي يرحم المؤمنين، فهو يخصهم برحمته التي يدخلهم بها الجنة."},
    {"name": "الملك", "dis": "المالك لجميع الأشياء، المتصرف فيها بلا ممانعة ولا مدافعة."},
    {"name": "القدوس", "dis": "المنزه عن كل عيب ونقص، الموصوف بالكمال المطلق."},
    {"name": "السلام", "dis": "الذي سلم من كل عيب ونقص، وهو مصدر السلامة للمخلوقات."},
    {"name": "المؤمن", "dis": "المصدق لرسله وأنبيائه بما أقام لهم من البراهين، والمؤمِّن عباده من عذابه."},
    {"name": "المهيمن", "dis": "الرقيب على كل شيء، الحافظ له، الشاهد عليه."},
    {"name": "العزيز", "dis": "الغالب الذي لا يغلبه شيء، القوي المنيع الذي لا يُرام جانبه."},
    {"name": "الجبار", "dis": "الذي جبر الخلائق على ما أراد، والذي يجبر الفقر بالغنى، والمرض بالصحة، والكسر بالإبرام."},
    {"name": "المتكبر", "dis": "المتعالي عن صفات الخلق، الذي تكبر عن كل سوء."},
    {"name": "الخالق", "dis": "المقدر للأشياء قبل إيجادها، المبدع لها على غير مثال سبق."},
    {"name": "البارئ", "dis": "الذي أوجد الخلق من العدم، فأعطاهم صورهم وأشكالهم."},
    {"name": "المصور", "dis": "الذي يصور الخلائق كيف يشاء، ويخلقهم على هيئات مختلفة."},
    {"name": "الغفار", "dis": "الكثير المغفرة للذنوب والعيوب، الستار للعيوب في الدنيا والآخرة."},
    {"name": "القهار", "dis": "الذي يقهر خلقه ويغلبهم على ما أراد منهم."},
    {"name": "الوهاب", "dis": "الكثير العطاء بلا عوض ولا استحقاق."},
    {"name": "الرزاق", "dis": "الذي يرزق جميع خلقه، ويسوق إليهم أرزاقهم بلا كلَف."},
    {"name": "الفتاح", "dis": "الذي يفتح أبواب الرحمة والرزق لعباده، ويفتح قلوب العارفين."},
    {"name": "العليم", "dis": "الذي أحاط بكل شيء علماً، فلا يغيب عنه مثقال ذرة في الأرض ولا في السماء."},
    {"name": "القابض", "dis": "الذي يقبض الأرواح والرزق."},
    {"name": "الباسط", "dis": "الذي يبسط الرزق لمن يشاء، ويبسط الأرواح في الأجساد."},
    {"name": "الخافض", "dis": "الذي يخفض الكافرين والأعداء."},
    {"name": "الرافع", "dis": "الذي يرفع المؤمنين في درجاتهم، ويرفع أوليائه."},
    {"name": "المعز", "dis": "الذي يعز من يشاء من خلقه بالطاعة والنصر."},
    {"name": "المذل", "dis": "الذي يذل من يشاء من خلقه بالمعصية والخيبة."},
    {"name": "السميع", "dis": "الذي يسمع كل صوت، فلا يغيب عنه شيء."},
    {"name": "البصير", "dis": "الذي يرى كل شيء، فلا يغيب عنه شيء."},
    {"name": "الحكم", "dis": "الذي يفصل بين الحق والباطل، وبين الناس بالعدل."},
    {"name": "العدل", "dis": "الذي هو العدل في أحكامه، والمستقيم في أفعاله."},
    {"name": "اللطيف", "dis": "الذي يعلم دقائق الأمور وخفاياها، ويصل لطفه إلى عباده من حيث لا يشعرون."},
    {"name": "الخبير", "dis": "العالم بكل شيء، فلا يخفى عليه خافية."},
    {"name": "الحليم", "dis": "الذي لا يعجل بالعقوبة على من عصاه، ويعفو مع القدرة."},
    {"name": "العظيم", "dis": "العظيم في ذاته وصفاته وأفعاله، فلا أعظم منه."},
    {"name": "الغفور", "dis": "الذي يغفر الذنوب الكثيرة والخطايا الكبيرة."},
    {"name": "الشكور", "dis": "الذي يشكر اليسير من الطاعة، ويثيب عليه الجزيل من الثواب."},
    {"name": "العلي", "dis": "الذي له العلو المطلق في ذاته وصفاته وقدره وقهر."},
    {"name": "الكبير", "dis": "الذي هو أكبر من كل شيء، وأعظم من كل عظيم."},
    {"name": "الحفيظ", "dis": "الذي يحفظ كل شيء، ويحفظ على عباده أعمالهم."},
    {"name": "المقيت", "dis": "الذي يقوت الأجسام بالأرزاق، ويقوت القلوب بالعلوم والمعارف."},
    {"name": "الحسيب", "dis": "الذي يحاسب عباده على أعمالهم، والكافي عباده ما أهمهم."},
    {"name": "الجليل", "dis": "ذو الجلال والعظمة، والكمال المطلق."},
    {"name": "الكريم", "dis": "الكثير الخير والعطاء، الذي يعطي بلا مقابل، ويغفر الذنوب."},
    {"name": "الرقيب", "dis": "المراقب لخلقه، والمطلع على أعمالهم."},
    {"name": "المجيب", "dis": "الذي يجيب دعاء من دعاه، ويجيب المضطرين."},
    {"name": "الواسع", "dis": "الذي وسع كل شيء علماً ورحمة، ووسع رزقه جميع خلقه."},
    {"name": "الحكيم", "dis": "صاحب الحكمة في خلقه وأمره، فلا يفعل إلا الصواب."},
    {"name": "الودود", "dis": "الذي يحب عباده الصالحين، ويتودد إليهم بالنعم، وهو محبوب من عباده."},
    {"name": "المجيد", "dis": "الذي له المجد والعظمة والشرف."},
    {"name": "الباعث", "dis": "الذي يبعث الخلق بعد الموت، ويبعث الرسل إلى الأمم."},
    {"name": "الشهيد", "dis": "الحاضر الذي لا يغيب عنه شيء، الشاهد على خلقه يوم القيامة."},
    {"name": "الحق", "dis": "الموجود حقاً، الذي لا يزول ولا يفنى، وقوله حق ووعده حق."},
    {"name": "الوكيل", "dis": "الذي يتولى أمور عباده، ويكفي من توكل عليه."},
    {"name": "القوي", "dis": "الذي لا يضعف ولا يعجز عن شيء."},
    {"name": "المتين", "dis": "الشديد القوة الذي لا يتعب، ولا تلحقه مشقة."},
    {"name": "الولي", "dis": "الناصر والمحب لأوليائه، الذي يتولى أمورهم."},
    {"name": "الحميد", "dis": "المحمود على كل حال، المستحق للحمد والثناء."},
    {"name": "المحصي", "dis": "الذي أحصى كل شيء عدداً، وعلم كل شيء."},
    {"name": "المبدئ", "dis": "الذي بدأ الخلق وأوجدهم من العدم."},
    {"name": "المعيد", "dis": "الذي يعيد الخلق بعد فنائهم إلى الحياة."},
    {"name": "المحيي", "dis": "الذي يحيي الموتى، ويحيي القلوب بالإيمان."},
    {"name": "المميت", "dis": "الذي يميت الأحياء ويقبض أرواحهم."},
    {"name": "الحي", "dis": "الباقي الذي لا يموت، الدائم الوجود."},
    {"name": "القيوم", "dis": "القائم بذاته، القائم على كل شيء بتدبيره."},
    {"name": "الواجد", "dis": "الذي يجد كل شيء، ولا يفقده شيء."},
    {"name": "الماجد", "dis": "الكثير المجد والثناء، صاحب العظمة."},
    {"name": "الواحد", "dis": "الأحد الذي لا شريك له، ولا مثيل له."},
    {"name": "الأحد", "dis": "الذي لا نظير له، ولا يماثله شيء."},
    {"name": "الصمد", "dis": "الذي تصمد إليه الخلائق في حاجاتهم، ولا يحتاج إلى أحد."},
    {"name": "القادر", "dis": "الذي يقدر على كل شيء، ولا يعجزه شيء."},
    {"name": "المقتدر", "dis": "التام القدرة الذي لا يمتنع عليه شيء."},
    {"name": "المقدم", "dis": "الذي يقدم من يشاء على من يشاء، ويقدم ما يشاء من الأعمال."},
    {"name": "المؤخر", "dis": "الذي يؤخر من يشاء عن مراتب الفضل، ويؤخر ما يشاء من الأمور."},
    {"name": "الأول", "dis": "الذي لا بداية لوجوده."},
    {"name": "الآخر", "dis": "الذي لا نهاية لوجوده، الباقي بعد فناء خلقه."},
    {"name": "الظاهر", "dis": "الذي ظهرت قدرته وآياته في كل شيء، فهو ظاهر لكل أحد."},
    {"name": "الباطن", "dis": "الذي لا يرى في الدنيا، والخافي عن الأبصار في هذه الدنيا."},
    {"name": "الوالي", "dis": "المالك المتصرف في كل شيء."},
    {"name": "المتعالي", "dis": "الذي تعالى عن النقائص والعيوب، وعن كل ما لا يليق به."},
    {"name": "البر", "dis": "الكثير الإحسان واللطف، المحسن إلى خلقه."},
    {"name": "التواب", "dis": "الذي يقبل توبة عباده، ويعفو عن خطاياهم."},
    {"name": "المنتقم", "dis": "الذي ينتقم من العصاة والمجرمين بعد إنذارهم."},
    {"name": "العفو", "dis": "الكثير العفو عن الذنوب، الذي يمحو السيئات."},
    {"name": "الرؤوف", "dis": "الذي هو شديد الرحمة والرأفة بعباده."},
    {"name": "مالك الملك", "dis": "الذي يملك الملك كله، يعطي الملك من يشاء وينزع الملك ممن يشاء."},
    {"name": "ذو الجلال والإكرام", "dis": "صاحب العظمة والكبرياء، والكرم والجود."},
    {"name": "المقسط", "dis": "الذي يعدل في أحكامه، ويقسط على خلقه بالعدل."},
    {"name": "الجامع", "dis": "الذي يجمع الناس ليوم القيامة، ويجمع بين المتفرقات."},
    {"name": "الغني", "dis": "الذي لا يحتاج إلى شيء، والخلق كلهم مفتقرون إليه."},
    {"name": "المغني", "dis": "الذي يغني من يشاء من خلقه، فيسد حاجاتهم."},
    {"name": "المانع", "dis": "الذي يمنع العطاء عن من يشاء، ويمنع البلاء عن من يشاء."},
    {"name": "الضار", "dis": "الذي يضر من يشاء من خلقه، لحكمة يعلمها."},
    {"name": "النافع", "dis": "الذي ينفع من يشاء من خلقه، ويسوق النفع إليهم."},
    {"name": "النور", "dis": "الذي ينور السماوات والأرض، وهو نور الهدى في قلوب عباده."},
    {"name": "الهادي", "dis": "الذي يهدي من يشاء إلى الصراط المستقيم، ويهدي خلقه إلى مصالحهم."},
    {"name": "البديع", "dis": "الذي أبدع الخلق على غير مثال سبق، وهو فريد في ذاته."},
    {"name": "الباقي", "dis": "الذي لا يفنى ولا يزول، وهو الدائم الباقي."},
    {"name": "الوارث", "dis": "الذي يرث الأرض ومن عليها، ويبقى بعد فناء الخلق."},
    {"name": "الرشيد", "dis": "الذي يرشد الخلق إلى الحق، وهو رشيد في تدبيره."},
    {"name": "الصبور", "dis": "الكثير الصبر، الذي لا يعجل على العصاة، ويمهلهم ليتوبوا."},
  ];
  // ===================================

  late SharedPreferences _prefs; // لا تزال 'late' لأنها تُعيَّن في دالة async

  static const String _counterKey = 'tasbeehCounter';
  static const String _targetKey = 'tasbeehTarget';
  static const String _dhikrKey = 'currentDhikr';
  static const String _dailyCountKey = 'dailyTasbeehCount';
  static const String _lastResetDateKey = 'lastResetDate';

  // ===== مفاتيح جديدة لأسماء الله الحسنى =====
  static const String _asmaAllahIndexKey = 'asmaAllahIndex';
  static const String _lastAsmaAllahUpdateKey = 'lastAsmaAllahUpdate';
  // =========================================

  // مؤشر جديد لإخبار الواجهة بأن SharedPreferences جاهزة
  RxBool isPrefsInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // تأكد من تحميل جميع القيم بعد تهيئة _prefs
      _loadCounter();
      _loadTargetCount();
      _loadDhikr();
      _loadDailyTasbeehCount();
      _checkDailyReset(); // يجب أن يأتي بعد تحميل dailyTasbeehCount
      await _loadAndCheckAsmaAllah(); // انتظار اكتمال تحميل اسم الله
      isPrefsInitialized.value = true; // تعيين هذا المتغير إلى true بعد اكتمال كل شيء
    } catch (e) {
      print("Error initializing SharedPreferences: $e");
      // يمكنك هنا عرض رسالة خطأ للمستخدم أو تسجيل الخطأ
    }
  }

  // ============== منطق أسماء الله الحسنى ==============

  Future<void> _loadAndCheckAsmaAllah() async {
    // التحقق للتأكد من أن القائمة ليست فارغة قبل الوصول إليها
    if (asmaAllahList.isEmpty) {
      currentAsmaAllah.value = {"name": "خطأ", "dis": "لم يتم تحميل أسماء الله الحسنى."};
      print("Error: asmaAllahList is empty!");
      return;
    }

    int index = _prefs.getInt(_asmaAllahIndexKey) ?? 0;
    String? lastUpdateString = _prefs.getString(_lastAsmaAllahUpdateKey);
    DateTime? lastUpdateDate = lastUpdateString != null
        ? DateTime.parse(lastUpdateString)
        : null;

    DateTime now = DateTime.now();
    bool shouldUpdate = false;

    // الشرط: إذا لم يتم التحديث من قبل، أو إذا مر 24 ساعة
    if (lastUpdateDate == null || now.difference(lastUpdateDate).inHours >= 24) {
      shouldUpdate = true;
    }

    if (shouldUpdate) {
      // الانتقال إلى الاسم التالي، والتفاف إلى البداية إذا وصلنا إلى النهاية
      index = (index + 1) % asmaAllahList.length;
      await _prefs.setInt(_asmaAllahIndexKey, index);
      await _prefs.setString(_lastAsmaAllahUpdateKey, now.toIso8601String()); // حفظ الوقت بالضبط
    }

    // التأكد من أن المؤشر ضمن النطاق الصحيح لتجنب Index out of bounds
    if (index < 0 || index >= asmaAllahList.length) {
      index = 0; // ارجع إلى أول اسم كحل احتياطي
      await _prefs.setInt(_asmaAllahIndexKey, index); // قم بتصحيح المؤشر المخزن
    }

    // تعيين الاسم الحالي
    currentAsmaAllah.value = asmaAllahList[index];
  }
  // ================================================


  // تحميل العداد
  void _loadCounter() {
    counter.value = _prefs.getInt(_counterKey) ?? 0;
  }

  // حفظ العداد
  void _saveCounter() {
    _prefs.setInt(_counterKey, counter.value);
  }

  // تحميل العدد المستهدف
  void _loadTargetCount() {
    targetCount.value = _prefs.getInt(_targetKey) ?? 33;
  }

  // حفظ العدد المستهدف
  void _saveTargetCount(int value) {
    targetCount.value = value;
    _prefs.setInt(_targetKey, value);
  }

  // تحميل الذكر الحالي
  void _loadDhikr() {
    currentDhikr.value = _prefs.getString(_dhikrKey) ?? "سبحان الله";
  }

  // حفظ الذكر الحالي
  void _saveDhikr(String dhikr) {
    currentDhikr.value = dhikr;
    _prefs.setString(_dhikrKey, dhikr);
  }

  // تحميل عدد التسبيحات اليومي
  void _loadDailyTasbeehCount() {
    dailyTasbeehCount.value = _prefs.getInt(_dailyCountKey) ?? 0;
  }

  // حفظ عدد التسبيحات اليومي
  void _saveDailyTasbeehCount() {
    _prefs.setInt(_dailyCountKey, dailyTasbeehCount.value);
  }

  // التحقق من إعادة التعيين اليومية
  void _checkDailyReset() {
    String? lastResetDateString = _prefs.getString(_lastResetDateKey);
    DateTime? lastResetDate;
    try {
      lastResetDate = lastResetDateString != null
          ? DateTime.parse(lastResetDateString)
          : null;
    } catch (e) {
      print("Error parsing lastResetDate: $e");
      lastResetDate = null; // إعادة تعيين التاريخ إذا كان التنسيق خاطئاً
    }

    DateTime now = DateTime.now();
    // التحقق مما إذا كان التاريخ مختلفًا (يوم جديد)
    if (lastResetDate == null ||
        lastResetDate.year != now.year ||
        lastResetDate.month != now.month ||
        lastResetDate.day != now.day) {
      dailyTasbeehCount.value = 0; // إعادة تعيين العدد اليومي
      _saveDailyTasbeehCount();
      // حفظ تاريخ اليوم الحالي (فقط السنة والشهر واليوم)
      _prefs.setString(_lastResetDateKey, DateFormat('yyyy-MM-dd').format(now));
    }
  }

  void incrementCounter() {
    if (!isPrefsInitialized.value) { // التأكد من تهيئة SharedPreferences
      print("SharedPreferences not initialized yet!");
      return;
    }
    counter.value++;
    dailyTasbeehCount.value++;
    _saveCounter();
    _saveDailyTasbeehCount();
    if (targetCount.value != 0 && counter.value >= targetCount.value) {
      Get.snackbar(
        "أحسنت!",
        "لقد أكملت $targetCount تسبيحة!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xff8FBC8F).withOpacity(0.9), // استخدام primaryColor من التصميم
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 15,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
      counter.value = 0;
      _saveCounter();
    }
  }

  void resetCounter() {
    if (!isPrefsInitialized.value) return; // التأكد من تهيئة SharedPreferences
    counter.value = 0;
    _saveCounter();
    Get.snackbar(
      "تم الإعادة",
      "تم إعادة تعيين العداد بنجاح.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 15,
      icon: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  void showTargetCountDialog(BuildContext context) {
    if (!isPrefsInitialized.value) return; // التأكد من تهيئة SharedPreferences
    TextEditingController _targetController =
        TextEditingController(text: targetCount.value.toString());

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "تحديد العدد المستهدف",
          style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
        ),
        content: TextField(
          controller: _targetController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "أدخل العدد المستهدف (0 لغير محدود)",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xff8FBC8F)), // لون متناسق
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("إلغاء", style: TextStyle(color: Colors.redAccent)),
          ),
          TextButton(
            onPressed: () {
              int? newTarget = int.tryParse(_targetController.text);
              if (newTarget != null && newTarget >= 0) {
                _saveTargetCount(newTarget);
                Get.back();
              } else {
                Get.snackbar(
                  "خطأ",
                  "الرجاء إدخال رقم صحيح.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.7),
                  colorText: Colors.white,
                );
              }
            },
            child: const Text("حفظ", style: TextStyle(color: Color(0xff8FBC8F))), // لون متناسق
          ),
        ],
      ),
    );
  }

  void showDhikrSelectionDialog(BuildContext context) {
    if (!isPrefsInitialized.value) return; // التأكد من تهيئة SharedPreferences
    List<String> dhikrOptions = [
      "سبحان الله",
      "الحمد لله",
      "لا إله إلا الله",
      "الله أكبر",
      "أستغفر الله",
      "لا حول ولا قوة إلا بالله",
      "اللهم صل على محمد"
    ];

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "اختر الذكر",
          style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: dhikrOptions
                .map(
                  (dhikr) => ListTile(
                    title: Text(
                      dhikr,
                      style: TextStyle(
                        color: currentDhikr.value == dhikr
                            ? const Color(0xff8FBC8F) // لون متناسق
                            : Colors.white,
                        fontFamily: 'Tajawal',
                        fontWeight: currentDhikr.value == dhikr
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      _saveDhikr(dhikr);
                      Get.back();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}