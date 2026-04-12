import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/date_utils.dart';
import 'game_controller.dart';

part 'timer_controller.g.dart';

/// bombId별 폭발 요청 중복 방지
final _explodeRequested = <String>{};

/// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider
/// activeBomb의 expiresAt 기준으로 1초마다 갱신
/// 0초 도달 시 서버에 폭발 요청
@riverpod
String bombTimer(Ref ref, String groupId) {
  final bomb = ref.watch(activeBombProvider(groupId)).asData?.value;
  if (bomb == null) return '00:00:00';

  final remaining = bomb.expiresAt.difference(DateTime.now());

  if (remaining.isNegative) {
    // 만료됨 — 서버에 폭발 요청 (bombId당 1회만)
    if (!_explodeRequested.contains(bomb.id)) {
      _explodeRequested.add(bomb.id);
      Future.microtask(() {
        try {
          ref
              .read(gameControllerProvider.notifier)
              .explodeBomb(groupId: groupId, bombId: bomb.id);
        } catch (e) {
          debugPrint('[bombTimer] explodeBomb 호출 실패: $e');
          _explodeRequested.remove(bomb.id);
        }
      });
    }
    return '00:00:00';
  }

  // 1초마다 갱신
  final timer = Timer.periodic(const Duration(seconds: 1), (_) {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  return AppDateUtils.formatDuration(remaining);
}
