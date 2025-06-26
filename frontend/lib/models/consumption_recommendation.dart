import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'daily_item.dart';

part 'consumption_recommendation.g.dart';

@JsonSerializable()
class ConsumptionRecommendation {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'item_id')
  final int itemId;
  @JsonKey(name: 'recommendation_type')
  final String recommendationType;
  @JsonKey(name: 'urgency_level')
  final String urgencyLevel;
  @JsonKey(name: 'user_consumption_pace')
  final double userConsumptionPace;
  @JsonKey(name: 'market_consumption_pace')
  final double? marketConsumptionPace;
  @JsonKey(name: 'estimated_days_remaining')
  final int estimatedDaysRemaining;
  @JsonKey(name: 'recommendation_message')
  final String recommendationMessage;
  @JsonKey(name: 'confidence_score')
  final double confidenceScore;
  @JsonKey(name: 'additional_info')
  final Map<String, dynamic>? additionalInfo;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'acknowledged_at')
  final DateTime? acknowledgedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final DailyItem? item;

  ConsumptionRecommendation({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.recommendationType,
    required this.urgencyLevel,
    required this.userConsumptionPace,
    this.marketConsumptionPace,
    required this.estimatedDaysRemaining,
    required this.recommendationMessage,
    required this.confidenceScore,
    this.additionalInfo,
    required this.isActive,
    this.acknowledgedAt,
    required this.createdAt,
    required this.updatedAt,
    this.item,
  });

  factory ConsumptionRecommendation.fromJson(Map<String, dynamic> json) =>
      _$ConsumptionRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumptionRecommendationToJson(this);

  // 緊急度レベルの色を取得
  Color get urgencyColor {
    switch (urgencyLevel) {
      case 'critical':
        return const Color(0xFFD32F2F); // 赤
      case 'high':
        return const Color(0xFFF57C00); // オレンジ
      case 'medium':
        return const Color(0xFFFBC02D); // 黄色
      case 'low':
      default:
        return const Color(0xFF388E3C); // 緑
    }
  }

  // 緊急度レベルのアイコンを取得
  IconData get urgencyIcon {
    switch (urgencyLevel) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
      default:
        return Icons.check_circle;
    }
  }

  // 緊急度レベルの表示テキストを取得
  String get urgencyText {
    switch (urgencyLevel) {
      case 'critical':
        return '緊急';
      case 'high':
        return '高';
      case 'medium':
        return '中';
      case 'low':
      default:
        return '低';
    }
  }

  // 推奨アクションの表示テキストを取得
  String get actionText {
    switch (recommendationType) {
      case 'urgent_purchase':
        return '今すぐ購入';
      case 'purchase_now':
        return '購入推奨';
      case 'purchase_soon':
        return '近日購入';
      case 'prepare':
        return '購入準備';
      case 'monitor':
      default:
        return '状況確認';
    }
  }
}

@JsonSerializable()
class RecommendationSummary {
  @JsonKey(name: 'total_recommendations')
  final int totalRecommendations;
  @JsonKey(name: 'critical_count')
  final int criticalCount;
  @JsonKey(name: 'high_count')
  final int highCount;
  @JsonKey(name: 'medium_count')
  final int mediumCount;
  @JsonKey(name: 'low_count')
  final int lowCount;
  @JsonKey(name: 'urgent_items')
  final List<UrgentItem> urgentItems;

  RecommendationSummary({
    required this.totalRecommendations,
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    required this.urgentItems,
  });

  factory RecommendationSummary.fromJson(Map<String, dynamic> json) =>
      _$RecommendationSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationSummaryToJson(this);
}

@JsonSerializable()
class UrgentItem {
  @JsonKey(name: 'item_id')
  final int itemId;
  @JsonKey(name: 'item_name')
  final String itemName;
  @JsonKey(name: 'days_remaining')
  final int daysRemaining;
  @JsonKey(name: 'urgency_level')
  final String urgencyLevel;

  UrgentItem({
    required this.itemId,
    required this.itemName,
    required this.daysRemaining,
    required this.urgencyLevel,
  });

  factory UrgentItem.fromJson(Map<String, dynamic> json) =>
      _$UrgentItemFromJson(json);

  Map<String, dynamic> toJson() => _$UrgentItemToJson(this);
}