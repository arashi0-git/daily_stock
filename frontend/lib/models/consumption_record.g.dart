// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsumptionRecord _$ConsumptionRecordFromJson(Map<String, dynamic> json) =>
    ConsumptionRecord(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      itemId: (json['item_id'] as num).toInt(),
      consumedQuantity: (json['consumed_quantity'] as num).toInt(),
      consumptionDate: DateTime.parse(json['consumption_date'] as String),
      remainingQuantity: (json['remaining_quantity'] as num?)?.toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      item: json['item'] == null
          ? null
          : DailyItem.fromJson(json['item'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConsumptionRecordToJson(ConsumptionRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'item_id': instance.itemId,
      'consumed_quantity': instance.consumedQuantity,
      'consumption_date': instance.consumptionDate.toIso8601String(),
      'remaining_quantity': instance.remainingQuantity,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'item': instance.item,
    };

ConsumptionRecordCreate _$ConsumptionRecordCreateFromJson(
        Map<String, dynamic> json) =>
    ConsumptionRecordCreate(
      itemId: (json['item_id'] as num).toInt(),
      consumedQuantity: (json['consumed_quantity'] as num).toInt(),
      consumptionDate: json['consumption_date'] == null
          ? null
          : DateTime.parse(json['consumption_date'] as String),
      remainingQuantity: (json['remaining_quantity'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ConsumptionRecordCreateToJson(
        ConsumptionRecordCreate instance) =>
    <String, dynamic>{
      'item_id': instance.itemId,
      'consumed_quantity': instance.consumedQuantity,
      'consumption_date': instance.consumptionDate?.toIso8601String(),
      'remaining_quantity': instance.remainingQuantity,
      'notes': instance.notes,
    };
