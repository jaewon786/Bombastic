import 'package:bomb_pass/core/constants/app_constants.dart';
import 'package:bomb_pass/core/utils/date_utils.dart';
import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:bomb_pass/data/models/mission_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      id: 'mission_3',
      title: '아이템 첫 구매',
      description: '상점에서 아이템을 처음 구매하세요.',
      reward: CurrencyConstants.missionReward,
      type: MissionType.daily,
    ),
    const MissionModel(
      id: 'mission_4',
      title: '폭탄 5회 전달',
      description: '폭탄을 총 5번 전달하세요.',
      reward: CurrencyConstants.missionReward,
      type: MissionType.daily,
    ),
    const MissionModel(
      id: 'mission_5',
      title: '폭탄 10회 전달',
      description: '폭탄을 총 10번 전달하세요.',
      reward: CurrencyConstants.missionReward,
      type: MissionType.weekly,
    ),
    const MissionModel(
      id: 'mission_6',
      title: '뽑기 3회',
      description: '상점에서 뽑기를 3번 하세요.',
      reward: CurrencyConstants.missionReward,
      type: MissionType.weekly,
    ),
    const MissionModel(
      id: 'mission_7',
      title: '빠른 전달',
      description: '폭탄을 받은 후 10분 안에 전달하세요.',
      reward: CurrencyConstants.missionReward,
      type: MissionType.daily,
    ),
  ];

  /// 출석 체크 — Cloud Function 우선, 미배포 시 클라이언트 직접 쓰기 fallback.
  Future<bool> checkIn({
    required String groupId,
    required String uid,
  }) async {
    try {
      await callHttpsCallableWithRegionFallback(
        functionName: 'checkIn',
        data: {'groupId': groupId},
      );
      return true;
    } catch (e) {
      if (e is FirebaseFunctionsException && e.code == 'already-exists') {
        return false; // 이미 출석 완료 — 에러가 아님
      }
      final isFunctionNotFound =
          e is StateError ||
          (e is FirebaseFunctionsException && e.code == 'not-found');
      if (!isFunctionNotFound) rethrow;
    }

    // Fallback: 클라이언트 직접 쓰기
    final todayKey = AppDateUtils.todayKey();
    final userRef = _firestore.collection('users').doc(uid);
    var alreadyCheckedIn = false;

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final groupCheckIns =
          snap.data()?['groupLastCheckInDate'] as Map<String, dynamic>? ?? {};
      final lastCheckIn = groupCheckIns[groupId] as String?;
      if (lastCheckIn == todayKey) {
        alreadyCheckedIn = true;
        return;
      }
      tx.update(userRef, {
        'groupLastCheckInDate.$groupId': todayKey,
        'groupCurrencies.$groupId':
            FieldValue.increment(CurrencyConstants.dailyCheckInReward),
      });
    });
    return !alreadyCheckedIn;
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
