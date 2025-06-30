class ApiConfig {
  // 本番環境のAPIエンドポイント（Railwayにデプロイ後に更新）
  static const String _prodBaseUrl = "https://your-app-name.up.railway.app";

  // ローカル開発環境のAPIエンドポイント
  static const String _devBaseUrl = "http://localhost:8000";

  // 現在の環境に応じてベースURLを返す
  static String get baseUrl {
    // Web環境では本番URLを使用
    const String.fromEnvironment('FLUTTER_ENV') == 'production'
        ? _prodBaseUrl
        : _devBaseUrl;

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
