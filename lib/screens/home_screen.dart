import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:fcm_ios_and_android/widgets/button.dart';
import 'package:fcm_ios_and_android/widgets/input.dart';
import 'package:fcm_ios_and_android/controller.dart';
import 'package:fcm_ios_and_android/services/api_service.dart';
import 'package:fcm_ios_and_android/widgets/input_label.dart';
import 'package:fcm_ios_and_android/widgets/bottom_navigation.dart';
import 'package:fcm_ios_and_android/widgets/home_screen_card.dart';

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
  final said = '0709111759';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 알림')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: const [
                HomeScreenCard(
                  imageUrl: 'assets/baby.png',
                  title: 'AI 알림 1',
                  content: '이것은 첫 번째 알림 내용입니다. 두 줄 이상은 잘립니다.',
                  receivedTime: '5분 전',
                ),
                HomeScreenCard(
                  imageUrl: 'assets/dog.png',
                  title: 'AI 알림 2',
                  content: '두 번째 알림입니다. 텍스트가 길 경우 자동 줄바꿈됩니다.',
                  receivedTime: '1시간 전',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await apiService.receiveNotification(said: said);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('알림 요청을 보냈습니다')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('알림 요청하기'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) async {
          controller.changePage(index);
        },
      ),
    );
  }
  }
