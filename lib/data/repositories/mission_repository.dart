import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../firebase/firebase_providers.dart';
import '../models/mission_model.dart';

part 'mission_repository.g.dart';

@riverpod
MissionRepository missionRepository(Ref ref) {
  return MissionRepository(ref.watch(firestoreProvider));
}

class MissionRepository {
  MissionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// 미션 목록 실시간 스트림 (Firestore, 비어있으면 하드코딩)
  Stream<List<MissionModel>> watchMissions() {
    return _firestore
        .collection(AppConstants.missionsCollection)
        .snapshots()
        .map((snap) {
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((d) => MissionModel.fromJson(d.data())).toList();
      }
      return _hardcodedMissions;
    });
  }

  /// 미션 목록 조회 (Firestore 또는 하드코딩)
  Future<List<MissionModel>> fetchMissions() async {
    final snap =
        await _firestore.collection(AppConstants.missionsCollection).get();

    if (snap.docs.isNotEmpty) {
      return snap.docs.map((d) => MissionModel.fromJson(d.data())).toList();
    }

    // Firestore에 미션이 없을 경우 하드코딩 기본 미션
    return _hardcodedMissions;
  }

  static final List<MissionModel> _hardcodedMissions = [
    const MissionModel(
      id: 'mission_1',
      title: '첫 전달 완료',
      description: '폭탄을 처음으로 다음 사람에게 전달하세요.',
      reward: CurrencyConstants.missionReward,
      type: MissionType.daily,
    ),
    const MissionModel(
      id: 'mission_2',
      title: '3연속 전달',
      description: '폭발 없이 3번 연속 전달에 성공하세요.',
      reward: CurrencyConstants.missionReward,
      type: MissionType.weekly,
    ),
    const MissionModel(
      id: 'mission_3',
      title: '아이템 첫 구매',
      description: '상점에서 아이템을 처음 구매하세요.',
      reward: CurrencyConstants.missionReward,
      type: MissionType.daily,
    ),
  ];

  /// 출석 체크 — 서버 사이드 Cloud Function 호출
  Future<bool> checkIn({required String groupId}) async {
    await callHttpsCallableWithRegionFallback(
      functionName: 'checkIn',
      data: {'groupId': groupId},
    );
    return true;
  }

  /// 서버(Asia/Seoul) 기준 오늘 날짜 key 조회
  Future<String> fetchServerTodayKey() async {
    final result = await callHttpsCallableWithRegionFallback(
      functionName: 'getTodayKey',
    );
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['todayKey'] as String;
  }
}
