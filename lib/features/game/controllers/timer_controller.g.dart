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
final bombTimerProvider = BombTimerProvider._();

/// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider
/// activeBomb의 expiresAt 기준으로 1초마다 갱신

final class BombTimerProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// 폭탄 남은 시간을 HH:MM:SS 문자열로 제공하는 provider
  /// activeBomb의 expiresAt 기준으로 1초마다 갱신
  BombTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bombTimerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bombTimerHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return bombTimer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$bombTimerHash() => r'fe63b4349b3742f1f0de36a4c65cdea4c5b2cc90';
