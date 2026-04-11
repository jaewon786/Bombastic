import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.freezed.dart';
part 'group_model.g.dart';

enum GroupStatus { waiting, playing, finished }

@freezed
abstract class GroupModel with _$GroupModel {
  const factory GroupModel({
    required String id,
    required String name,
    required String joinCode,
    required String hostUid,
    required int maxMembers,                          // 방장이 설정한 인원 (2~10)
    required List<String> memberUids,                 // 고정 순서 (index = 전달 순서)
    required Map<String, String> memberNicknames,     // uid → 그룹 내 닉네임
    required GroupStatus status,
    required DateTime createdAt,
    DateTime? gameStartedAt,
    DateTime? gameEndedAt,
    DateTime? gameExpiresAt, // 7일 경과 정상 종료 기준 시각
  }) = _GroupModel;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(_normalizeGroupJson(json));
}

Map<String, dynamic> _normalizeGroupJson(Map<String, dynamic> json) {
  final map = Map<String, dynamic>.from(json);
  map['createdAt'] = _normalizeRequiredDateValue(map['createdAt'], 'createdAt');
  map['gameStartedAt'] = _normalizeNullableDateValue(map['gameStartedAt']);
  map['gameEndedAt'] = _normalizeNullableDateValue(map['gameEndedAt']);
  map['gameExpiresAt'] = _normalizeNullableDateValue(map['gameExpiresAt']);
  return map;
}

Object _normalizeRequiredDateValue(Object? value, String field) {
  final normalized = _normalizeNullableDateValue(value);
  if (normalized == null) {
    throw FormatException('Missing required date field: $field');
  }
  return normalized;
}

String? _normalizeNullableDateValue(Object? value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  if (value is String) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
  }
  throw FormatException('Unsupported date value: $value');
}
