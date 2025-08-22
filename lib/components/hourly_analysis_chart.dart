import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// class HourlyStatisticChart extends StatelessWidget {
//   final Map<int, int> hourlyStats;
//
//   const HourlyStatisticChart({
//     Key? key,
//     required this.hourlyStats,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return LineChart(
//       LineChartData(
//         maxY: 5,
//         maxX: 24,
//         minY: 0,
//         minX: 0,
//         titlesData: FlTitlesData(
//           topTitles: AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: false,
//               interval: 1,
//               getTitlesWidget: (value, meta) {
//                 return Text(value.toInt().toString());
//               },
//             ),
//           ),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               interval: 1,
//               getTitlesWidget: (value, meta) {
//                 if (value % 3 == 0) {
//                   return Text("${value.toInt()}시");
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ),
//         lineBarsData: [
//           LineChartBarData(
//             spots: hourlyStats.entries
//                 .where((e) => e.value > 0)
//                 .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
//                 .toList(),
//             isCurved: true,
//             color: Colors.red,
//             barWidth: 2,
//             dotData: FlDotData(show: true),
//           ),
//         ], lineTouchData: LineTouchData(
//         touchTooltipData: LineTouchTooltipData(
//           getTooltipItems: (touchedSpots) {
//             return touchedSpots.map((touchedSpot) {
//               return LineTooltipItem(
//                 touchedSpot.y.toInt().toString(),
//                 const TextStyle(color: Colors.white),
//               );
//             }).toList();
//           },
//         ),
//       ),
//       ),
//     );
//   }
// }
class HourlyStatisticChart extends StatelessWidget {
  final Map<int, int> hourlyStats;
  final int maxCount;

  const HourlyStatisticChart({
    Key? key,
    required this.hourlyStats,
    this.maxCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            children: hourlyStats.entries.map((entry) {
              double fraction = (entry.value / maxCount).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text('${entry.key}:00')),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 20,
                            color: Colors.grey.shade200,
                          ),
                          FractionallySizedBox(
                            widthFactor: fraction,
                            child: Container(
                              height: 20,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('${entry.value} cases'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
