// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 특정 그룹 실시간 스트림

@ProviderFor(watchGroup)
final watchGroupProvider = WatchGroupFamily._();

/// 특정 그룹 실시간 스트림

final class WatchGroupProvider
    extends
        $FunctionalProvider<
          AsyncValue<GroupModel?>,
          GroupModel?,
          Stream<GroupModel?>
        >
    with $FutureModifier<GroupModel?>, $StreamProvider<GroupModel?> {
  /// 특정 그룹 실시간 스트림
  WatchGroupProvider._({
    required WatchGroupFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchGroupProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchGroupHash();

  @override
  String toString() {
    return r'watchGroupProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<GroupModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<GroupModel?> create(Ref ref) {
    final argument = this.argument as String;
    return watchGroup(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchGroupProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchGroupHash() => r'b4c0e6ec6d4928b52163eb26130e78cee8bcc634';

/// 특정 그룹 실시간 스트림

final class WatchGroupFamily extends $Family
    with $FunctionalFamilyOverride<Stream<GroupModel?>, String> {
  WatchGroupFamily._()
    : super(
        retry: null,
        name: r'watchGroupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 그룹 실시간 스트림

  WatchGroupProvider call(String groupId) =>
      WatchGroupProvider._(argument: groupId, from: this);

  @override
  String toString() => r'watchGroupProvider';
}

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

String _$groupControllerHash() => r'fcf0b43eb097b98a1e772eed5c80ed598dea8994';

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
