import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/services.dart';

class AppRatingController extends GetxController {
  final ApiService _api = ApiService();
  final MyServices _services = Get.find<MyServices>();

  final rating = 0.obs;
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final hasRating = false.obs;
  final commentController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadRating();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  bool get isLoggedIn => _services.sharedprf.getString('token') != null;

  Future<void> _loadRating() async {
    final token = _services.sharedprf.getString('token');
    if (token == null) {
      isLoading.value = false;
      return;
    }

    try {
      final data = await _api.fetchAppRating(authToken: token);
      if (data != null) {
        rating.value = (data['rating'] as num?)?.toInt() ?? 0;
        commentController.text = data['comment']?.toString() ?? '';
        hasRating.value = rating.value > 0;
      }
    } catch (_) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRating() async {
    if (!isLoggedIn) {
      Get.snackbar('تنبيه', 'يرجى تسجيل الدخول أولاً');
      return;
    }

    if (rating.value < 1) {
      Get.snackbar('تنبيه', 'يرجى اختيار التقييم');
      return;
    }

    final token = _services.sharedprf.getString('token');
    if (token == null) return;

    isSubmitting.value = true;
    try {
      await _api.submitAppRating(
        authToken: token,
        rating: rating.value,
        comment: commentController.text.trim(),
      );
      hasRating.value = true;
      Get.snackbar('شكراً لك', 'تم إرسال تقييمك بنجاح');
    } catch (_) {
      Get.snackbar('خطأ', 'تعذر إرسال التقييم');
    } finally {
      isSubmitting.value = false;
    }
  }
}
