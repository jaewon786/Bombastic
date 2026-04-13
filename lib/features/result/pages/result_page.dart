import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

import '../controllers/result_controller.dart';
import '../models/game_result_model.dart';
import '../widgets/result_share_card.dart';

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label $value',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class ResultPage extends ConsumerStatefulWidget {
  const ResultPage({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _screenshotCtrl = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  void _listenShareState() {
    ref.listen<AsyncValue<void>>(resultControllerProvider, (prev, next) {
      if (!mounted) return;
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (_controller.isDismissed) _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    _listenShareState();
    final resultAsync = ref.watch(gameResultProvider(widget.groupId));
    final isSharing = ref.watch(resultControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('게임 결과')),
      body: resultAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (result) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SNS 공유용 카드
                Screenshot(
                  controller: _screenshotCtrl,
                  child: ResultShareCard(result: result),
                ),
                const SizedBox(height: 24),

                // 공유 버튼
                ElevatedButton.icon(
                  onPressed: isSharing
                      ? null
                      : () => ref
                            .read(resultControllerProvider.notifier)
                            .shareResult(_screenshotCtrl),
                  icon: isSharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: Text(isSharing ? '공유 준비 중...' : 'SNS 공유'),
                ),
                const SizedBox(height: 16),

                // 명예의 전당
                const Text(
                  '명예의 전당 🏆',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ..._buildRankCards(result),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildRankCards(GameResultModel result) {
    final total = result.rankList.length;
    return result.rankList.asMap().entries.map((e) {
      final rank = e.key;
      final player = e.value;

      // 각 카드는 150ms 간격으로 순차 등장, 애니메이션 구간 40%
      final start = (rank * 0.15).clamp(0.0, 0.8);
      final end = (start + 0.4).clamp(0.0, 1.0);
      final curve = CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );

      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.25, 0),
            end: Offset.zero,
          ).animate(curve),
          child: _RankCard(rank: rank, player: player, total: total),
        ),
      );
    }).toList();
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({
    required this.rank,
    required this.player,
    required this.total,
  });

  final int rank;
  final PlayerResultModel player;
  final int total;

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              rank < 3 ? _medals[rank] : '${rank + 1}',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _StatChip(label: '📤 패스', value: '${player.passCount}회'),
                      if (player.maxHoldingMinutes > 0)
                        _StatChip(
                          label: '⏱ 최장보유',
                          value: '${player.maxHoldingMinutes}분',
                        ),
                      if (player.itemUsedCount > 0)
                        _StatChip(
                          label: '🎁 아이템',
                          value: '${player.itemUsedCount}개',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '💥 ${player.explodeCount}회',
              style: TextStyle(
                color:
                    player.explodeCount == 0 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
