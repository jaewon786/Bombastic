// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShopItemModel _$ShopItemModelFromJson(Map<String, dynamic> json) =>
    _ShopItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toInt(),
      type: $enumDecode(_$ItemTypeEnumMap, json['type']),
      usageType:
          $enumDecodeNullable(_$UsageTypeEnumMap, json['usageType']) ??
          UsageType.always,
      isAvailable: json['isAvailable'] as bool? ?? true,
      probability: (json['probability'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ShopItemModelToJson(_ShopItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'type': _$ItemTypeEnumMap[instance.type]!,
      'usageType': _$UsageTypeEnumMap[instance.usageType]!,
      'isAvailable': instance.isAvailable,
      'probability': instance.probability,
    };

const _$ItemTypeEnumMap = {
  ItemType.swapOrder: 'swapOrder',
  ItemType.shrinkDuration: 'shrinkDuration',
  ItemType.reverseDirection: 'reverseDirection',
  ItemType.guardianAngel: 'guardianAngel',
};

const _$UsageTypeEnumMap = {
  UsageType.always: 'always',
  UsageType.bombHolder: 'bombHolder',
  UsageType.passive: 'passive',
};
