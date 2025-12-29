import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/services.dart';

class AppSuggestionController extends GetxController {
  final ApiService _api = ApiService();
  final MyServices _services = Get.find<MyServices>();

  final titleController = TextEditingController();
  final messageController = TextEditingController();
  final isSubmitting = false.obs;

  bool get isLoggedIn => _services.sharedprf.getString('token') != null;

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> submitSuggestion() async {
    if (!isLoggedIn) {
      Get.snackbar('تنبيه', 'يرجى تسجيل الدخول أولاً');
      return;
    }

    final title = titleController.text.trim();
    final message = messageController.text.trim();
    if (title.isEmpty || message.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة العنوان والرسالة');
      return;
    }

    final token = _services.sharedprf.getString('token');
    if (token == null) return;

    isSubmitting.value = true;
    try {
      await _api.submitSuggestion(
        authToken: token,
        title: title,
        message: message,
      );
      titleController.clear();
      messageController.clear();
      Get.snackbar('شكراً لك', 'تم إرسال الاقتراح بنجاح');
    } catch (_) {
      Get.snackbar('خطأ', 'تعذر إرسال الاقتراح');
    } finally {
      isSubmitting.value = false;
    }
  }
}
