import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fcm_ios_and_android/controller.dart';

class BottomNavigation extends StatelessWidget {
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.onTap,
  });

  Widget _buildNavItem({
    required Widget icon,
    required String label,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 4),
        Container(
          width: isSelected ? 10 : 0,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();

    return Obx(() => BottomNavigationBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      currentIndex: controller.currentIndex.value,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        onTap(index);
        controller.changePage(index);
      },
      items: [
        BottomNavigationBarItem(
          icon: _buildNavItem(
            icon: const Icon(Icons.home_rounded, size: 25),
            label: "home",
            isSelected: controller.currentIndex.value == 0,
          ),
          label: "home",
        ),
        BottomNavigationBarItem(
          icon: _buildNavItem(
            icon: Image.asset(
              'assets/statistic.png',
              width: 25,
              height: 25,
            ),
            label: "statistic",
            isSelected: controller.currentIndex.value == 1,
          ),
          label: "statistic",
        ),
        BottomNavigationBarItem(
          icon: _buildNavItem(
            icon: const Icon(Icons.settings, size: 25),
            label: "setting",
            isSelected: controller.currentIndex.value == 2,
          ),
          label: "setting",
        ),
      ],
    ));
  }
}
