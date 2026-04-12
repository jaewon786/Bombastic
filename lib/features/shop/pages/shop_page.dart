import 'package:bomb_pass/core/constants/app_constants.dart';
import 'package:bomb_pass/data/firebase/firebase_providers.dart';
import 'package:bomb_pass/data/models/shop_item_model.dart';
import 'package:bomb_pass/features/shop/controllers/shop_controller.dart';
import 'package:bomb_pass/widgets/item_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 탭에서 직접 사용하는 상점 body 위젯
class ShopBody extends ConsumerWidget {
  const ShopBody({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(shopItemsProvider);
    final currency = ref.watch(groupCurrencyProvider(groupId));

    return itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (items) {
          final pool = items.where((i) => i.probability > 0).toList()
            ..sort((a, b) => b.probability.compareTo(a.probability));
          final totalWeight = pool.fold(0, (sum, i) => sum + i.probability);

          final ownedInventory = ref.watch(groupOwnedInventoryProvider(groupId));
          final totalOwnedCount =
              ref.watch(groupOwnedInventoryTotalCountProvider(groupId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 내 인벤토리
                if (ownedInventory.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.backpack_rounded,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text(
                        '내 인벤토리',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$totalOwnedCount개',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ownedInventory
                        .map(
                          (inventoryItem) => _InventoryChip(
                            item: inventoryItem.item,
                            count: inventoryItem.count,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
                _RandomBoxCard(currency: currency, groupId: groupId),
                const SizedBox(height: 32),
                const Text(
                  '아이템 목록',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  '랜덤박스에서 아래 아이템 중 하나를 획득합니다.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ...pool.map(
                  (item) => _ItemPoolTile(
                    item: item,
                    percent: totalWeight > 0
                        ? item.probability / totalWeight * 100
                        : 0,
                  ),
                ),
              ],
            ),
          );
        },
      );
  }
}

// ── 랜덤박스 구매 카드 ────────────────────────────────────────

class _RandomBoxCard extends ConsumerWidget {
  const _RandomBoxCard({required this.currency, required this.groupId});

  final int currency;
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(shopControllerProvider).isLoading;
    final canAfford = currency >= CurrencyConstants.randomBoxPrice;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            const Text('🎁', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text(
              '랜덤박스',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              '랜덤한 아이템 1개를 획득합니다.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading || !canAfford
                    ? null
                    : () => _onPurchase(context, ref),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.casino),
                label: const Text(
                  '뽑기! 💰 ${CurrencyConstants.randomBoxPrice}',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (!canAfford)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '재화가 부족합니다.',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPurchase(BuildContext context, WidgetRef ref) async {
    final obtained = await ref
        .read(shopControllerProvider.notifier)
        .purchaseRandomBox(groupId: groupId);

    if (!context.mounted) return;

    final error = ref.read(shopControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('구매 실패: $error')),
      );
      return;
    }

    if (obtained != null) {
      _showObtainedDialog(context, obtained);
    }
  }

  void _showObtainedDialog(BuildContext context, ShopItemModel item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('획득!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ItemIcon(itemType: item.id, size: 64),
            const SizedBox(height: 12),
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            _UsageChip(usageType: item.usageType),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// ── 아이템 풀 목록 타일 ──────────────────────────────────────

class _ItemPoolTile extends StatelessWidget {
  const _ItemPoolTile({required this.item, required this.percent});

  final ShopItemModel item;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      _UsageChip(usageType: item.usageType),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _rarityColor(percent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rarityColor(double percent) {
    if (percent >= 25) return Colors.green;
    if (percent >= 15) return Colors.blue;
    if (percent >= 7) return Colors.orange;
    return Colors.red;
  }
}

class _InventoryChip extends StatelessWidget {
  const _InventoryChip({required this.item, required this.count});

  final ShopItemModel item;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ItemIcon(itemType: item.id, size: 28),
          const SizedBox(width: 8),
          Text(
            item.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'x$count',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageChip extends StatelessWidget {
  const _UsageChip({required this.usageType});

  final UsageType usageType;

  @override
  Widget build(BuildContext context) {
    final (label, bgColor, fgColor) = switch (usageType) {
      UsageType.always => ('상시', Colors.blue.shade50, Colors.blue.shade700),
      UsageType.bombHolder => ('폭탄 보유 시', Colors.orange.shade50, Colors.orange.shade700),
      UsageType.passive => ('자동 발동', Colors.purple.shade50, Colors.purple.shade700),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: fgColor),
      ),
    );
  }
}
