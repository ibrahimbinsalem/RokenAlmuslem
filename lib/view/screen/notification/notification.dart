import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/notification_item.dart';
import 'package:rokenalmuslem/controller/notificationcontroller.dart';

class NotificationsView extends StatefulWidget {
  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final NotificationsController controller = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('الإشعارات', style: theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[900]!, Colors.teal[700]!, Colors.teal[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clearAllNotifications,
            tooltip: 'حذف الكل',
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshNotifications,
            tooltip: 'تحديث',
            color: Colors.white,
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
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshNotifications,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد إشعارات مجدولة حالياً',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
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
            itemCount:
                controller.notifications.length +
                (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.notifications.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final notification = controller.notifications[index];
              return _buildNotificationTile(
                notification,
                index,
                theme,
                isDarkMode,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationTile(
    NotificationItem notification,
    int index,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final cardColor =
        notification.isRead
            ? (isDarkMode
                ? Colors.blueGrey.shade900.withOpacity(0.5)
                : Colors.grey.shade200)
            : (isDarkMode ? Colors.blueGrey.shade800 : Colors.white);

    final titleStyle = theme.textTheme.titleMedium!.copyWith(
      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
      color:
          notification.isRead
              ? (isDarkMode ? Colors.white70 : Colors.black54)
              : (isDarkMode ? Colors.white : Colors.black87),
    );

    final subtitleStyle = theme.textTheme.bodyMedium!.copyWith(
      color:
          notification.isRead
              ? (isDarkMode ? Colors.white60 : Colors.black45)
              : (isDarkMode ? Colors.white70 : Colors.black54),
    );

    return Card(
      elevation: notification.isRead ? 1 : 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color:
              notification.isRead
                  ? Colors.transparent
                  : notification.color.withOpacity(0.5),
          width: 1,
        ),
      ),
      color: cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: notification.color.withOpacity(0.2),
          child: Icon(notification.icon, color: notification.color),
        ),
        title: Text(notification.title, style: titleStyle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message, style: subtitleStyle),
            const SizedBox(height: 4),
            Text(
              controller.formatTime(notification.time),
              style: theme.textTheme.bodySmall!.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing:
            notification.isRead
                ? null
                : Icon(
                  Icons.circle,
                  size: 12,
                  color: theme.colorScheme.primary,
                ),
        onTap: () => controller.handleNotificationTap(index),
      ),
    );
  }
}
