import 'package:flutter/material.dart';
import 'package:fcm_ios_and_android/controller.dart';
import 'package:get/get.dart';

class BottomNavigation extends StatelessWidget {
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      currentIndex: controller.currentIndex.value,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_rounded,
            size: 25,
          ),
          label: "home",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
            size: 25,
          ),
          label: "search",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
            size: 25,
          ),
          label: "setting",
        ),
      ],
    );
  }
}