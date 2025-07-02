class ApiConfig {
  // 環境変数からAPIベースURLを取得、デフォルトは本番環境
  static const String _defaultBaseUrl =
      "https://daily-store-app.an.r.appspot.com";

  // テスト環境用のベースURL
  static const String _testBaseUrl = "http://localhost:8000";

  // 環境変数API_BASE_URLがあればそれを使用、なければデフォルト値を使用
  static String get baseUrl {
    const apiBaseUrl =
        String.fromEnvironment('API_BASE_URL', defaultValue: _defaultBaseUrl);

    // テスト環境の判定（環境変数またはデバッグモードで判定）
    const isTest = String.fromEnvironment('ENVIRONMENT') == 'test';
    const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;

    // テスト環境またはローカル開発時
    if (isTest || (kDebugMode && apiBaseUrl == _defaultBaseUrl)) {
      return apiBaseUrl != _defaultBaseUrl ? apiBaseUrl : _testBaseUrl;
    }

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
    print(
        'Environment: ${String.fromEnvironment('ENVIRONMENT', defaultValue: 'production')}');
    print('========================');
  }
}
