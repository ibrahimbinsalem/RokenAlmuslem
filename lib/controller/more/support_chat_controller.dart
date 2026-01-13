import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rokenalmuslem/core/services/api_service.dart';
import 'package:rokenalmuslem/core/services/services.dart';

class SupportMessage {
  final int id;
  final String senderType;
  final String message;
  final DateTime createdAt;
  final String? attachmentUrl;
  final String? attachmentType;
  final String? attachmentName;

  SupportMessage({
    required this.id,
    required this.senderType,
    required this.message,
    required this.createdAt,
    required this.attachmentUrl,
    required this.attachmentType,
    required this.attachmentName,
  });

  factory SupportMessage.fromApi(Map<String, dynamic> json) {
    return SupportMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      senderType: json['sender_type']?.toString() ?? 'user',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      attachmentUrl: json['attachment_url']?.toString(),
      attachmentType: json['attachment_type']?.toString(),
      attachmentName: json['attachment_name']?.toString(),
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
  final selectedAttachment = Rxn<File>();
  final _picker = ImagePicker();
  final selectedCategory = 'general'.obs;
  int? threadId;
  bool readOnly = false;

  final List<Map<String, String>> categories = const [
    {'id': 'general', 'label': 'عام'},
    {'id': 'account', 'label': 'الحساب'},
    {'id': 'technical', 'label': 'تقني'},
    {'id': 'content', 'label': 'المحتوى'},
    {'id': 'suggestion', 'label': 'اقتراحات'},
    {'id': 'other', 'label': 'أخرى'},
  ];

  @override
  void onInit() {
    super.onInit();
    selectedCategory.value = 'general';
    _loadArguments();
    _loadMessages();
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  bool get isLoggedIn => _services.sharedprf.getString('token') != null;

  void _loadArguments() {
    final args = Get.arguments;
    if (args is Map) {
      final rawId = args['thread_id'];
      if (rawId is int) {
        threadId = rawId;
      } else if (rawId is String) {
        threadId = int.tryParse(rawId);
      }
      final rawReadOnly = args['read_only'];
      if (rawReadOnly is bool) {
        readOnly = rawReadOnly;
      } else if (rawReadOnly is String) {
        readOnly = rawReadOnly.toLowerCase() == 'true';
      }
    }
  }

  void applyArguments() {
    final previousThreadId = threadId;
    final previousReadOnly = readOnly;
    _loadArguments();
    if (previousThreadId != threadId || previousReadOnly != readOnly) {
      isLoading.value = true;
      messages.clear();
      _loadMessages();
    }
  }

  Future<void> _loadMessages() async {
    final token = _services.sharedprf.getString('token');
    if (token == null) {
      isLoading.value = false;
      return;
    }

    try {
      final data = await _api.fetchSupportMessages(
        authToken: token,
        threadId: threadId,
      );
      messages.assignAll(
        data.map((item) => SupportMessage.fromApi(item)).toList(),
      );
      if (messages.isNotEmpty && threadId == null) {
        final last = messages.last.createdAt;
        _services.sharedprf.setString(
          'support_last_seen_at',
          last.toIso8601String(),
        );
      }
    } catch (_) {
      // ignore
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAttachment() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) {
      return;
    }
    selectedAttachment.value = File(image.path);
  }

  void clearAttachment() {
    selectedAttachment.value = null;
  }

  Future<void> sendMessage() async {
    if (readOnly) {
      Get.snackbar('تنبيه', 'هذه المحادثة مؤرشفة للعرض فقط');
      return;
    }
    final token = _services.sharedprf.getString('token');
    if (token == null) {
      Get.snackbar('تنبيه', 'يرجى تسجيل الدخول أولاً');
      return;
    }
    final text = inputController.text.trim();
    if (text.isEmpty && selectedAttachment.value == null) {
      return;
    }

    isSending.value = true;
    try {
      await _api.sendSupportMessage(
        authToken: token,
        message: text,
        attachment: selectedAttachment.value,
        category: selectedCategory.value,
      );
      inputController.clear();
      clearAttachment();
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
