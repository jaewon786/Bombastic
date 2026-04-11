import 'package:flutter/material.dart';

import '../models/game_result_model.dart';

/// SNS 공유용 결과 카드 위젯 (screenshot 패키지로 캡처됨)
class ResultShareCard extends StatelessWidget {
  const ResultShareCard({super.key, required this.result});

  final GameResultModel result;

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${result.endedAt.year}.${result.endedAt.month.toString().padLeft(2, '0')}.${result.endedAt.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('💣', style: TextStyle(fontSize: 32)),
              SizedBox(width: 8),
              Text(
                'Bombastic',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '게임 종료 · $dateStr',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // 랭킹 목록
          ...result.rankList.asMap().entries.map(
            (e) {
              final rank = e.key;
              final player = e.value;
              final isTop3 = rank < 3;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Text(
                        isTop3 ? _medals[rank] : '${rank + 1}',
                        style: TextStyle(
                          fontSize: isTop3 ? 24 : 16,
                          color: isTop3 ? null : Colors.white54,
                          fontWeight: isTop3 ? null : FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        player.displayName,
                        style: TextStyle(
                          color: rank == 0 ? const Color(0xFFFFD700) : Colors.white,
                          fontSize: 15,
                          fontWeight: rank == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '💥 ${player.explodeCount}회',
                          style: TextStyle(
                            color: player.explodeCount == 0
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '📤 ${player.passCount}패스',
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          const Text(
            '#Bombastic #봄바스틱 #폭탄돌리기',
            style: TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
