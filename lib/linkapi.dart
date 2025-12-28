class AppLink {
  static const String baseUrl = "http://197.167.67.165:8000";
  static const String apiBase = "$baseUrl/api";

  // ============== Auth ==================
  static const String signUp = "$apiBase/auth/register";
  static const String login = "$apiBase/auth/login";
  static const String me = "$apiBase/auth/me";

  // ============== Stories ==================
  static const String stories = "$apiBase/stories";
  static const String prophetStories = "$apiBase/prophet-stories";

  // ============== App Updates ==================
  static const String appVersion = "$apiBase/app-version";
  static const String appVersionCheck = "$apiBase/app-version/check";

  // ============== Device Tokens ==================
  static const String deviceTokens = "$apiBase/device-tokens";

  // ============== Notifications ==================
  static const String notifications = "$apiBase/notifications";
  static String notificationRead(int id) => "$apiBase/notifications/$id/read";
  static String notificationDelete(int id) => "$apiBase/notifications/$id";

  // ============== App Settings ==================
  static const String appSettings = "$apiBase/app-settings";
}
