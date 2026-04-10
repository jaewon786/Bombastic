// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 상점 아이템 목록

@ProviderFor(shopItems)
final shopItemsProvider = ShopItemsProvider._();

/// 상점 아이템 목록

final class ShopItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ShopItemModel>>,
          List<ShopItemModel>,
          FutureOr<List<ShopItemModel>>
        >
    with
        $FutureModifier<List<ShopItemModel>>,
        $FutureProvider<List<ShopItemModel>> {
  /// 상점 아이템 목록
  ShopItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopItemsHash();

  @$internal
  @override
  $FutureProviderElement<List<ShopItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ShopItemModel>> create(Ref ref) {
    return shopItems(ref);
  }
}

String _$shopItemsHash() => r'595a4b1609ddd271cdcb773227b24c594a2400ed';

@ProviderFor(ShopController)
final shopControllerProvider = ShopControllerProvider._();

final class ShopControllerProvider
    extends $NotifierProvider<ShopController, AsyncValue<void>> {
  ShopControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopControllerHash();

  @$internal
  @override
  ShopController create() => ShopController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$shopControllerHash() => r'5ba4c13191b2f45c45cf06a2233575fe25eafd5c';

abstract class _$ShopController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
