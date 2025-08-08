import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/statistic_screen.dart';
import 'controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:fcm_ios_and_android/controller.dart';


// FlutterLocalNotificationsPlugin 인스턴스
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 알림 채널 등록
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // MainController 전역 등록
  final controller = Get.put(MainController());

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    try {
      final controller = Get.find<MainController>();
      controller.changePage(0);
    } catch (e) {
      print("MainController not found: $e");
    }
  });


  // FCM 초기화
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  final token = await messaging.getToken();
  if (token != null) {
    controller.fcmToken.value = token;

    await controller.loadSaidForCurrentToken();
  }

  await _loadDeviceInfo(controller);


  runApp(const MyApp());
}

Future<void> _loadDeviceInfo(MainController controller) async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    print(androidInfo);
    controller.type.value = "A";
  } else {
    controller.type.value = "I";
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FCM Notification Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/search', page: () => const SearchScreen()),
        GetPage(name: '/setting', page: () => const SettingScreen()),
      ],
    );
  }
}
