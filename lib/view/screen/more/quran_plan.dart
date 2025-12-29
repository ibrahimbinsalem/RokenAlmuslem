import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_plan_controller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class QuranPlanView extends StatelessWidget {
  QuranPlanView({super.key});

  final QuranPlanController controller = Get.put(QuranPlanController());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ModernScaffold(
      title: 'خطة ختم القرآن',
      body: GetX<QuranPlanController>(
        builder: (state) {
          if (state.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final completed = state.completedPages.value;
          final total = state.totalPages.value;
          final remaining = (total - completed).clamp(0, total);
          final progress = total == 0 ? 0.0 : completed / total;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSummaryCard(
                scheme: scheme,
                textTheme: textTheme,
                completed: completed,
                remaining: remaining,
                total: total,
                progress: progress,
                targetDays: state.targetDays.value,
                startDate: state.startDate.value,
              ),
              const SizedBox(height: 20),
              _buildDailyCard(
                scheme: scheme,
                textTheme: textTheme,
                todayPages: state.todayPages.value,
                onAdd: () => _showAddPagesDialog(context),
              ),
              const SizedBox(height: 20),
              _buildWeeklyCard(
                scheme: scheme,
                textTheme: textTheme,
                weeklyPages: state.weeklyPages.value,
                weeklyGoal: state.weeklyGoalPages.value,
              ),
              const SizedBox(height: 20),
              _buildSettingsCard(
                context,
                scheme: scheme,
                textTheme: textTheme,
                targetDays: state.targetDays.value,
                pagesPerDay: state.pagesPerDay.value,
                weeklyGoal: state.weeklyGoalPages.value,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required ColorScheme scheme,
    required TextTheme textTheme,
    required int completed,
    required int remaining,
    required int total,
    required double progress,
    required int targetDays,
    required String startDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقدم الختم',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: scheme.onSurface.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.secondary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statChip(
                label: 'المقروء',
                value: '$completed صفحة',
                scheme: scheme,
              ),
              _statChip(
                label: 'المتبقي',
                value: '$remaining صفحة',
                scheme: scheme,
              ),
              _statChip(
                label: 'الهدف',
                value: '$targetDays يوم',
                scheme: scheme,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'تاريخ البدء: $startDate',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 16, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'إجمالي الصفحات: $total',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard({
    required ColorScheme scheme,
    required TextTheme textTheme,
    required int todayPages,
    required VoidCallback onAdd,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.secondary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.today_outlined, color: scheme.secondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متابعة اليوم',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'تم قراءة $todayPages صفحة اليوم',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyCard({
    required ColorScheme scheme,
    required TextTheme textTheme,
    required int weeklyPages,
    required int weeklyGoal,
  }) {
    final progress = weeklyGoal == 0 ? 0.0 : weeklyPages / weeklyGoal;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الهدف الأسبوعي',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: scheme.onSurface.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$weeklyPages من $weeklyGoal صفحة',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required ColorScheme scheme,
    required TextTheme textTheme,
    required int targetDays,
    required int pagesPerDay,
    required int weeklyGoal,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات الخطة',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'الهدف: $targetDays يوم • اليومي: $pagesPerDay صفحة • الأسبوعي: $weeklyGoal صفحة',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showEditPlanDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.primary,
                    side: BorderSide(color: scheme.primary.withOpacity(0.4)),
                  ),
                  child: const Text('تعديل الخطة'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () => controller.resetPlan(),
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.error,
                  ),
                  child: const Text('إعادة الضبط'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPagesDialog(BuildContext context) {
    final controllerText = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل صفحات اليوم'),
        content: TextField(
          controller: controllerText,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'عدد الصفحات',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controllerText.text.trim()) ?? 0;
              if (value > 0) {
                controller.addPages(value);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditPlanDialog(BuildContext context) {
    final targetController =
        TextEditingController(text: controller.targetDays.value.toString());
    final dailyController =
        TextEditingController(text: controller.pagesPerDay.value.toString());
    final weeklyController =
        TextEditingController(text: controller.weeklyGoalPages.value.toString());

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل خطة الختم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'عدد الأيام'),
            ),
            TextField(
              controller: dailyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'صفحات يومية'),
            ),
            TextField(
              controller: weeklyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'الهدف الأسبوعي'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final target = int.tryParse(targetController.text.trim()) ?? 30;
              final daily = int.tryParse(dailyController.text.trim()) ?? 20;
              final weekly = int.tryParse(weeklyController.text.trim()) ??
                  (daily * 7);
              controller.updatePlanSettings(
                newTargetDays: target,
                newPagesPerDay: daily,
                newWeeklyGoal: weekly,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}
