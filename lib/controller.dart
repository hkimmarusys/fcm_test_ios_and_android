import 'package:get/get.dart';

class MainController extends GetxController {
  var fcmToken = "".obs;
  var userId = "".obs;
  var type = "".obs;
  var currentIndex = 0.obs;
  var pageStack = <int>[0].obs;

  void changePage(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        if (Get.currentRoute != '/home') {
          Get.offAllNamed('/home');
          break;
        }
      case 1:
        if (Get.currentRoute != '/setting') {
          Get.offAllNamed('/setting');
          break;
        }
      case 2:
        if (Get.currentRoute != '/statistic') {
          Get.offAllNamed('/statistic');
          break;
        }
    }
}}