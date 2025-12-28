import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/custom_adkar_controller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/modern_scaffold.dart';

class CustomAdkarGroupView extends StatelessWidget {
  final Map<String, dynamic> group;
  CustomAdkarGroupView({super.key, required this.group});

  final CustomAdkarController controller = Get.find<CustomAdkarController>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final groupId = group['id'] as int;
    if (controller.selectedGroupId.value != groupId) {
      controller.loadItems(groupId);
    }

    return ModernScaffold(
      title: group['name']?.toString() ?? 'مجموعة أذكار',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: scheme.primary,
        child: const Icon(Icons.add),
      ),
      body: GetX<CustomAdkarController>(
        builder: (state) {
          if (state.items.isEmpty) {
            return Center(
              child: Text(
                'لا توجد أذكار بعد',
                style: TextStyle(color: scheme.onSurface.withOpacity(0.7)),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _buildItemCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Map<String, dynamic> item) {
    final scheme = Theme.of(context).colorScheme;
    final title = (item['title'] as String?)?.trim();
    final current = item['current_count'] as int? ?? 0;
    final target = item['target_count'] as int? ?? 1;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title?.isNotEmpty == true ? title! : 'ذكر',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditItemDialog(context, item);
                  }
                  if (value == 'reset') {
                    controller.resetItem(item);
                  }
                  if (value == 'delete') {
                    controller.deleteItem(item['id'] as int);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(value: 'reset', child: Text('إعادة ضبط')),
                  const PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['content']?.toString() ?? '',
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.75),
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$current / $target',
                  style: TextStyle(color: scheme.secondary),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: current > 0 ? () => controller.decrementItem(item) : null,
                icon: Icon(Icons.remove_circle_outline, color: scheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final countController = TextEditingController(text: '1');
    Get.dialog(
      AlertDialog(
        title: const Text('إضافة ذكر'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'عنوان'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'النص'),
                maxLines: 3,
              ),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'العدد'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final count = int.tryParse(countController.text.trim()) ?? 1;
              controller.addItem(
                group['id'] as int,
                titleController.text.trim(),
                contentController.text.trim(),
                count,
              );
              Get.back();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    final titleController =
        TextEditingController(text: item['title']?.toString() ?? '');
    final contentController =
        TextEditingController(text: item['content']?.toString() ?? '');
    final countController =
        TextEditingController(text: item['target_count']?.toString() ?? '1');
    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الذكر'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'عنوان'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'النص'),
                maxLines: 3,
              ),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'العدد'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final count = int.tryParse(countController.text.trim()) ?? 1;
              controller.updateItem(
                item['id'] as int,
                titleController.text.trim(),
                contentController.text.trim(),
                count,
              );
              Get.back();
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}
