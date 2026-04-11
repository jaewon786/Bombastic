import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/repositories/mission_repository.dart';

part 'mission_controller.g.dart';

final serverTodayKeyProvider = FutureProvider<String>((ref) {
  return ref.watch(missionRepositoryProvider).fetchServerTodayKey();
});

/// 미션 목록 (실시간, 유저의 completedMissionIds 반영)
@riverpod
Stream<List<MissionModel>> missions(Ref ref) {
  final currentUser = ref.watch(currentUserProvider).asData?.value;
  final completedIds = currentUser?.completedMissionIds ?? [];
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

  Future<void> checkIn({required String groupId}) async {
    state = const AsyncLoading();
    final next = await AsyncValue.guard(() async {
      await ref.read(missionRepositoryProvider).checkIn(groupId: groupId);
    });
    if (ref.mounted) state = next;
  }
}
