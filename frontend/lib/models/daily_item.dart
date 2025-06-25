import 'package:json_annotation/json_annotation.dart';

part 'daily_item.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class DailyItem {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String name;
  final String? description;
  @JsonKey(name: 'current_quantity')
  final int currentQuantity;
  final String unit;
  @JsonKey(name: 'minimum_threshold')
  final int minimumThreshold;
  @JsonKey(name: 'estimated_consumption_days')
  final int estimatedConsumptionDays;
  @JsonKey(name: 'purchase_url')
  final String? purchaseUrl;
  final double? price;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final Category? category;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  DailyItem({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.currentQuantity,
    required this.unit,
    required this.minimumThreshold,
    required this.estimatedConsumptionDays,
    this.purchaseUrl,
    this.price,
    this.categoryId,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyItem.fromJson(Map<String, dynamic> json) => _$DailyItemFromJson(json);
  Map<String, dynamic> toJson() => _$DailyItemToJson(this);

  // 在庫が少ないかどうかを判定
  bool get isLowStock => currentQuantity <= minimumThreshold;

  // 在庫切れかどうかを判定
  bool get isOutOfStock => currentQuantity <= 0;
}

@JsonSerializable()
class DailyItemCreate {
  final String name;
  final String? description;
  @JsonKey(name: 'current_quantity')
  final int currentQuantity;
  final String unit;
  @JsonKey(name: 'minimum_threshold')
  final int minimumThreshold;
  @JsonKey(name: 'estimated_consumption_days')
  final int estimatedConsumptionDays;
  @JsonKey(name: 'purchase_url')
  final String? purchaseUrl;
  final double? price;
  @JsonKey(name: 'category_id')
  final int? categoryId;

  DailyItemCreate({
    required this.name,
    this.description,
    this.currentQuantity = 0,
    this.unit = '個',
    this.minimumThreshold = 1,
    this.estimatedConsumptionDays = 30,
    this.purchaseUrl,
    this.price,
    this.categoryId,
  });

  factory DailyItemCreate.fromJson(Map<String, dynamic> json) => _$DailyItemCreateFromJson(json);
  Map<String, dynamic> toJson() => _$DailyItemCreateToJson(this);
}

@JsonSerializable()
class DailyItemUpdate {
  final String? name;
  final String? description;
  @JsonKey(name: 'current_quantity')
  final int? currentQuantity;
  final String? unit;
  @JsonKey(name: 'minimum_threshold')
  final int? minimumThreshold;
  @JsonKey(name: 'estimated_consumption_days')
  final int? estimatedConsumptionDays;
  @JsonKey(name: 'purchase_url')
  final String? purchaseUrl;
  final double? price;
  @JsonKey(name: 'category_id')
  final int? categoryId;

  DailyItemUpdate({
    this.name,
    this.description,
    this.currentQuantity,
    this.unit,
    this.minimumThreshold,
    this.estimatedConsumptionDays,
    this.purchaseUrl,
    this.price,
    this.categoryId,
  });

  factory DailyItemUpdate.fromJson(Map<String, dynamic> json) => _$DailyItemUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$DailyItemUpdateToJson(this);
} 