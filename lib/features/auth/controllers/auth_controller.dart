import 'package:riverpod_annotation/riverpod_annotation.dart';

// 현재 프로젝트 구조에 맞는 AuthRepository 경로
import '../../../data/repositories/auth_repository.dart'; 

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  // 수정된 로그인 함수: 로그인 + Firestore 저장 통합
  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      
      // 1. 파이어베이스 익명 로그인 요청
      final userCredential = await repo.signInAnonymously();
      
      // 2. 로그인 성공 시 Firestore에 유저 정보(UserModel) 최초 1회 저장
      if (userCredential.user != null) {
        await repo.saveUserToFirestore(userCredential.user!);
      }
    });
  }

  // 기존에 잘 만들어두신 로그아웃 함수 유지
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signOut(),
    );
  }
}