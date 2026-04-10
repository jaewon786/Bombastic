// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String,
  currency: (json['currency'] as num?)?.toInt() ?? 0,
  ownedItemIds:
      (json['ownedItemIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  currentGroupId: json['currentGroupId'] as String?,
  lastCheckInDate: json['lastCheckInDate'] == null
      ? null
      : DateTime.parse(json['lastCheckInDate'] as String),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'displayName': instance.displayName,
      'currency': instance.currency,
      'ownedItemIds': instance.ownedItemIds,
      'currentGroupId': instance.currentGroupId,
      'lastCheckInDate': instance.lastCheckInDate?.toIso8601String(),
    };
