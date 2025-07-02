class ApiConfig {
  // 環境変数からAPIベースURLを取得、デフォルトは本番環境
  static const String _defaultBaseUrl =
      "https://daily-store-app.an.r.appspot.com";

  // 環境変数API_BASE_URLがあればそれを使用、なければデフォルト値を使用
  static String get baseUrl {
    const apiBaseUrl =
        String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);
    return apiBaseUrl;
  }

  // APIエンドポイント
  static String get apiUrl => "$baseUrl/api/v1";

  // 認証エンドポイント
  static String get authUrl => "$apiUrl/auth";
  static String get itemsUrl => "$apiUrl/items";
  static String get consumptionUrl => "$apiUrl/consumption";
  static String get recommendationsUrl => "$apiUrl/recommendations";

  // デバッグ用：現在の設定を確認
  static void printConfig() {
    print('=== API Configuration ===');
    print('Base URL: $baseUrl');
    print('API URL: $apiUrl');
    print('Auth URL: $authUrl');
    print('========================');
  }
}
