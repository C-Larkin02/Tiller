import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proto_proj/models/transaction.dart' as local;

import '../../models/budget_model.dart' as model;
import '../../shared/app_colors.dart';

class TransactionChart extends StatelessWidget {
  final Map<DateTime, double>? transactionsByDay;
  final Map<DateTime, double>? predictedTransactionsByDay;


  TransactionChart({this.transactionsByDay, this.predictedTransactionsByDay});


  @override
  Widget build(BuildContext context) {

    Color myBlue = Colors.blue[50]!;

    List<Color> gradientColors = [
      myBlue,
      AppColors.contentColorBlue,
    ];

    double maxY = transactionsByDay!.isNotEmpty
        ? transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next) * 3
        : 0.0;

    //if(budget! > maxY) maxY = budget! * 2 ?? 0.0;

    double minY = transactionsByDay!.isNotEmpty
        ? transactionsByDay!.values.reduce((curr, next) => curr < next ? curr : next)
        : 0.0;

    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var entries1 = transactionsByDay!.entries.where((entry) => entry.key.isBefore(now) || entry.key.isAtSameMomentAs(now)).toList();
    var entries2 = transactionsByDay!.entries.where((entry) => entry.key.isAfter(now) || entry.key.isAtSameMomentAs(today)).toList();
    entries1.sort((a, b) => a.key.compareTo(b.key));
    entries2.sort((a, b) => a.key.compareTo(b.key));

    DateTime startDate = transactionsByDay!.keys.reduce((curr, next) => curr.isBefore(next) ? curr : next);


    return Container(
            height: 100,
      child: LineChart(
        LineChartData(
          // backgroundColor: Colors.green[300],
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.logoBlue,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppColors.logoBlue,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles:AxisTitles(),
            leftTitles: AxisTitles(
             // axisNameWidget: Text('Amount'),
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: Padding(
                padding: EdgeInsets.only(top: 10),
                //child: Text('Date'),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
            border: Border.all(color: Colors.black),
          ),
          lineBarsData: [
            LineChartBarData(
              barWidth: 3,
              color: Colors.blue[400],
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
                ),
              ),
              isCurved: false,
              dotData: FlDotData(show: false),
              spots: entries1
                  .map((entry) =>
                  FlSpot(entry.key.difference(startDate).inDays.toDouble(), entry.value))
                  .toList(),
            ),
            LineChartBarData(
              show: true,
              barWidth: 3,
              dashArray: [5, 5],
              color: Colors.grey[400],
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
                ),
              ),
              isCurved: false,
              dotData: FlDotData(show: false),
              spots: entries2
                  .map((entry) =>
                  FlSpot(entry.key.difference(startDate).inDays.toDouble(), entry.value))
                  .toList(),
            ),
            // LineChartBarData(
            //   barWidth: 2,
            //   color: Colors.red[200],
            //   isCurved: false,
            //   dotData: FlDotData(show: false),
            //   spots: entries
            //       .map((entry) =>
            //       FlSpot(entry.key.difference(startDate).inDays.toDouble(), budget ?? 0.0))
            //       .toList(),
            // ),
            LineChartBarData(
              barWidth: 3,
              color: Colors.red,
              isCurved: true,
              spots: (predictedTransactionsByDay?.entries ?? []).map((entry) =>
                  FlSpot(entry.key.difference(startDate).inDays.toDouble(), entry.value)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}