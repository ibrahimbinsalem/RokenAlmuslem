import 'dart:convert';
import 'dart:io';
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

  Future<Map<String, dynamic>?> fetchAppRating({
    required String authToken,
  }) async {
    final uri = Uri.parse(AppLink.ratingMe);

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
      return null;
    }

    throw Exception('Failed to fetch rating');
  }

  Future<void> submitAppRating({
    required String authToken,
    required int rating,
    String? comment,
  }) async {
    final uri = Uri.parse(AppLink.ratings);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode({
        'rating': rating,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit rating');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSupportMessages({
    required String authToken,
    int? threadId,
  }) async {
    final uri = Uri.parse(AppLink.supportMessages).replace(
      queryParameters: {
        if (threadId != null) 'thread_id': threadId.toString(),
      },
    );

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

    throw Exception('Failed to fetch support messages');
  }

  Future<List<Map<String, dynamic>>> fetchSupportFaqs() async {
    final uri = Uri.parse(AppLink.supportFaq);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    }

    throw Exception('Failed to fetch support FAQs');
  }

  Future<Map<String, dynamic>?> fetchSupportThread({
    required String authToken,
  }) async {
    final uri = Uri.parse(AppLink.supportThread);

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
      return null;
    }

    throw Exception('Failed to fetch support thread');
  }

  Future<List<Map<String, dynamic>>> fetchSupportThreads({
    required String authToken,
    String? status,
  }) async {
    final uri = Uri.parse(AppLink.supportThreads).replace(
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
      },
    );

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

    throw Exception('Failed to fetch support threads');
  }

  Future<Map<String, dynamic>?> closeSupportThread({
    required String authToken,
    int? threadId,
  }) async {
    final uri = Uri.parse(AppLink.supportThreadClose);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: threadId == null
          ? null
          : json.encode({'thread_id': threadId}),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return null;
    }

    throw Exception('Failed to close support thread');
  }

  Future<void> sendSupportMessage({
    required String authToken,
    required String message,
    File? attachment,
    String? category,
  }) async {
    final uri = Uri.parse(AppLink.supportMessages);

    if (attachment == null) {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'message': message,
          if (category != null) 'category': category,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send support message');
      }
      return;
    }

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $authToken';
    if (message.trim().isNotEmpty) {
      request.fields['message'] = message.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      request.fields['category'] = category.trim();
    }
    request.files.add(
      await http.MultipartFile.fromPath('attachment', attachment.path),
    );

    final streamed = await request.send();
    if (streamed.statusCode != 200 && streamed.statusCode != 201) {
      throw Exception('Failed to send support message');
    }
  }

  Future<Map<String, dynamic>?> fetchSupportRating({
    required String authToken,
    int? threadId,
  }) async {
    final uri = Uri.parse(AppLink.supportRating).replace(
      queryParameters: {
        if (threadId != null) 'thread_id': threadId.toString(),
      },
    );

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
      return null;
    }

    throw Exception('Failed to fetch support rating');
  }

  Future<void> submitSupportRating({
    required String authToken,
    required int rating,
    String? comment,
    int? threadId,
  }) async {
    final uri = Uri.parse(AppLink.supportRating);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode({
        'rating': rating,
        if (threadId != null) 'thread_id': threadId,
        if (comment != null && comment.trim().isNotEmpty)
          'comment': comment.trim(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit support rating');
    }
  }

  Future<void> submitSuggestion({
    required String authToken,
    required String title,
    required String message,
  }) async {
    final uri = Uri.parse(AppLink.suggestions);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: json.encode({
        'title': title,
        'message': message,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit suggestion');
    }
  }
}
