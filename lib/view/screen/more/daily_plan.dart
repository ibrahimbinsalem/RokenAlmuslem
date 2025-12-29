import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';
import 'package:rokenalmuslem/controller/more/daily_plan_controller.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';

class DailyPlanView extends StatelessWidget {
  const DailyPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    final DailyPlanController controller = Get.put(DailyPlanController());
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: 0,
                  backgroundColor: scheme.primary.withOpacity(0.85),
                  title: const Text('خطة اليوم'),
                  actions: [
                    IconButton(
                      tooltip: 'إعادة ضبط اليوم',
                      onPressed: controller.resetToday,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _buildProgressCard(
                      context,
                      controller,
                      scheme,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = controller.tasks[index];
                      final isDone = controller.completion[task.id] == true;
                      return _buildTaskCard(
                        context,
                        controller,
                        task,
                        isDone,
                      );
                    },
                    childCount: controller.tasks.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoute.setting),
        icon: const Icon(Icons.settings),
        label: const Text('الإعدادات'),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    DailyPlanController controller,
    ColorScheme scheme,
  ) {
    final progress = controller.progress;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إنجاز اليوم',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'أنجزت ${controller.completedCount} من ${controller.tasks.length} مهام',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.primary.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    DailyPlanController controller,
    DailyPlanTask task,
    bool isDone,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? scheme.primary : scheme.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(task.icon, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Checkbox(
                value: isDone,
                onChanged: (_) => controller.toggleTask(task.id),
              ),
              TextButton(
                onPressed: () => Get.toNamed(task.route),
                child: const Text('فتح'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
