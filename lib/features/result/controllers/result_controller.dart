import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/repositories/bomb_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../models/game_result_model.dart';

part 'result_controller.g.dart';

/// 게임 결과 계산 (폭발 기록 + pass 로그 기반)
@riverpod
Future<GameResultModel> gameResult(Ref ref, String groupId) async {
  final bombRepo = ref.read(bombRepositoryProvider);

  // 병렬 데이터 조회
  final group = await ref
      .read(groupRepositoryProvider)
      .watchGroup(groupId)
      .first;
  final nicknames = group?.memberNicknames ?? {};
  final memberUids = group?.memberUids ?? [];

  final results = await Future.wait([
    bombRepo.fetchExplodedBombs(groupId),
    bombRepo.fetchPassCounts(groupId),
    bombRepo.fetchPassLogs(groupId),
    bombRepo.fetchItemUsedCounts(groupId),
  ]);

  final bombs = results[0] as List;
  final passCounts = results[1] as Map<String, int>;
  final passLogs = results[2] as List<Map<String, dynamic>>;
  final itemUsedCounts = results[3] as Map<String, int>;

  // uid별 폭발 횟수
  final explodeCountMap = <String, int>{};
  for (final bomb in bombs) {
    final explodedUid = (bomb as dynamic).explodedUid as String?;
    if (explodedUid != null) {
      explodeCountMap[explodedUid] = (explodeCountMap[explodedUid] ?? 0) + 1;
    }
  }

  // 최장 홀딩 시간 계산
  final maxHoldingMap = _computeMaxHolding(passLogs);

  // 전체 멤버 랭킹 (폭발 횟수 오름차순)
  final rankList = memberUids
      .map((uid) => PlayerResultModel(
            uid: uid,
            displayName: nicknames[uid] ?? uid,
            explodeCount: explodeCountMap[uid] ?? 0,
            passCount: passCounts[uid] ?? 0,
            maxHoldingMinutes: maxHoldingMap[uid] ?? 0,
            itemUsedCount: itemUsedCounts[uid] ?? 0,
          ))
      .toList()
    ..sort((a, b) => a.explodeCount.compareTo(b.explodeCount));

  return GameResultModel(
    groupId: groupId,
    rankList: rankList,
    endedAt: group?.gameEndedAt ?? DateTime.now(),
  );
}

/// pass 로그에서 uid별 최장 홀딩 시간(분) 계산
Map<String, int> _computeMaxHolding(List<Map<String, dynamic>> logs) {
  if (logs.isEmpty) return {};
  final maxMap = <String, int>{};

  for (int i = 0; i < logs.length; i++) {
    final toUid = logs[i]['toUid'] as String?;
    final receiveTs = logs[i]['timestamp'];
    if (toUid == null || receiveTs == null) continue;

    final receiveTime = _toDateTime(receiveTs);
    if (receiveTime == null) continue;

    for (int j = i + 1; j < logs.length; j++) {
      if (logs[j]['fromUid'] != toUid) continue;
      final passTime = _toDateTime(logs[j]['timestamp']);
      if (passTime == null) break;
      final minutes = passTime.difference(receiveTime).inMinutes;
      maxMap[toUid] = max(maxMap[toUid] ?? 0, minutes);
      break;
    }
  }
  return maxMap;
}

DateTime? _toDateTime(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

@riverpod
class ResultController extends _$ResultController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> shareResult(ScreenshotController screenshotCtrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final Uint8List? image = await screenshotCtrl.capture(
        delay: const Duration(milliseconds: 20),
      );
      if (image == null) throw Exception('이미지 캡처에 실패했습니다. 다시 시도해주세요.');
      try {
        await Share.shareXFiles(
          [XFile.fromData(image, mimeType: 'image/png', name: 'bombastic_result.png')],
        );
      } catch (e) {
        throw Exception('공유에 실패했습니다: $e');
      }
    });
  }
}
