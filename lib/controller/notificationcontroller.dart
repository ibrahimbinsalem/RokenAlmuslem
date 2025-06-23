import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notification_item.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart'
    hide NotificationType;

class NotificationsController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasMore = true.obs;

  final int _notificationsPerPage = 20;
  int _currentPage = 0;
  final NotificationService _notificationService;

  NotificationsController({NotificationService? notificationService})
    : _notificationService =
          notificationService ?? Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    _loadInitialNotifications();
  }

  Future<void> refreshNotifications() async {
    _currentPage = 0;
    hasMore.value = true;
    await _loadInitialNotifications();
  }

  Future<void> _loadInitialNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _fetchNotifications();
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreNotifications() async {
    if (!hasMore.value || isLoading.value) return;

    try {
      isLoading.value = true;
      _currentPage++;
      await _fetchNotifications();
    } catch (e) {
      _handleError(e);
      _currentPage--;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchNotifications() async {
    final pendingRequests =
        await _notificationService.getPendingNotifications();
    final startIndex = _currentPage * _notificationsPerPage;

    if (startIndex >= pendingRequests.length) {
      hasMore.value = false;
      return;
    }

    final endIndex = startIndex + _notificationsPerPage;
    final paginatedRequests = pendingRequests.sublist(
      startIndex,
      endIndex.clamp(0, pendingRequests.length),
    );

    final newNotifications =
        paginatedRequests.map((request) {
          final type = _determineNotificationType(request.payload ?? '');
          return NotificationItem.fromPendingRequest(
            request,
            type: type,
            icon: _getIconForType(type),
            color: _getColorForType(type),
          );
        }).toList();

    if (_currentPage == 0) {
      notifications.value = newNotifications;
    } else {
      notifications.addAll(newNotifications);
    }

    hasMore.value = endIndex < pendingRequests.length;
  }

  NotificationType _determineNotificationType(String payload) {
    const typeMap = {
      'morning': NotificationType.morningAdhkar,
      'evening': NotificationType.eveningAdhkar,
      'hadith': NotificationType.hadith,
      'ayah': NotificationType.ayah,
      'duaa': NotificationType.duaa,
    };

    for (final entry in typeMap.entries) {
      if (payload.contains(entry.key)) return entry.value;
    }
    return NotificationType.general;
  }

  IconData _getIconForType(NotificationType type) {
    const icons = {
      NotificationType.morningAdhkar: Icons.wb_sunny_outlined,
      NotificationType.eveningAdhkar: Icons.nights_stay_outlined,
      NotificationType.hadith: Icons.format_quote_outlined,
      NotificationType.ayah: Icons.book_outlined,
      NotificationType.duaa: Icons.emoji_people_outlined,
    };
    return icons[type] ?? Icons.notifications_none;
  }

  Color _getColorForType(NotificationType type) {
    const colors = {
      NotificationType.morningAdhkar: Color(0xFFF9A825),
      NotificationType.eveningAdhkar: Color(0xFF5C6BC0),
      NotificationType.hadith: Color(0xFF43A047),
      NotificationType.ayah: Color(0xFF00897B),
      NotificationType.duaa: Color(0xFF7B1FA2),
    };
    return colors[type] ?? Colors.grey;
  }

  Future<void> clearAllNotifications() async {
    final confirmed = await _showConfirmationDialog(
      title: "حذف الإشعارات",
      message: "هل أنت متأكد من رغبتك في حذف جميع الإشعارات؟",
    );

    if (!confirmed) return;

    try {
      isLoading.value = true;
      await _notificationService.cancelAllNotifications();
      notifications.clear();
      Get.snackbar(
        "تم الحذف",
        "تم حذف جميع الإشعارات بنجاح",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(int index) async {
    notifications[index] = notifications[index].copyWith(isRead: true);
  }

  Future<void> handleNotificationTap(int index) async {
    await markAsRead(index);
    final notification = notifications[index];

    // Example navigation - adjust based on your app structure
    switch (notification.type) {
      case NotificationType.morningAdhkar:
        Get.toNamed('/morning-adhkar');
        break;
      case NotificationType.eveningAdhkar:
        Get.toNamed('/evening-adhkar');
        break;
      default:
        debugPrint('Notification tapped: ${notification.title}');
    }
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return "الآن";
    if (difference.inMinutes < 60) return "منذ ${difference.inMinutes} دقيقة";
    if (difference.inHours < 24) return "منذ ${difference.inHours} ساعة";
    if (difference.inDays == 1) return "بالأمس";
    if (difference.inDays < 7) return "منذ ${difference.inDays} أيام";
    return DateFormat('yyyy/MM/dd', 'ar').format(time);
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = "حذف",
    Color confirmColor = Colors.red,
    String cancelText = "تراجع",
  }) async {
    return (await Get.dialog<bool>(
          AlertDialog(
            title: Text(title, style: Get.textTheme.titleLarge),
            content: Text(message, style: Get.textTheme.bodyLarge),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  cancelText,
                  style: TextStyle(color: Get.theme.primaryColor),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(confirmText, style: TextStyle(color: confirmColor)),
              ),
            ],
          ),
        )) ??
        false;
  }

  void _handleError(dynamic error) {
    errorMessage.value = error.toString();
    Get.snackbar(
      "خطأ",
      "حدث خطأ: ${error.toString()}",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
