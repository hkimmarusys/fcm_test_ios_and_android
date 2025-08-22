import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fcm_ios_and_android/controller.dart';
import 'package:fcm_ios_and_android/services/api_service.dart';
import 'package:fcm_ios_and_android/widgets/bottom_navigation.dart';
import 'package:fcm_ios_and_android/components/weekday_analysis_chart.dart';
import 'package:fcm_ios_and_android/components/hourly_analysis_chart.dart';
import 'package:fcm_ios_and_android/widgets/week_selector.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final MainController controller = Get.find<MainController>();
  final ApiService apiService = ApiService();

  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> weeklyNotifications = [];
  Map<int, int> dailyStats = {};
  Map<int, int> hourlyStats = {};
  int? selectedWeekday;

  DateTime currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchNotifications().then((_) {
      _setCurrentWeekStartToMonday();
      _filterNotificationsForWeek();
    });
  }

  void _setCurrentWeekStartToMonday() {
    DateTime now = DateTime.now();
    currentWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  Future<void> _fetchNotifications() async {
    var said = controller.said.value;
    try {
      final response = await apiService.fetchNotification(said: said);
      debugPrint(response, wrapWidth: 512);
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
      debugPrint("Error fetching notifications: $e");
    }
  }

  void _filterNotificationsForWeek() {
    final startOfWeek = currentWeekStart;
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    weeklyNotifications = notifications.where((n) {
      final time = n['receivedTime'] as DateTime;
      return !time.isBefore(startOfWeek) && time.isBefore(endOfWeek);
    }).toList();

    setState(() {
      dailyStats = _getDailyStats(weeklyNotifications);
      if (selectedWeekday != null) {
        hourlyStats = _getHourlyStatsForDay(weeklyNotifications, selectedWeekday!);
      }
    });
  }

  void _changeWeek(int offsetWeeks) {
    setState(() {
      currentWeekStart = currentWeekStart.add(Duration(days: 7 * offsetWeeks));
      _filterNotificationsForWeek();
    });
  }

  Map<int, int> _getDailyStats(List<Map<String, dynamic>> notifications) {
    Map<int, int> dailyCount = {1:0,2:0,3:0,4:0,5:0,6:0,7:0};
    for (var n in notifications) {
      DateTime time = n['receivedTime'] as DateTime;
      int weekday = time.weekday;
      dailyCount[weekday] = (dailyCount[weekday] ?? 0) + 1;
    }
    return dailyCount;
  }

  Map<int, int> _getHourlyStatsForDay(List<Map<String, dynamic>> notifications, int weekday) {
    Map<int, int> hourlyCount = {for (var h=0; h<24; h++) h: 0};
    for (var n in notifications) {
      DateTime time = n['receivedTime'] as DateTime;
      if (time.weekday == weekday) {
        int hour = time.hour;
        hourlyCount[hour] = (hourlyCount[hour] ?? 0) + 1;
      }
    }
    return hourlyCount;
  }

  @override
  Widget build(BuildContext context) {
    const weekdays = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];

    return Scaffold(
      appBar: AppBar(title: const Text('AI Analysis')),
      body: notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            WeekSelector(
              currentWeekStart: currentWeekStart,
              onWeekChange: (offsetWeeks) => _changeWeek(offsetWeeks),
            ),
            const SizedBox(height: 16),
            const Text(
              "Pet Safety Management Daily Analysis",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 20.0),
                child: WeekdayStatisticChart(
                  dailyStats: dailyStats,
                  onBarTapped: (weekday) {
                    setState(() {
                      selectedWeekday = weekday;
                      hourlyStats = _getHourlyStatsForDay(weeklyNotifications, weekday);
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (selectedWeekday != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Builder(
                builder: (_) {
                  DateTime dateOfSelectedWeekday =
                  currentWeekStart.add(Duration(days: selectedWeekday! - 1));
                  String formattedDate =
                      "${dateOfSelectedWeekday.month}/${dateOfSelectedWeekday.day}";
                  String weekdayName =
                  weekdays[dateOfSelectedWeekday.weekday - 1];

                  return Text(
                    "$formattedDate ($weekdayName) Hourly Statistics",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  );
                },
              ),
              SizedBox(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 4,right: 4),
                  child: HourlyStatisticChart(hourlyStats: hourlyStats),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        onTap: (int index) async {
          controller.changePage(index);
        },
      ),
    );
  }
}
