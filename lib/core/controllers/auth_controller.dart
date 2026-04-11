import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/auth_repository.dart';
import '../services/fcm_service.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // 초기 상태는 비워둡니다.
  }

  // UI에서 호출할 로그인 함수
  Future<void> signIn() async {
    // 로딩 상태 시작 (UI에서 빙글빙글 로딩을 보여줄 수 있습니다)
    state = const AsyncLoading();
    
    // 에러를 안전하게 잡기 위해 guard 사용
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      
      // 1. 익명 로그인 요청
      final userCredential = await repo.signInAnonymously();
      
      // 2. 로그인 성공 시 Firestore에 정보 저장 + FCM 토큰 등록
      if (userCredential.user != null) {
        final user = userCredential.user!;
        await repo.saveUserToFirestore(user);
        await FcmService.saveTokenForUser(user.uid);
      }
    });
  }
}