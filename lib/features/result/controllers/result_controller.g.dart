// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 게임 결과 계산 (폭발 기록 + pass 로그 기반)

@ProviderFor(gameResult)
final gameResultProvider = GameResultFamily._();

/// 게임 결과 계산 (폭발 기록 + pass 로그 기반)

final class GameResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<GameResultModel>,
          GameResultModel,
          FutureOr<GameResultModel>
        >
    with $FutureModifier<GameResultModel>, $FutureProvider<GameResultModel> {
  /// 게임 결과 계산 (폭발 기록 + pass 로그 기반)
  GameResultProvider._({
    required GameResultFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'gameResultProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$gameResultHash();

  @override
  String toString() {
    return r'gameResultProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<GameResultModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GameResultModel> create(Ref ref) {
    final argument = this.argument as String;
    return gameResult(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GameResultProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$gameResultHash() => r'a24d6256d04a0215544f3674566828394857cbde';

/// 게임 결과 계산 (폭발 기록 + pass 로그 기반)

final class GameResultFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<GameResultModel>, String> {
  GameResultFamily._()
    : super(
        retry: null,
        name: r'gameResultProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 게임 결과 계산 (폭발 기록 + pass 로그 기반)

  GameResultProvider call(String groupId) =>
      GameResultProvider._(argument: groupId, from: this);

  @override
  String toString() => r'gameResultProvider';
}

@ProviderFor(ResultController)
final resultControllerProvider = ResultControllerProvider._();

final class ResultControllerProvider
    extends $NotifierProvider<ResultController, AsyncValue<void>> {
  ResultControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resultControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resultControllerHash();

  @$internal
  @override
  ResultController create() => ResultController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$resultControllerHash() => r'48b709a6fc4113bfcd6abfb587c0a6f03cd9a5e3';

abstract class _$ResultController extends $Notifier<AsyncValue<void>> {
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
