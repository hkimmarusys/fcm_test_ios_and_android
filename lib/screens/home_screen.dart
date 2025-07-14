import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:fcm_ios_and_android/controller.dart';
import 'package:fcm_ios_and_android/services/api_service.dart';
import 'package:fcm_ios_and_android/widgets/bottom_navigation.dart';
import 'package:fcm_ios_and_android/components/home_screen_card.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


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

  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _setupFCMListener();
  }

  void _setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _fetchNotifications();
    });
  }

  Future<void> _fetchNotifications() async {
    var said = controller.said.value;
    try {
      final response = await apiService.fetchNotification(said: said);
      if (response != null) {
        final List<dynamic> data = json.decode(response);
        final parsed = data.map<Map<String, dynamic>>((item) {
          return {
            'type': item['type'],
            'title': item['title'],
            'content': item['message'],
            'receivedTime': DateTime.parse(item['reg_date']),
          };
        }).toList();

        parsed.sort((a, b) =>
            (b['receivedTime'] as DateTime).compareTo(a['receivedTime'] as DateTime));

        setState(() {
          notifications = parsed;
        });
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 알림')),
      body: Column(
        children: [
          Expanded(
            child: notifications.isEmpty
                ? const Center(child: Text('알림이 없습니다.'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return HomeScreenCard(
                  type: item['type'],
                  title: item['title'],
                  content: item['content'],
                  receivedTime: item['receivedTime'],
                );
              },
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
