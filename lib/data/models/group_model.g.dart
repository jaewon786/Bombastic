// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => _GroupModel(
  id: json['id'] as String,
  joinCode: json['joinCode'] as String,
  memberUids: (json['memberUids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$GroupStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  gameStartedAt: json['gameStartedAt'] == null
      ? null
      : DateTime.parse(json['gameStartedAt'] as String),
  gameEndedAt: json['gameEndedAt'] == null
      ? null
      : DateTime.parse(json['gameEndedAt'] as String),
);

Map<String, dynamic> _$GroupModelToJson(_GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'joinCode': instance.joinCode,
      'memberUids': instance.memberUids,
      'status': _$GroupStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'gameStartedAt': instance.gameStartedAt?.toIso8601String(),
      'gameEndedAt': instance.gameEndedAt?.toIso8601String(),
    };

const _$GroupStatusEnumMap = {
  GroupStatus.waiting: 'waiting',
  GroupStatus.playing: 'playing',
  GroupStatus.finished: 'finished',
};
