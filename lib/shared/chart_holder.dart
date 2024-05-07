// import 'package:fl_chart_app/presentation/resources/app_resources.dart';
// import 'package:fl_chart_app/presentation/samples/chart_sample.dart';
// import 'package:fl_chart_app/util/app_utils.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

class ChartHolder extends StatelessWidget {
  final Widget chartWidget;
  final String chartName;


  const ChartHolder({
    Key? key,
    required this.chartWidget,
    required this.chartName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const SizedBox(width: 6),
            Text(
              chartName,
              style: const TextStyle(
                color: AppColors.contentColorBlack,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(child: Container()),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
            color: Colors.white,
            borderRadius:
            BorderRadius.all(Radius.circular(AppDimens.defaultRadius)),
          ),
          child: chartWidget,
        ),
      ],
    );
  }
}