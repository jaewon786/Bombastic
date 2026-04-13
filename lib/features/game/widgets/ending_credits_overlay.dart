import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/group_model.dart';
import '../../result/controllers/result_controller.dart';
import '../../result/models/game_result_model.dart';

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
  late final AnimationController _controller;
  final _contentKey = GlobalKey();
  double _contentHeight = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDismissed();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _maybeStart() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) setState(() => _contentHeight = box.size.height);
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    _maybeStart();

    final resultAsync = ref.watch(gameResultProvider(widget.group.id));
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

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
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _CreditsContent(
                  key: _contentKey,
                  group: widget.group,
                  resultAsync: resultAsync,
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

// ── 크레딧 내용 ───────────────────────────────────────────────

class _CreditsContent extends StatelessWidget {
  const _CreditsContent({
    super.key,
    required this.group,
    required this.resultAsync,
  });

  final GroupModel group;
  final AsyncValue<GameResultModel> resultAsync;

  @override
  Widget build(BuildContext context) {
    final awards = resultAsync.asData?.value != null
        ? _computeAwards(resultAsync.asData!.value)
        : <_Award>[];

    final loserName = awards
        .where((a) => a.isLoser)
        .expand((a) => a.winners)
        .join(', ');

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
                group.name,
                style: const TextStyle(
                    fontSize: 18, color: Colors.white70, letterSpacing: 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),

        // 명예의 전당
        if (awards.isNotEmpty) ...[
          _center(_heading('🏆 명예의 전당')),
          const SizedBox(height: 32),
          ...awards.map((a) => _AwardItem(award: a)),
          const SizedBox(height: 80),
        ],

        // 참여자 목록
        _center(_heading('참여자')),
        const SizedBox(height: 24),
        ...group.memberUids.map((uid) {
          final nickname = group.memberNicknames[uid] ?? uid;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              nickname,
              style: const TextStyle(
                  fontSize: 20, color: Colors.white, letterSpacing: 1),
              textAlign: TextAlign.center,
            ),
          );
        }),

        const SizedBox(height: 48),

        // 감사 + 패배자 장난 문구
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

        const SizedBox(height: 700),
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

  List<_Award> _computeAwards(GameResultModel result) {
    final players = result.rankList;
    if (players.isEmpty) return [];

    final awards = <_Award>[];

    // 1. 패배자 — 맨 먼저
    final maxExplode =
        players.map((p) => p.explodeCount).reduce((a, b) => a > b ? a : b);
    if (maxExplode > 0) {
      final winners = players
          .where((p) => p.explodeCount == maxExplode)
          .map((p) => p.displayName)
          .toList();
      awards.add(_Award(
        emoji: '💥',
        title: '패배자',
        subtitle: '진정한 인간 폭탄... 🙃',
        winners: winners,
        isLoser: true,
      ));
    }

    // 2. 폭탄 러버
    final maxHolding =
        players.map((p) => p.maxHoldingMinutes).reduce((a, b) => a > b ? a : b);
    if (maxHolding > 0) {
      final winners = players
          .where((p) => p.maxHoldingMinutes == maxHolding)
          .map((p) => p.displayName)
          .toList();
      awards.add(_Award(
        emoji: '🔥',
        title: '폭탄 러버',
        subtitle: '폭탄을 가장 오래 들고 있던 사람',
        winners: winners,
      ));
    }

    // 3. 안전제일
    final holdingValues = players
        .where((p) => p.maxHoldingMinutes > 0)
        .map((p) => p.maxHoldingMinutes)
        .toList();
    if (holdingValues.isNotEmpty) {
      final minHolding = holdingValues.reduce((a, b) => a < b ? a : b);
      if (minHolding != maxHolding) {
        final winners = players
            .where((p) => p.maxHoldingMinutes == minHolding)
            .map((p) => p.displayName)
            .toList();
        awards.add(_Award(
          emoji: '🛡️',
          title: '안전제일',
          subtitle: '폭탄을 가장 적게 들고 있던 사람',
          winners: winners,
        ));
      }
    }

    // 4. 다재다능
    final maxItems =
        players.map((p) => p.itemUsedCount).reduce((a, b) => a > b ? a : b);
    if (maxItems > 0) {
      final winners = players
          .where((p) => p.itemUsedCount == maxItems)
          .map((p) => p.displayName)
          .toList();
      awards.add(_Award(
        emoji: '🎯',
        title: '다재다능',
        subtitle: '아이템을 가장 많이 사용한 사람',
        winners: winners,
      ));
    }

    // 5. 폭탄 배송 (📦 → 🚀, 픽셀 오류 수정)
    final maxPass =
        players.map((p) => p.passCount).reduce((a, b) => a > b ? a : b);
    if (maxPass > 0) {
      final winners = players
          .where((p) => p.passCount == maxPass)
          .map((p) => p.displayName)
          .toList();
      awards.add(_Award(
        emoji: '🚀',
        title: '폭탄 배송',
        subtitle: '누구보다 빠르게 폭탄을 넘긴 사람',
        winners: winners,
      ));
    }

    return awards;
  }
}

// ── 어워드 데이터 ─────────────────────────────────────────────

class _Award {
  const _Award({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.winners,
    this.isLoser = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final List<String> winners;
  final bool isLoser;
}

// ── 일반 어워드 항목 ──────────────────────────────────────────

class _AwardItem extends StatelessWidget {
  const _AwardItem({required this.award});

  final _Award award;

  @override
  Widget build(BuildContext context) {
    if (award.isLoser) return _LoserAwardItem(award: award);

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

// ── 패배자 전용 강조 위젯 ─────────────────────────────────────

class _LoserAwardItem extends StatelessWidget {
  const _LoserAwardItem({required this.award});

  final _Award award;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 56),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.redAccent.withValues(alpha: 0.6), width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: Colors.red.withValues(alpha: 0.08),
        ),
        child: Column(
          children: [
            const Text('💥', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 10),
            const Text(
              '패배자',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                letterSpacing: 4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              award.subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white54,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ...award.winners.map(
              (name) => Text(
                name,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              award.winners.length == 1
                  ? '${award.winners.first}님, 수고하셨습니다... 👋'
                  : '두 분 다 수고하셨습니다... 👋',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white38,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
