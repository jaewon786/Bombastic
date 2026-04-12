import 'package:bomb_pass/core/utils/date_utils.dart';
import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:bomb_pass/data/models/mission_model.dart';
import 'package:bomb_pass/data/repositories/mission_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show FutureProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mission_controller.g.dart';

/// 서버 기준 오늘 날짜 key 조회.
/// Cloud Function 실패 시 클라이언트 시간으로 fallback.
final serverTodayKeyProvider = FutureProvider<String>((ref) async {
  try {
    return await ref.watch(missionRepositoryProvider).fetchServerTodayKey();
  } catch (_) {
    return AppDateUtils.todayKey();
  }
});

/// 미션 목록 (실시간, 유저의 completedMissionIds 반영)
@riverpod
Stream<List<MissionModel>> missions(Ref ref) {
  final completedIds = ref.watch(completedMissionIdsProvider);
  return ref.watch(missionRepositoryProvider).watchMissions().map(
        (missions) => missions
            .map((m) => m.copyWith(isCompleted: completedIds.contains(m.id)))
            .toList(),
      );
}

@riverpod
class MissionController extends _$MissionController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 출석 체크. 반환값: true=성공, false=이미 출석함.
  Future<bool> checkIn({required String groupId}) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return false;

    state = const AsyncLoading();
    var alreadyDone = false;
    final next = await AsyncValue.guard(() async {
      final result = await ref
          .read(missionRepositoryProvider)
          .checkIn(groupId: groupId, uid: uid);
      alreadyDone = !result;
    });
    if (ref.mounted) state = next;
    return !alreadyDone;
  }
}
