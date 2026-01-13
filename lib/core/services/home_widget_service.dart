import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetService extends GetxService {
  static const String androidProvider = 'PrayerWidgetProvider';
  static const String iOSProvider = 'PrayerWidgetProvider';

  static const String keyPrayerName = 'widget_prayer_name';
  static const String keyPrayerTime = 'widget_prayer_time';
  static const String keyPrayerSubtitle = 'widget_prayer_subtitle';
  static const String keyUpdatedAt = 'widget_updated_at';

  Future<void> updatePrayerWidget({
    required String prayerName,
    required String prayerTime,
    required String subtitle,
  }) async {
    await HomeWidget.saveWidgetData(keyPrayerName, prayerName);
    await HomeWidget.saveWidgetData(keyPrayerTime, prayerTime);
    await HomeWidget.saveWidgetData(keyPrayerSubtitle, subtitle);
    await HomeWidget.saveWidgetData(
      keyUpdatedAt,
      DateTime.now().toIso8601String(),
    );

    await HomeWidget.updateWidget(
      name: androidProvider,
      iOSName: iOSProvider,
    );
  }
}
