import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainController extends GetxController {
  var fcmToken = "".obs;
  var userId = "".obs;
  var type = "".obs;
  var currentIndex = 0.obs;
  var pageStack = <int>[0].obs;
  var said = "".obs;

  static const _key = 'token_history';

  Future<void> loadSaidForCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = fcmToken.value;
    if (token.isEmpty) return;

    final rawList = prefs.getStringList(_key) ?? [];

    for (final item in rawList) {
      final map = json.decode(item) as Map<String, dynamic>;
      if (map['token'] == token) {
        said.value = map['said'] ?? '';
        break;
      }
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        if (Get.currentRoute != '/home') {
          Get.offAllNamed('/home');
          break;
        }
      case 1:
        if (Get.currentRoute != '/analysis') {
          Get.offAllNamed('/analysis');
          break;
        }
      case 2:
        if (Get.currentRoute != '/setting') {
          Get.offAllNamed('/setting');
          break;
        }
    }
  }
}
