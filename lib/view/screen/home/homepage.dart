import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // بيانات محلية بدلاً من Firebase
  final List<Map<String, String>> items = [
    {
      "ayah": "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
      "sorah": "سورة الشرح",
      "hadyth": "من سلك طريقًا يلتمس فيه علمًا سهل الله له به طريقًا إلى الجنة",
      "alrawy": "رواه مسلم",
      "name": "الرحمن",
      "dis": "الذي وسعت رحمته كل شيء",
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xff8FBC8F);
    const secondaryColor = Color(0xFF2E7D32);
    const bgColor = Color(0xFF121212);
    const cardColor = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // البسملة
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Center(
                  child: Text(
                    " بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ ",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Uthmanic',
                    ),
                  ),
                ),
              ),

              // اختصارات
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "اختصارات:",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // الأيقونات الرئيسية
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShortcut(
                      context,
                      icon: "assets/images/اسماء الله.png",
                      label: "اسماء الله",
                      onTap: () {},
                    ),
                    _buildShortcut(
                      context,
                      icon: "assets/images/حلقات ذكر .png",
                      label: "حلقات ذكر",
                      onTap: () {},
                    ),
                    _buildShortcut(
                      context,
                      icon: "assets/images/مسبحة.png",
                      label: "بيت الاستغفار",
                      onTap: () {},
                    ),
                    _buildShortcut(
                      context,
                      icon: "assets/images/الاربعون النووية .png",
                      label: "الأربعين النووية",
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // رسالة يوم الجمعة
              _buildSectionHeader(title: "رسالة يوم الجمعة", onPressed: () {}),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/سنن يوم الجمعة .jpeg",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // آية اليوم
              _buildSectionHeader(title: "اية اليوم", onPressed: () {}),
              _buildAyahCard(items[0], primaryColor, cardColor),

              // حديث اليوم
              _buildSectionHeader(title: "حديث اليوم", onPressed: () {}),
              _buildHadithCard(items[0], primaryColor, cardColor),

              // أسماء الله الحسنى
              _buildSectionHeader(title: "اسماء الله الحسنى", onPressed: () {}),
              _buildAsmaAllahCard(items[0], primaryColor, cardColor),

              // تذييل الصفحة
              const SizedBox(height: 30),
              Text(
                "أذكاري",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Uthmanic',
                ),
              ),
              Divider(
                indent: MediaQuery.of(context).size.width * 0.3,
                endIndent: MediaQuery.of(context).size.width * 0.3,
                thickness: 3,
                color: primaryColor,
              ),
              const SizedBox(height: 10),
              Text(
                "V1.0.0",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ================ Widgets مساعدة =================

  // بناء عنصر اختصار
  Widget _buildShortcut(
    BuildContext context, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: const Color(0xff8FBC8F),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.green[900]!.withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image.asset(icon, fit: BoxFit.contain),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // رأس القسم
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, right: 25, left: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(Icons.more_horiz, color: Colors.grey[500]),
          ),
          Text(
            ": $title",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة الآية
  Widget _buildAyahCard(
    Map<String, String> item,
    Color primaryColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20, left: 20),
            child: Text(
              item["ayah"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Uthmanic',
                height: 1.8,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _copyToClipboard(item["ayah"]!),
                  icon: const Icon(Icons.copy_outlined, color: Colors.white),
                ),
                Text(
                  item["sorah"]!,
                  style: TextStyle(
                    color: primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة الحديث
  Widget _buildHadithCard(
    Map<String, String> item,
    Color primaryColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20, left: 20),
            child: Text(
              item["hadyth"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.6,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _copyToClipboard(item["hadyth"]!),
                  icon: const Icon(Icons.copy_outlined, color: Colors.white),
                ),
                Text(
                  item["alrawy"]!,
                  style: TextStyle(
                    color: primaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة أسماء الله الحسنى
  Widget _buildAsmaAllahCard(
    Map<String, String> item,
    Color primaryColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Text(
              item["name"]!,
              style: TextStyle(
                color: primaryColor,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                fontFamily: 'Uthmanic',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              item["dis"]!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(indent: 20, endIndent: 20, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () => _copyToClipboard(item["name"]!),
                  icon: const Icon(Icons.copy_outlined, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // نسخ النص
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xff8FBC8F),
        content: const Text(
          "تم النسخ بنجاح",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.only(bottom: 20, left: 50, right: 50),
      ),
    );
  }
}
