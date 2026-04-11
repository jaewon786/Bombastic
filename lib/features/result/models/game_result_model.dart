import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_result_model.freezed.dart';
part 'game_result_model.g.dart';

@freezed
abstract class PlayerResultModel with _$PlayerResultModel {
  const factory PlayerResultModel({
    required String uid,
    required String displayName,
    required int explodeCount,
    required int passCount,
    @Default(0) int maxHoldingMinutes, // 최장 홀딩 시간 (분)
    @Default(0) int itemUsedCount,     // 아이템 사용 횟수
  }) = _PlayerResultModel;

  factory PlayerResultModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerResultModelFromJson(json);
}

@freezed
abstract class GameResultModel with _$GameResultModel {
  const factory GameResultModel({
    required String groupId,
    required List<PlayerResultModel> rankList, // 폭발 횟수 오름차순 정렬
    required DateTime endedAt,
  }) = _GameResultModel;

  factory GameResultModel.fromJson(Map<String, dynamic> json) =>
      _$GameResultModelFromJson(json);
}
