class ApiConfig {
  // 本番環境のAPIエンドポイント（GCPにデプロイ済み）
  static const String _prodBaseUrl = "https://daily-store-app.an.r.appspot.com";

  // ローカル開発環境のAPIエンドポイント
  static const String _devBaseUrl = "http://localhost:8000";

  // 現在の環境に応じてベースURLを返す
  static String get baseUrl {
    // URLにlocalhost が含まれていない場合は本番環境と判断
    if (Uri.base.host != 'localhost' && Uri.base.host != '127.0.0.1') {
      return _prodBaseUrl;
    }

    return _devBaseUrl;
  }

  // APIエンドポイント
  static String get apiUrl => "$baseUrl/api/v1";

  // 認証エンドポイント
  static String get authUrl => "$apiUrl/auth";
  static String get itemsUrl => "$apiUrl/items";
  static String get consumptionUrl => "$apiUrl/consumption";
  static String get recommendationsUrl => "$apiUrl/recommendations";
}
