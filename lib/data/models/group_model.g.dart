// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => _GroupModel(
  id: json['id'] as String,
  name: json['name'] as String,
  joinCode: json['joinCode'] as String,
  hostUid: json['hostUid'] as String,
  maxMembers: (json['maxMembers'] as num).toInt(),
  memberUids: (json['memberUids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  memberNicknames: Map<String, String>.from(json['memberNicknames'] as Map),
  status: $enumDecode(_$GroupStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  gameStartedAt: json['gameStartedAt'] == null
      ? null
      : DateTime.parse(json['gameStartedAt'] as String),
  gameEndedAt: json['gameEndedAt'] == null
      ? null
      : DateTime.parse(json['gameEndedAt'] as String),
  gameExpiresAt: json['gameExpiresAt'] == null
      ? null
      : DateTime.parse(json['gameExpiresAt'] as String),
);

Map<String, dynamic> _$GroupModelToJson(_GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'joinCode': instance.joinCode,
      'hostUid': instance.hostUid,
      'maxMembers': instance.maxMembers,
      'memberUids': instance.memberUids,
      'memberNicknames': instance.memberNicknames,
      'status': _$GroupStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'gameStartedAt': instance.gameStartedAt?.toIso8601String(),
      'gameEndedAt': instance.gameEndedAt?.toIso8601String(),
      'gameExpiresAt': instance.gameExpiresAt?.toIso8601String(),
    };

const _$GroupStatusEnumMap = {
  GroupStatus.waiting: 'waiting',
  GroupStatus.playing: 'playing',
  GroupStatus.finished: 'finished',
};
