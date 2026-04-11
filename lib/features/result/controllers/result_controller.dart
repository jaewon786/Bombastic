import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/repositories/bomb_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../models/game_result_model.dart';

part 'result_controller.g.dart';

/// 게임 결과 계산 (폭발 기록 기반)
@riverpod
Future<GameResultModel> gameResult(Ref ref, String groupId) async {
  final bombs =
      await ref.read(bombRepositoryProvider).fetchExplodedBombs(groupId);

  // 그룹 정보에서 닉네임 맵 가져오기
  final group = await ref
      .read(groupRepositoryProvider)
      .watchGroup(groupId)
      .first;
  final nicknames = group?.memberNicknames ?? {};
  final memberUids = group?.memberUids ?? [];

  // uid별 폭발 횟수 집계
  final countMap = <String, int>{};
  for (final bomb in bombs) {
    if (bomb.explodedUid != null) {
      countMap[bomb.explodedUid!] = (countMap[bomb.explodedUid!] ?? 0) + 1;
    }
  }

  // 전달 횟수 집계
  final passCounts =
      await ref.read(bombRepositoryProvider).fetchPassCounts(groupId);

  // 모든 멤버를 포함한 랭킹 생성 (폭발 0회인 멤버도 포함)
  final rankList = memberUids
      .map(
        (uid) => PlayerResultModel(
          uid: uid,
          displayName: nicknames[uid] ?? uid,
          explodeCount: countMap[uid] ?? 0,
          passCount: passCounts[uid] ?? 0,
        ),
      )
      .toList()
    ..sort((a, b) => a.explodeCount.compareTo(b.explodeCount));

  return GameResultModel(
    groupId: groupId,
    rankList: rankList,
    endedAt: group?.gameEndedAt ?? DateTime.now(),
  );
}

@riverpod
class ResultController extends _$ResultController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// screenshot으로 카드 이미지 캡처 후 공유
  Future<void> shareResult(ScreenshotController screenshotCtrl) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final Uint8List? image = await screenshotCtrl.capture();
      if (image == null) throw Exception('이미지 캡처 실패');
      await Share.shareXFiles(
        [XFile.fromData(image, mimeType: 'image/png', name: 'bombastic_result.png')],
      );
    });
  }
}
