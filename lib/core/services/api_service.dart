import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rokenalmuslem/linkapi.dart';

class ApiService {
  Future<void> sendDeviceToken({
    required String authToken,
    required String deviceToken,
    String? platform,
  }) async {
    final uri = Uri.parse(AppLink.deviceTokens);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode({
        'token': deviceToken,
        if (platform != null) 'platform': platform,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to register device token');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications({
    required String authToken,
  }) async {
    final uri = Uri.parse('${AppLink.notifications}?include_read=1');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    throw Exception('Failed to fetch notifications');
  }

  Future<void> markNotificationRead({
    required String authToken,
    required int notificationId,
  }) async {
    final uri = Uri.parse(AppLink.notificationRead(notificationId));

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> deleteNotification({
    required String authToken,
    required int notificationId,
  }) async {
    final uri = Uri.parse(AppLink.notificationDelete(notificationId));

    final response = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

  Future<Map<String, dynamic>> fetchAppSettings({
    required String authToken,
  }) async {
    final uri = Uri.parse(AppLink.appSettings);

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    }

    throw Exception('Failed to fetch app settings');
  }

  Future<Map<String, dynamic>> updateAppSettings({
    required String authToken,
    required Map<String, dynamic> payload,
  }) async {
    final uri = Uri.parse(AppLink.appSettings);

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {};
    }

    throw Exception('Failed to update app settings');
  }
}
