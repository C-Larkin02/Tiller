import 'package:proto_proj/shared/dotted_circle2.dart';

import '../models/transaction.dart' as local;

import 'app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proto_proj/shared/extensions/color_extensions.dart';
import 'dart:math';


class BarChartSample2 extends StatefulWidget {
  final List<local.Transaction> transactionsInPeriod;
  final String currentFilter;
  final DateTime startOfPeriod;

  BarChartSample2({
    super.key,
    required this.currentFilter,
    required this.transactionsInPeriod,
    required this.startOfPeriod,

  });

  final Color leftBarColor = AppColors.logoBlue;
  final Color rightBarColor = Colors.black;
  final Color avgColor = AppColors.contentColorOrange.avg(AppColors.contentColorRed);
  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {

  final double width = 7;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex = -1;
  double maxYValue = 0.0;

  @override
  void initState() {
    super.initState();
    Map<DateTime, List<double>> sumsByDay = {};
    List<DateTime> weekDates = [];

    if (widget.currentFilter == 'Week') {
      // Calculate sum for each day in the week
      DateTime startOfWeek = widget.startOfPeriod;
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

      for (int i = 0; i < 7; i++) {
        DateTime currentDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i, 2);
        if (!sumsByDay.containsKey(currentDate)) {
          sumsByDay[currentDate] = [0.0, 0.0];
        }
      }
      for (var transaction in widget.transactionsInPeriod) {
        DateTime transactionDate = DateTime(transaction.timestamp!.year, transaction.timestamp!.month, transaction.timestamp!.day, 2, 0, 0, 0, 0);

        if (transactionDate.isAfter(startOfWeek) && transactionDate.isBefore(endOfWeek)) {
          if (!sumsByDay.containsKey(transactionDate)) {
            sumsByDay[transactionDate] = [0.0, 0.0];
          }
          if (transaction.amount > 0) {
            sumsByDay[transactionDate]![0] += transaction.amount;
          } else {
            sumsByDay[transactionDate]![1] += transaction.amount;
          }
        }
        print('Sums By Day Map $sumsByDay');
      }
    }else if (widget.currentFilter == 'Month') {
      int year = widget.startOfPeriod.year;
      int month = widget.startOfPeriod.month;

      // Start from the first Monday of current month
      DateTime weekStart = DateTime(year, month, 1);
      while (weekStart.weekday != DateTime.monday) {
        weekStart = weekStart.add(Duration(days: 1));
      }

      // Continue until the next month
      while (weekStart.month == month) {
        DateTime weekEnd = weekStart.add(Duration(days: 6));
        List<double> weekSum = [0.0, 0.0];
        for (var transaction in widget.transactionsInPeriod) {
          DateTime transactionDate = DateTime(transaction.timestamp!.year, transaction.timestamp!.month, transaction.timestamp!.day);
          if (transactionDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
              transactionDate.isBefore(weekEnd.add(Duration(days: 1)))) {
            if (transaction.amount > 0) {
              weekSum[0] += transaction.amount;
            } else {
              weekSum[1] += transaction.amount;
            }
          }
        }
        sumsByDay[weekStart] = weekSum;
        weekStart = weekStart.add(Duration(days: 7));
      }
    }else if (widget.currentFilter == 'Year') {
      // Calculate sum for each month in the year
      int year = widget.startOfPeriod.year;
      for (int month = 1; month <= 12; month++) {
        DateTime firstDayOfMonth = DateTime(year, month, 1);
        DateTime lastDayOfMonth = DateTime(year, month + 1, 0);
        sumsByDay[firstDayOfMonth] = [0.0, 0.0];
        for (var transaction in widget.transactionsInPeriod) {
          DateTime transactionDate = DateTime(transaction.timestamp!.year, transaction.timestamp!.month, transaction.timestamp!.day);
          if (transactionDate.isAfter(firstDayOfMonth.subtract(Duration(days: 1))) &&
              transactionDate.isBefore(lastDayOfMonth.add(Duration(days: 1)))) {
            if (transaction.amount > 0) {
              sumsByDay[firstDayOfMonth]![0] += transaction.amount;
            } else {
              sumsByDay[firstDayOfMonth]![1] += transaction.amount;
            }
          }
        }
      }
    }

    maxYValue = 0.0;
    for (var valueList in sumsByDay.values) {
      maxYValue = maxYValue.abs() > valueList[0].abs() ? maxYValue.abs() : valueList[0].abs();
      maxYValue = maxYValue > valueList[1].abs() ? maxYValue : valueList[1].abs();
    }
    maxYValue *= 1.6;

    List<DateTime> sortedDates = sumsByDay.keys.toList()..sort();
    rawBarGroups = sortedDates.asMap().entries.map((entry) {
      List<double> values = sumsByDay[entry.value] ?? [0.5, 0.5];
      if(values[0] == null || values[0] < 0.01){
        values[0] = 0.1;
      }
      if(values[1] == null || values[1] > - 0.01){
        values[1] = 0.1;
      }

      double positiveValue = values[1] < 0 ? values[1] * -1 : values[1];
      return makeGroupData(entry.key, values[0], positiveValue, entry.value);
    }).toList();
    print(sumsByDay);
    print("Transactions In Period\n\n${widget.transactionsInPeriod}");

    showingBarGroups = List.of(rawBarGroups);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                makeTransactionsIcon(),
                const SizedBox(
                  width: 10,
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.circle, color: AppColors.logoBlue, size: 10),
                    Text(' Money In', style: TextStyle(color: Colors.black, fontSize: 16)),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Row(
                  children: <Widget>[
                    Icon(Icons.circle, color: Colors.black, size: 10),
                    Text(' Money Out', style: TextStyle(color: Colors.black, fontSize: 16)),
                  ],
                ),
                const SizedBox(
                  width: 10,
                ),
                Row(
                  children: <Widget>[
                    DottedCircle2(),
                    Text(' Predicted', style: TextStyle(color: Colors.black, fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 38,
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: maxYValue,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.grey,
                      getTooltipItem: (a, b, c, d) => null,
                    ),
                    touchCallback: (FlTouchEvent event, response) {
                      if (response == null || response.spot == null) {
                        setState(() {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                        });
                        return;
                      }

                      touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                      setState(() {
                        if (!event.isInterestedForInteractions) {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                          return;
                        }
                        showingBarGroups = List.of(rawBarGroups);
                        if (touchedGroupIndex != -1) {
                          var sum = 0.0;
                          for (final rod
                          in showingBarGroups[touchedGroupIndex].barRods) {
                            sum += rod.toY;
                          }
                          final avg = sum /
                              showingBarGroups[touchedGroupIndex]
                                  .barRods
                                  .length;

                          showingBarGroups[touchedGroupIndex] =
                              showingBarGroups[touchedGroupIndex].copyWith(
                                barRods: showingBarGroups[touchedGroupIndex]
                                    .barRods
                                    .map((rod) {
                                  return rod.copyWith(
                                      toY: avg, color: widget.avgColor);
                                }).toList(),
                              );
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(color: Colors.transparent),
                      top: BorderSide(color: Colors.transparent),
                      right: BorderSide(color: Colors.transparent),
                      bottom: BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),

                  barGroups: showingBarGroups,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    verticalInterval: 1,
                    horizontalInterval: maxYValue != 0 ? maxYValue / 6 : 1,
                    getDrawingVerticalLine: (value) => FlLine(color: AppColors.lightGrey, strokeWidth: 1),
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey, strokeWidth: 1),
                    checkToShowVerticalLine: (_) => true,
                    checkToShowHorizontalLine: (_) => true,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }

  bool labelDrawn1 = false;
  bool labelDrawn2 = false;
  bool labelDrawn3 = false;
  bool labelDrawn4 = false;
  bool labelDrawn5 = false;


  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    const tolerance = 5;

    final quarterValue = (maxYValue / 4).abs();
    final halfValue = (maxYValue / 2).abs();
    final threeQuartersValue = (3 * maxYValue / 4).abs();
    final fullValue = maxYValue.abs();

    String? text;

    if ((value - quarterValue).abs() <= tolerance && !labelDrawn1) {
      text = '€${quarterValue.toStringAsFixed(0)}';
      labelDrawn1 = true;
    } else if ((value - halfValue).abs() <= tolerance && !labelDrawn2) {
      text = '€${halfValue.toStringAsFixed(0)}';
      labelDrawn2 = true;
    } else if ((value - threeQuartersValue).abs() <= tolerance && !labelDrawn3) {
      text = '€${threeQuartersValue.toStringAsFixed(0)}';
      labelDrawn3 = true;
    } else if ((value - fullValue).abs() <= tolerance && !labelDrawn4) {
      text = '€${fullValue.toStringAsFixed(0)}';
      labelDrawn4 = true;
    } else if ((value - 0).abs() <= tolerance && !labelDrawn5) {
      text = '€0';
      labelDrawn5 = true;
    }

    return text != null
        ? FittedBox(
      fit: BoxFit.scaleDown,
      child: SideTitleWidget(
        axisSide: meta.axisSide,
        space: 0,
        child: Text(text, style: style),
      ),
    )
        : Container();
  }



  Widget bottomTitles(double value, TitleMeta meta) {
    final weekTitles = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final monthTitles = <String>['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 5'];
    final yearTitles = <String>['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

    List<String> titles;
    if (widget.currentFilter == 'Week') {
      titles = weekTitles;
    } else if (widget.currentFilter == 'Month') {
      titles = monthTitles;
    } else if (widget.currentFilter == 'Year') {
      titles = yearTitles;
    } else {
      throw Exception('Invalid filter: ${widget.currentFilter}');
    }

    final Widget text = Text(
      titles[value.toInt()],
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16, //margin top
      child: text,
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2, DateTime date) {
    bool isFuture = date.isAfter(DateTime.now());

    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: isFuture ? Colors.white : widget.leftBarColor,
          width: width,
          borderDashArray: isFuture ? [2, 2] : null,
          borderSide: BorderSide(color: widget.leftBarColor, width: 2.0),
        ),
        BarChartRodData(
          toY: y2,
          color: isFuture ? Colors.white  : widget.rightBarColor,
          width: width,
          borderDashArray: isFuture ? [2, 2] : null,
          borderSide: BorderSide(color: widget.rightBarColor, width: 2.0),
        ),
      ],
    );
  }

  Widget makeTransactionsIcon() {
    const width = 4.5;
    const space = 3.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 42,
          color: Colors.white.withOpacity(1),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 28,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(
          width: space,
        ),
        Container(
          width: width,
          height: 10,
          color: Colors.white.withOpacity(0.4),
        ),
      ],
    );
  }
}