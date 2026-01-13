import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';

class SpiritualStatsController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final isLoading = true.obs;
  final todayCount = 0.obs;
  final weeklyCount = 0.obs;
  final streakDays = 0.obs;
  final mostActiveHour = '—'.obs;
  final activityBreakdown = <String, int>{}.obs;
  final weeklySeries = <Map<String, dynamic>>[].obs;
  final weeklyAverage = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));
    final monthStart = todayStart.subtract(const Duration(days: 29));

    final logs = await _db.getActivityLogs(
      monthStart.toIso8601String(),
      now.toIso8601String(),
    );
    final summary = await _db.getActivitySummary(
      weekStart.toIso8601String(),
      now.toIso8601String(),
    );

    final dailyTotals = <String, int>{};
    final hourTotals = <int, int>{};
    int todayTotal = 0;
    int weekTotal = 0;

    for (final log in logs) {
      final count = (log['activity_count'] as int?) ?? 0;
      final createdAt = DateTime.parse(log['created_at'] as String);
      final dateKey = DateFormat('yyyy-MM-dd').format(createdAt);
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + count;
      hourTotals[createdAt.hour] = (hourTotals[createdAt.hour] ?? 0) + count;
    }

    final todayKey = DateFormat('yyyy-MM-dd').format(todayStart);
    todayTotal = dailyTotals[todayKey] ?? 0;

    for (int i = 0; i < 7; i++) {
      final date =
          DateFormat('yyyy-MM-dd')
              .format(todayStart.subtract(Duration(days: i)));
      weekTotal += dailyTotals[date] ?? 0;
    }

    final weeklyItems = <Map<String, dynamic>>[];
    for (int i = 6; i >= 0; i--) {
      final day = todayStart.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(day);
      weeklyItems.add({
        'label': DateFormat('EEE', 'ar').format(day),
        'count': dailyTotals[dateKey] ?? 0,
        'date': day,
      });
    }

    weeklySeries.assignAll(weeklyItems);
    weeklyAverage.value = (weekTotal / 7).round();

    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final date =
          DateFormat('yyyy-MM-dd')
              .format(todayStart.subtract(Duration(days: i)));
      if ((dailyTotals[date] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }

    String bestHourLabel = '—';
    if (hourTotals.isNotEmpty) {
      final bestHour =
          hourTotals.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
      bestHourLabel =
          '${bestHour.toString().padLeft(2, '0')}:00 - ${(bestHour + 1).toString().padLeft(2, '0')}:00';
    }

    final breakdownMap = <String, int>{};
    for (final row in summary) {
      final type = row['activity_type'] as String? ?? '';
      final total = row['total_count'] as int? ?? 0;
      breakdownMap[type] = total;
    }

    todayCount.value = todayTotal;
    weeklyCount.value = weekTotal;
    streakDays.value = streak;
    mostActiveHour.value = bestHourLabel;
    activityBreakdown.assignAll(breakdownMap);
    isLoading.value = false;
  }
}
