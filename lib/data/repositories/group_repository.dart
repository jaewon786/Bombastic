import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../firebase/firebase_providers.dart';
import '../models/group_model.dart';

part 'group_repository.g.dart';

@riverpod
GroupRepository groupRepository(Ref ref) {
  return GroupRepository(ref.watch(firestoreProvider));
}

class GroupRepository {
  GroupRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection(AppConstants.groupsCollection);

  /// 그룹 생성 (참여코드 발급)
  Future<GroupModel> createGroup({
    required String creatorUid,
    required String joinCode,
    required String name,
    required int maxMembers,
    required String nickname,
  }) async {
    final doc = _groups.doc();
    final group = GroupModel(
      id: doc.id,
      name: name,
      joinCode: joinCode,
      hostUid: creatorUid,
      maxMembers: maxMembers,
      memberUids: [creatorUid],
      memberNicknames: {creatorUid: nickname},
      status: GroupStatus.waiting,
      createdAt: DateTime.now(),
    );
    await doc.set(group.toJson());
    return group;
  }

  /// 참여코드로 그룹 찾기
  Future<GroupModel?> findByJoinCode(String joinCode) async {
    final query = await _groups
        .where('joinCode', isEqualTo: joinCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return GroupModel.fromJson(query.docs.first.data());
  }

  /// 그룹 참여
  Future<void> joinGroup({
    required String groupId,
    required String uid,
  }) async {
    final groupRef = _groups.doc(groupId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(groupRef);
      if (!snap.exists || snap.data() == null) {
        throw StateError('그룹을 찾을 수 없습니다.');
      }

      final data = snap.data()!;
      final memberUids = List<String>.from(data['memberUids'] as List<dynamic>? ?? const []);
      final maxMembers = (data['maxMembers'] as int?) ?? AppConstants.maxGroupSize;

      if (memberUids.contains(uid)) {
        throw StateError('이미 참여한 그룹입니다.');
      }
      if (memberUids.length >= maxMembers) {
        throw StateError('그룹이 가득 찼습니다.');
      }

      // Firestore rules에서 배열 길이/포함 검증을 수행하므로
      // transform(arrayUnion) 대신 확정된 배열 값을 직접 기록한다.
      final nextMemberUids = [...memberUids, uid];

      tx.update(groupRef, {
        'memberUids': nextMemberUids,
      });
    });
  }

  /// 그룹 멤버 닉네임 업데이트
  Future<void> updateMemberNickname({
    required String groupId,
    required String uid,
    required String nickname,
  }) async {
    await _groups.doc(groupId).update({
      'memberNicknames.$uid': nickname,
    });
  }

  /// 그룹 실시간 스트림 (onSnapshot)
  Stream<GroupModel?> watchGroup(String groupId) {
    return _groups.doc(groupId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return GroupModel.fromJson(snap.data()!);
    });
  }
}
