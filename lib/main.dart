import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';

import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/audio_service.dart';
import 'firebase_options.dart';

/// 앱이 백그라운드/종료 상태일 때 FCM 메시지 수신 핸들러.
/// 시스템 트레이에는 Firebase SDK가 자동으로 알림을 표시하므로 별도 처리 불필요.
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage _) async {}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  KakaoSdk.init(nativeAppKey: '35b52fa389bef4ffce0448f75705bee1');

  // onBackgroundMessage는 runApp 이전에 등록해야 함 (FCM 요구사항)
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: BombasticApp(),
    ),
  );

  // 채널 등록·권한 요청은 첫 프레임을 막지 않도록 runApp 이후 실행
  unawaited(FcmService.initialize());
}

class BombasticApp extends ConsumerStatefulWidget {
  const BombasticApp({super.key});

  @override
  ConsumerState<BombasticApp> createState() => _BombasticAppState();
}

class _BombasticAppState extends ConsumerState<BombasticApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // 앱이 종료된 상태에서 링크로 실행된 경우
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    // 앱이 백그라운드에 있다가 링크로 포그라운드로 전환된 경우
    _linkSub = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    String? code;

    // bombastic://join?code=XXXXXX (기존 커스텀 스킴)
    if (uri.scheme == 'bombastic' && uri.host == 'join') {
      code = uri.queryParameters['code'];
    }
    // kakao[appKey]://kakaolink?code=XXXXXX (카카오링크 실행 파라미터)
    else if (uri.scheme == 'kakao35b52fa389bef4ffce0448f75705bee1' &&
        uri.host == 'kakaolink') {
      code = uri.queryParameters['code'];
    }

    if (code != null && code.isNotEmpty) {
      final router = ref.read(appRouterProvider);
      router.push('${AppRoutes.groupJoin}?code=$code');
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Listener(
      onPointerDown: (_) {
        ref.read(audioServiceProvider).playSfx('ButtonClickSound1.mp3');
      },
      child: MaterialApp.router(
        title: 'Bombastic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
