// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 미션 목록

@ProviderFor(missions)
final missionsProvider = MissionsProvider._();

/// 미션 목록

final class MissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MissionModel>>,
          List<MissionModel>,
          FutureOr<List<MissionModel>>
        >
    with
        $FutureModifier<List<MissionModel>>,
        $FutureProvider<List<MissionModel>> {
  /// 미션 목록
  MissionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionsHash();

  @$internal
  @override
  $FutureProviderElement<List<MissionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MissionModel>> create(Ref ref) {
    return missions(ref);
  }
}

String _$missionsHash() => r'8850a9deb3a77f4d7ed63a5f31f94005af8cc58a';

@ProviderFor(MissionController)
final missionControllerProvider = MissionControllerProvider._();

final class MissionControllerProvider
    extends $NotifierProvider<MissionController, AsyncValue<void>> {
  MissionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionControllerHash();

  @$internal
  @override
  MissionController create() => MissionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$missionControllerHash() => r'9e5c325733bc60aade09fceb85bb4fa62519b796';

abstract class _$MissionController extends $Notifier<AsyncValue<void>> {
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
