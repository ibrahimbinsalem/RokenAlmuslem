import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';

class CustomAdkarController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final NotificationService _notifications = Get.find<NotificationService>();

  final groups = <Map<String, dynamic>>[].obs;
  final items = <Map<String, dynamic>>[].obs;
  final selectedGroupId = 0.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadGroups();
  }

  Future<void> loadGroups() async {
    isLoading.value = true;
    final data = await _db.getCustomAdkarGroups();
    groups.assignAll(data);
    isLoading.value = false;
  }

  Future<void> loadItems(int groupId) async {
    selectedGroupId.value = groupId;
    final data = await _db.getCustomAdkarItems(groupId);
    items.assignAll(data);
  }

  Future<void> addGroup(String name, String description) async {
    final id = await _db.insertCustomAdkarGroup({
      'name': name,
      'description': description,
      'reminder_enabled': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
    await loadGroups();
    if (id > 0) {
      selectedGroupId.value = id;
    }
  }

  Future<void> updateGroup(int id, String name, String description) async {
    await _db.updateCustomAdkarGroup(id, {
      'name': name,
      'description': description,
    });
    await loadGroups();
  }

  Future<void> deleteGroup(int id) async {
    await _db.deleteCustomAdkarGroup(id);
    if (selectedGroupId.value == id) {
      selectedGroupId.value = 0;
      items.clear();
    }
    await loadGroups();
  }

  Future<void> addItem(
    int groupId,
    String title,
    String content,
    int targetCount,
  ) async {
    await _db.insertCustomAdkarItem({
      'group_id': groupId,
      'title': title,
      'content': content,
      'target_count': targetCount,
      'current_count': targetCount,
      'created_at': DateTime.now().toIso8601String(),
    });
    await loadItems(groupId);
  }

  Future<void> updateItem(
    int itemId,
    String title,
    String content,
    int targetCount,
  ) async {
    await _db.updateCustomAdkarItem(itemId, {
      'title': title,
      'content': content,
      'target_count': targetCount,
      'current_count': targetCount,
    });
    await loadItems(selectedGroupId.value);
  }

  Future<void> deleteItem(int itemId) async {
    await _db.deleteCustomAdkarItem(itemId);
    await loadItems(selectedGroupId.value);
  }

  Future<void> decrementItem(Map<String, dynamic> item) async {
    final current = item['current_count'] as int? ?? 0;
    if (current <= 0) return;
    final newCount = current - 1;
    await _db.updateCustomAdkarItem(item['id'] as int, {
      'current_count': newCount,
    });
    await _db.logSpiritualActivity('custom_dhikr', count: 1);
    await loadItems(selectedGroupId.value);
  }

  Future<void> resetItem(Map<String, dynamic> item) async {
    final target = item['target_count'] as int? ?? 1;
    await _db.updateCustomAdkarItem(item['id'] as int, {
      'current_count': target,
    });
    await loadItems(selectedGroupId.value);
  }

  String _formatTime(TimeOfDay time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  int _reminderId(int groupId) => 50000 + groupId;

  Future<void> toggleReminder(
    Map<String, dynamic> group,
    bool enabled,
  ) async {
    final settings = Get.find<AppSettingsController>();
    if (!settings.notificationsEnabled.value && enabled) {
      Get.snackbar(
        'التنبيهات معطلة',
        'يرجى تفعيل الإشعارات أولاً من الإعدادات.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final groupId = group['id'] as int;
    final reminderTime = group['reminder_time'] as String? ?? '08:00';
    final time = _parseTime(reminderTime);
    final reminderId = group['reminder_id'] as int? ?? _reminderId(groupId);

    if (enabled) {
      await _notifications.scheduleDailyReminder(
        id: reminderId,
        title: 'تذكير الأذكار الخاصة',
        body: 'حان وقت مجموعة ${group['name']}',
        time: time,
        payload: 'custom_dhikr_$groupId',
      );
    } else {
      await _notifications.cancelNotification(reminderId);
    }

    await _db.updateCustomAdkarGroup(groupId, {
      'reminder_enabled': enabled ? 1 : 0,
      'reminder_time': reminderTime,
      'reminder_id': reminderId,
    });
    await loadGroups();
  }

  Future<void> updateReminderTime(
    Map<String, dynamic> group,
    TimeOfDay time,
  ) async {
    final groupId = group['id'] as int;
    final reminderId = group['reminder_id'] as int? ?? _reminderId(groupId);
    final reminderTime = _formatTime(time);
    await _db.updateCustomAdkarGroup(groupId, {
      'reminder_time': reminderTime,
      'reminder_id': reminderId,
    });
    if ((group['reminder_enabled'] as int? ?? 0) == 1) {
      await _notifications.scheduleDailyReminder(
        id: reminderId,
        title: 'تذكير الأذكار الخاصة',
        body: 'حان وقت مجموعة ${group['name']}',
        time: time,
        payload: 'custom_dhikr_$groupId',
      );
    }
    await loadGroups();
  }

  String formatReminderLabel(String? value) {
    if (value == null || value.isEmpty) return '08:00';
    final time = _parseTime(value);
    final date = DateTime(2024, 1, 1, time.hour, time.minute);
    return DateFormat('hh:mm a', 'ar').format(date);
  }
}
