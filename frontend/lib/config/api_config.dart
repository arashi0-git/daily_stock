import 'package:flutter/foundation.dart';

class ApiConfig {
  // 本番環境のAPIエンドポイント（GCPにデプロイ済み）
  static const String _prodBaseUrl = "https://daily-store-app.an.r.appspot.com";

  // ローカル開発環境のAPIエンドポイント
  static const String _devBaseUrl = "http://localhost:8000";

  // 現在の環境に応じてベースURLを返す
  static String get baseUrl {
    // Webプラットフォームでは常に本番環境を使用（Firebase Hosting用）
    if (kIsWeb) {
      if (kDebugMode) {
        print('Current host: ${Uri.base.host}');
        print('Using production URL: $_prodBaseUrl');
      }
      return _prodBaseUrl;
    }

    // モバイルアプリの場合はローカル開発環境
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
