import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/services.dart';

class SupportThreadSummary {
  final int id;
  final String status;
  final String category;
  final DateTime? lastMessageAt;
  final String lastMessagePreview;
  final String lastSenderType;
  final DateTime? updatedAt;

  SupportThreadSummary({
    required this.id,
    required this.status,
    required this.category,
    required this.lastMessageAt,
    required this.lastMessagePreview,
    required this.lastSenderType,
    required this.updatedAt,
  });

  factory SupportThreadSummary.fromApi(Map<String, dynamic> json) {
    return SupportThreadSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'open',
      category: json['category']?.toString() ?? 'general',
      lastMessageAt: DateTime.tryParse(
        json['last_message_at']?.toString() ?? '',
      ),
      lastMessagePreview: json['last_message_preview']?.toString() ?? '',
      lastSenderType: json['last_sender_type']?.toString() ?? '',
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

class HelpCenterController extends GetxController {
  final ApiService _api = ApiService();
  final MyServices _services = Get.find<MyServices>();

  final isLoading = true.obs;
  final thread = Rxn<SupportThreadSummary>();
  final supportRating = Rxn<SupportRatingSummary>();
  final archivedThreads = <SupportThreadSummary>[].obs;
  final ratingValue = 0.obs;
  final isSubmittingRating = false.obs;
  final isClosingThread = false.obs;
  final ratingCommentController = TextEditingController();

  bool get isLoggedIn => _services.sharedprf.getString('token') != null;

  final faqItems = <FaqItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFaqCache();
    loadThread();
    loadArchivedThreads();
  }

  @override
  void onClose() {
    ratingCommentController.dispose();
    super.onClose();
  }

  Future<void> loadThread() async {
    if (!isLoggedIn) {
      isLoading.value = false;
      thread.value = null;
      archivedThreads.clear();
      return;
    }

    final token = _services.sharedprf.getString('token');
    if (token == null) {
      isLoading.value = false;
      thread.value = null;
      archivedThreads.clear();
      return;
    }

    isLoading.value = true;
    try {
      final data = await _api.fetchSupportThread(authToken: token);
      if (data == null) {
        thread.value = null;
        supportRating.value = null;
      } else {
        thread.value = SupportThreadSummary.fromApi(data);
        _markThreadSeen(thread.value?.lastMessageAt);
        await _loadRating(token, thread.value?.id);
      }
    } catch (_) {
      thread.value = null;
      supportRating.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadRating(String token, int? threadId) async {
    try {
      final data = await _api.fetchSupportRating(
        authToken: token,
        threadId: threadId,
      );
      if (data == null) {
        supportRating.value = null;
        ratingValue.value = 0;
        ratingCommentController.text = '';
        return;
      }
      supportRating.value = SupportRatingSummary.fromApi(data);
      ratingValue.value = supportRating.value?.rating ?? 0;
      ratingCommentController.text =
          supportRating.value?.comment ?? '';
    } catch (_) {
      supportRating.value = null;
    }
  }

  Future<void> _loadFaqCache() async {
    final prefs = _services.sharedprf;
    final cached = prefs.getString('support_faq_cache');
    final cachedAt = prefs.getInt('support_faq_cache_at') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final isFresh = now - cachedAt < 1000 * 60 * 60 * 12;

    if (cached != null && cached.isNotEmpty) {
      try {
        final decoded = jsonDecode(cached) as List<dynamic>;
        final items = decoded
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => FaqItem(
                question: item['question']?.toString() ?? '',
                answer: item['answer']?.toString() ?? '',
              ),
            )
            .where((item) => item.question.isNotEmpty)
            .toList();
        if (items.isNotEmpty) {
          faqItems.assignAll(items);
        }
      } catch (_) {}
    }

    if (!isFresh || faqItems.isEmpty) {
      await refreshFaqs();
    }
  }

  Future<void> refreshFaqs() async {
    try {
      final data = await _api.fetchSupportFaqs();
      if (data.isEmpty) return;
      final items = data
          .map(
            (item) => FaqItem(
              question: item['question']?.toString() ?? '',
              answer: item['answer']?.toString() ?? '',
            ),
          )
          .where((item) => item.question.isNotEmpty)
          .toList();
      if (items.isNotEmpty) {
        faqItems.assignAll(items);
        _services.sharedprf.setString(
          'support_faq_cache',
          jsonEncode(
            items
                .map(
                  (item) => {
                    'question': item.question,
                    'answer': item.answer,
                  },
                )
                .toList(),
          ),
        );
        _services.sharedprf.setInt(
          'support_faq_cache_at',
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (_) {}
  }

  Future<void> refreshData() async {
    await Future.wait([loadThread(), refreshFaqs(), loadArchivedThreads()]);
  }

  void _markThreadSeen(DateTime? lastMessageAt) {
    if (lastMessageAt == null) return;
    _services.sharedprf.setString(
      'support_last_seen_at',
      lastMessageAt.toIso8601String(),
    );
  }

  Future<void> submitRating() async {
    if (!isLoggedIn) {
      Get.snackbar('تنبيه', 'يرجى تسجيل الدخول أولاً');
      return;
    }
    if (ratingValue.value <= 0) {
      Get.snackbar('تنبيه', 'يرجى اختيار التقييم');
      return;
    }
    final token = _services.sharedprf.getString('token');
    if (token == null) return;

    isSubmittingRating.value = true;
    try {
      await _api.submitSupportRating(
        authToken: token,
        rating: ratingValue.value,
        comment: ratingCommentController.text.trim(),
        threadId: thread.value?.id,
      );
      await _loadRating(token, thread.value?.id);
      Get.snackbar('شكراً لك', 'تم إرسال تقييم الدعم بنجاح');
    } catch (_) {
      Get.snackbar('خطأ', 'تعذر إرسال التقييم');
    } finally {
      isSubmittingRating.value = false;
    }
  }

  Future<void> closeThread() async {
    if (!isLoggedIn) {
      Get.snackbar('تنبيه', 'يرجى تسجيل الدخول أولاً');
      return;
    }

    final currentThread = thread.value;
    if (currentThread == null || currentThread.status == 'closed') {
      return;
    }

    final token = _services.sharedprf.getString('token');
    if (token == null) return;

    isClosingThread.value = true;
    try {
      final data = await _api.closeSupportThread(
        authToken: token,
        threadId: currentThread.id,
      );
      if (data != null) {
        thread.value = SupportThreadSummary.fromApi(data);
      } else {
        thread.value = SupportThreadSummary(
          id: currentThread.id,
          status: 'closed',
          category: currentThread.category,
          lastMessageAt: currentThread.lastMessageAt,
          lastMessagePreview: currentThread.lastMessagePreview,
          lastSenderType: currentThread.lastSenderType,
          updatedAt: DateTime.now(),
        );
      }
      await _loadRating(token, thread.value?.id);
      await loadArchivedThreads();
      Get.snackbar('تم الإغلاق', 'يمكنك الآن تقييم تجربة الدعم.');
    } catch (_) {
      Get.snackbar('خطأ', 'تعذر إغلاق المحادثة');
    } finally {
      isClosingThread.value = false;
    }
  }

  Future<void> loadArchivedThreads() async {
    if (!isLoggedIn) {
      archivedThreads.clear();
      return;
    }
    final token = _services.sharedprf.getString('token');
    if (token == null) {
      archivedThreads.clear();
      return;
    }

    try {
      final data = await _api.fetchSupportThreads(
        authToken: token,
        status: 'closed',
      );
      archivedThreads.assignAll(
        data.map((item) => SupportThreadSummary.fromApi(item)).toList(),
      );
    } catch (_) {
      archivedThreads.clear();
    }
  }
}

class SupportRatingSummary {
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  SupportRatingSummary({
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory SupportRatingSummary.fromApi(Map<String, dynamic> json) {
    return SupportRatingSummary(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
