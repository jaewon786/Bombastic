import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../firebase/firebase_providers.dart';
import '../models/bomb_model.dart';

part 'bomb_repository.g.dart';

@riverpod
BombRepository bombRepository(Ref ref) {
  return BombRepository(ref.watch(firestoreProvider));
}

class BombRepository {
  BombRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _bombsOf(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('bombs');

  /// 현재 활성 폭탄 실시간 스트림
  Stream<BombModel?> watchActiveBomb(String groupId) {
    return _bombsOf(groupId)
        .where('status', isEqualTo: BombStatus.active.name)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return BombModel.fromJson(snap.docs.first.data());
    });
  }

  /// 폭탄 다음 사람에게 전달
  Future<void> passBomb({
    required String groupId,
    required String bombId,
    required String nextHolderUid,
    required DateTime expiresAt,
  }) async {
    await _bombsOf(groupId).doc(bombId).update({
      'holderUid': nextHolderUid,
      'receivedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });
  }

  /// 그룹의 전체 폭발 기록 조회 (결산용)
  Future<List<BombModel>> fetchExplodedBombs(String groupId) async {
    final snap = await _bombsOf(groupId)
        .where('status', isEqualTo: BombStatus.exploded.name)
        .get();
    return snap.docs.map((d) => BombModel.fromJson(d.data())).toList();
  }

  /// 폭탄 전달 로그 기록 (passes 서브컬렉션)
  Future<void> logPass({
    required String groupId,
    required String fromUid,
    required String toUid,
  }) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('passes')
        .add({
      'fromUid': fromUid,
      'toUid': toUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// uid별 전달 횟수 집계 (결산용)
  Future<Map<String, int>> fetchPassCounts(String groupId) async {
    final snap = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('passes')
        .get();
    final map = <String, int>{};
    for (final doc in snap.docs) {
      final fromUid = doc.data()['fromUid'] as String?;
      if (fromUid != null) {
        map[fromUid] = (map[fromUid] ?? 0) + 1;
      }
    }
    return map;
  }

  /// pass 로그 전체 조회 (타임스탬프 포함, 최장 홀딩 시간 계산용)
  Future<List<Map<String, dynamic>>> fetchPassLogs(String groupId) async {
    final snap = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('passes')
        .orderBy('timestamp')
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// uid별 아이템 사용 횟수 집계 (결산용)
  Future<Map<String, int>> fetchItemUsedCounts(String groupId) async {
    final snap = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('itemUsages')
        .get();
    final map = <String, int>{};
    for (final doc in snap.docs) {
      final uid = doc.data()['uid'] as String?;
      if (uid != null) {
        map[uid] = (map[uid] ?? 0) + 1;
      }
    }
    return map;
  }

  /// 모든 활성 폭탄 실시간 스트림 (다중 폭탄 지원)
  Stream<List<BombModel>> watchActiveBombs(String groupId) {
    return _bombsOf(groupId)
        .where('status', isEqualTo: BombStatus.active.name)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => BombModel.fromJson(d.data())).toList());
  }
}
