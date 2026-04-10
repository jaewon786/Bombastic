// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 현재 유저가 속한 그룹 실시간 스트림

@ProviderFor(currentGroup)
final currentGroupProvider = CurrentGroupProvider._();

/// 현재 유저가 속한 그룹 실시간 스트림

final class CurrentGroupProvider
    extends
        $FunctionalProvider<
          AsyncValue<GroupModel?>,
          GroupModel?,
          Stream<GroupModel?>
        >
    with $FutureModifier<GroupModel?>, $StreamProvider<GroupModel?> {
  /// 현재 유저가 속한 그룹 실시간 스트림
  CurrentGroupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentGroupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentGroupHash();

  @$internal
  @override
  $StreamProviderElement<GroupModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<GroupModel?> create(Ref ref) {
    return currentGroup(ref);
  }
}

String _$currentGroupHash() => r'f7d404ef134c853ab0b4f036fe23db8325305b09';

@ProviderFor(GroupController)
final groupControllerProvider = GroupControllerProvider._();

final class GroupControllerProvider
    extends $NotifierProvider<GroupController, AsyncValue<void>> {
  GroupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupControllerHash();

  @$internal
  @override
  GroupController create() => GroupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$groupControllerHash() => r'088fac3d095897dec742561bfe5de612f043e2c1';

abstract class _$GroupController extends $Notifier<AsyncValue<void>> {
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
