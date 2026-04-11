import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _kChannelId = 'bombastic_channel';
const _kChannelName = '봄바스틱 알림';
const _kChannelDesc = '폭탄 수신 · 경고 · 폭발 알림';

/// FCM 초기화, Android 채널 등록, 토큰 저장을 담당하는 서비스.
/// main()에서 [initialize]를 1회 호출하고,
/// 로그인 직후 [saveTokenForUser]를 호출합니다.
class FcmService {
  FcmService._();

  static final _flnp = FlutterLocalNotificationsPlugin();

  /// 앱 시작 시 1회 호출.
  /// - Android 알림 채널 `bombastic_channel` 등록
  /// - 알림 권한 요청 (Android 13+ / iOS)
  /// - 포그라운드 메시지 수신 시 직접 알림 표시
  static Future<void> initialize() async {
    // Android 알림 채널 등록
    const channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.max,
    );
    await _flnp
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // flutter_local_notifications 초기화
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _flnp.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // 알림 권한 요청
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 포그라운드 메시지 → 로컬 알림으로 표시
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
  }

  /// 로그인 직후 [uid]에 연결된 FCM 토큰을 Firestore에 저장.
  /// 토큰 갱신 시 자동으로 재저장됩니다.
  static Future<void> saveTokenForUser(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _writeToken(uid, token);

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) => _writeToken(uid, newToken),
    );
  }

  static Future<void> _writeToken(String uid, String token) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  static void _showLocalNotification(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    _flnp.show(
      n.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _kChannelId,
          _kChannelName,
          channelDescription: _kChannelDesc,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
