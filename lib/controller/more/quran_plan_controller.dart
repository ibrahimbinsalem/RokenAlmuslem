import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rokenalmuslem/data/database/database_helper.dart';

class QuranPlanController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final isLoading = true.obs;
  final targetDays = 30.obs;
  final pagesPerDay = 20.obs;
  final weeklyGoalPages = 140.obs;
  final totalPages = 604.obs;
  final completedPages = 0.obs;
  final todayPages = 0.obs;
  final weeklyPages = 0.obs;
  final startDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlan();
  }

  Future<void> loadPlan() async {
    isLoading.value = true;
    final plan = await _db.getQuranKhatmPlan();
    if (plan == null) {
      final now = DateTime.now();
      final dateString = DateFormat('yyyy-MM-dd').format(now);
      await _db.upsertQuranKhatmPlan({
        'start_date': dateString,
        'target_days': targetDays.value,
        'pages_per_day': pagesPerDay.value,
        'weekly_goal_pages': weeklyGoalPages.value,
        'total_pages': totalPages.value,
        'completed_pages': completedPages.value,
        'last_updated': dateString,
      });
      startDate.value = dateString;
    } else {
      startDate.value = plan['start_date']?.toString() ?? '';
      targetDays.value = plan['target_days'] as int;
      pagesPerDay.value = plan['pages_per_day'] as int;
      weeklyGoalPages.value = plan['weekly_goal_pages'] as int;
      totalPages.value = plan['total_pages'] as int;
      completedPages.value = plan['completed_pages'] as int;
    }
    await _loadLogs();
    isLoading.value = false;
  }

  Future<void> _loadLogs() async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final weekStart = DateFormat('yyyy-MM-dd')
        .format(now.subtract(const Duration(days: 6)));
    final logs = await _db.getQuranKhatmLogs(weekStart, today);

    int todayValue = 0;
    int weeklyValue = 0;
    for (final log in logs) {
      final date = log['log_date'] as String;
      final pages = log['pages_read'] as int;
      weeklyValue += pages;
      if (date == today) {
        todayValue = pages;
      }
    }
    todayPages.value = todayValue;
    weeklyPages.value = weeklyValue;
  }

  Future<void> addPages(int pages) async {
    if (pages <= 0) return;
    final now = DateTime.now();
    final dateString = DateFormat('yyyy-MM-dd').format(now);
    await _db.logQuranKhatmPages(dateString, pages);
    await _db.logSpiritualActivity('quran', count: pages);
    completedPages.value =
        (completedPages.value + pages).clamp(0, totalPages.value);
    await _db.upsertQuranKhatmPlan({
      'start_date': startDate.value,
      'target_days': targetDays.value,
      'pages_per_day': pagesPerDay.value,
      'weekly_goal_pages': weeklyGoalPages.value,
      'total_pages': totalPages.value,
      'completed_pages': completedPages.value,
      'last_updated': dateString,
    });
    await _loadLogs();
  }

  Future<void> updatePlanSettings({
    required int newTargetDays,
    required int newPagesPerDay,
    required int newWeeklyGoal,
  }) async {
    targetDays.value = newTargetDays;
    pagesPerDay.value = newPagesPerDay;
    weeklyGoalPages.value = newWeeklyGoal;
    await _db.upsertQuranKhatmPlan({
      'start_date': startDate.value,
      'target_days': targetDays.value,
      'pages_per_day': pagesPerDay.value,
      'weekly_goal_pages': weeklyGoalPages.value,
      'total_pages': totalPages.value,
      'completed_pages': completedPages.value,
      'last_updated': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    });
  }

  Future<void> resetPlan() async {
    final dateString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    completedPages.value = 0;
    todayPages.value = 0;
    weeklyPages.value = 0;
    startDate.value = dateString;
    await _db.upsertQuranKhatmPlan({
      'start_date': startDate.value,
      'target_days': targetDays.value,
      'pages_per_day': pagesPerDay.value,
      'weekly_goal_pages': weeklyGoalPages.value,
      'total_pages': totalPages.value,
      'completed_pages': 0,
      'last_updated': dateString,
    });
  }
}
