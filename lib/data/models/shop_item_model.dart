import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_item_model.freezed.dart';
part 'shop_item_model.g.dart';

/// 아이템 종류
enum ItemType {
  swapOrder,
  shrinkDuration,
  reverseDirection,
  adjustGameDays,
}

/// 사용 조건: always = 상시 / bombHolder = 폭탄 보유 중 전용
enum UsageType { always, bombHolder }

@freezed
abstract class ShopItemModel with _$ShopItemModel {
  const factory ShopItemModel({
    required String id,
    required String name,
    required String description,
    required int price,
    required ItemType type,
    @Default(UsageType.always) UsageType usageType,
    @Default(true) bool isAvailable,
    /// 랜덤박스 당첨 가중치 (전체 합 기준 비율)
    @Default(0) int probability,
  }) = _ShopItemModel;

  factory ShopItemModel.fromJson(Map<String, dynamic> json) =>
      _$ShopItemModelFromJson(json);
}
