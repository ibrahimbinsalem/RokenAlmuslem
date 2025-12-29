import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/services.dart';

class SupportMessage {
  final int id;
  final String senderType;
  final String message;
  final DateTime createdAt;

  SupportMessage({
    required this.id,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  factory SupportMessage.fromApi(Map<String, dynamic> json) {
    return SupportMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      senderType: json['sender_type']?.toString() ?? 'user',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class SupportChatController extends GetxController {
  final ApiService _api = ApiService();
  final MyServices _services = Get.find<MyServices>();

  final messages = <SupportMessage>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;
  final inputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  bool get isLoggedIn => _services.sharedprf.getString('token') != null;

  Future<void> _loadMessages() async {
    final token = _services.sharedprf.getString('token');
    if (token == null) {
      isLoading.value = false;
      return;
    }

    try {
      final data = await _api.fetchSupportMessages(authToken: token);
      messages.assignAll(
        data.map((item) => SupportMessage.fromApi(item)).toList(),
      );
    } catch (_) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final token = _services.sharedprf.getString('token');
    if (token == null) {
      Get.snackbar('تنبيه', 'يرجى تسجيل الدخول أولاً');
      return;
    }
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    isSending.value = true;
    try {
      await _api.sendSupportMessage(authToken: token, message: text);
      inputController.clear();
      await _loadMessages();
    } catch (_) {
      Get.snackbar('خطأ', 'تعذر إرسال الرسالة');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> refreshMessages() async {
    await _loadMessages();
  }
}
