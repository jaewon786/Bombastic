import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/admin_controller.dart';

class AdminCliDialog extends ConsumerWidget {
  const AdminCliDialog({super.key, required this.groupId});

  final String groupId;

  static const _commands = [
    _AdminCmd(
      command: '/money 10000',
      label: '재화 지급',
      subtitle: '10,000 골드 추가',
      icon: Icons.monetization_on_rounded,
      color: Colors.amber,
    ),
    _AdminCmd(
      command: '/items',
      label: '아이템 전체 지급',
      subtitle: '모든 아이템 1개씩 지급',
      icon: Icons.card_giftcard_rounded,
      color: Colors.purple,
    ),
    _AdminCmd(
      command: '/mission',
      label: '출석 초기화',
      subtitle: '출석 기록 리셋',
      icon: Icons.restart_alt_rounded,
      color: Colors.teal,
    ),
    _AdminCmd(
      command: '/steal',
      label: '폭탄 강탈',
      subtitle: '폭탄을 내게로 (15초)',
      icon: Icons.front_hand_rounded,
      color: Colors.orange,
    ),
    _AdminCmd(
      command: '/explode',
      label: '즉시 폭발',
      subtitle: '내 폭탄 즉시 터뜨리기',
      icon: Icons.local_fire_department_rounded,
      color: Colors.red,
    ),
    _AdminCmd(
      command: '/endgame',
      label: '게임 종료',
      subtitle: '강제 게임 종료',
      icon: Icons.stop_circle_rounded,
      color: Colors.grey,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(adminControllerProvider).isLoading;

    return AlertDialog(
      title: const Text('관리자 도구',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _commands
              .map((cmd) => _AdminButton(
                    cmd: cmd,
                    groupId: groupId,
                    isLoading: isLoading,
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}

class _AdminCmd {
  const _AdminCmd({
    required this.command,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String command;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
}

class _AdminButton extends ConsumerWidget {
  const _AdminButton({
    required this.cmd,
    required this.groupId,
    required this.isLoading,
  });

  final _AdminCmd cmd;
  final String groupId;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isLoading ? null : () => _execute(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cmd.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(cmd.icon, size: 20, color: cmd.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cmd.label,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(cmd.subtitle,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _execute(BuildContext context, WidgetRef ref) async {
    await ref.read(adminControllerProvider.notifier).executeCommand(
          command: cmd.command,
          groupId: groupId,
        );

    if (!context.mounted) return;
    final state = ref.read(adminControllerProvider);
    state.when(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${cmd.label} 완료')),
        );
        Navigator.pop(context);
      },
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('실패: $e')),
      ),
      loading: () {},
    );
  }
}
