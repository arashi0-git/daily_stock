class ApiConfig {
  // 本番環境のAPIエンドポイント（Web用：固定）
  static const String baseUrl = "https://daily-store-app.an.r.appspot.com";

  // APIエンドポイント
  static String get apiUrl => "$baseUrl/api/v1";

  // 認証エンドポイント
  static String get authUrl => "$apiUrl/auth";
  static String get itemsUrl => "$apiUrl/items";
  static String get consumptionUrl => "$apiUrl/consumption";
  static String get recommendationsUrl => "$apiUrl/recommendations";
}
