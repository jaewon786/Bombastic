import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

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
import 'package:bomb_pass/widgets/floating_bomb_background.dart';
import 'package:bomb_pass/widgets/group_currency_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';


class GamePage extends ConsumerStatefulWidget {
  const GamePage({required this.groupId, super.key});

  final String groupId;

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _explosionController;
  bool _explosionTriggered = false;
  bool _readyForFinished = false;
  bool _explosionShownChecked = false;
  bool _explosionAlreadyShown = false;
  bool _isLateExplosion = false;
  GroupModel? _finishedGroup;

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _readyForFinished = true);
        }
      });
  }

  Future<void> _checkExplosionShown() async {
    _explosionShownChecked = true;
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown =
        prefs.getBool('explosion_shown_${widget.groupId}') ?? false;
    if (!mounted) return;

    if (alreadyShown) {
      setState(() => _explosionAlreadyShown = true);
    } else {
      await prefs.setBool('explosion_shown_${widget.groupId}', true);
      if (!mounted) return;
      final audioSvc = ref.read(audioServiceProvider);
      audioSvc.playSfx('ExplosionSound1.mp3');
      audioSvc.stopTicking();
      audioSvc.stopBgm();
      setState(() {
        _explosionTriggered = true;
        _isLateExplosion = true;
      });
      _explosionController.forward();
    }
  }

  @override
  void dispose() {
    _explosionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);

    // 강퇴/삭제 감지
    ref.listen<AsyncValue<GroupModel?>>(watchGroupProvider(widget.groupId), (prev, next) {
      if (next.isLoading) return;
      final group = next.asData?.value;
      final hasPermissionError = next.hasError;
      final isNoLongerMember = group != null && uid != null && !group.memberUids.contains(uid);
      final isDeleted = !next.isLoading && group == null;

      if (hasPermissionError || isDeleted || isNoLongerMember) {
        if (context.mounted && GoRouterState.of(context).uri.toString() != AppRoutes.home) {
          context.go(AppRoutes.home);
        }
      }
      // finished group 캐싱 (멤버 탈퇴 전 데이터 보존)
      if (group?.status == GroupStatus.finished) {
        _finishedGroup ??= group;
      }
    });

    // 폭발 감지: activeBomb 가 bomb → null 로 변하면 폭발
    ref.listen(activeBombProvider(widget.groupId), (prev, next) {
      final oldBomb = prev?.asData?.value;
      final newBomb = next.asData?.value;
      if (oldBomb != null && newBomb == null && !_explosionTriggered) {
        final audioSvc = ref.read(audioServiceProvider);
        audioSvc.playSfx('ExplosionSound1.mp3');
        audioSvc.stopTicking();
        audioSvc.stopBgm();
        _explosionShownChecked = true;
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('explosion_shown_${widget.groupId}', true);
        });
        setState(() => _explosionTriggered = true);
        _explosionController.forward();
      }
    });

    final groupAsync = ref.watch(watchGroupProvider(widget.groupId));

    return groupAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('그룹 정보를 불러올 수 없거나 멤버가 아닙니다.'),
              Text('홈으로 이동 중...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
      data: (group) {
        if (group == null || (uid != null && !group.memberUids.contains(uid))) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('그룹에서 나갔거나 삭제되었습니다.'),
                  Text('홈으로 이동 중...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        // 폭발 애니메이션 재생 중
        if (_explosionTriggered && !_readyForFinished) {
          return Stack(
            children: [
              if (!_isLateExplosion)
                _PlayingTabView(groupId: widget.groupId)
              else
                const Scaffold(
                    backgroundColor: Colors.black, body: SizedBox()),
              _ExplosionOverlay(controller: _explosionController),
            ],
          );
        }

        // 애니메이션 종료 후: finished 화면으로 전환
        if (_readyForFinished) {
          return _FinishedView(group: _finishedGroup ?? group);
        }

        // 게임이 이미 끝난 상태로 앱을 연 경우: 폭발 애니메이션 1회 재생 여부 확인
        if (group.status == GroupStatus.finished) {
          _finishedGroup ??= group;
          if (!_explosionShownChecked) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_explosionShownChecked) _checkExplosionShown();
            });
            return const Scaffold(
                backgroundColor: Colors.black, body: SizedBox());
          }
          if (_explosionAlreadyShown) {
            return _FinishedView(group: _finishedGroup ?? group);
          }
          // 체크 완료됐지만 애니메이션 시작 전 순간
          return const Scaffold(
              backgroundColor: Colors.black, body: SizedBox());
        }

        return switch (group.status) {
          GroupStatus.waiting => _WaitingView(group: group),
          GroupStatus.playing => _PlayingTabView(groupId: widget.groupId),
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
      showTopToast(context, '카카오 공유 오류: $e',
          duration: const Duration(seconds: 6));
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
      ref.read(audioServiceProvider).playBgm('WaitingRoomSound1.mp3', volume: 0.05); // 5% 볼륨
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
        leading: BackButton(onPressed: () {
          ref.read(audioServiceProvider).playBgm('GameMainThemeSong1.mp3');
          ref.read(audioServiceProvider).stopTicking();
          context.go(AppRoutes.home);
        }),
        title: Text(group.name),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          ref.read(audioServiceProvider).playBgm('GameMainThemeSong1.mp3');
          ref.read(audioServiceProvider).stopTicking();
          context.go(AppRoutes.home);
        },
        child: FloatingBombBackground(
          child: SafeArea(
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
                            showTopToast(context, '참여 코드가 복사되었습니다 📋',
                                duration: const Duration(seconds: 2));
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
                    final rawNickname = group.memberNicknames[memberUid];
                    // 레거시 데이터 호환: '익명'도 닉네임 미설정으로 취급한다
                    final hasNickname = rawNickname != null &&
                        rawNickname.isNotEmpty &&
                        rawNickname != '익명';
                    final nickname = hasNickname ? rawNickname : '닉네임 설정중...';
                    final isSelf = memberUid == uid;
                    final isMemberHost = i == 0;
                    final showKick = isHost && !isMemberHost;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(hasNickname ? nickname[0] : '?'),
                      ),
                      title: Text(
                        '$nickname${isSelf ? ' (나)' : ''}',
                        style: TextStyle(
                          fontWeight: isSelf
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: hasNickname ? null : Colors.grey,
                          fontStyle: hasNickname
                              ? FontStyle.normal
                              : FontStyle.italic,
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
                Builder(
                  builder: (context) {
                    final allNicknamesSet = group.memberUids.every((u) {
                      final n = group.memberNicknames[u];
                      // 레거시 데이터 호환: '익명'은 닉네임 미설정으로 취급
                      return n != null && n.isNotEmpty && n != '익명';
                    });
                    final canStart =
                        group.memberUids.length >= 2 && allNicknamesSet;
                    final label = !allNicknamesSet
                        ? '닉네임 설정 대기 중'
                        : group.memberUids.length < 2
                            ? '참여자 대기 중'
                            : '게임 시작';
                    return ElevatedButton(
                      onPressed: canStart
                          ? () async {
                              try {
                                await ref
                                    .read(gameControllerProvider.notifier)
                                    .startGame(groupId: group.id);
                              } catch (e) {
                                if (context.mounted) {
                                  showTopToast(context, '게임 시작 실패: $e');
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        // 비활성 상태는 회색 톤으로 명확히 구분
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
            ),
          ),
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
            onPressed: () {
              ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
              Navigator.of(ctx).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final audioSvc = ref.read(audioServiceProvider);
    final groupNotifier = ref.read(groupControllerProvider.notifier);

    audioSvc.playBgm('GameMainThemeSong1.mp3');
    audioSvc.stopTicking();

    // 탈퇴 처리를 비동기로 던지고 즉시 홈으로 이동
    unawaited(groupNotifier.leaveGroup(groupId: widget.group.id));
    if (context.mounted) {
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
            onPressed: () {
              ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
              Navigator.of(ctx).pop(true);
            },
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
      showTopToast(context, '강퇴 실패: ${state.error}');
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
            onPressed: () {
              ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
              Navigator.of(ctx).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('폐쇄'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final audioSvc = ref.read(audioServiceProvider);
    final groupNotifier = ref.read(groupControllerProvider.notifier);

    audioSvc.playBgm('GameMainThemeSong1.mp3');
    audioSvc.stopTicking();

    // 방 폐쇄 및 탈퇴 처리를 비동기로 던지고 즉시 홈으로 이동
    unawaited(groupNotifier.leaveGroup(groupId: widget.group.id));
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
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
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUidProvider);
    final audioSvc = ref.read(audioServiceProvider);

    // 폭탄 상태 리스너 (BGM 변경)
    ref.listen(activeBombProvider(widget.groupId), (prev, next) {
      final oldBomb = prev?.asData?.value;
      final newBomb = next.asData?.value;

      if (newBomb == null) return;

      final audio = ref.read(audioServiceProvider);
      final iHaveBomb = newBomb.holderUid == uid;
      final iHadBomb = oldBomb?.holderUid == uid;

      // 내가 폭탄을 받았을 때
      if (!iHadBomb && iHaveBomb) {
        audio.changeBgmVolume(0.025);
        audio.playTicking();
      }
      // 내가 폭탄을 넘겼을 때 (안 가짐)
      else if (iHadBomb && !iHaveBomb) {
        audio.stopTicking();
        _currentBgm = (DateTime.now().millisecondsSinceEpoch % 2 == 0) ? 'IngameBGM1.mp3' : 'IngameBGM2.mp3';
        audio.playBgm(_currentBgm, volume: 0.05);
      }
      // 처음 진입 시 or 초기화 시
      else if (oldBomb == null && !iHaveBomb && newBomb.status == BombStatus.active) {
        audio.playBgm(_currentBgm, volume: 0.05);
      }
      else if (oldBomb == null && iHaveBomb && newBomb.status == BombStatus.active) {
        audio.playBgm(_currentBgm, volume: 0.025);
        audio.playTicking();
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

        showTopToast(context, message);
      },
    );

    final groupName = ref
            .watch(watchGroupProvider(widget.groupId))
            .asData
            ?.value
            ?.name ??
        'Bombastic';

    final scaffold = Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          ref.read(audioServiceProvider).playBgm('GameMainThemeSong1.mp3');
          ref.read(audioServiceProvider).stopTicking();
          context.go(AppRoutes.home);
        }),
        title: Text(groupName),
        actions: _buildGlobalActions(widget.groupId),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          ref.read(audioServiceProvider).playBgm('GameMainThemeSong1.mp3');
          ref.read(audioServiceProvider).stopTicking();
          context.go(AppRoutes.home);
        },
        child: FloatingBombBackground(
          child: switch (_tabIndex) {
            0 => ShopBody(groupId: widget.groupId),
            1 => MissionBody(groupId: widget.groupId),
            2 => HomeTab(groupId: widget.groupId),
            3 => LogTab(groupId: widget.groupId),
            4 => SettingsTab(groupId: widget.groupId),
            _ => HomeTab(groupId: widget.groupId),
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) {
          setState(() => _tabIndex = i);
          // 탭 전환 후 BGM이 멈춰있으면 복구
          ref.read(audioServiceProvider).ensureBgmPlaying();
        },
        destinations: _tabs,
      ),
    );

    return scaffold;
  }
}

// ── 폭발 애니메이션 오버레이 ──────────────────────────────────

class _ExplosionOverlay extends StatelessWidget {
  const _ExplosionOverlay({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;

        // Phase 1 (0.0~0.30): 폭탄 흔들림 + 미세 글로우
        final shakeProgress = (t / 0.30).clamp(0.0, 1.0);
        final shakeX = t < 0.30
            ? sin(shakeProgress * 9 * pi) * 22 * (1 - shakeProgress * 0.6)
            : 0.0;
        final bombScale = t < 0.30 ? 1.0 + shakeProgress * 0.35 : 1.35;
        final bombOpacity =
            t < 0.30 ? 1.0 : t < 0.42 ? 1.0 - (t - 0.30) / 0.12 : 0.0;

        // Phase 2 (0.28~0.52): 오렌지/흰색 플래시
        final flashOpacity = t < 0.28
            ? 0.0
            : t < 0.38
                ? (t - 0.28) / 0.10
                : t < 0.52
                    ? 1.0 - (t - 0.38) / 0.14
                    : 0.0;

        // Phase 3 (0.46~1.0): 검정 페이드
        final blackOpacity = t < 0.46
            ? 0.0
            : t < 0.82
                ? (t - 0.46) / 0.36
                : 1.0;

        return Positioned.fill(
          child: Stack(
            children: [
              // 폭탄 흔들림
              if (bombOpacity > 0)
                Center(
                  child: Opacity(
                    opacity: bombOpacity,
                    child: Transform.translate(
                      offset: Offset(shakeX, 0),
                      child: Transform.scale(
                        scale: bombScale,
                        child: const Text(
                          '💣',
                          style: TextStyle(fontSize: 96),
                        ),
                      ),
                    ),
                  ),
                ),

              // 오렌지 플래시
              if (flashOpacity > 0)
                Positioned.fill(
                  child: Opacity(
                    opacity: flashOpacity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white,
                            Colors.orangeAccent,
                            Colors.deepOrange.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.25, 0.55, 1.0],
                          radius: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),

              // 검정 페이드
              if (blackOpacity > 0)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: blackOpacity),
                  ),
                ),
            ],
          ),
        );
      },
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
  void initState() {
    super.initState();
    // 폭발 → finished 전환 타이밍 문제로 째깍 소리가 남을 수 있어 여기서 보장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(audioServiceProvider).stopTicking();
      ref.read(audioServiceProvider).stopBgm();
    });
  }

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
      onDismissed: () {
        ref.read(audioServiceProvider).stopBgm();
        ref.read(creditsShownProvider(widget.group.id).notifier).markShown();
      },
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
        leading: BackButton(onPressed: () {
          ref.read(audioServiceProvider).playBgm('GameMainThemeSong1.mp3');
          ref.read(audioServiceProvider).stopTicking();
          context.go(AppRoutes.home);
        }),
        title: Text('🏆 ${widget.group.name}'),
        actions: _buildGlobalActions(widget.group.id),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          ref.read(audioServiceProvider).playBgm('GameMainThemeSong1.mp3');
          ref.read(audioServiceProvider).stopTicking();
          context.go(AppRoutes.home);
        },
        child: FloatingBombBackground(
        child: switch (_tabIndex) {
          0 => _FinishedHomeTab(group: widget.group),
          1 => LogTab(groupId: widget.group.id),
          2 => SettingsTab(groupId: widget.group.id),
          _ => _FinishedHomeTab(group: widget.group),
        },
      ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
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
          ],
        ),
      ),
    );
  }
}

// ── 상단 토스트 알림 ──────────────────────────────────────────

void showTopToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TopToast(
      message: message,
      duration: duration,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _TopToast extends StatefulWidget {
  const _TopToast({
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();
    Future.delayed(widget.duration, () {
      if (mounted) _ctrl.reverse().then((_) => widget.onDismiss());
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + kToolbarHeight + 8;
    return Positioned(
      top: top,
      left: 24,
      right: 24,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
