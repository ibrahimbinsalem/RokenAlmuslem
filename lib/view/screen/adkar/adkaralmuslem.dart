import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';

class AdkarAlmuslam extends StatelessWidget {
  const AdkarAlmuslam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'أذكار المسلم',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[800]!, Colors.green[600]!],
                    begin: Alignment.topCenter,

                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildListDelegate([
                _buildAdkarCard(
                  title: "أذكار المساء",
                  icon: Icons.nightlight_round,
                  color: Colors.deepPurple,
                  onTap: () {
                    Get.toNamed(AppRoute.almsa);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار الصباح",
                  icon: Icons.wb_sunny,
                  color: Colors.amber,
                  onTap: () {
                    Get.toNamed(AppRoute.alsbah);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار بعد الصلاة",
                  icon: Icons.mosque,
                  color: Colors.green,
                  onTap: () {
                    Get.toNamed(AppRoute.afterpray);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار الصلاة",
                  icon: Icons.man,
                  color: Colors.blue,
                  onTap: () {
                    Get.toNamed(AppRoute.pray);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار النوم",
                  icon: Icons.bedtime,
                  color: Colors.indigo,
                  onTap: () {
                    Get.toNamed(AppRoute.sleep);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار الآذان",
                  icon: Icons.mic,
                  color: Colors.teal,
                  onTap: () {
                    Get.toNamed(AppRoute.aladan);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار المسجد",
                  icon: Icons.account_balance,
                  color: Colors.brown,
                  onTap: () {
                    Get.toNamed(AppRoute.almsjed);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار الإستيقاظ",
                  icon: Icons.alarm,
                  color: Colors.lightBlue,
                  onTap: () {
                    Get.toNamed(AppRoute.alastygad);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار المنزل",
                  icon: Icons.home,
                  color: Colors.orange,
                  onTap: () {
                    Get.toNamed(AppRoute.almanzel);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار الوضوء",
                  icon: Icons.water_drop,
                  color: Colors.cyan,
                  onTap: () {
                    Get.toNamed(AppRoute.washing);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار الخلاء",
                  icon: Icons.meeting_room_rounded,
                  color: Colors.pink,
                  onTap: () {
                    Get.toNamed(AppRoute.alkhla);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار الطعام",
                  icon: Icons.restaurant,
                  color: Colors.red,
                  onTap: () {
                    Get.toNamed(AppRoute.eat);
                  },
                ),
                _buildAdkarCard(
                  title: "أذكار أخرى",
                  icon: Icons.more_horiz,
                  color: Colors.grey,
                  onTap: () {
                    _showComingSoonDialog(context);
                  },
                ),
                _buildAdkarCard(
                  title: "أدعية للميّت",
                  icon: Icons.heart_broken,
                  color: Colors.deepOrange,
                  onTap: () {
                    Get.toNamed(AppRoute.fordead);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdkarCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: const Color(0xFF1E1E1E),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "قريبا",
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "سيتم إضافة هذه الأذكار قريباً بإذن الله",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "حسناً",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
