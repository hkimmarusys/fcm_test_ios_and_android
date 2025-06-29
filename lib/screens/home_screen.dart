import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../widgets/button.dart';
import '../widgets/input.dart';
import '../controller.dart';
import '../services/api_service.dart';
import '../widgets/input_label.dart';

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
            Text(
              'SAID / Token',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: apiService.getTokenHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final data = snapshot.data;
                if (data == null || data.isEmpty) {
                  return const Text('저장된 이력이 없습니다.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final entry = data[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text('SAID: ${entry['said']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Token: ${entry['token']}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}
