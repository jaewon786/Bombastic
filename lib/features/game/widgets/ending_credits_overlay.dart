import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bomb_pass/core/services/audio_service.dart';
import 'package:bomb_pass/data/models/bomb_model.dart';
import 'package:bomb_pass/data/models/group_model.dart';
import 'package:bomb_pass/data/repositories/bomb_repository.dart';
import 'package:bomb_pass/features/game/controllers/credits_controller.dart';

class EndingCreditsOverlay extends ConsumerStatefulWidget {
  const EndingCreditsOverlay({
    super.key,
    required this.group,
    required this.onDismissed,
  });

  final GroupModel group;
  final VoidCallback onDismissed;

  @override
  ConsumerState<EndingCreditsOverlay> createState() =>
      _EndingCreditsOverlayState();
}

class _EndingCreditsOverlayState extends ConsumerState<EndingCreditsOverlay>
    with SingleTickerProviderStateMixin {
  // 초기 duration은 임시값 — _maybeStart에서 콘텐츠 높이 측정 후 덮어씀
  late final AnimationController _controller;
  final _contentKey = GlobalKey();
  double _contentHeight = 0;
  bool _started = false;

  CreditsSnapshotData? _snapshot;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDismissed();
        }
      });

    _initSnapshot();
  }

  Future<void> _initSnapshot() async {
    final notifier =
        ref.read(creditsShownProvider(widget.group.id).notifier);

    var snapshot = await notifier.loadSnapshot();

    if (snapshot == null) {
      final nicknames = widget.group.memberUids
          .map((uid) => widget.group.memberNicknames[uid] ?? uid)
          .toList();
      final awards = await _fetchAwards(
        widget.group.id,
        widget.group.memberUids,
        widget.group.memberNicknames,
      );
      await notifier.saveSnapshot(widget.group.name, nicknames, awards);
      snapshot = CreditsSnapshotData(
        groupName: widget.group.name,
        nicknames: nicknames,
        awards: awards,
      );
    }

    if (mounted) setState(() => _snapshot = snapshot);
  }

  Future<List<CreditsAwardData>> _fetchAwards(
    String groupId,
    List<String> memberUids,
    Map<String, String> nicknames,
  ) async {
    try {
      final bombRepo = ref.read(bombRepositoryProvider);

      final results = await Future.wait([
        bombRepo.fetchExplodedBombs(groupId),
        bombRepo.fetchPassCounts(groupId),
        bombRepo.fetchPassLogs(groupId),
        bombRepo.fetchItemUsedCounts(groupId),
      ]);

      final bombs = results[0] as List<BombModel>;
      final passCounts = results[1] as Map<String, int>;
      final passLogs = results[2] as List<Map<String, dynamic>>;
      final itemUsedCounts = results[3] as Map<String, int>;

      final explodeCountMap = <String, int>{};
      for (final bomb in bombs) {
        final uid = bomb.explodedUid;
        if (uid != null) {
          explodeCountMap[uid] = (explodeCountMap[uid] ?? 0) + 1;
        }
      }

      final maxHoldingMap = _computeMaxHolding(passLogs);

      final players = memberUids
          .map((uid) => _PlayerStats(
                displayName: nicknames[uid] ?? uid,
                explodeCount: explodeCountMap[uid] ?? 0,
                passCount: passCounts[uid] ?? 0,
                maxHoldingMinutes: maxHoldingMap[uid] ?? 0,
                itemUsedCount: itemUsedCounts[uid] ?? 0,
              ))
          .toList();

      return _buildAwards(players);
    } catch (_) {
      return [];
    }
  }

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

  List<CreditsAwardData> _buildAwards(List<_PlayerStats> players) {
    if (players.isEmpty) return [];
    final awards = <CreditsAwardData>[];

    // 패배자 — 폭발 횟수 최다 (항상 맨 앞)
    final maxExplode =
        players.map((p) => p.explodeCount).reduce((a, b) => a > b ? a : b);
    if (maxExplode > 0) {
      awards.add(CreditsAwardData(
        emoji: '💥',
        title: '패배자',
        subtitle: '마지막까지 폭탄과 함께한 사람',
        winners: players
            .where((p) => p.explodeCount == maxExplode)
            .map((p) => p.displayName)
            .toList(),
        isLoser: true,
      ));
    }

    // 폭탄 러버 — 최장 홀딩
    final maxHolding =
        players.map((p) => p.maxHoldingMinutes).reduce((a, b) => a > b ? a : b);
    if (maxHolding > 0) {
      awards.add(CreditsAwardData(
        emoji: '🔥',
        title: '폭탄 러버',
        subtitle: '가장 오랫동안 폭탄을 들고 있던 사람',
        winners: players
            .where((p) => p.maxHoldingMinutes == maxHolding)
            .map((p) => p.displayName)
            .toList(),
      ));

      // 안전제일 — 최단 홀딩 (홀딩 경험자 중)
      final holdingValues = players
          .where((p) => p.maxHoldingMinutes > 0)
          .map((p) => p.maxHoldingMinutes)
          .toList();
      if (holdingValues.isNotEmpty) {
        final minHolding = holdingValues.reduce((a, b) => a < b ? a : b);
        if (minHolding != maxHolding) {
          awards.add(CreditsAwardData(
            emoji: '🛡️',
            title: '안전제일',
            subtitle: '누구보다 빠르게 다른 사람에게 폭탄을 넘긴 사람',
            winners: players
                .where((p) => p.maxHoldingMinutes == minHolding)
                .map((p) => p.displayName)
                .toList(),
          ));
        }
      }
    }

    // 다재다능 — 아이템 최다 사용
    final maxItems =
        players.map((p) => p.itemUsedCount).reduce((a, b) => a > b ? a : b);
    if (maxItems > 0) {
      awards.add(CreditsAwardData(
        emoji: '🎯',
        title: '다재다능',
        subtitle: '가장 많은 아이템을 사용한 사람',
        winners: players
            .where((p) => p.itemUsedCount == maxItems)
            .map((p) => p.displayName)
            .toList(),
      ));
    }

    // 폭탄 배송 — 패스 횟수 최다
    final maxPass =
        players.map((p) => p.passCount).reduce((a, b) => a > b ? a : b);
    if (maxPass > 0) {
      awards.add(CreditsAwardData(
        emoji: '🚀',
        title: '폭탄 배송',
        subtitle: '다른 사람에게 폭탄을 가장 많이 전달한 사람',
        winners: players
            .where((p) => p.passCount == maxPass)
            .map((p) => p.displayName)
            .toList(),
      ));
    }

    return awards;
  }

  @override
  void dispose() {
    ref.read(audioServiceProvider).stopBgm();
    _controller.dispose();
    super.dispose();
  }

  void _maybeStart(double screenHeight) {
    if (_started || _snapshot == null) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      final contentH = box?.size.height ?? 1200.0;
      setState(() => _contentHeight = contentH);

      // 콘텐츠 길이에 비례한 재생 시간 (70px/초, 최소 20초 ~ 최대 120초)
      const scrollSpeed = 70.0;
      final totalDistance = screenHeight + contentH;
      final durationSec = (totalDistance / scrollSpeed).clamp(20.0, 120.0);
      _controller.duration =
          Duration(milliseconds: (durationSec * 1000).round());

      _controller.forward();
      ref.read(audioServiceProvider).playBgm('EndingCreditSound1.mp3');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_snapshot == null) {
      return const Scaffold(backgroundColor: Colors.black, body: SizedBox());
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    _maybeStart(screenHeight);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final totalDistance = screenHeight + _contentHeight;
              final dy = screenHeight - _controller.value * totalDistance;
              return Transform.translate(
                offset: Offset(0, dy),
                child: child,
              );
            },
            child: OverflowBox(
              minHeight: 0,
              maxHeight: double.infinity,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: _CreditsContent(
                    key: _contentKey,
                    snapshot: _snapshot!,
                  ),
                ),
              ),
            ),
          ),

          // X 버튼
          Positioned(
            top: topPadding + 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 28),
              tooltip: '건너뛰기',
              onPressed: widget.onDismissed,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 플레이어 통계 (내부 계산용) ────────────────────────────────

class _PlayerStats {
  const _PlayerStats({
    required this.displayName,
    required this.explodeCount,
    required this.passCount,
    required this.maxHoldingMinutes,
    required this.itemUsedCount,
  });

  final String displayName;
  final int explodeCount;
  final int passCount;
  final int maxHoldingMinutes;
  final int itemUsedCount;
}

// ── 크레딧 내용 ───────────────────────────────────────────────

class _CreditsContent extends StatelessWidget {
  const _CreditsContent({
    super.key,
    required this.snapshot,
  });

  final CreditsSnapshotData snapshot;

  @override
  Widget build(BuildContext context) {
    final loserAward =
        snapshot.awards.where((a) => a.isLoser).firstOrNull;
    final otherAwards =
        snapshot.awards.where((a) => !a.isLoser).toList();
    final loserName =
        loserAward?.winners.join(', ') ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 64),

        // 인트로
        _center(
          Column(
            children: [
              const Text('💣',
                  style: TextStyle(fontSize: 72, color: Colors.white)),
              const SizedBox(height: 16),
              const Text(
                'Bombastic',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                snapshot.groupName,
                style: const TextStyle(
                    fontSize: 18, color: Colors.white70, letterSpacing: 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),

        // ── 패배자 대형 광고 ──────────────────────────────────
        if (loserAward != null) ...[
          _LoserShowcase(award: loserAward),
          const SizedBox(height: 100),
        ],

        // ── 명예의 전당 (패배자 외 나머지) ───────────────────
        if (otherAwards.isNotEmpty) ...[
          _center(_heading('🏆 명예의 전당')),
          const SizedBox(height: 32),
          ...otherAwards.map((a) => _AwardItem(award: a)),
          const SizedBox(height: 80),
        ],

        // 참여자 목록
        _center(_heading('참여자')),
        const SizedBox(height: 24),
        ...snapshot.nicknames.map(
          (nickname) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              nickname,
              style: const TextStyle(
                  fontSize: 20, color: Colors.white, letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        const SizedBox(height: 48),

        _center(
          Column(
            children: [
              const Text(
                '플레이에 감사드립니다! 🙏',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              if (loserName.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '단, $loserName 님은\n내기를 꼭 이행하셔야 합니다 😈',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.orangeAccent,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 200),
      ],
    );
  }

  Widget _heading(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
        textAlign: TextAlign.center,
      );

  Widget _center(Widget child) => Center(child: child);
}

// ── 패배자 대형 광고판 ────────────────────────────────────────

class _LoserShowcase extends StatelessWidget {
  const _LoserShowcase({required this.award});

  final CreditsAwardData award;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(20),
        color: Colors.red.withValues(alpha: 0.12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // 경고성 상단 뱃지
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '⚠️  이번 게임의 결과  ⚠️',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 폭발 이모지
          const Text('💥', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),

          // 패배자 타이틀
          const Text(
            'P A T H E T I C',
            style: TextStyle(
              fontSize: 13,
              color: Colors.redAccent,
              letterSpacing: 6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '패배자',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.redAccent,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 이름 (아주 크게)
          ...award.winners.map(
            (name) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 서브타이틀
          Text(
            award.subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white60,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // 놀리는 문구
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              award.winners.length == 1
                  ? '${award.winners.first}님, 내기 잊지 마세요 😈'
                  : '두 분 다... 내기 잊지 마세요 😈',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.orangeAccent,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 일반 어워드 항목 ──────────────────────────────────────────

class _AwardItem extends StatelessWidget {
  const _AwardItem({required this.award});

  final CreditsAwardData award;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Column(
        children: [
          Text(award.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(
            award.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            award.subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          ...award.winners.map(
            (name) => Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
