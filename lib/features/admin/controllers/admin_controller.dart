import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/firebase/firebase_providers.dart';

part 'admin_controller.g.dart';

@riverpod
class AdminController extends _$AdminController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> executeCommand({
    required String command,
    required String groupId,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) throw Exception('로그인이 필요합니다.');

    state = const AsyncLoading();
    final next = await AsyncValue.guard(() async {
      await callHttpsCallableWithRegionFallback(
        functionName: 'adminCommand',
        data: {'command': command, 'groupId': groupId},
      );
    });
    if (ref.mounted) state = next;
  }
}
