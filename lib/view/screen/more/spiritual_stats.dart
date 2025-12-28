import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/spiritual_stats_controller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class SpiritualStatsView extends StatelessWidget {
  SpiritualStatsView({super.key});

  final SpiritualStatsController controller =
      Get.put(SpiritualStatsController());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'إحصائيات روحانية',
      body: GetX<SpiritualStatsController>(
        builder: (state) {
          if (state.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      scheme: scheme,
                      title: 'أذكار اليوم',
                      value: '${state.todayCount.value}',
                      icon: Icons.auto_awesome_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      scheme: scheme,
                      title: 'أسبوعيًا',
                      value: '${state.weeklyCount.value}',
                      icon: Icons.calendar_month_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _statCard(
                scheme: scheme,
                title: 'الأيام المتتالية',
                value: '${state.streakDays.value} يوم',
                icon: Icons.local_fire_department_outlined,
              ),
              const SizedBox(height: 16),
              _infoCard(
                scheme: scheme,
                title: 'أكثر وقت نشاطًا',
                value: state.mostActiveHour.value,
                icon: Icons.access_time,
              ),
              const SizedBox(height: 16),
              _buildBreakdownCard(context, scheme, state.activityBreakdown),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard({
    required ColorScheme scheme,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required ColorScheme scheme,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.secondary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: scheme.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: scheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(
    BuildContext context,
    ColorScheme scheme,
    Map<String, int> breakdown,
  ) {
    final labels = {
      'dhikr': 'الأذكار',
      'tasbeeh': 'التسبيح',
      'duaa': 'الأدعية',
      'custom_dhikr': 'الأذكار الخاصة',
      'quran': 'قراءة القرآن',
    };

    final entries =
        breakdown.entries
            .where((entry) => entry.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفصيل النشاط',
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(
              'لا توجد بيانات كافية بعد.',
              style: TextStyle(color: scheme.onSurface.withOpacity(0.6)),
            )
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        labels[entry.key] ?? entry.key,
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
