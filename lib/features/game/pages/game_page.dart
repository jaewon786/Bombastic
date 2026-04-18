import 'dart:async';

import 'package:bomb_pass/core/router/app_router.dart';
import 'package:bomb_pass/core/services/audio_service.dart';
import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:bomb_pass/data/models/group_model.dart';
import 'package:bomb_pass/data/models/bomb_model.dart';
import 'package:bomb_pass/features/game/controllers/credits_controller.dart';
import 'package:bomb_pass/features/game/controllers/game_controller.dart';
import 'package:bomb_pass/features/game/pages/tabs/home_tab.dart';
import 'package:bomb_pass/features/game/pages/tabs/log_tab.dart';
import 'package:bomb_pass/features/game/pages/tabs/settings_tab.dart';
import 'package:bomb_pass/features/game/widgets/ending_credits_overlay.dart';
import 'package:bomb_pass/features/group/controllers/group_controller.dart';
import 'package:bomb_pass/features/mission/pages/mission_page.dart';
import 'package:bomb_pass/features/shop/pages/shop_page.dart';
import 'package:bomb_pass/widgets/group_currency_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';


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
      error: (e, _) {
        // 그룹 삭제/강퇴로 인한 권한 오류 → 홈으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(AppRoutes.home);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
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

// ── 카카오링크 공유 ───────────────────────────────────────────

Future<void> _shareViaKakao(
  BuildContext context, {
  required String groupName,
  required String joinCode,
}) async {
  final template = TextTemplate(
    text: '$groupName에서 Bombastic 폭탄 돌리기 게임을 시작했어요! 💣\n아래 버튼으로 바로 입장하세요!',
    link: Link(
      androidExecutionParams: {'code': joinCode},
      iosExecutionParams: {'code': joinCode},
    ),
    buttonTitle: '앱에서 참여하기',
  );

  try {
    if (await isKakaoTalkInstalled()) {
      final uri = await ShareClient.instance.shareDefault(template: template);
      await ShareClient.instance.launchKakaoTalk(uri);
    } else {
      final uri = await WebSharerClient.instance.makeDefaultUrl(
        template: template,
      );
      await launchBrowserTab(uri, popupOpen: true);
    }
  } catch (e) {
    debugPrint('KakaoLink 공유 실패: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 공유 오류: $e'),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }
}

// ── Waiting 상태 UI ──────────────────────────────────────────

List<Widget> _buildGlobalActions(String groupId) {
  return [GroupCurrencyBadge(groupId: groupId)];
}

class _WaitingView extends ConsumerStatefulWidget {
  const _WaitingView({required this.group});

  final GroupModel group;

  @override
  ConsumerState<_WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends ConsumerState<_WaitingView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playSfx('EnteringSound1.mp3');
      ref.read(audioServiceProvider).stopBgm(); // 대기실 진입 시 메인 테마 중지
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);
    final group = widget.group;
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 참여 코드 — 탭하면 클립보드 복사 / 공유 아이콘으로 초대 링크 공유
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: group.joinCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('참여 코드가 복사되었습니다 📋'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
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
                                      color:
                                          Colors.grey.withValues(alpha: 0.7)),
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
                      IconButton(
                        icon: const Icon(Icons.share),
                        tooltip: '카카오톡으로 초대',
                        onPressed: () => _shareViaKakao(
                          context,
                          groupName: group.name,
                          joinCode: group.joinCode,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  onPressed: group.memberUids.length >= 2 &&
                          (group.memberNicknames[uid]?.isNotEmpty ?? false)
                      ? () async {
                          try {
                            await ref
                                .read(gameControllerProvider.notifier)
                                .startGame(groupId: group.id);
                            if (context.mounted) {
                              ref.read(audioServiceProvider).playSfx('GameStartSound1.mp3');
                            }
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

    // 홈으로 먼저 이동하여 watchGroup 스트림을 해제한 뒤 탈퇴
    context.go(AppRoutes.home);
    unawaited(ref.read(groupControllerProvider.notifier).leaveGroup(groupId: widget.group.id));
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
        .kickMember(groupId: widget.group.id, kickedUid: kickedUid);

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

    // 홈으로 먼저 이동하여 watchGroup 스트림을 해제한 뒤 삭제
    // (그룹 삭제 후 스트림이 권한 오류를 받는 깜빡임 방지)
    context.go(AppRoutes.home);
    unawaited(ref.read(groupControllerProvider.notifier).leaveGroup(groupId: widget.group.id));
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

  String _currentBgm = 'IngameBGM1.mp3';

  @override
  void initState() {
    super.initState();
    // 첫 진입 시 BGM을 시작하기 위해 현재 holderUid 확인이 필요합니다만,
    // activeBombProvider 데이터 로딩 이후를 위해 build() 내 listen에서 처리합니다.
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);

    // 폭탄 상태 리스너 (BGM 1/2 vs Ticking, Explosion)
    ref.listen(activeBombProvider(widget.groupId), (prev, next) {
      final oldBomb = prev?.asData?.value;
      final newBomb = next.asData?.value;
      if (newBomb == null) return;

      final audioSvc = ref.read(audioServiceProvider);

      // 폭발 처리
      if (newBomb.status == BombStatus.exploded && oldBomb?.status != BombStatus.exploded) {
        audioSvc.playSfx('ExplosionSound1.mp3');
        audioSvc.stopTicking();
        audioSvc.stopBgm();
        return;
      }

      final iHaveBomb = newBomb.holderUid == uid;
      final iHadBomb = oldBomb?.holderUid == uid;

      // 내가 폭탄을 받았을 때
      if (!iHadBomb && iHaveBomb) {
        audioSvc.stopBgm();
        audioSvc.playTicking();
      } 
      // 내가 폭탄을 넘겼을 때 (안 가짐)
      else if (iHadBomb && !iHaveBomb) {
        audioSvc.stopTicking();
        _currentBgm = (DateTime.now().millisecondsSinceEpoch % 2 == 0) ? 'IngameBGM1.mp3' : 'IngameBGM2.mp3';
        audioSvc.playBgm(_currentBgm);
      }
      // 처음 진입 시 or 초기화 시 (변경 없이 폭탄이 없는 상태)
      else if (oldBomb == null && !iHaveBomb && newBomb.status == BombStatus.active) {
        audioSvc.playBgm(_currentBgm);
      }
      else if (oldBomb == null && iHaveBomb && newBomb.status == BombStatus.active) {
        audioSvc.playTicking();
      }
    });

    // 아이템 사용 알림 리스너
    ref.listen(
      latestItemUsageProvider(widget.groupId),
      (prev, next) {
        final usage = next.asData?.value;
        if (usage == null) return;
        // 같은 이벤트 중복 방지
        if (_lastShownUsage != null &&
            _lastShownUsage!['usedAt'] == usage['usedAt']) {
          return;
        }
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
