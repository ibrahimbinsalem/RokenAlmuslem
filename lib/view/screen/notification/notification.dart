import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: "موعد أذكار الصباح",
      message:
          "حان الآن وقت أذكار الصباح، احرص على ذكر الله في هذا الوقت المبارك",
      time: DateTime.now().subtract(Duration(minutes: 30)),
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFF9A825), // لون ذهبي فاتح
      isRead: false,
      type: NotificationType.morningAdhkar,
    ),
    NotificationItem(
      title: "تذكير بأذكار المساء",
      message: "لا تنسى أذكار المساء قبل النوم، فهي حرز لك من الشيطان",
      time: DateTime.now().subtract(Duration(hours: 2)),
      icon: Icons.nights_stay_outlined,
      color: Color(0xFF5C6BC0), // لون نيلي
      isRead: true,
      type: NotificationType.eveningAdhkar,
    ),
    NotificationItem(
      title: "حديث اليوم",
      message: "من سلك طريقًا يلتمس فيه علمًا سهل الله له طريقًا إلى الجنة",
      time: DateTime.now().subtract(Duration(days: 1)),
      icon: Icons.format_quote_outlined,
      color: Color(0xFF43A047), // لون أخضر
      isRead: true,
      type: NotificationType.hadith,
    ),
    NotificationItem(
      title: "آية اليوم",
      message: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
      time: DateTime.now().subtract(Duration(days: 2)),
      icon: Icons.book_outlined,
      color: Color(0xFF00897B), // لون تركواز
      isRead: true,
      type: NotificationType.ayah,
    ),
    NotificationItem(
      title: "تذكير بالدعاء",
      message: "أوقات الاستجابة بين الأذان والإقامة، فأكثر من الدعاء",
      time: DateTime.now().subtract(Duration(days: 3)),
      icon: Icons.emoji_people_outlined,
      color: Color(0xFF7B1FA2), // لون بنفسجي
      isRead: true,
      type: NotificationType.duaa,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "الإشعارات",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal', // استخدام خط عربي
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: Colors.white),
            onPressed: () => _clearAllNotifications(context),
            tooltip: 'حذف الكل',
          ),
        ],
        elevation: 4,
      ),
      body:
          notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: () async {
                  // يمكن إضافة تحديث للإشعارات هنا
                  await Future.delayed(Duration(seconds: 1));
                },
                child: ListView.separated(
                  padding: EdgeInsets.all(8),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(notifications[index]);
                  },
                ),
              ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              notification.isRead
                  ? Colors.transparent
                  : Color(0xFF1B5E20).withOpacity(0.3),
        ),
      ),
      color:
          notification.isRead
              ? Colors.white
              : Color(0xFFE8F5E9).withOpacity(0.7),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleNotificationTap(notification),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: notification.color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 22,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                              fontFamily: 'Tajawal',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _formatTime(notification.time),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontFamily: 'Tajawal',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFF1B5E20),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1B5E20).withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 20),
          Text(
            "لا توجد إشعارات",
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "عند وجود إشعارات جديدة، ستظهر هنا لتكون على اطلاع بكل ما هو جديد",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return "الآن";
    } else if (difference.inMinutes < 60) {
      return "منذ ${difference.inMinutes} دقيقة";
    } else if (difference.inHours < 24) {
      return "منذ ${difference.inHours} ساعة";
    } else if (difference.inDays == 1) {
      return "بالأمس";
    } else if (difference.inDays < 7) {
      return "منذ ${difference.inDays} أيام";
    } else {
      return DateFormat('yyyy/MM/dd').format(time);
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // يمكن إضافة التنقل للصفحة المناسبة حسب نوع الإشعار
    switch (notification.type) {
      case NotificationType.morningAdhkar:
      case NotificationType.eveningAdhkar:
        // الانتقال لصفحة الأذكار
        break;
      case NotificationType.hadith:
        // الانتقال لصفحة الأحاديث
        break;
      case NotificationType.ayah:
        // الانتقال لصفحة الآيات
        break;
      case NotificationType.duaa:
        // الانتقال لصفحة الأدعية
        break;
    }
  }

  void _clearAllNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "حذف الإشعارات",
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            content: Text(
              "هل أنت متأكد من رغبتك في حذف جميع الإشعارات؟",
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "تراجع",
                  style: TextStyle(
                    color: Color(0xFF1B5E20),
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "تم حذف جميع الإشعارات بنجاح",
                        style: TextStyle(fontFamily: 'Tajawal'),
                      ),
                      backgroundColor: Color(0xFF1B5E20),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Text(
                  "حذف",
                  style: TextStyle(color: Colors.red, fontFamily: 'Tajawal'),
                ),
              ),
            ],
          ),
    );
  }
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color color;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { morningAdhkar, eveningAdhkar, hadith, ayah, duaa }
