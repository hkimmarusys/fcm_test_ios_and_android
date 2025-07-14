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

  @override
  void onInit() {
    super.onInit();
    _loadSaidForCurrentToken();
  }

  Future<void> _loadSaidForCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    final token = fcmToken.value;

    for (final item in rawList) {
      try {
        final map = json.decode(item) as Map<String, dynamic>;
        if (map['token'] == token) {
          said.value = map['said'] ?? "";
          print("Loaded SAID for current token: ${said.value}");
          return;
        }
      } catch (e) {
        print('Failed to decode stored token entry: $e');
      }
    }
    said.value = "";
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
        if (Get.currentRoute != '/search') {
          Get.offAllNamed('/search');
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
