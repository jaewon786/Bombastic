abstract final class AppConstants {
  /// 그룹 최소 인원
  static const int minGroupSize = 2;

  /// 그룹 최대 인원
  static const int maxGroupSize = 10;

  /// 참여코드 길이
  static const int joinCodeLength = 6;

  /// 폭탄 기본 제한시간 (초) — 24시간
  static const int defaultBombDurationSeconds = 86400;

  /// 게임 기본 총 기간 (초) — 7일 (서버 BOMB_DEFAULT_DURATION_SECONDS × 7과 동기화)
  static const int defaultGameDurationSeconds = 7 * 24 * 60 * 60;

  /// 게임 최소 진행 일수
  static const int minGameDays = 4;

  /// 게임 최대 진행 일수
  static const int maxGameDays = 7;

  /// Firestore 컬렉션명
  static const String groupsCollection = 'groups';
  static const String usersCollection = 'users';
  static const String missionsCollection = 'missions';
  static const String shopItemsCollection = 'shopItems';
}

abstract final class CurrencyConstants {
  /// 출석 체크 보상 재화
  static const int dailyCheckInReward = 50;

  /// 미션 완료 보상 재화
  static const int missionReward = 30;

  /// 랜덤박스 가격
  static const int randomBoxPrice = 100;
}
