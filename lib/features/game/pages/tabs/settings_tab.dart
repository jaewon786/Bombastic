import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../data/models/group_model.dart';
import '../../../admin/widgets/admin_cli_dialog.dart';
import '../../../group/controllers/group_controller.dart';
import '../../controllers/credits_controller.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final group = ref.watch(watchGroupProvider(groupId)).asData?.value;
    final isFinished = group?.status == GroupStatus.finished;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 테마 설정
        const Text(
          '테마',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('시스템 설정 따름'),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).setMode(v!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('라이트 모드'),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).setMode(v!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('다크 모드'),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (v) =>
                    ref.read(themeModeProvider.notifier).setMode(v!),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 개발자 기능
        const Text(
          '개발자 기능',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.developer_mode),
            title: const Text('관리자 도구'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AdminCliDialog(groupId: groupId),
            ),
          ),
        ),

        // 게임 종료 후 기능
        if (isFinished) ...[
          const SizedBox(height: 24),
          const Text(
            '그룹',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.movie_filter_outlined),
                  title: const Text('엔딩 크레딧 다시보기'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => ref
                      .read(creditsShownProvider(groupId).notifier)
                      .showAgain(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text(
                    '그룹 나가기',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text('그룹을 나가면 목록에서 사라집니다.'),
                  onTap: () => _confirmLeave(context, ref),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('그룹 나가기'),
        content: const Text(
          '정말 이 그룹을 나가시겠어요?\n모든 멤버가 나가면 그룹 데이터가 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // 홈으로 먼저 이동하여 watchGroup 스트림을 해제한 뒤 탈퇴
    context.go(AppRoutes.home);
    unawaited(ref.read(groupControllerProvider.notifier).leaveGroup(groupId: groupId));
  }
}
