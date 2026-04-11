import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../admin/widgets/admin_cli_dialog.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
            title: const Text('Admin CLI (명령어 입력기)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => AdminCliDialog(groupId: groupId),
            ),
          ),
        ),
      ],
    );
  }
}
