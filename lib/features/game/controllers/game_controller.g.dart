// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 활성 폭탄 실시간 스트림

@ProviderFor(activeBomb)
final activeBombProvider = ActiveBombProvider._();

/// 현재 활성 폭탄 실시간 스트림

final class ActiveBombProvider
    extends
        $FunctionalProvider<
          AsyncValue<BombModel?>,
          BombModel?,
          Stream<BombModel?>
        >
    with $FutureModifier<BombModel?>, $StreamProvider<BombModel?> {
  /// 현재 활성 폭탄 실시간 스트림
  ActiveBombProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeBombProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeBombHash();

  @$internal
  @override
  $StreamProviderElement<BombModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<BombModel?> create(Ref ref) {
    return activeBomb(ref);
  }
}

String _$activeBombHash() => r'1770309f63a33915cd3a4af66a0336dc7efce7a8';

/// 내 차례인지 여부

@ProviderFor(isMyTurn)
final isMyTurnProvider = IsMyTurnProvider._();

/// 내 차례인지 여부

final class IsMyTurnProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 내 차례인지 여부
  IsMyTurnProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isMyTurnProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isMyTurnHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isMyTurn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isMyTurnHash() => r'628a63c029ae1698446c670a8d31ce120c049b57';

@ProviderFor(GameController)
final gameControllerProvider = GameControllerProvider._();

final class GameControllerProvider
    extends $NotifierProvider<GameController, AsyncValue<void>> {
  GameControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameControllerHash();

  @$internal
  @override
  GameController create() => GameController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$gameControllerHash() => r'020b5c6e29e377246cc01e2a292c788927910b08';

abstract class _$GameController extends $Notifier<AsyncValue<void>> {
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
