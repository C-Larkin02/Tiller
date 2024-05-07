import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/transaction.dart' as local;
import 'app_colors.dart';
import 'extensions/indicator.dart';

class PieChartSample1 extends StatefulWidget  {

  final List<local.Transaction> transactionsInPeriod;


  const PieChartSample1({
    super.key,
    required this.transactionsInPeriod,
  });

  @override
  State<StatefulWidget> createState() => PieChartSample1State();
}

class PieChartSample1State extends State<PieChartSample1> {
  int touchedIndex = -1;
  List<MapEntry<String, double>> categoryList = [];
  double totalCount = 0;
  double value0 = 0;
  double value1 = 0;
  double value2 = 0;
  List<double> ListOfvalues = [];

  @override
  void initState() {
    super.initState();
    Map<String, double> categoryCounts = {};

    for (var transaction in widget.transactionsInPeriod) {
      categoryCounts.update(transaction.category, (count) => count + 1, ifAbsent: () => 1);
    }

    categoryList = categoryCounts.entries.toList();

    categoryList.sort((a, b) => b.value.compareTo(a.value));
    totalCount = 0;
    if (categoryList.length > 0) {
      totalCount += categoryList[0].value;
      value0 = (categoryList[0].value / totalCount) * 100;

    }
    if (categoryList.length > 1) {
      totalCount += categoryList[1].value;
      value1 = (categoryList[1].value / totalCount) * 100;

    }
    if (categoryList.length > 2) {
      totalCount += categoryList[2].value;
      value2 = (categoryList[2].value / totalCount) * 100;

    }
    ListOfvalues = [value0, value1, value2];
    ListOfvalues = ListOfvalues.where((value) => value != null).toList();

  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 28,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (categoryList.length > 0)
                Indicator(
                  color: AppColors.contentColorBlue,
                  text: categoryList[0].key,
                  isSquare: false,
                  size: touchedIndex == 0 ? 18 : 16,
                  textColor: touchedIndex == 0
                      ? AppColors.contentColorBlack
                      : AppColors.contentColorBlack,
                ),
              if (categoryList.length > 1)
                Indicator(
                  color: AppColors.contentColorYellow,
                  text: categoryList[1].key,
                  isSquare: false,
                  size: touchedIndex == 1 ? 18 : 16,
                  textColor: touchedIndex == 1
                      ? AppColors.contentColorBlack
                      : AppColors.contentColorBlack,
                ),
              if (categoryList.length > 2)
                Indicator(
                  color: AppColors.contentColorPink,
                  text: categoryList[2].key,
                  isSquare: false,
                  size: touchedIndex == 2 ? 18 : 16,
                  textColor: touchedIndex == 2
                      ? AppColors.contentColorBlue
                      : AppColors.contentColorBlack,
                ),
            ],
          ),
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 1,
                  centerSpaceRadius: 0,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(
      ListOfvalues.length,
          (i) {
        final isTouched = i == touchedIndex;
        const color0 = AppColors.logoBlue;
        const color1 = AppColors.contentColorYellow;
        const color2 = AppColors.contentColorPink;
        const color3 = AppColors.contentColorGreen;

        switch (i) {
          case 0:
            return PieChartSectionData(
              color: color0,
              value: value0,
              title: '',
              radius: 80,
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? const BorderSide(
                  color: AppColors.contentColorBlack, width: 6)
                  : BorderSide(
                  color: AppColors.contentColorBlack.withOpacity(0)),
            );
          case 1:
            //(value / sumValues) * 360
            return PieChartSectionData(
              color: color1,
              value: value1,
              title: '',
              radius: 80,
              titlePositionPercentageOffset: 0.55,
              borderSide: isTouched
                  ? const BorderSide(
                  color: AppColors.contentColorBlack, width: 6)
                  : BorderSide(
                  color: AppColors.contentColorBlack.withOpacity(0)),
            );
          case 2:
            return PieChartSectionData(
              color: color2,
              value: value2,
              title: '',
              radius: 80,
              titlePositionPercentageOffset: 0.6,
              borderSide: isTouched
                  ? const BorderSide(
                  color: AppColors.contentColorBlack, width: 6)
                  : BorderSide(
                  color: AppColors.contentColorBlack.withOpacity(0)),
            );

          default:
            throw Error();
        }
      },
    );
  }
}