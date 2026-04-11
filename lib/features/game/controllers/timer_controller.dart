import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/date_utils.dart';
import 'game_controller.dart';

part 'timer_controller.g.dart';

/// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider.
///
/// ## 유저 간 타이머 동기화
/// - `bomb.expiresAt`은 게임 시작 시 서버(Cloud Function)가 단 한 번 설정하는 절대 타임스탬프.
/// - 폭탄 전달 시 `expiresAt`을 변경하지 않으므로 타이머는 계속 카운트다운된다.
/// - `bomb.expiresAt - DateTime.now()` : 모든 기기의 `DateTime.now()`가 NTP로
///   동기화되어 있으므로(오차 < 1s) 유저 간 표시 값이 일치한다.
@riverpod
Stream<String> bombTimer(Ref ref, String groupId) async* {
  final bomb = ref.watch(activeBombProvider(groupId)).asData?.value;
  if (bomb == null) {
    yield '00:00:00';
    return;
  }

  String compute() {
    final remaining = bomb.expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return '00:00:00';
    return AppDateUtils.formatDuration(remaining);
  }

  yield compute();
  yield* Stream.periodic(const Duration(seconds: 1), (_) => compute());
}
