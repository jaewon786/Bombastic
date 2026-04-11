import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/group_model.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../data/repositories/user_repository.dart';

part 'group_controller.g.dart';

/// 특정 그룹 실시간 스트림
@riverpod
Stream<GroupModel?> watchGroup(Ref ref, String groupId) {
  if (groupId.isEmpty) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchGroup(groupId);
}

@riverpod
class GroupController extends _$GroupController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 새 그룹 생성 — 성공 시 groupId 반환
  Future<String?> createGroup({
    required String name,
    required int maxMembers,
    String nickname = '익명',
  }) async {
    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return null;
    }

    final joinCode = _generateJoinCode();
    String? groupId;
    final result = await AsyncValue.guard(() async {
      final group = await ref.read(groupRepositoryProvider).createGroup(
            creatorUid: uid,
            joinCode: joinCode,
            name: name,
            maxMembers: maxMembers,
            nickname: nickname,
          );
      groupId = group.id;
      await ref.read(userRepositoryProvider).addGroupMembership(
            uid: uid,
            groupId: group.id,
            nickname: nickname,
          );
    });

    state = result.when(
      data: (_) => const AsyncData(null),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
    return state.hasError ? null : groupId;
  }

  /// 코드로 그룹 참여 — 성공 시 groupId 반환
  Future<String?> joinGroup(String joinCode) async {
    if (joinCode.length != AppConstants.joinCodeLength) {
      state = AsyncError('${AppConstants.joinCodeLength}자리 코드를 입력하세요.', StackTrace.current);
      return null;
    }

    state = const AsyncLoading();
    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return null;
    }

    final repo = ref.read(groupRepositoryProvider);
    String? groupId;
    final result = await AsyncValue.guard(() async {
      final group = await repo.findByJoinCode(joinCode);
      if (group == null) throw Exception('존재하지 않는 코드입니다.');
      if (group.memberUids.contains(uid)) {
        throw Exception('이미 참여한 그룹입니다.');
      }
      if (group.memberUids.length >= group.maxMembers) {
        throw Exception('그룹이 가득 찼습니다.');
      }
      await repo.joinGroup(groupId: group.id, uid: uid);
      await ref.read(userRepositoryProvider).addGroupMembership(
            uid: uid,
            groupId: group.id,
            nickname: '익명',
          );
      await repo.updateMemberNickname(
            groupId: group.id,
            uid: uid,
            nickname: '익명',
          );
      groupId = group.id;
    });

    state = result.when(
      data: (_) => const AsyncData(null),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
    return state.hasError ? null : groupId;
  }

  String _generateJoinCode() {
    const uuid = Uuid();
    return uuid.v4().replaceAll('-', '').substring(0, AppConstants.joinCodeLength).toUpperCase();
  }
}
