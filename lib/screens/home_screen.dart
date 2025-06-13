
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _token;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    final token = await messaging.getToken();
    setState(() => _token = token);
    print("FCM Token: $token");

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? message.data['title'];
      final body = message.notification?.body ?? message.data['body'];

      if (title != null || body != null) {
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          title ?? '',
          body ?? '',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }

      // 토스트도 보여주고 싶으면 아래 주석 해제
      // Fluttertoast.showToast(
      //   msg: "${title ?? ''}\n${body ?? ''}".trim(),
      //   toastLength: Toast.LENGTH_LONG,
      //   gravity: ToastGravity.BOTTOM,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM 알림 테스트')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _token != null ? 'FCM Token:\n$_token' : '토큰 가져오는 중...',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
