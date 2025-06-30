import 'package:flutter/material.dart';
import 'daily_item.dart';

class ConsumptionRecommendation {
  final int id;
  final int userId;
  final int itemId;
  final String recommendationType;
  final String urgencyLevel;
  final double userConsumptionPace;
  final double? marketConsumptionPace;
  final int estimatedDaysRemaining;
  final String recommendationMessage;
  final double confidenceScore;
  final Map<String, dynamic>? additionalInfo;
  final bool isActive;
  final DateTime? acknowledgedAt;
  final DateTime createdAt;
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

  factory ConsumptionRecommendation.fromJson(Map<String, dynamic> json) {
    return ConsumptionRecommendation(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      itemId: json['item_id'] as int,
      recommendationType: json['recommendation_type'] as String,
      urgencyLevel: json['urgency_level'] as String,
      userConsumptionPace: (json['user_consumption_pace'] as num).toDouble(),
      marketConsumptionPace: json['market_consumption_pace'] != null
          ? (json['market_consumption_pace'] as num).toDouble()
          : null,
      estimatedDaysRemaining: json['estimated_days_remaining'] as int,
      recommendationMessage: json['recommendation_message'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool,
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      item: json['item'] != null ? DailyItem.fromJson(json['item']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'recommendation_type': recommendationType,
      'urgency_level': urgencyLevel,
      'user_consumption_pace': userConsumptionPace,
      'market_consumption_pace': marketConsumptionPace,
      'estimated_days_remaining': estimatedDaysRemaining,
      'recommendation_message': recommendationMessage,
      'confidence_score': confidenceScore,
      'additional_info': additionalInfo,
      'is_active': isActive,
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'item': item?.toJson(),
    };
  }

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

class RecommendationSummary {
  final int totalRecommendations;
  final int criticalCount;
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final List<UrgentItem> urgentItems;

  RecommendationSummary({
    required this.totalRecommendations,
    required this.criticalCount,
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    required this.urgentItems,
  });

  factory RecommendationSummary.fromJson(Map<String, dynamic> json) {
    return RecommendationSummary(
      totalRecommendations: json['total_recommendations'] as int,
      criticalCount: json['critical_count'] as int,
      highCount: json['high_count'] as int,
      mediumCount: json['medium_count'] as int,
      lowCount: json['low_count'] as int,
      urgentItems: (json['urgent_items'] as List)
          .map((item) => UrgentItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_recommendations': totalRecommendations,
      'critical_count': criticalCount,
      'high_count': highCount,
      'medium_count': mediumCount,
      'low_count': lowCount,
      'urgent_items': urgentItems.map((item) => item.toJson()).toList(),
    };
  }
}

class UrgentItem {
  final int itemId;
  final String itemName;
  final int daysRemaining;
  final String urgencyLevel;

  UrgentItem({
    required this.itemId,
    required this.itemName,
    required this.daysRemaining,
    required this.urgencyLevel,
  });

  factory UrgentItem.fromJson(Map<String, dynamic> json) {
    return UrgentItem(
      itemId: json['item_id'] as int,
      itemName: json['item_name'] as String,
      daysRemaining: json['days_remaining'] as int,
      urgencyLevel: json['urgency_level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_name': itemName,
      'days_remaining': daysRemaining,
      'urgency_level': urgencyLevel,
    };
  }
}
