import 'package:bomb_pass/core/services/audio_service.dart';
import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:bomb_pass/data/models/shop_item_model.dart';
import 'package:bomb_pass/features/game/controllers/game_controller.dart';
import 'package:bomb_pass/features/game/controllers/timer_controller.dart';
import 'package:bomb_pass/features/group/controllers/group_controller.dart';
import 'package:bomb_pass/features/shop/controllers/shop_controller.dart';
import 'package:bomb_pass/widgets/item_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bombAsync = ref.watch(activeBombProvider(groupId));

    return bombAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
      data: (bomb) {
        if (bomb == null) {
          return const SizedBox.shrink();
        }
        return _GameBody(
          groupId: groupId,
          bombId: bomb.id,
          holderUid: bomb.holderUid,
        );
      },
    );
  }
}

class _GameBody extends ConsumerStatefulWidget {
  const _GameBody({
    required this.groupId,
    required this.bombId,
    required this.holderUid,
  });

  final String groupId;
  final String bombId;
  final String holderUid;

  @override
  ConsumerState<_GameBody> createState() => _GameBodyState();
}

class _GameBodyState extends ConsumerState<_GameBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  late final Animation<Color?> _flashAnimation;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _flashAnimation = ColorTween(
      begin: Colors.orange,
      end: Colors.transparent,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // shrinkDuration 시 타이머 플래시 효과
    ref.listen(
      latestItemUsageProvider(widget.groupId),
      (prev, next) {
        final usage = next.asData?.value;
        if (usage == null) return;
        if (usage['itemType'] == 'shrinkDuration') {
          _flashController.forward(from: 0);
        }
      },
    );

    final groupId = widget.groupId;
    final timer = ref.watch(bombTimerProvider(groupId));
    final isMyTurn = ref.watch(isMyTurnProvider(groupId));
    final uid = ref.watch(currentUidProvider);
    final group =
        ref.watch(watchGroupProvider(groupId)).asData?.value;
    final ownedInventory = ref.watch(groupOwnedInventoryProvider(groupId));
    final totalOwnedItemCount =
      ref.watch(groupOwnedInventoryTotalCountProvider(groupId));

    final holderNickname =
        group?.memberNicknames[widget.holderUid] ?? widget.holderUid;
    final memberUids = group?.memberUids ?? const <String>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 중앙 콘텐츠 (폭탄 보유자, 타이머, 전달 순서)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 현재 폭탄 보유자 카드
                Card(
                  color: isMyTurn ? Colors.red.shade50 : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: isMyTurn ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            isMyTurn
                                ? '내가 폭탄을 보유 중!'
                                : '현재 폭탄 보유: $holderNickname',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isMyTurn ? Colors.red : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 타이머
                const Center(
                  child: Text(
                    '폭발까지 남은 시간',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                AnimatedBuilder(
                  animation: _flashAnimation,
                  builder: (context, child) {
                    final flashColor = _flashAnimation.value;
                    return Center(
                      child: Text(
                        timer,
                        style: TextStyle(
                          fontFamily: 'BlackHanSans',
                          fontSize: 77,
                          color: flashColor != Colors.transparent &&
                                  flashColor != null
                              ? flashColor
                              : (isMyTurn ? Colors.red : Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    isMyTurn ? '빨리 전달하세요!' : '대기 중...',
                    style: TextStyle(
                      fontSize: 16,
                      color: isMyTurn ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Center(
                    child: Text('💣', style: TextStyle(fontSize: 80))),
                const SizedBox(height: 8),

                // 전달 순서 (가로 스크롤)
                if (memberUids.length > 1) ...[
                  const Text(
                    '전달 순서',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: memberUids.length,
                      separatorBuilder: (_, __) => const Center(
                        child: Icon(Icons.chevron_right,
                            size: 14, color: Colors.grey),
                      ),
                      itemBuilder: (_, i) {
                        final mUid = memberUids[i];
                        final nick = group?.memberNicknames[mUid] ?? '?';
                        final isHolder = mUid == widget.holderUid;
                        final isMe = mUid == uid;
                        return Container(
                          alignment: Alignment.center,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isHolder
                                ? Colors.red
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isHolder
                                  ? Colors.red
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            isMe ? '$nick(나)' : nick,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isHolder
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isHolder ? Colors.white : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 아이템 바
          _ItemBar(
            inventory: ownedInventory,
            totalCount: totalOwnedItemCount,
            groupId: groupId,
            isMyTurn: isMyTurn,
          ),
          const SizedBox(height: 8),

          // 폭탄 전달 버튼
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isMyTurn
                  ? () {
                      ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
                      ref.read(gameControllerProvider.notifier)
                          .passBomb(groupId: groupId, bombId: widget.bombId);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                '다음 사람에게 전달! 🔥',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 아이템 가로 스크롤 바
class _ItemBar extends ConsumerWidget {
  const _ItemBar({
    required this.inventory,
    required this.totalCount,
    required this.groupId,
    required this.isMyTurn,
  });

  final List<OwnedInventoryItem> inventory;
  final int totalCount;
  final String groupId;
  final bool isMyTurn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (inventory.isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        alignment: Alignment.center,
        child: const Text(
          '보유한 아이템이 없습니다.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.backpack_rounded, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            const Text(
              '아이템',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              '$totalCount개',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final n = inventory.length;
            final totalGaps = (n - 1) * 8.0;
            final cardWidth =
                ((constraints.maxWidth - totalGaps) / n).clamp(0.0, 82.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < n; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  SizedBox(
                    width: cardWidth,
                    child: _ItemCard(
                      item: inventory[i].item,
                      groupId: groupId,
                      count: inventory[i].count,
                      isUsable: inventory[i].item.usageType == UsageType.passive
                          ? false
                          : inventory[i].item.usageType == UsageType.always ||
                              isMyTurn,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 개별 아이템 카드
class _ItemCard extends ConsumerWidget {
  const _ItemCard({
    required this.item,
    required this.groupId,
    required this.count,
    required this.isUsable,
  });

  final ShopItemModel item;
  final String groupId;
  final int count;
  final bool isUsable;

  Future<void> _onItemTap(BuildContext context, WidgetRef ref) async {
    ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
    // 패시브 아이템은 직접 사용 불가
    if (item.usageType == UsageType.passive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('자동 발동 아이템입니다.')),
      );
      return;
    }

    // 일반 아이템: 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            ItemIcon(itemType: item.id, size: 36),
            const SizedBox(width: 12),
            Expanded(child: Text(item.name)),
          ],
        ),
        content: Text(item.description),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
                      Navigator.pop(ctx, false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
                      Navigator.pop(ctx, true);
                    },
                    child: const Text('사용'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !context.mounted) return;
    await ref
        .read(gameControllerProvider.notifier)
        .useItem(groupId: groupId, itemId: item.id);
    if (!context.mounted) return;
    final state = ref.read(gameControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.hasError
              ? '사용 실패: ${state.error}'
              : '${item.name} 사용 완료!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(gameControllerProvider).isLoading;
    final canTap = isUsable && !isLoading;
    final backgroundColor = isUsable
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.surfaceContainerLow;
    final borderColor = Colors.grey.shade300;
    final textColor = isUsable ? null : Colors.grey;

    return GestureDetector(
      onTap: canTap ? () => _onItemTap(context, ref) : null,
      child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 정사각형 아이콘 영역
              AspectRatio(
                aspectRatio: 1.0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final iconSize = constraints.maxWidth - 12;
                    return Stack(
                      children: [
                        Container(color: backgroundColor),
                        Center(child: ItemIcon(itemType: item.id, size: iconSize)),
                        if (!isUsable)
                          Positioned(
                            top: 5,
                            left: 5,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isUsable ? Colors.black87 : Colors.grey,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'x$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // 이름 영역
              Container(
                height: 22,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
