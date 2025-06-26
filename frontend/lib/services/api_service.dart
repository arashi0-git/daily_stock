import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/daily_item.dart';
import '../models/consumption_record.dart';
import '../models/consumption_recommendation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // インターセプターを追加してトークンを自動で追加
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // 認証エラーの場合、トークンを削除
          await clearToken();
        }
        handler.next(error);
      },
    ));
  }

  // トークンを保存
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // トークンを取得
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // トークンを削除
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // GETリクエスト
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POSTリクエスト
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUTリクエスト
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETEリクエスト
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // エラーハンドリング
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('接続がタイムアウトしました');
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return Exception('認証に失敗しました');
        } else if (error.response?.statusCode == 404) {
          return Exception('リソースが見つかりません');
        } else if ((error.response?.statusCode ?? 0) >= 500) {
          return Exception('サーバーエラーが発生しました');
        } else {
          final message = error.response?.data['detail'] ?? 'エラーが発生しました';
          return Exception(message);
        }
      case DioExceptionType.cancel:
        return Exception('リクエストがキャンセルされました');
      case DioExceptionType.connectionError:
        return Exception('インターネット接続を確認してください');
      default:
        return Exception('予期しないエラーが発生しました');
    }
  }

  // ===== ITEMS API =====
  Future<List<DailyItem>> getItems() async {
    try {
      final response = await get('/items');
      final List<dynamic> data = response.data;
      return data.map((json) => DailyItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('商品の取得に失敗しました: $e');
    }
  }

  Future<DailyItem> createItem(DailyItemCreate item) async {
    try {
      final response = await post('/items', data: item.toJson());
      return DailyItem.fromJson(response.data);
    } catch (e) {
      throw Exception('商品の作成に失敗しました: $e');
    }
  }

  Future<DailyItem> updateItem(int itemId, DailyItemUpdate itemUpdate) async {
    try {
      final response = await put('/items/$itemId', data: itemUpdate.toJson());
      return DailyItem.fromJson(response.data);
    } catch (e) {
      throw Exception('商品の更新に失敗しました: $e');
    }
  }

  Future<void> deleteItem(int itemId) async {
    try {
      await delete('/items/$itemId');
    } catch (e) {
      throw Exception('商品の削除に失敗しました: $e');
    }
  }

  // ===== CONSUMPTION API =====
  Future<List<ConsumptionRecord>> getConsumptionRecords() async {
    try {
      final response = await get('/consumption');
      final List<dynamic> data = response.data;
      return data.map((json) => ConsumptionRecord.fromJson(json)).toList();
    } catch (e) {
      throw Exception('消費記録の取得に失敗しました: $e');
    }
  }

  Future<ConsumptionRecord> createConsumptionRecord(ConsumptionRecordCreate record) async {
    try {
      final response = await post('/consumption', data: record.toJson());
      return ConsumptionRecord.fromJson(response.data);
    } catch (e) {
      throw Exception('消費記録の作成に失敗しました: $e');
    }
  }

  Future<ConsumptionRecord> updateConsumptionRecord(int recordId, ConsumptionRecordUpdate recordUpdate) async {
    try {
      final response = await put('/consumption/$recordId', data: recordUpdate.toJson());
      return ConsumptionRecord.fromJson(response.data);
    } catch (e) {
      throw Exception('消費記録の更新に失敗しました: $e');
    }
  }

  Future<void> deleteConsumptionRecord(int recordId) async {
    try {
      await delete('/consumption/$recordId');
    } catch (e) {
      throw Exception('消費記録の削除に失敗しました: $e');
    }
  }

  // ===== RECOMMENDATIONS API =====
  Future<List<ConsumptionRecommendation>> getRecommendations({
    int skip = 0,
    int limit = 100,
    bool activeOnly = true,
    String? urgencyLevel,
  }) async {
    try {
      final queryParams = {
        'skip': skip,
        'limit': limit,
        'active_only': activeOnly,
        if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      };
      
      final response = await get('/recommendations', queryParameters: queryParams);
      final List<dynamic> data = response.data;
      return data.map((json) => ConsumptionRecommendation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('推奨の取得に失敗しました: $e');
    }
  }

  Future<ConsumptionRecommendation> generateItemRecommendation(
    int itemId, {
    int? targetStockLevel,
  }) async {
    try {
      final data = {
        'item_id': itemId,
        if (targetStockLevel != null) 'target_stock_level': targetStockLevel,
      };
      
      final response = await post('/recommendations/generate/$itemId', data: data);
      return ConsumptionRecommendation.fromJson(response.data);
    } catch (e) {
      throw Exception('推奨の生成に失敗しました: $e');
    }
  }

  Future<List<ConsumptionRecommendation>> generateAllRecommendations() async {
    try {
      final response = await post('/recommendations/generate-all');
      final List<dynamic> data = response.data['recommendations'];
      return data.map((json) => ConsumptionRecommendation.fromJson(json)).toList();
    } catch (e) {
      throw Exception('一括推奨の生成に失敗しました: $e');
    }
  }

  Future<RecommendationSummary> getRecommendationSummary() async {
    try {
      final response = await get('/recommendations/summary');
      return RecommendationSummary.fromJson(response.data);
    } catch (e) {
      throw Exception('推奨要約の取得に失敗しました: $e');
    }
  }

  Future<void> acknowledgeRecommendation(int recommendationId) async {
    try {
      await put('/recommendations/$recommendationId/acknowledge');
    } catch (e) {
      throw Exception('推奨の確認に失敗しました: $e');
    }
  }

  Future<void> deactivateRecommendation(int recommendationId) async {
    try {
      await delete('/recommendations/$recommendationId');
    } catch (e) {
      throw Exception('推奨の非アクティブ化に失敗しました: $e');
    }
  }
} 