import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/bomb_model.dart';
import '../../../data/repositories/bomb_repository.dart';
import '../../../data/repositories/group_repository.dart';

part 'game_controller.g.dart';

/// 현재 활성 폭탄 실시간 스트림
@riverpod
Stream<BombModel?> activeBomb(Ref ref, String groupId) {
  if (groupId.isEmpty) return const Stream.empty();
  return ref.watch(bombRepositoryProvider).watchActiveBomb(groupId);
}

/// 내 차례인지 여부
@riverpod
bool isMyTurn(Ref ref, String groupId) {
  final bomb = ref.watch(activeBombProvider(groupId)).asData?.value;
  final uid = ref.watch(currentUidProvider);
  return bomb?.holderUid == uid;
}

@riverpod
class GameController extends _$GameController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 폭탄을 다음 사람에게 전달
  Future<void> passBomb({
    required String groupId,
    required String bombId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final uid = ref.read(currentUidProvider);
      if (uid == null) throw Exception('로그인이 필요합니다.');

      final group =
          await ref.read(groupRepositoryProvider).watchGroup(groupId).first;
      if (group == null) throw Exception('그룹을 찾을 수 없습니다.');

      final members = group.memberUids;
      final currentIndex = members.indexOf(uid);
      if (currentIndex == -1) throw Exception('그룹 멤버가 아닙니다.');

      final nextIndex = (currentIndex + 1) % members.length;
      final nextUid = members[nextIndex];

      await ref.read(bombRepositoryProvider).passBomb(
            groupId: groupId,
            bombId: bombId,
            nextHolderUid: nextUid,
            expiresAt: DateTime.now().add(
              const Duration(seconds: AppConstants.defaultBombDurationSeconds),
            ),
          );

      // 전달 로그 기록 (passCount 집계용)
      await ref.read(bombRepositoryProvider).logPass(
            groupId: groupId,
            fromUid: uid,
            toUid: nextUid,
          );
    });
  }

  /// 아이템 사용 (Cloud Function 경유)
  Future<void> useItem({
    required String groupId,
    required String itemId,
    int? days,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final data = <String, dynamic>{'groupId': groupId, 'itemId': itemId};
      if (days != null) data['days'] = days;
      await ref
          .read(functionsProvider)
          .httpsCallable('useItem')
          .call<dynamic, Map<String, dynamic>>(data);
    });
  }
}
