import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/custom_adkar_controller.dart';
import 'package:rokenalmuslem/view/screen/more/custom_adkar_group.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class CustomAdkarView extends StatelessWidget {
  CustomAdkarView({super.key});

  final CustomAdkarController controller = Get.put(CustomAdkarController());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ModernScaffold(
      title: 'أذكار خاصة',
      actions: [
        IconButton(
          onPressed: () => _showHelpDialog(context),
          icon: const Icon(Icons.info_outline, color: Colors.white),
          tooltip: 'تعليمات',
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGroupDialog(context),
        backgroundColor: scheme.primary,
        child: const Icon(Icons.add),
      ),
      body: GetX<CustomAdkarController>(
        builder: (state) {
          if (state.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.groups.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.groups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final group = state.groups[index];
              final reminderEnabled = (group['reminder_enabled'] as int? ?? 0) == 1;
              return _buildGroupCard(context, group, reminderEnabled);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 60, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            'لم تقم بإضافة أذكار بعد',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أنشئ مجموعة خاصة بك وابدأ التتبع اليومي',
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    Map<String, dynamic> group,
    bool reminderEnabled,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final description = (group['description'] as String?) ?? '';
    final reminderLabel = controller.formatReminderLabel(
      group['reminder_time'] as String?,
    );

    return InkWell(
      onTap: () {
        Get.to(() => CustomAdkarGroupView(group: group));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.primary.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.menu_book, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    group['name']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditGroupDialog(context, group);
                    }
                    if (value == 'delete') {
                      controller.deleteGroup(group['id'] as int);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('تعديل'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف'),
                    ),
                  ],
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: scheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'التذكير: $reminderLabel',
                    style: TextStyle(
                      color: scheme.onSurface.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
                Switch(
                  value: reminderEnabled,
                  onChanged: (value) {
                    controller.toggleReminder(group, value);
                  },
                  activeColor: scheme.primary,
                ),
                IconButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) {
                      controller.updateReminderTime(group, picked);
                    }
                  },
                  icon: Icon(Icons.schedule, color: scheme.secondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('مجموعة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المجموعة'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'وصف مختصر'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                controller.addGroup(name, descController.text.trim());
              }
              Get.back();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(
    BuildContext context,
    Map<String, dynamic> group,
  ) {
    final nameController =
        TextEditingController(text: group['name']?.toString() ?? '');
    final descController =
        TextEditingController(text: group['description']?.toString() ?? '');
    Get.dialog(
      AlertDialog(
        title: const Text('تعديل المجموعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم المجموعة'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'وصف مختصر'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                controller.updateGroup(
                  group['id'] as int,
                  name,
                  descController.text.trim(),
                );
              }
              Get.back();
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('ماذا تفعل في صفحة أذكار خاصة؟'),
        content: const Text(
          'هذه الصفحة تساعدك على إنشاء مجموعات أذكارك الخاصة مع تذكير يومي.\n\n'
          'الخطوات:\n'
          '1) اضغط على زر + لإضافة مجموعة جديدة.\n'
          '2) افتح المجموعة لإضافة الأذكار وتحديد العدد المطلوب لكل ذكر.\n'
          '3) فعّل التذكير واختر وقت التذكير المناسب.\n'
          '4) عند الانتهاء يمكنك إعادة ضبط العداد أو تعديل الذكر في أي وقت.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }
}
