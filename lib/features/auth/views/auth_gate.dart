import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../home/views/home_page.dart'; // 홈 페이지 경로

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Firebase Auth의 상태 변화를 지켜봅니다.
    final authState = ref.watch(authRepositoryProvider).authStateChanges;

    return StreamBuilder(
      stream: authState,
      builder: (context, snapshot) {
        // 로딩 중일 때
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. 로그인된 사용자가 있다면 홈 화면으로 이동
        if (snapshot.hasData) {
          return const HomePage();
        }

        // 3. 로그인이 안 되어 있다면 익명 로그인을 시도하는 화면(또는 자동 로그인)
        return const SignInAttemptPage();
      },
    );
  }
}

// 로그인이 안 되어 있을 때 자동으로 익명 로그인을 시도하는 임시 페이지
class SignInAttemptPage extends ConsumerStatefulWidget {
  const SignInAttemptPage({super.key});

  @override
  ConsumerState<SignInAttemptPage> createState() => _SignInAttemptPageState();
}

class _SignInAttemptPageState extends ConsumerState<SignInAttemptPage> {
  @override
  void initState() {
    super.initState();
    // 페이지가 뜨자마자 익명 로그인 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).signIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('사용자 정보를 확인 중입니다...'),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}