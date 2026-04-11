// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerResultModel _$PlayerResultModelFromJson(Map<String, dynamic> json) =>
    _PlayerResultModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      explodeCount: (json['explodeCount'] as num).toInt(),
      passCount: (json['passCount'] as num).toInt(),
      maxHoldingMinutes: (json['maxHoldingMinutes'] as num?)?.toInt() ?? 0,
      itemUsedCount: (json['itemUsedCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PlayerResultModelToJson(_PlayerResultModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'explodeCount': instance.explodeCount,
      'passCount': instance.passCount,
      'maxHoldingMinutes': instance.maxHoldingMinutes,
      'itemUsedCount': instance.itemUsedCount,
    };

_GameResultModel _$GameResultModelFromJson(Map<String, dynamic> json) =>
    _GameResultModel(
      groupId: json['groupId'] as String,
      rankList: (json['rankList'] as List<dynamic>)
          .map((e) => PlayerResultModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      endedAt: DateTime.parse(json['endedAt'] as String),
    );

Map<String, dynamic> _$GameResultModelToJson(_GameResultModel instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'rankList': instance.rankList,
      'endedAt': instance.endedAt.toIso8601String(),
    };
