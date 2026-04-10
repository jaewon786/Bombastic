// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bomb_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BombModel _$BombModelFromJson(Map<String, dynamic> json) => _BombModel(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  holderUid: json['holderUid'] as String,
  receivedAt: DateTime.parse(json['receivedAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  status: $enumDecode(_$BombStatusEnumMap, json['status']),
  round: (json['round'] as num?)?.toInt() ?? 0,
  explodedUid: json['explodedUid'] as String?,
);

Map<String, dynamic> _$BombModelToJson(_BombModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'holderUid': instance.holderUid,
      'receivedAt': instance.receivedAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'status': _$BombStatusEnumMap[instance.status]!,
      'round': instance.round,
      'explodedUid': instance.explodedUid,
    };

const _$BombStatusEnumMap = {
  BombStatus.active: 'active',
  BombStatus.exploded: 'exploded',
  BombStatus.defused: 'defused',
};
