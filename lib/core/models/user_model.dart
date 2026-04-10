import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    // 다중 그룹 참여 지원을 위해 리스트로 관리
    @Default([]) List<String> groupIds, 
    // 익명 로그인 생성 시간 기록 (선택 사항)
    DateTime? createdAt, 
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
}