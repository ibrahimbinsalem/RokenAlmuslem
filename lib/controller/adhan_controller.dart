import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/view/screen/praytime/adhan_alert.dart';

class AdhanController extends GetxService with WidgetsBindingObserver {
  static const String _handledPrayerKey = 'handled_prayer_notification_key';
  final AudioPlayer _player = AudioPlayer();
  final isPlaying = false.obs;
  final currentPrayerName = ''.obs;
  final lastNotificationId = RxnInt();
  final GetStorage _box = GetStorage();
  String? _pendingHandledKey;

  StreamSubscription<String>? _actionSub;
  StreamSubscription<NotificationResponse>? _notificationSub;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _player.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });

    final notificationService = Get.find<NotificationService>();
    _actionSub =
        notificationService.actionStream.listen(_handleNotificationAction);
    _notificationSub =
        notificationService.notificationStream.listen(_handleNotificationTap);

    final launchPayload = notificationService.lastLaunchPayload;
    if (launchPayload != null && launchPayload.isNotEmpty) {
      _handlePayload(launchPayload);
      notificationService.clearLaunchPayload();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _actionSub?.cancel();
    _notificationSub?.cancel();
    _player.dispose();
    super.onClose();
  }

  Future<void> playAdhan() async {
    await _player.stop();
    await _player.play(AssetSource('voice/adhan.mp3'));
  }

  Future<void> stopAdhan() async {
    await _player.stop();
    isPlaying.value = false;
  }

  void _handleNotificationAction(String actionId) {
    if (actionId == 'adhan_stop') {
      stopAdhan();
      final notificationId = lastNotificationId.value;
      if (notificationId != null) {
        Get.find<NotificationService>().cancelNotification(notificationId);
      }
      _markHandled();
      Get.snackbar('الأذان', 'تم إيقاف الأذان');
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    _handlePayload(payload);
  }

  void _handlePayload(String payload) {
    try {
      final data = jsonDecode(payload);
      if (data is! Map) return;
      final type = data['type']?.toString();
      if (type != 'prayer') return;
      final scheduledTime = data['scheduledTime']?.toString() ?? '';
      final notificationIdRaw = data['notificationId'];
      final notificationId =
          notificationIdRaw is int
              ? notificationIdRaw
              : int.tryParse('$notificationIdRaw');
      final handledKey = _buildHandledKey(notificationId, scheduledTime);
      if (handledKey != null && _isHandled(handledKey)) {
        Get.find<NotificationService>().clearLaunchPayload();
        return;
      }
      final prayerName = data['prayerName']?.toString() ?? '';
      currentPrayerName.value = prayerName;
      lastNotificationId.value = notificationId;
      _pendingHandledKey = handledKey;
      stopAdhan();
      if (notificationId != null) {
        Get.find<NotificationService>().cancelNotification(notificationId);
      }
      Get.find<NotificationService>().clearLaunchPayload();
      _showAdhanAlert(prayerName);
    } catch (_) {
      // ignore invalid payloads
    }
  }

  bool _isHandled(String handledKey) {
    return _box.read(_handledPrayerKey) == handledKey;
  }

  String? _buildHandledKey(int? notificationId, String scheduledTime) {
    if (notificationId == null || scheduledTime.isEmpty) {
      return null;
    }
    return '$notificationId|$scheduledTime';
  }

  void _markHandled() {
    final key = _pendingHandledKey;
    if (key == null) return;
    _box.write(_handledPrayerKey, key);
    _pendingHandledKey = null;
  }

  void _showAdhanAlert(String prayerName) {
    if (prayerName.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.dialog(
        AdhanAlertDialog(
          prayerName: prayerName,
          onStop: () {
            stopAdhan();
            final notificationId = lastNotificationId.value;
            if (notificationId != null) {
              Get.find<NotificationService>().cancelNotification(
                    notificationId,
                  );
            }
            _markHandled();
          },
          onClose: () {
            _markHandled();
          },
        ),
        barrierDismissible: false,
      );
    });
  }
}
