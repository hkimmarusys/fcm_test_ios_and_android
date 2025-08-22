import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeekdayStatisticChart extends StatelessWidget {
  final Map<int, int> dailyStats;
  final void Function(int weekday) onBarTapped;

  const WeekdayStatisticChart({
    Key? key,
    required this.dailyStats,
    required this.onBarTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 10,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"];
                if (value.toInt() >= 1 && value.toInt() <= 7) {
                  return GestureDetector(
                    onTap: () {
                      onBarTapped(value.toInt());
                    },
                    child: Text(
                      days[value.toInt() - 1],
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        barGroups: dailyStats.entries.map((entry) {
          final yValue = entry.value > 10 ? 10 : entry.value;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: yValue.toDouble(),
                color: Colors.blue,
                width: 16,
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final yValue = rod.toY.toInt();
              return BarTooltipItem(
                "$yValue",
                const TextStyle(color: Colors.white),
              );
            },
          ),
          touchCallback: (event, response) {
            if (response != null &&
                response.spot != null &&
                event.isInterestedForInteractions) {
              int weekday = response.spot!.touchedBarGroup.x;
              onBarTapped(weekday);
            }
          },
        ),
      ),
    );
  }
}
