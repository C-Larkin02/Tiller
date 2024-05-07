import 'package:flutter/material.dart';
import 'package:proto_proj/shared/app_colors.dart';

import '../../models/budget_model.dart' as model;
import '../MainScreen.dart';
import 'icon_by_category.dart';

class BudgetProgress extends StatelessWidget {
  final Map<String, double> categoryLimits;
  final Map<String, double> categorySpent;
  final model.Budget? usersBudget;
  final double? totalSpent;

  BudgetProgress({required this.categoryLimits, required this.categorySpent, required this.usersBudget, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    if(totalSpent == null || usersBudget == null) return Container();

    Icon budgetStatusIcon = totalSpent! > usersBudget!.totalMonthlySpend
        ? Icon(Icons.close, color: Colors.red)
        : Icon(Icons.check, color: Colors.green);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: InkWell(
          onTap: () {
            MainScreen.of(context)?.changePage(2);
          },
          child: Container(
            width: 155,
              height: 190,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 5, bottom: 0, right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BUDGET',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                          budgetStatusIcon ?? Container(),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 0),
                      child: Text(
                        '€${(totalSpent ?? 0).toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 0),
                      child: Text(
                        '/€${(usersBudget?.totalMonthlySpend ?? 0).toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Divider(color: Colors.grey.shade100),
                  Row(
                    children: [
                      ...generateCategoryProgressBars(),
                    ],
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  List<Widget> generateCategoryProgressBars() {
    List<Widget> categoryWidgets = [];

    categoryLimits.forEach((category, limit) {
      if (categoryWidgets.length < 3) {
        double spent = categorySpent[category] ?? 0;
        double progress = spent / limit;

        categoryWidgets.add(
          Column(
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                margin: EdgeInsets.all(3.0),
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[350],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress > 0.8 ? Colors.red : Colors.blue,
                            ),
                          ),
                          IconByCategory(category),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2),
              Text(
                '%${(progress * 100).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }
    });

    return categoryWidgets;
  }
}