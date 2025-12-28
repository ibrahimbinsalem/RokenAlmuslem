import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/notification_item.dart';
import 'package:rokenalmuslem/controller/notificationcontroller.dart';
import 'package:rokenalmuslem/view/wedgit/layout/app_background.dart';

class NotificationsView extends StatelessWidget {
  NotificationsView({super.key});

  final NotificationsController controller = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('الرسائل', style: theme.appBarTheme.titleTextStyle),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.9),
                theme.colorScheme.secondary.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshNotifications,
            tooltip: 'تحديث',
            color: Colors.white,
          ),
        ],
      ),
      body: AppBackground(
        child: GetX<NotificationsController>(
          builder: (controller) {
            final items = controller.notifications;
            if (controller.isLoading.value && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _buildErrorState(theme);
            }

            return RefreshIndicator(
              onRefresh: controller.refreshNotifications,
              child: items.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = items[index];
                        return Dismissible(
                          key: ValueKey(
                            notification.remoteId ?? notification.id,
                          ),
                          direction: DismissDirection.horizontal,
                          background: _buildDismissBackground(
                            alignRight: false,
                            theme: theme,
                          ),
                          secondaryBackground: _buildDismissBackground(
                            alignRight: true,
                            theme: theme,
                          ),
                          confirmDismiss: (direction) async {
                            final allowRightSwipe = isRtl
                                ? direction == DismissDirection.endToStart
                                : direction == DismissDirection.startToEnd;
                            return allowRightSwipe;
                          },
                          onDismissed: (_) {
                            controller.dismissNotification(notification);
                          },
                          child: _buildNotificationCard(
                            notification,
                            theme,
                            isDarkMode,
                          ),
                        );
                      },
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem notification,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final scheme = theme.colorScheme;
    final Color cardColor = scheme.surface;
    final Color borderColor = theme.dividerColor;
    final Color iconColor = notification.color;

    return InkWell(
      onTap: () => controller.handleNotificationTap(notification),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconColor.withOpacity(0.12),
              child: Icon(notification.icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_hasAction(notification))
                        Icon(
                          notification.actionType == 'route'
                              ? Icons.open_in_new
                              : Icons.link,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.formatTime(notification.time),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 120),
      children: [
        Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'لا توجد رسائل حالياً',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اسحب للأسفل للتحديث',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 60),
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

  Widget _buildDismissBackground({
    required bool alignRight,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.delete_outline, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'حذف',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAction(NotificationItem notification) {
    if (notification.actionType == 'route' &&
        notification.actionValue != null &&
        notification.actionValue!.trim().isNotEmpty) {
      return true;
    }

    final payload = notification.actionValue ?? notification.payload;
    if (payload == null) {
      return false;
    }
    final trimmed = payload.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final withScheme = trimmed.startsWith('http://') ||
            trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(withScheme);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
