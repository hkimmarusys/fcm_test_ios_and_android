import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:fcm_ios_and_android/controller.dart';
import 'package:fcm_ios_and_android/services/api_service.dart';
import 'package:fcm_ios_and_android/widgets/bottom_navigation.dart';
import 'package:fcm_ios_and_android/components/home_screen_card.dart';

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
    final now = DateTime.now();
    final sampleNotifications = [
      {
        'imageUrl': 'assets/baby.png',
        'title': 'AI 알림 1',
        'content': '이것은 첫 번째 알림 내용입니다. 두 줄 이상은 잘립니다.',
        'receivedTime': now.subtract(const Duration(minutes: 5)),
      },
      {
        'imageUrl': 'assets/dog.png',
        'title': 'AI 알림 2',
        'content': '두 번째 알림입니다. 텍스트가 길 경우 자동 줄바꿈됩니다.',
        'receivedTime': now.subtract(const Duration(hours: 1)),
      },
    ];

    sampleNotifications.sort((a, b) =>
        (b['receivedTime'] as DateTime).compareTo(a['receivedTime'] as DateTime));

    return Scaffold(
      appBar: AppBar(title: const Text('AI 알림')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: sampleNotifications
                  .map(
                    (data) => HomeScreenCard(
                  imageUrl: data['imageUrl'] as String,
                  title: data['title'] as String,
                  content: data['content'] as String,
                  receivedTime: data['receivedTime'] as DateTime,
                ),
              )
                  .toList(),
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
