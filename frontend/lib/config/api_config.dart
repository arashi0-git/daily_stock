class ApiConfig {
  // 環境に応じたAPIエンドポイント
  static String get baseUrl {
    // Docker環境で動作している場合のローカルURL
    // Dockerコンテナ間通信の場合は service名:port を使用
    const dockerUrl = "http://backend:8000";
    
    // 本番環境のURL
    const productionUrl = "https://daily-store-app.an.r.appspot.com";
    
    // ローカル開発環境のURL
    const localUrl = "http://localhost:8000";
    
    // プラットフォームや環境変数で判定
    // 現在はローカル開発環境用のURLを使用
    return localUrl;
  }

  // APIエンドポイント
  static String get apiUrl => "$baseUrl/api/v1";

  // 認証エンドポイント
  static String get authUrl => "$apiUrl/auth";
  static String get itemsUrl => "$apiUrl/items";
  static String get consumptionUrl => "$apiUrl/consumption";
  static String get recommendationsUrl => "$apiUrl/recommendations";
}