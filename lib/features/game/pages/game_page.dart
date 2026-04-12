import 'package:bomb_pass/core/router/app_router.dart';
import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bomb_pass/data/models/group_model.dart';
import 'package:bomb_pass/features/game/controllers/game_controller.dart';
import 'package:bomb_pass/features/game/pages/tabs/home_tab.dart';
import 'package:bomb_pass/features/game/pages/tabs/log_tab.dart';
import 'package:bomb_pass/features/game/pages/tabs/settings_tab.dart';
import 'package:bomb_pass/features/game/controllers/credits_controller.dart';
import 'package:bomb_pass/features/game/widgets/ending_credits_overlay.dart';
import 'package:bomb_pass/features/group/controllers/group_controller.dart';
import 'package:bomb_pass/features/mission/pages/mission_page.dart';
import 'package:bomb_pass/features/shop/pages/shop_page.dart';
import 'package:bomb_pass/widgets/group_currency_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class GamePage extends ConsumerWidget {
  const GamePage({required this.groupId, super.key});

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
          // 그룹 삭제(마지막 멤버 탈퇴 등) 시 자동으로 홈으로 이동
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(AppRoutes.home);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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

String _itemUsageMessage(String nickname, String itemType) {
  return switch (itemType) {
    'swapOrder' => '$nickname님이 순서를 섞었습니다! 🔀',
    'reverseDirection' => '$nickname님이 전달 방향을 반전했습니다! ↩️',
    'shrinkDuration' => '$nickname님이 타이머를 단축했습니다! ⏱️',
    'guardianAngel' => '$nickname님의 수호천사가 폭발을 막았습니다! 😇',
    _ => '$nickname님이 아이템을 사용했습니다!',
  };
}

// ── Waiting 상태 UI ──────────────────────────────────────────

List<Widget> _buildGlobalActions(String groupId) {
  return [GroupCurrencyBadge(groupId: groupId)];
}

class _WaitingView extends ConsumerWidget {
  const _WaitingView({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider);
    final isHost = group.memberUids.isNotEmpty && group.memberUids[0] == uid;

    // 강퇴된 경우 (내가 더 이상 멤버가 아닌 경우) 홈으로 이동
    if (uid != null && !group.memberUids.contains(uid)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.home);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        title: Text(group.name),
        actions: _buildGlobalActions(group.id),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 참여 코드 — 탭하면 클립보드 복사
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: group.joinCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('참여 코드가 복사되었습니다 📋'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('참여 코드',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(width: 6),
                            Icon(Icons.copy,
                                size: 14,
                                color: Colors.grey.withValues(alpha: 0.7)),
                          ],
                        ),
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
              ),
              const SizedBox(height: 8),
              _InviteLinkTile(joinCode: group.joinCode),
              const SizedBox(height: 16),
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
                    final showKick = isHost && !isMemberHost;
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
                          : showKick
                              ? IconButton(
                                  icon: const Icon(Icons.person_remove,
                                      color: Colors.red),
                                  tooltip: '강퇴',
                                  onPressed: () => _confirmKick(
                                      context, ref, memberUid, nickname),
                                )
                              : null,
                    );
                  },
                ),
              ),
              if (!isHost) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '방장이 게임을 시작하면 자동으로 시작됩니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => _confirmLeave(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('그룹 나가기'),
                  ),
                ),
              ],
              if (isHost) ...[
                // 방장 혼자일 때만 방 폐쇄 버튼 노출
                if (group.memberUids.length == 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: () => _confirmAbort(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('방 폐쇄'),
                    ),
                  ),
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('그룹 나가기'),
        content: const Text('정말 이 그룹을 나가시겠어요?'),
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

    await ref
        .read(groupControllerProvider.notifier)
        .leaveGroup(groupId: group.id);

    if (!context.mounted) return;
    final state = ref.read(groupControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('나가기 실패: ${state.error}')),
      );
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _confirmKick(
    BuildContext context,
    WidgetRef ref,
    String kickedUid,
    String nickname,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('멤버 강퇴'),
        content: Text('$nickname 님을 강퇴하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('강퇴'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref
        .read(groupControllerProvider.notifier)
        .kickMember(groupId: group.id, kickedUid: kickedUid);

    if (!context.mounted) return;
    final state = ref.read(groupControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('강퇴 실패: ${state.error}')),
      );
    }
  }

  Future<void> _confirmAbort(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('방 폐쇄'),
        content: const Text('방을 폐쇄하면 그룹이 삭제됩니다.\n정말 취소하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('폐쇄'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await ref
        .read(groupControllerProvider.notifier)
        .leaveGroup(groupId: group.id);

    if (!context.mounted) return;
    final state = ref.read(groupControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방 폐쇄 실패: ${state.error}')),
      );
    } else {
      context.go(AppRoutes.home);
    }
  }
}

// ── 초대 링크 하이퍼링크 타일 ────────────────────────────────────

class _InviteLinkTile extends StatelessWidget {
  const _InviteLinkTile({required this.joinCode});

  final String joinCode;

  String get _link => 'bombastic://join?code=$joinCode';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.link, size: 18, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('초대 링크가 복사되었습니다 🔗'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  _link,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blueAccent,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.share, size: 20),
              tooltip: '공유',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Share.share(_link),
            ),
          ],
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

  Map<String, dynamic>? _lastShownUsage;

  @override
  Widget build(BuildContext context) {
    // 아이템 사용 알림 리스너
    ref.listen(
      latestItemUsageProvider(widget.groupId),
      (prev, next) {
        final usage = next.asData?.value;
        if (usage == null) return;
        // 같은 이벤트 중복 방지
        if (_lastShownUsage != null &&
            _lastShownUsage!['usedAt'] == usage['usedAt']) return;
        _lastShownUsage = usage;

        final uid = ref.read(currentUidProvider);
        final usedByUid = usage['uid'] as String? ?? '';
        final itemType = usage['itemType'] as String? ?? '';
        // 수호천사는 자동 발동이므로 본인에게도 알림
        if (usedByUid == uid && itemType != 'guardianAngel') return;

        final group = ref.read(watchGroupProvider(widget.groupId)).asData?.value;
        final nick = group?.memberNicknames[usedByUid] ?? usedByUid;
        final message = _itemUsageMessage(nick, itemType);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );

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
        actions: _buildGlobalActions(widget.groupId),
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

class _FinishedView extends ConsumerStatefulWidget {
  const _FinishedView({required this.group});

  final GroupModel group;

  @override
  ConsumerState<_FinishedView> createState() => _FinishedViewState();
}

class _FinishedViewState extends ConsumerState<_FinishedView> {
  @override
  Widget build(BuildContext context) {
    final creditsState =
        ref.watch(creditsShownProvider(widget.group.id));

    return creditsState.when(
      // SharedPreferences 로딩 중엔 검은 화면 유지 (크레딧과 자연스럽게 연결)
      loading: () => const Scaffold(backgroundColor: Colors.black, body: SizedBox()),
      error: (_, __) => _showCredits(),
      data: (shown) => shown ? _FinishedTabView(group: widget.group) : _showCredits(),
    );
  }

  Widget _showCredits() {
    return EndingCreditsOverlay(
      group: widget.group,
      onDismissed: () =>
          ref.read(creditsShownProvider(widget.group.id).notifier).markShown(),
    );
  }
}

// ── Finished 탭 뷰 (크레딧 이후) ────────────────────────────────

class _FinishedTabView extends ConsumerStatefulWidget {
  const _FinishedTabView({required this.group});

  final GroupModel group;

  @override
  ConsumerState<_FinishedTabView> createState() => _FinishedTabViewState();
}

class _FinishedTabViewState extends ConsumerState<_FinishedTabView> {
  int _tabIndex = 0; // 홈 탭 기본

  static const _tabs = [
    NavigationDestination(icon: Icon(Icons.home), label: '홈'),
    NavigationDestination(icon: Icon(Icons.history), label: '로그'),
    NavigationDestination(icon: Icon(Icons.settings), label: '설정'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        title: Text('🏆 ${widget.group.name}'),
        actions: _buildGlobalActions(widget.group.id),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _FinishedHomeTab(group: widget.group),
          LogTab(groupId: widget.group.id),
          SettingsTab(groupId: widget.group.id),
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

// ── Finished 홈 탭 ───────────────────────────────────────────

class _FinishedHomeTab extends StatelessWidget {
  const _FinishedHomeTab({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            const Text(
              '게임이 종료되었습니다!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              group.name,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () =>
                    context.push('${AppRoutes.result}/${group.id}'),
                icon: const Icon(Icons.emoji_events),
                label: const Text('결과 보기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
