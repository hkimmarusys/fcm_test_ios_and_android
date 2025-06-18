import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../controller.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final MainController controller = Get.find<MainController>();
  final ApiService apiService = ApiService();
  final TextEditingController saidController = TextEditingController();
  final TextEditingController fcmTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupFCMForegroundListener();

    // FCM 토큰 초기화 및 변경 시 업데이트
    fcmTokenController.text = controller.fcmToken.value;
    ever(controller.fcmToken, (token) {
      fcmTokenController.text = token;
    });
  }

  @override
  void dispose() {
    saidController.dispose();
    fcmTokenController.dispose();
    super.dispose();
  }

  void _setupFCMForegroundListener() {
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
    });
  }

  void _sendToken() async {
    final said = saidController.text.trim();

    if (controller.fcmToken.isNotEmpty && said.isNotEmpty) {
      await apiService.sendToken(said: said);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token sent to server')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FCM Token 또는 SAID가 비어있습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM 알림 테스트')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Input(
              controller: saidController,
              hint: 'SAID 입력',
              inputType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'SAID를 입력하세요';
                }
                if (!RegExp(r'^\d{11}$').hasMatch(value)) {
                  return '정확히 11자리 숫자를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Input(
              controller: fcmTokenController,
              hint: 'FCM Token',
              readonly: true,
            ),
            const SizedBox(height: 20),
            Button(onPressed: _sendToken, text: 'send'),
          ],
        ),
      ),
    );
  }
}
