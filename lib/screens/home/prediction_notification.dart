import 'package:flutter/material.dart';
import 'package:proto_proj/models/transaction.dart' as local;
import 'package:proto_proj/services/database.dart';
import 'package:proto_proj/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:proto_proj/models/user.dart' as local;

import '../../models/budget_model.dart' as model;
import '../../services/machine_learning/ml_service.dart';
import '../MainScreen.dart';

class PredictionNotification extends StatefulWidget {
  final double totalSpentThisMonth;
  final List<local.Transaction> allTransactions;
  final model.Budget? usersBudget;

  PredictionNotification({required this.totalSpentThisMonth, required this.allTransactions, required this.usersBudget});

  @override
  _PredictionNotificationState createState() => _PredictionNotificationState();
}

class _PredictionNotificationState extends State<PredictionNotification> {
  List<local.Transaction>? predictedTransactions;
  String? budgetStatus;
  String? monthlyLimit;
  double predictedTotalSpent = 0.0;
  double margin = 0.0;
  Icon? budgetStatusIcon;


  @override
  void initState() {
    super.initState();
    fetchPredictions();
  }

  Future<void> fetchPredictions() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfThisMonth = DateTime(now.year, now.month, 1);
    DateTime firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);


    final user = Provider.of<local.User?>(context, listen: false);
    List<local.Transaction>? transactions = await DatabaseService(uid: user?.uid).transactions.first;
    if(transactions == null) {
      print('No transactions available');
      return;
    }
    model.Budget budget = await DatabaseService(uid: user?.uid).budget.first;
    monthlyLimit = budget.totalMonthlySpend.toStringAsFixed(0);
    print('Spent This month: ${widget.totalSpentThisMonth}');
    //margin = budget.totalMonthlySpend - widget.totalSpentThisMonth;
    //transactions = transactions?.where((transaction) => transaction.timestamp!.isAfter(firstDayOfThisMonth) && transaction.timestamp!.isBefore(firstDayOfNextMonth) && transaction.amount > 0).toList();


    if (transactions != null) {
      try {
        predictedTransactions = await getPrediction(transactions);
        predictedTransactions = predictedTransactions?.where((transaction) => transaction.timestamp!.isAfter(firstDayOfThisMonth) && transaction.timestamp!.isBefore(firstDayOfNextMonth) && transaction.amount > 0).toList();

        predictedTotalSpent = widget.totalSpentThisMonth + predictedTransactions!.fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
        budgetStatus = predictedTotalSpent > budget.totalMonthlySpend ? 'OVER Budget' : 'UNDER Budget';
        budgetStatusIcon = predictedTotalSpent > budget.totalMonthlySpend
            ? Icon(Icons.close, color: Colors.red)
            : Icon(Icons.check, color: Colors.green);
        margin = (budget.totalMonthlySpend - predictedTotalSpent).abs();
        setState(() {});
      } catch (e) {
        print('Failed to load prediction: $e');
      }
    } else {
      print('No transactions available');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (predictedTransactions == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 50.0),
        child: Container(
            width: 100,
            height: 100,
            child: Loading()),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 0.0, right: 20, bottom: 20, left: 10),
        child: InkWell(
          onTap: () {
            MainScreen.of(context)?.changePage(1);
          },
          child: Container(
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
            width: 186,
            //height: 156,
            height: 190,
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
                          'PREDICTION',
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
                      '€${predictedTotalSpent.toStringAsFixed(2)}',
                      style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lato',
                    ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 0, bottom: 0),
                    child: Text(
                      '/€${(monthlyLimit ?? 0)}',
                      style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Divider(color: Colors.grey.shade100),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, top: 5, bottom: 0, right: 15),
                    child: Text(
                      'Looks Like you will be $budgetStatus by €${margin.toStringAsFixed(0)} this month!',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                //Text('Looks Like you wil be $budgetStatus this month!'),
              ],
            ),
          ),
        ),
      );
    }
  }
}