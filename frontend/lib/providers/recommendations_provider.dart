import 'package:flutter/foundation.dart';
import '../models/consumption_recommendation.dart';
import '../services/api_service.dart';

class RecommendationsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ConsumptionRecommendation> _recommendations = [];
  RecommendationSummary? _summary;
  bool _isLoading = false;
  String? _error;

  List<ConsumptionRecommendation> get recommendations => _recommendations;
  RecommendationSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 緊急度の高い推奨のみを取得
  List<ConsumptionRecommendation> get urgentRecommendations {
    return _recommendations
        .where((rec) => rec.urgencyLevel == 'critical' || rec.urgencyLevel == 'high')
        .toList();
  }

  // 中程度の推奨を取得
  List<ConsumptionRecommendation> get mediumRecommendations {
    return _recommendations
        .where((rec) => rec.urgencyLevel == 'medium')
        .toList();
  }

  // 低優先度の推奨を取得
  List<ConsumptionRecommendation> get lowRecommendations {
    return _recommendations
        .where((rec) => rec.urgencyLevel == 'low')
        .toList();
  }

  // 推奨一覧を取得
  Future<void> fetchRecommendations({
    bool activeOnly = true,
    String? urgencyLevel,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _recommendations = await _apiService.getRecommendations(
        activeOnly: activeOnly,
        urgencyLevel: urgencyLevel,
      );
    } catch (e) {
      _setError('推奨の取得に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 推奨要約を取得
  Future<void> fetchRecommendationSummary() async {
    try {
      _summary = await _apiService.getRecommendationSummary();
      notifyListeners();
    } catch (e) {
      _setError('推奨要約の取得に失敗しました: $e');
    }
  }

  // 特定商品の推奨を生成
  Future<ConsumptionRecommendation?> generateItemRecommendation(
    int itemId, {
    int? targetStockLevel,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final recommendation = await _apiService.generateItemRecommendation(
        itemId,
        targetStockLevel: targetStockLevel,
      );
      
      // 既存の推奨リストを更新
      final existingIndex = _recommendations.indexWhere((rec) => rec.itemId == itemId);
      if (existingIndex != -1) {
        _recommendations[existingIndex] = recommendation;
      } else {
        _recommendations.add(recommendation);
      }
      
      notifyListeners();
      return recommendation;
    } catch (e) {
      _setError('推奨の生成に失敗しました: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // 全商品の推奨を一括生成
  Future<void> generateAllRecommendations() async {
    _setLoading(true);
    _clearError();

    try {
      _recommendations = await _apiService.generateAllRecommendations();
      await fetchRecommendationSummary(); // 要約も更新
    } catch (e) {
      _setError('一括推奨の生成に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // 推奨を確認済みとしてマーク
  Future<void> acknowledgeRecommendation(int recommendationId) async {
    try {
      await _apiService.acknowledgeRecommendation(recommendationId);
      
      // ローカルリストを更新
      final index = _recommendations.indexWhere((rec) => rec.id == recommendationId);
      if (index != -1) {
        // acknowledgedAtが更新されたとして扱う（実際のAPIレスポンスがあればそれを使用）
        // ここでは簡単に処理するため、リストから削除せずに、必要に応じて再取得を促す
      }
      
      notifyListeners();
    } catch (e) {
      _setError('推奨の確認に失敗しました: $e');
    }
  }

  // 推奨を非アクティブ化
  Future<void> deactivateRecommendation(int recommendationId) async {
    try {
      await _apiService.deactivateRecommendation(recommendationId);
      
      // ローカルリストから削除
      _recommendations.removeWhere((rec) => rec.id == recommendationId);
      notifyListeners();
    } catch (e) {
      _setError('推奨の非アクティブ化に失敗しました: $e');
    }
  }

  // 推奨をタイプ別にフィルタリング
  List<ConsumptionRecommendation> getRecommendationsByType(String type) {
    return _recommendations.where((rec) => rec.recommendationType == type).toList();
  }

  // 推奨を緊急度別にフィルタリング
  List<ConsumptionRecommendation> getRecommendationsByUrgency(String urgency) {
    return _recommendations.where((rec) => rec.urgencyLevel == urgency).toList();
  }

  // データをリフレッシュ
  Future<void> refresh() async {
    await Future.wait([
      fetchRecommendations(),
      fetchRecommendationSummary(),
    ]);
  }

  // ローディング状態を設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // エラーを設定
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // エラーをクリア
  void _clearError() {
    _error = null;
  }

  // エラーを手動でクリア
  void clearError() {
    _clearError();
    notifyListeners();
  }

  // リソースをクリア
  void clear() {
    _recommendations.clear();
    _summary = null;
    _clearError();
    notifyListeners();
  }
}