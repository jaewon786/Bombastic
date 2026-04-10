// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 게임 결과 계산 (폭발 기록 기반)

@ProviderFor(gameResult)
final gameResultProvider = GameResultProvider._();

/// 게임 결과 계산 (폭발 기록 기반)

final class GameResultProvider
    extends
        $FunctionalProvider<
          AsyncValue<GameResultModel>,
          GameResultModel,
          FutureOr<GameResultModel>
        >
    with $FutureModifier<GameResultModel>, $FutureProvider<GameResultModel> {
  /// 게임 결과 계산 (폭발 기록 기반)
  GameResultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gameResultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gameResultHash();

  @$internal
  @override
  $FutureProviderElement<GameResultModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GameResultModel> create(Ref ref) {
    return gameResult(ref);
  }
}

String _$gameResultHash() => r'9bb3db6df0d926d123c491b947c224530c0ccbce';

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

String _$resultControllerHash() => r'c661a0adf5b12b782e3b36395e9387eb868fc114';

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
