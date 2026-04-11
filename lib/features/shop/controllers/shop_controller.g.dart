// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 상점 아이템 목록 (실시간)

@ProviderFor(shopItems)
final shopItemsProvider = ShopItemsProvider._();

/// 상점 아이템 목록 (실시간)

final class ShopItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ShopItemModel>>,
          List<ShopItemModel>,
          Stream<List<ShopItemModel>>
        >
    with
        $FutureModifier<List<ShopItemModel>>,
        $StreamProvider<List<ShopItemModel>> {
  /// 상점 아이템 목록 (실시간)
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
  $StreamProviderElement<List<ShopItemModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ShopItemModel>> create(Ref ref) {
    return shopItems(ref);
  }
}

String _$shopItemsHash() => r'932de6eb1cf63abffdd8da7de6d9febeaf624f17';

@ProviderFor(ShopController)
final shopControllerProvider = ShopControllerProvider._();

final class ShopControllerProvider
    extends $NotifierProvider<ShopController, AsyncValue<ShopItemModel?>> {
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
  Override overrideWithValue(AsyncValue<ShopItemModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ShopItemModel?>>(value),
    );
  }
}

String _$shopControllerHash() => r'183d59ee53e6bb3fbb5ab1913b6acdf1d7ca82e0';

abstract class _$ShopController extends $Notifier<AsyncValue<ShopItemModel?>> {
  AsyncValue<ShopItemModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<ShopItemModel?>, AsyncValue<ShopItemModel?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ShopItemModel?>,
                AsyncValue<ShopItemModel?>
              >,
              AsyncValue<ShopItemModel?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
