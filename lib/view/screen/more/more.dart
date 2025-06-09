import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

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
                'المزيد',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[800]!, Colors.teal[600]!],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                    'assets/images/حلقات ذكر .png',
                    fit: BoxFit.cover,
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.login, color: Colors.white),
                onPressed: () {},
              ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  title: "أسماء الله الحسنى",
                  image: "assets/images/اسماء الله.png",
                  color: Colors.deepPurple,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "حلقات الذكر",
                  image: "assets/images/حلقات ذكر .png",
                  color: Colors.blue,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "المسبحة الإلكترونية",
                  image: "assets/images/الكترونية.png",
                  color: Colors.green,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "أذكار المسلم",
                  image: "assets/images/دعاء.png",
                  color: Colors.amber,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "اتجاه القبلة",
                  image: "assets/images/القبله.png",
                  color: Colors.orange,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "بيت الاستغفار",
                  image: "assets/images/مسبحة.png",
                  color: Colors.lightBlue,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "فضل الدعاء",
                  image: "assets/images/استغفار.png",
                  color: Colors.indigo,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "الاشعارات",
                  image: "assets/images/masseg icon.png",
                  color: Colors.pink,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "الرقية الشرعية",
                  image: "assets/images/الرقية الشرعية .png",
                  color: Colors.red,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "الأدعية القرآنية",
                  image: "assets/images/ادعية قرانية .png",
                  color: Colors.teal,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "أدعية نبوية",
                  image: "assets/images/ادعية نبوية .png",
                  color: Colors.brown,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "أدعية الأنبياء",
                  image: "assets/images/ادعية الانبياء.png",
                  color: Colors.cyan,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "الأربعين النووية",
                  image: "assets/images/الاربعون النووية .png",
                  color: Colors.deepOrange,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "فضل الذكر",
                  image: "assets/images/رمضان .png",
                  color: Colors.lime,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "الحج والعمرة",
                  image: "assets/images/الحج والعمره .png",
                  color: Colors.purple,
                  onTap: () {},
                ),
                _buildFeatureCard(
                  title: "الإعدادات",
                  image: "assets/images/اعدادات.png",
                  color: Colors.grey,
                  onTap: () {},
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String image,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF1E1E1E),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.3), width: 2),
                ),
                child: Image.asset(image, width: 40, height: 40, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(height: 2, width: 40, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
