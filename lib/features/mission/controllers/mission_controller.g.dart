// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 미션 목록 (실시간, 그룹별 completedMissionIds 반영)

@ProviderFor(missions)
final missionsProvider = MissionsFamily._();

/// 미션 목록 (실시간, 그룹별 completedMissionIds 반영)

final class MissionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MissionModel>>,
          List<MissionModel>,
          Stream<List<MissionModel>>
        >
    with
        $FutureModifier<List<MissionModel>>,
        $StreamProvider<List<MissionModel>> {
  /// 미션 목록 (실시간, 그룹별 completedMissionIds 반영)
  MissionsProvider._({
    required MissionsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'missionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$missionsHash();

  @override
  String toString() {
    return r'missionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MissionModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MissionModel>> create(Ref ref) {
    final argument = this.argument as String;
    return missions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MissionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$missionsHash() => r'dbfaad70854ace06787003e2f053bfa7dcba315a';

/// 미션 목록 (실시간, 그룹별 completedMissionIds 반영)

final class MissionsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MissionModel>>, String> {
  MissionsFamily._()
    : super(
        retry: null,
        name: r'missionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 미션 목록 (실시간, 그룹별 completedMissionIds 반영)

  MissionsProvider call(String groupId) =>
      MissionsProvider._(argument: groupId, from: this);

  @override
  String toString() => r'missionsProvider';
}

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

String _$missionControllerHash() => r'8b2472c8e3b4e2c65a42481f1de9486381da0679';

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
