import 'package:json_annotation/json_annotation.dart';
import 'daily_item.dart';

part 'consumption_record.g.dart';

@JsonSerializable()
class ConsumptionRecord {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'item_id')
  final int itemId;
  @JsonKey(name: 'consumed_quantity')
  final int consumedQuantity;
  @JsonKey(name: 'consumption_date')
  final DateTime consumptionDate;
  @JsonKey(name: 'remaining_quantity')
  final int? remainingQuantity;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final DailyItem? item;

  ConsumptionRecord({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.consumedQuantity,
    required this.consumptionDate,
    this.remainingQuantity,
    this.notes,
    required this.createdAt,
    this.item,
  });

  factory ConsumptionRecord.fromJson(Map<String, dynamic> json) => _$ConsumptionRecordFromJson(json);
  Map<String, dynamic> toJson() => _$ConsumptionRecordToJson(this);
}

@JsonSerializable()
class ConsumptionRecordCreate {
  @JsonKey(name: 'item_id')
  final int itemId;
  @JsonKey(name: 'consumed_quantity')
  final int consumedQuantity;
  @JsonKey(name: 'consumption_date')
  final DateTime? consumptionDate;
  @JsonKey(name: 'remaining_quantity')
  final int? remainingQuantity;
  final String? notes;

  ConsumptionRecordCreate({
    required this.itemId,
    required this.consumedQuantity,
    this.consumptionDate,
    this.remainingQuantity,
    this.notes,
  });

  factory ConsumptionRecordCreate.fromJson(Map<String, dynamic> json) => _$ConsumptionRecordCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ConsumptionRecordCreateToJson(this);
} 