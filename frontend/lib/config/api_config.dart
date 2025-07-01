import 'package:flutter/foundation.dart';

class ApiConfig {
  // 本番環境のAPIエンドポイント（GCPにデプロイ済み）
  static const String _prodBaseUrl = "https://daily-store-app.an.r.appspot.com";

  // ローカル開発環境のAPIエンドポイント
  static const String _devBaseUrl = "http://localhost:8000";

  // 現在の環境に応じてベースURLを返す
  static String get baseUrl {
    // Webプラットフォーム（Firebase Hosting）では本番環境を使用
    if (kIsWeb) {
      // ローカル開発の場合のみlocalhost
      if (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1') {
        return _devBaseUrl;
      }
      // その他のWeb環境（Firebase Hosting等）では本番環境
      return _prodBaseUrl;
    }

    // モバイルアプリの場合はローカル開発環境（開発時）
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
