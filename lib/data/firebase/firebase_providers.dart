import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

const _preferredFunctionsRegion = 'asia-northeast3';
const _fallbackFunctionsRegions = ['us-central1'];

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final preferredFunctionsRegionProvider = Provider<String>((ref) {
  return _preferredFunctionsRegion;
});

final fallbackFunctionsRegionsProvider = Provider<List<String>>((ref) {
  return _fallbackFunctionsRegions;
});

final functionsProvider = Provider<FirebaseFunctions>((ref) {
  final region = ref.watch(preferredFunctionsRegionProvider);
  return FirebaseFunctions.instanceFor(region: region);
});

Future<HttpsCallableResult<dynamic>> callHttpsCallableWithRegionFallback(
{
  required String functionName,
  Object? data,
}) async {
  const preferredRegion = _preferredFunctionsRegion;
  const fallbackRegions = _fallbackFunctionsRegions;
  final regions = <String>{preferredRegion, ...fallbackRegions}.toList();

  for (final region in regions) {
    try {
      return await FirebaseFunctions.instanceFor(region: region)
          .httpsCallable(functionName)
          .call<dynamic>(data);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'not-found') {
        continue;
      }
      rethrow;
    }
  }

  throw StateError(
    'Callable function "$functionName" was not found in regions: ${regions.join(', ')}',
  );
}

final messagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

/// 현재 로그인된 User 스트림
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// 현재 uid (null이면 미인증)
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});

/// 현재 유저 Firestore 문서 실시간 스트림
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(uid).handleError(
    (Object e) {
      debugPrint('[currentUserProvider] stream error: $e');
    },
  );
});

/// 유저 문서 raw 스트림 (UserModel 파싱 우회, Firestore 직접 watch)
final _rawUserDocProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((snap) => snap.data());
});

/// 그룹별 재화 실시간
final groupCurrencyProvider =
    Provider.family<int, String>((ref, groupId) {
  final data = ref.watch(_rawUserDocProvider).asData?.value;
  if (data == null) return 0;
  final currencies =
      data['groupCurrencies'] as Map<String, dynamic>? ?? {};
  return (currencies[groupId] as num?)?.toInt() ?? 0;
});

/// 마지막 출석 날짜 (String, e.g. "2026-04-12")
final lastCheckInDateProvider = Provider<String?>((ref) {
  final data = ref.watch(_rawUserDocProvider).asData?.value;
  if (data == null) return null;
  return data['lastCheckInDate'] as String?;
});

/// 완료한 미션 ID 목록
final completedMissionIdsProvider = Provider<List<String>>((ref) {
  final data = ref.watch(_rawUserDocProvider).asData?.value;
  if (data == null) return [];
  final list = data['completedMissionIds'] as List<dynamic>?;
  return list?.cast<String>() ?? [];
});
