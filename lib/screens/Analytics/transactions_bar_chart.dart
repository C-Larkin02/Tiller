import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:proto_proj/models/transaction.dart' as local;

class TransactionBarChart extends StatelessWidget {
  final Map<DateTime, double>? transactionsByDay;

  TransactionBarChart({this.transactionsByDay});

  @override
  Widget build(BuildContext context) {
    var entries = transactionsByDay!.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    List<BarChartGroupData> barGroups = entries.map((entry) {
      int index = entries.indexOf(entry);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            fromY: 0.0,
            color: Colors.blue,
            toY: entry.value,
          ),
        ],
      );
    }).toList();

    return Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.5), Colors.transparent],
          stops: [0.0, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: BarChart(
        BarChartData(
          maxY: transactionsByDay!.values.reduce((curr, next) => curr > next ? curr : next) * 2,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles:AxisTitles(),
            leftTitles: AxisTitles(              // axisNameWidget: Text('Amount'),

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
        ),
      ),
    );
  }
}