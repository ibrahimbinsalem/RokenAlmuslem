import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/notification_item.dart';
import 'package:rokenalmuslem/controller/notificationcontroller.dart';

class NotificationsView extends StatelessWidget {
  final NotificationsController controller = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clearAllNotifications,
            tooltip: 'حذف الكل',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshNotifications,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value),
                ElevatedButton(
                  onPressed: controller.refreshNotifications,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return const Center(child: Text('لا توجد إشعارات'));
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.metrics.pixels ==
                scrollNotification.metrics.maxScrollExtent) {
              controller.loadMoreNotifications();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: controller.notifications.length + 
                (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.notifications.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final notification = controller.notifications[index];
              return _buildNotificationTile(notification, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationTile(NotificationItem notification, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? Colors.grey[100] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.color.withOpacity(0.2),
          child: Icon(notification.icon, color: notification.color),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              controller.formatTime(notification.time),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : const Icon(Icons.circle, size: 10, color: Colors.blue),
        onTap: () => controller.handleNotificationTap(index),
      ),
    );
  }
}