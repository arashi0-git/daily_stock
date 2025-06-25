// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
    };

DailyItem _$DailyItemFromJson(Map<String, dynamic> json) => DailyItem(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      currentQuantity: (json['current_quantity'] as num).toInt(),
      unit: json['unit'] as String,
      minimumThreshold: (json['minimum_threshold'] as num).toInt(),
      estimatedConsumptionDays:
          (json['estimated_consumption_days'] as num).toInt(),
      purchaseUrl: json['purchase_url'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DailyItemToJson(DailyItem instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'current_quantity': instance.currentQuantity,
      'unit': instance.unit,
      'minimum_threshold': instance.minimumThreshold,
      'estimated_consumption_days': instance.estimatedConsumptionDays,
      'purchase_url': instance.purchaseUrl,
      'price': instance.price,
      'category_id': instance.categoryId,
      'category': instance.category,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

DailyItemCreate _$DailyItemCreateFromJson(Map<String, dynamic> json) =>
    DailyItemCreate(
      name: json['name'] as String,
      description: json['description'] as String?,
      currentQuantity: (json['current_quantity'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? '個',
      minimumThreshold: (json['minimum_threshold'] as num?)?.toInt() ?? 1,
      estimatedConsumptionDays:
          (json['estimated_consumption_days'] as num?)?.toInt() ?? 30,
      purchaseUrl: json['purchase_url'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      categoryId: (json['category_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DailyItemCreateToJson(DailyItemCreate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'current_quantity': instance.currentQuantity,
      'unit': instance.unit,
      'minimum_threshold': instance.minimumThreshold,
      'estimated_consumption_days': instance.estimatedConsumptionDays,
      'purchase_url': instance.purchaseUrl,
      'price': instance.price,
      'category_id': instance.categoryId,
    };

DailyItemUpdate _$DailyItemUpdateFromJson(Map<String, dynamic> json) =>
    DailyItemUpdate(
      name: json['name'] as String?,
      description: json['description'] as String?,
      currentQuantity: (json['current_quantity'] as num?)?.toInt(),
      unit: json['unit'] as String?,
      minimumThreshold: (json['minimum_threshold'] as num?)?.toInt(),
      estimatedConsumptionDays:
          (json['estimated_consumption_days'] as num?)?.toInt(),
      purchaseUrl: json['purchase_url'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      categoryId: (json['category_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DailyItemUpdateToJson(DailyItemUpdate instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'current_quantity': instance.currentQuantity,
      'unit': instance.unit,
      'minimum_threshold': instance.minimumThreshold,
      'estimated_consumption_days': instance.estimatedConsumptionDays,
      'purchase_url': instance.purchaseUrl,
      'price': instance.price,
      'category_id': instance.categoryId,
    };
