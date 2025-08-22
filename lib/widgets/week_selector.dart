import 'package:flutter/material.dart';

typedef WeekChangeCallback = void Function(int offsetWeeks);

class WeekSelector extends StatelessWidget {
  final DateTime currentWeekStart;
  final WeekChangeCallback onWeekChange;

  const WeekSelector({
    Key? key,
    required this.currentWeekStart,
    required this.onWeekChange,
  }) : super(key: key);

  String _getWeekLabel(DateTime monday) {
    final startOfWeek = monday;
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final firstDayOfMonth = DateTime(startOfWeek.year, startOfWeek.month, 1);
    final weekNumber = ((startOfWeek.day + firstDayOfMonth.weekday - 1) / 7).ceil();

    final startStr = "${startOfWeek.month}/${startOfWeek.day}";
    final endStr = "${endOfWeek.month}/${endOfWeek.day}";

    return "Week $weekNumber, ${startOfWeek.year} (${startStr}~${endStr})";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () => onWeekChange(-1),
        ),
        Text(
          _getWeekLabel(currentWeekStart),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () => onWeekChange(1),
        ),
      ],
    );
  }
}
