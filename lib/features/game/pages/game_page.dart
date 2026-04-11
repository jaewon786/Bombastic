import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../data/firebase/firebase_providers.dart';
import '../../../data/models/group_model.dart';
import '../../group/controllers/group_controller.dart';
import '../../mission/pages/mission_page.dart';
import '../../shop/pages/shop_page.dart';
import '../controllers/game_controller.dart';
import 'tabs/home_tab.dart';
import 'tabs/log_tab.dart';
import 'tabs/settings_tab.dart';

class GamePage extends ConsumerWidget {
  const GamePage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(watchGroupProvider(groupId));

    return groupAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('오류: $e')),
      ),
      data: (group) {
        if (group == null) {
          return const Scaffold(
            body: Center(child: Text('그룹을 찾을 수 없습니다.')),
          );
        }

        return switch (group.status) {
          GroupStatus.waiting => _WaitingView(group: group),
          GroupStatus.playing => _PlayingTabView(groupId: groupId),
          GroupStatus.finished => _FinishedView(group: group),
        };
      },
    );
  }
}

// ── Waiting 상태 UI ──────────────────────────────────────────

List<Widget> _buildGlobalActions(WidgetRef ref, String groupId) {
  final currency = ref.watch(currentUserProvider).asData?.value?.groupCurrencies[groupId] ?? 0;
  return [
    Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '$currency 🪙',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    ),
  ];
}

class _WaitingView extends ConsumerWidget {
  const _WaitingView({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final isHost = group.memberUids.isNotEmpty && group.memberUids[0] == uid;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        title: Text(group.name),
        actions: _buildGlobalActions(ref, group.id),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('참여 코드',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        group.joinCode,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '참여자 (${group.memberUids.length}/${group.maxMembers})',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: group.memberUids.length,
                  itemBuilder: (_, i) {
                    final memberUid = group.memberUids[i];
                    final nickname =
                        group.memberNicknames[memberUid] ?? '알 수 없음';
                    final isSelf = memberUid == uid;
                    final isMemberHost = i == 0;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(nickname.isNotEmpty ? nickname[0] : '?'),
                      ),
                      title: Text(
                        '$nickname${isSelf ? ' (나)' : ''}',
                        style: TextStyle(
                          fontWeight: isSelf
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isMemberHost
                          ? const Chip(label: Text('방장'))
                          : null,
                    );
                  },
                ),
              ),
              if (!isHost)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    '방장이 게임을 시작하면 자동으로 시작됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              if (isHost)
                ElevatedButton(
                  onPressed: group.memberUids.length >= 2
                      ? () async {
                          try {
                            await ref
                                .read(gameControllerProvider.notifier)
                                .startGame(groupId: group.id);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('게임 시작 실패: $e')),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('게임 시작',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Playing 상태 — 하단 탭 뷰 ──────────────────────────────────

class _PlayingTabView extends ConsumerStatefulWidget {
  const _PlayingTabView({required this.groupId});

  final String groupId;

  @override
  ConsumerState<_PlayingTabView> createState() => _PlayingTabViewState();
}

class _PlayingTabViewState extends ConsumerState<_PlayingTabView> {
  int _tabIndex = 2; // 홈 탭 기본

  static const _tabs = [
    NavigationDestination(icon: Icon(Icons.store), label: '상점'),
    NavigationDestination(icon: Icon(Icons.assignment), label: '미션'),
    NavigationDestination(icon: Icon(Icons.home), label: '홈'),
    NavigationDestination(icon: Icon(Icons.history), label: '로그'),
    NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
  ];

  @override
  Widget build(BuildContext context) {
    final groupName = ref
            .watch(watchGroupProvider(widget.groupId))
            .asData
            ?.value
            ?.name ??
        'Bombastic';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        title: Text('💣 $groupName'),
        actions: _buildGlobalActions(ref, widget.groupId),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          ShopBody(groupId: widget.groupId),
          MissionBody(groupId: widget.groupId),
          HomeTab(groupId: widget.groupId),
          LogTab(groupId: widget.groupId),
          SettingsTab(groupId: widget.groupId),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: _tabs,
      ),
    );
  }
}

// ── Finished 상태 UI ─────────────────────────────────────────

class _FinishedView extends ConsumerWidget {
  const _FinishedView({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        title: Text(group.name),
        actions: _buildGlobalActions(ref, group.id), // Added currency here as well for consistency
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              '게임이 종료되었습니다!',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  context.push('${AppRoutes.result}/${group.id}'),
              child: const Text('결과 보기'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
