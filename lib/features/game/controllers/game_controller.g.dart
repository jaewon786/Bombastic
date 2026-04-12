// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 최근 아이템 사용 이벤트 실시간 스트림 (최신 1건)

@ProviderFor(latestItemUsage)
final latestItemUsageProvider = LatestItemUsageFamily._();

/// 최근 아이템 사용 이벤트 실시간 스트림 (최신 1건)

final class LatestItemUsageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>?>,
          Map<String, dynamic>?,
          Stream<Map<String, dynamic>?>
        >
    with
        $FutureModifier<Map<String, dynamic>?>,
        $StreamProvider<Map<String, dynamic>?> {
  /// 최근 아이템 사용 이벤트 실시간 스트림 (최신 1건)
  LatestItemUsageProvider._({
    required LatestItemUsageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'latestItemUsageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$latestItemUsageHash();

  @override
  String toString() {
    return r'latestItemUsageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, dynamic>?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, dynamic>?> create(Ref ref) {
    final argument = this.argument as String;
    return latestItemUsage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestItemUsageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestItemUsageHash() => r'd74db47b17b391b2f0d4b4ea5cd07412cb7439fc';

/// 최근 아이템 사용 이벤트 실시간 스트림 (최신 1건)

final class LatestItemUsageFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, dynamic>?>, String> {
  LatestItemUsageFamily._()
    : super(
        retry: null,
        name: r'latestItemUsageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 최근 아이템 사용 이벤트 실시간 스트림 (최신 1건)

  LatestItemUsageProvider call(String groupId) =>
      LatestItemUsageProvider._(argument: groupId, from: this);

  @override
  String toString() => r'latestItemUsageProvider';
}

/// 현재 활성 폭탄 실시간 스트림

@ProviderFor(activeBomb)
final activeBombProvider = ActiveBombFamily._();

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
  ActiveBombProvider._({
    required ActiveBombFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeBombProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeBombHash();

  @override
  String toString() {
    return r'activeBombProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<BombModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<BombModel?> create(Ref ref) {
    final argument = this.argument as String;
    return activeBomb(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveBombProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeBombHash() => r'0655d94825bac943b0bffa7c2ed15a38aed1c6f8';

/// 현재 활성 폭탄 실시간 스트림

final class ActiveBombFamily extends $Family
    with $FunctionalFamilyOverride<Stream<BombModel?>, String> {
  ActiveBombFamily._()
    : super(
        retry: null,
        name: r'activeBombProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 현재 활성 폭탄 실시간 스트림

  ActiveBombProvider call(String groupId) =>
      ActiveBombProvider._(argument: groupId, from: this);

  @override
  String toString() => r'activeBombProvider';
}

/// 내 차례인지 여부

@ProviderFor(isMyTurn)
final isMyTurnProvider = IsMyTurnFamily._();

/// 내 차례인지 여부

final class IsMyTurnProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// 내 차례인지 여부
  IsMyTurnProvider._({
    required IsMyTurnFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isMyTurnProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isMyTurnHash();

  @override
  String toString() {
    return r'isMyTurnProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isMyTurn(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IsMyTurnProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isMyTurnHash() => r'6bd4c856076b4c1b00e2e14455a8f5a205aad87e';

/// 내 차례인지 여부

final class IsMyTurnFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsMyTurnFamily._()
    : super(
        retry: null,
        name: r'isMyTurnProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 내 차례인지 여부

  IsMyTurnProvider call(String groupId) =>
      IsMyTurnProvider._(argument: groupId, from: this);

  @override
  String toString() => r'isMyTurnProvider';
}

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

String _$gameControllerHash() => r'bdca143f5100143a44e2825daeb447685cefffa0';

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
