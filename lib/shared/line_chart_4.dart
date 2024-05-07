//import 'package:fl_chart_app/presentation/resources/app_resources.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

class LineChartSample4 extends StatelessWidget {

  final Map<DateTime, double>? transactionsByDay;
  final String currentFilter;
  final double spendingLimit;
  late Map<DateTime, double> pastTransactionsByDay;
  late Map<DateTime, double> futureTransactionsByDay;

  LineChartSample4({
    required this.currentFilter,
    required this.transactionsByDay,
    required this.spendingLimit,
    super.key,
    Color? mainLineColor,
    Color? belowLineColor,
    Color? aboveLineColor,
  })  : mainLineColor =
      mainLineColor ?? AppColors.contentColorYellow.withOpacity(1),
        belowLineColor =
            belowLineColor ?? AppColors.contentColorPink.withOpacity(1),
        aboveLineColor =
            aboveLineColor ?? AppColors.contentColorPurple.withOpacity(0.7) {
    populateTransactionMaps();
  }

  final Color mainLineColor;
  final Color belowLineColor;
  final Color aboveLineColor;
  bool hasDisplayedMiddleTitle = false;
  bool hasDisplayedMiddleTitle2 = false;

  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.logoBlue,
  ];

  List<Color> gradientColors2 = [
    AppColors.logoBlue,
    AppColors.contentColorRed,
  ];


  //double balance = 1000.0;

  // Map<DateTime, double> pastTransactionsByDay = {};
  // Map<DateTime, double> futureTransactionsByDay = {};

  void populateTransactionMaps() {
    pastTransactionsByDay = {};
    futureTransactionsByDay = {};

    var startOfToday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    for (var entry in transactionsByDay!.entries) {
      var date = entry.key;
      var amount = entry.value;

      if (currentFilter == 'Year' && date.month == startOfToday.month && date.year == startOfToday.year) {
        futureTransactionsByDay[date] = amount;
        pastTransactionsByDay[date] = amount;
      } else if (date.isAfter(startOfToday)) {
        futureTransactionsByDay[date] = amount;
      } else if (date.isAtSameMomentAs(startOfToday)) {
        futureTransactionsByDay[date] = amount;
        pastTransactionsByDay[date] = amount;
      } else {
        pastTransactionsByDay[date] = amount;
      }
    }
  }

  List<FlSpot> get pastSpots {
    var sortedEntries = pastTransactionsByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sortedEntries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList();
  }

  List<FlSpot> get futureSpots {
    var sortedEntries = futureTransactionsByDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    var futureSpots = sortedEntries.map((entry) {
      var index = transactionsByDay!.keys.toList().indexOf(entry.key);
      return FlSpot(index.toDouble(), entry.value);
    }).toList();


    return futureSpots;
  }

  double get meanBalance {
    return transactionsByDay!.values.reduce((a, b) => a + b) / transactionsByDay!.values.length;
  }

  double middleBalance() {
    var values = transactionsByDay!.values.toList();
    values.sort((a, b) => a.compareTo(b));

    final int middleIndex = values.length ~/ 2;
    if (values.length % 2 == 0) {
      return (values[middleIndex - 1] + values[middleIndex]) / 2;
    } else {
      return values[middleIndex];
    }
  }



  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    String text;


    if (currentFilter == 'Week') {
      switch (value.toInt()) {
        case 0:
          text = 'M';
          break;
        case 1:
          text = 'T';
          break;
        case 2:
          text = 'W';
          break;
        case 3:
          text = 'T';
          break;
        case 4:
          text = 'F';
          break;
        case 5:
          text = 'S';
          break;
        case 6:
          text = 'S';
          break;
        default:
          return Container();
      }
    } else if (currentFilter == 'Month') {
      switch (value.toInt()) {
        case 0:
          text = '1';
          break;
        case 5:
          text = '5';
          break;
        case 10:
          text = '10';
          break;
        case 15:
          text = '15';
          break;
        case 20:
          text = '20';
          break;
        case 25:
          text = '25';
          break;
        default:
          return Container();
      }
    } else {
        switch (value.toInt()) {
          case 0:
            text = 'J';
            break;
          case 1:
            text = 'F';
            break;
          case 2:
            text = 'M';
            break;
          case 3:
            text = 'A';
            break;
          case 4:
            text = 'M';
            break;
          case 5:
            text = 'J';
            break;
          case 6:
            text = 'J';
            break;
          case 7:
            text = 'A';
            break;
          case 8:
            text = 'S';
            break;
          case 9:
            text = 'O';
            break;
          case 10:
            text = 'N';
            break;
          case 11:
            text = 'D';
            break;
          default:
            return Container();
        }
      }


    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

bool labelDrawn1 = false;
bool labelDrawn2 = false;
bool labelDrawn3 = false;
bool labelDrawn4 = false;
bool labelDrawn5 = false;

Widget leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );


  const tolerance = 5;

  final middleValue = middleBalance();
  final double maxValue = transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next);
  final double twoTimesMax = maxValue * 2;

  String? text;
  if ((value - maxValue).abs() <= tolerance && !labelDrawn4) {
    text = '€${maxValue.toStringAsFixed(0)}';
    print('Label 1 value: $text');
    labelDrawn4 = true;
  } else if ((value - (maxValue / 2)).abs() <= tolerance && !labelDrawn3) {
    text = '€${(maxValue / 2).toStringAsFixed(0)}';
    print('Label 2 value: $text');
    labelDrawn3 = true;
  } else if ((value - twoTimesMax).abs() <= tolerance && !labelDrawn2) {
    text = '€${twoTimesMax.toStringAsFixed(0)}';
    print('Label 3 value: $text');
    labelDrawn2 = true;
  } else if ((value - (maxValue * 1.5)).abs() <= tolerance && !labelDrawn1) {
    text = '€${(maxValue * 1.5).toStringAsFixed(0)}';
    print('Label 4 value: $text');
    labelDrawn1 = true;
  } else if ((value - 0).abs() <= tolerance && !labelDrawn5) {
    text = '€0';
    print('Label 5 value: $text');
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
  @override
  Widget build(BuildContext context) {
    double cutOffYValue =  300;
    double rangeY = transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next) - transactionsByDay!.values.reduce((curr, next) => curr < next ? curr : next);
    double horizontalInterval = rangeY / 10;


    return AspectRatio(
      aspectRatio: 2,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 28,
          top: 22,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            maxY: transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next) == 0 ? 1 : transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next) * 2,
            lineTouchData: const LineTouchData(enabled: true),
            lineBarsData: [
              LineChartBarData(
                spots: pastSpots,
                isCurved: true,
                curveSmoothness: 0.1,
                //barWidth: 2,
                color: AppColors.logoBlue,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: gradientColors
                        .map((color) => color.withOpacity(0.3))
                        .toList(),
                  ),
                ),
                // aboveBarData: BarAreaData(
                //   show: false,
                //   color: aboveLineColor,
                //   cutOffY: cutOffYValue,
                //   applyCutOffY: true,
                // ),
                dotData: const FlDotData(
                  show: false,
                ),
              ),
              LineChartBarData(
                spots: futureSpots,
                dashArray: [10, 6],
                isCurved: true,
                color: AppColors.contentColorRed,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: gradientColors2
                        .map((color) => color.withOpacity(0.3))
                        .toList(),
                  ),
                ),
                dotData: const FlDotData(
                  show: false,
                ),// Color for future data
              ),
            ],
            minY: 0,
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  '',
                  style: TextStyle(
                    fontSize: 10,
                    color: mainLineColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 18,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameSize: 20,
                axisNameWidget: const Text(
                  '',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                  getTitlesWidget: leftTitleWidgets,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xff37434d)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 1,
              drawHorizontalLine: true,
              horizontalInterval: transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next) == 0 ? 0.1 : transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next) * 2 / (currentFilter == 'Month' ? 10 : 6),
              getDrawingHorizontalLine: (value) {
                return const FlLine(
                  color: Colors.grey,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return const FlLine(
                  color: AppColors.lightGrey,
                  strokeWidth: 1,
                );
              },
              checkToShowVerticalLine: (currentFilter == 'Month' || currentFilter == 'Year')
                  ? (double value) {
                return value % 2 == 0;
              }
                  : (double value) {
                return value < transactionsByDay!.values.length.abs() - 1;
              },
              checkToShowHorizontalLine: (double value) {
                // int totalVerticalLines = currentFilter == 'Week' ? 7 : transactionsByDay!.values.length ~/ 2;
                // double rangeY = transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next) * 2;
                // double interval = rangeY / totalVerticalLines;
                // double horizontalInterval = rangeY / totalVerticalLines;
                //return value == transactionsByDay!.values.first || value == transactionsByDay!.values.toList()[1];
                  return true;

                //return value % transactionsByDay!.values.length == 4;
              },
            ),
          ),
        ),
      ),
    );
  }
}