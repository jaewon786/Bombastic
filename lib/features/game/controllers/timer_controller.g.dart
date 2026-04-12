// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider
/// activeBomb의 expiresAt 기준으로 1초마다 갱신

@ProviderFor(bombTimer)
final bombTimerProvider = BombTimerFamily._();

/// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider
/// activeBomb의 expiresAt 기준으로 1초마다 갱신

final class BombTimerProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider
  /// activeBomb의 expiresAt 기준으로 1초마다 갱신
  BombTimerProvider._({
    required BombTimerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bombTimerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bombTimerHash();

  @override
  String toString() {
    return r'bombTimerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as String;
    return bombTimer(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BombTimerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bombTimerHash() => r'ac844da51de628d8380ce3795686c23f2d098b99';

/// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider
/// activeBomb의 expiresAt 기준으로 1초마다 갱신

final class BombTimerFamily extends $Family
    with $FunctionalFamilyOverride<String, String> {
  BombTimerFamily._()
    : super(
        retry: null,
        name: r'bombTimerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider
  /// activeBomb의 expiresAt 기준으로 1초마다 갱신

  BombTimerProvider call(String groupId) =>
      BombTimerProvider._(argument: groupId, from: this);

  @override
  String toString() => r'bombTimerProvider';
}
