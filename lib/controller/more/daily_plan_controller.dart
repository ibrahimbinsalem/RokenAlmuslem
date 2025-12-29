import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rokenalmuslem/core/constant/routes.dart';

class DailyPlanTask {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String route;

  const DailyPlanTask({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
  });
}

class DailyPlanController extends GetxController {
  final tasks = <DailyPlanTask>[
    const DailyPlanTask(
      id: 'morning_adhkar',
      title: 'أذكار الصباح',
      description: 'ابدأ يومك بذكر الله',
      icon: Icons.wb_sunny_outlined,
      route: AppRoute.alsbah,
    ),
    const DailyPlanTask(
      id: 'evening_adhkar',
      title: 'أذكار المساء',
      description: 'حصّن نفسك بذكر الله',
      icon: Icons.nights_stay_outlined,
      route: AppRoute.almsa,
    ),
    const DailyPlanTask(
      id: 'quran_reading',
      title: 'ورد القرآن',
      description: 'اقرأ ما تيسّر من القرآن',
      icon: Icons.menu_book,
      route: AppRoute.quran,
    ),
    const DailyPlanTask(
      id: 'quran_plan',
      title: 'خطة الختم',
      description: 'تابع خطة ختمك اليومية',
      icon: Icons.auto_stories_outlined,
      route: AppRoute.quranPlan,
    ),
    const DailyPlanTask(
      id: 'tasbeeh',
      title: 'التسبيح',
      description: 'خصص وقتًا للتسبيح',
      icon: Icons.fingerprint_outlined,
      route: AppRoute.msbaha,
    ),
  ];

  final completion = <String, bool>{}.obs;
  final isLoading = true.obs;
  late SharedPreferences _prefs;

  static const String _historyKey = 'daily_plan_history';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  String _todayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final history = _loadHistory();
    final todayKey = _todayKey();
    final dayData =
        Map<String, dynamic>.from(history[todayKey] as Map? ?? {});
    completion.assignAll(
      dayData.map((key, value) => MapEntry(key, value == true)),
    );
    isLoading.value = false;
  }

  Map<String, dynamic> _loadHistory() {
    final raw = _prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveHistory(Map<String, dynamic> history) async {
    await _prefs.setString(_historyKey, jsonEncode(history));
  }

  void toggleTask(String taskId) {
    completion[taskId] = !(completion[taskId] ?? false);
    _persistToday();
  }

  void resetToday() {
    completion.clear();
    _persistToday();
  }

  void _persistToday() {
    final history = _loadHistory();
    final todayKey = _todayKey();
    history[todayKey] = completion;
    _saveHistory(history);
  }

  double get progress {
    if (tasks.isEmpty) return 0;
    final done = tasks.where((t) => completion[t.id] == true).length;
    return done / tasks.length;
  }

  int get completedCount {
    return tasks.where((t) => completion[t.id] == true).length;
  }
}
