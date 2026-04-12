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
          return const Center(child: Text('폭탄을 기다리는 중...'));
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

class _GameBody extends ConsumerWidget {
  const _GameBody({
    required this.groupId,
    required this.bombId,
    required this.holderUid,
  });

  final String groupId;
  final String bombId;
  final String holderUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(bombTimerProvider(groupId));
    final isMyTurn = ref.watch(isMyTurnProvider(groupId));
    final uid = ref.watch(currentUidProvider);
    final group = ref.watch(watchGroupProvider(groupId)).asData?.value;
    final ownedItemIds = ref
            .watch(currentUserProvider)
            .asData
            ?.value
            ?.groupOwnedItemIds[groupId] ??
        const <String>[];
    final shopItems =
        ref.watch(shopItemsProvider).asData?.value ?? const <ShopItemModel>[];

    final holderNickname = group?.memberNicknames[holderUid] ?? holderUid;
    final memberUids = group?.memberUids ?? const <String>[];

    final usableItems = shopItems
        .where((item) => ownedItemIds.contains(item.id))
        .where((item) => item.usageType == UsageType.always || isMyTurn)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 현재 폭탄 보유자 카드
          Card(
            color: isMyTurn ? Colors.red.shade50 : null,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          const SizedBox(height: 12),

          // 타이머
          Center(
            child: Text(
              timer,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: isMyTurn ? Colors.red : Colors.grey,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
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
          const Center(child: Text('💣', style: TextStyle(fontSize: 80))),
          const SizedBox(height: 12),

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
                  child:
                      Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                ),
                itemBuilder: (_, i) {
                  final mUid = memberUids[i];
                  final nick = group?.memberNicknames[mUid] ?? '?';
                  final isHolder = mUid == holderUid;
                  final isMe = mUid == uid;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isHolder ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isHolder ? Colors.red : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      isMe ? '$nick(나)' : nick,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isHolder ? FontWeight.bold : FontWeight.normal,
                        color: isHolder ? Colors.white : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 아이템 인벤토리 (전달 버튼 위)
          if (usableItems.isNotEmpty) ...[
            const SizedBox(height: 4),
            _ItemBar(items: usableItems, groupId: groupId),
            const SizedBox(height: 16),
          ],

          // 폭탄 전달 버튼
          ElevatedButton(
            onPressed: isMyTurn
                ? () => ref
                    .read(gameControllerProvider.notifier)
                    .passBomb(groupId: groupId, bombId: bombId)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              '다음 사람에게 전달! 🔥',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// 아이템 가로 스크롤 바
class _ItemBar extends ConsumerWidget {
  const _ItemBar({required this.items, required this.groupId});

  final List<ShopItemModel> items;
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              '${items.length}개',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) =>
                _ItemCard(item: items[i], groupId: groupId),
          ),
        ),
      ],
    );
  }
}

/// 개별 아이템 카드
class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.item, required this.groupId});

  final ShopItemModel item;
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(gameControllerProvider).isLoading;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
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
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('사용'),
                    ),
                  ],
                ),
              );
              if ((confirmed ?? false) && context.mounted) {
                await ref
                    .read(gameControllerProvider.notifier)
                    .useItem(groupId: groupId, itemId: item.id);
                if (context.mounted) {
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
              }
            },
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ItemIcon(itemType: item.id),
            const SizedBox(height: 4),
            Text(
              item.name,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
