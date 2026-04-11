import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/models/shop_item_model.dart';
import '../../../data/repositories/shop_repository.dart';

part 'shop_controller.g.dart';

/// 상점 아이템 목록 (실시간)
@riverpod
Stream<List<ShopItemModel>> shopItems(Ref ref) {
  return ref.watch(shopRepositoryProvider).watchShopItems();
}

@riverpod
class ShopController extends _$ShopController {
  @override
  AsyncValue<ShopItemModel?> build() => const AsyncData(null);

  /// 랜덤박스 구매 — Cloud Function 호출, 성공 시 state에 획득 아이템 저장
  Future<ShopItemModel?> purchaseRandomBox({required String groupId}) async {
    state = const AsyncLoading();
    ShopItemModel? obtained;
    final next = await AsyncValue.guard(() async {
      obtained = await ref
          .read(shopRepositoryProvider)
          .purchaseRandomBox(groupId: groupId);
      return obtained;
    });
    if (ref.mounted) state = next;
    return obtained;
  }
}
