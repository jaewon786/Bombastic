import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  Future<void> _runGuarded(Future<void> Function() operation) async {
    if (!ref.mounted) return;
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(operation);
    if (!ref.mounted) return;
    state = nextState;
  }

  /// 게임 시작 (Cloud Function 우선, 미배포 시 Firestore fallback)
  Future<void> startGame({required String groupId}) async {
    await _runGuarded(() async {
      final uid = ref.read(currentUidProvider);
      final firestore = ref.read(firestoreProvider);

      try {
        await callHttpsCallableWithRegionFallback(
          functionName: 'startGame',
          data: {'groupId': groupId},
        );
        return;
      } catch (e) {
        final isFunctionNotFound =
            e is StateError ||
            (e is FirebaseFunctionsException && e.code == 'not-found');
        if (!isFunctionNotFound) rethrow;
      }

      if (uid == null) throw Exception('로그인이 필요합니다.');
      final groupRef = firestore.collection('groups').doc(groupId);

      await firestore.runTransaction((tx) async {
        final groupSnap = await tx.get(groupRef);
        if (!groupSnap.exists || groupSnap.data() == null) {
          throw StateError('그룹을 찾을 수 없습니다.');
        }

        final group = groupSnap.data()!;
        final memberUids =
            List<String>.from(group['memberUids'] as List<dynamic>? ?? const []);
        final status = group['status'] as String? ?? 'waiting';

        if (memberUids.isEmpty || memberUids.first != uid) {
          throw StateError('방장만 게임을 시작할 수 있습니다.');
        }
        if (status != 'waiting') {
          throw StateError('이미 시작된 게임입니다.');
        }
        if (memberUids.length < AppConstants.minGroupSize) {
          throw StateError('최소 2명이 필요합니다.');
        }

        final now = Timestamp.now();
        final expiresAt = Timestamp.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch +
              AppConstants.defaultBombDurationSeconds * 1000,
        );
        final bombRef = groupRef.collection('bombs').doc();

        tx.set(bombRef, {
          'id': bombRef.id,
          'groupId': groupId,
          'holderUid': memberUids.first,
          'receivedAt': now,
          'expiresAt': expiresAt,
          'status': BombStatus.active.name,
          'round': 1,
          'explodedUid': null,
        });

        final gameExpiresAt = Timestamp.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch +
              AppConstants.defaultGameDurationSeconds * 1000,
        );

        tx.update(groupRef, {
          'status': 'playing',
          'gameStartedAt': now,
          'gameExpiresAt': gameExpiresAt,
        });
      });
    });
  }

  /// 폭탄을 다음 사람에게 전달
  Future<void> passBomb({
    required String groupId,
    required String bombId,
  }) async {
    await _runGuarded(() async {
      final groupRepository = ref.read(groupRepositoryProvider);
      final bombRepository = ref.read(bombRepositoryProvider);
      final uid = ref.read(currentUidProvider);
      if (uid == null) throw Exception('로그인이 필요합니다.');

      final group = await groupRepository.watchGroup(groupId).first;
      if (group == null) throw Exception('그룹을 찾을 수 없습니다.');

      final members = group.memberUids;
      final currentIndex = members.indexOf(uid);
      if (currentIndex == -1) throw Exception('그룹 멤버가 아닙니다.');

      final nextIndex = (currentIndex + 1) % members.length;
      final nextUid = members[nextIndex];

      await bombRepository.passBomb(
            groupId: groupId,
            bombId: bombId,
            nextHolderUid: nextUid,
            expiresAt: DateTime.now().add(
              const Duration(seconds: AppConstants.defaultBombDurationSeconds),
            ),
          );

      // 전달 로그 기록 (passCount 집계용)
      await bombRepository.logPass(
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
    await _runGuarded(() async {
      final data = <String, dynamic>{'groupId': groupId, 'itemId': itemId};
      if (days != null) data['days'] = days;
      await callHttpsCallableWithRegionFallback(
        functionName: 'useItem',
        data: data,
      );
    });
  }
}
