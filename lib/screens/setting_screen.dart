import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:fcm_ios_and_android/widgets/button.dart';
import 'package:fcm_ios_and_android/widgets/input.dart';
import 'package:fcm_ios_and_android/controller.dart';
import 'package:fcm_ios_and_android/services/api_service.dart';
import 'package:fcm_ios_and_android/widgets/input_label.dart';
import 'package:fcm_ios_and_android/widgets/bottom_navigation.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
      final success = await apiService.sendToken(said: said);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(success ? '전송 완료' : '전송 실패'),
          content: Text(success
              ? '서버로 토큰을 성공적으로 전송했습니다.'
              : '토큰 전송에 실패했습니다. 다시 시도해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FCM Token 또는 SAID가 비어있습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 알림')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Obx(() => controller.said.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '현재 등록된 SAID: ${controller.said.value}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : const SizedBox.shrink()),
              const InputLabel(name: 'SAID'),
              Input(
                controller: saidController,
                hint: 'SAID 입력',
              ),
              const SizedBox(height: 16),
              const InputLabel(name: 'FCM Token'),
              Input(
                controller: fcmTokenController,
                hint: 'FCM Token',
                readonly: true,
              ),
              const SizedBox(height: 20),
              Button(onPressed: _sendToken, text: 'send'),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) async {
          controller.changePage(index);
        },
      ),
    );
  }
}
