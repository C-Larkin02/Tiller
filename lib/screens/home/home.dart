import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proto_proj/models/transaction.dart' as local;
import 'package:proto_proj/screens/home/prediction_notification.dart';
import 'package:proto_proj/screens/home/transaction_chart.dart';
import 'package:proto_proj/screens/home/transaction_list_limited.dart';
import 'package:proto_proj/screens/home/budget_progress.dart';
import 'package:proto_proj/screens/home/upload_csv.dart';
import 'package:proto_proj/services/auth.dart';
import 'package:proto_proj/services/database.dart';
import 'package:proto_proj/models/budget_model.dart' as model;
import 'package:provider/provider.dart';

import '../../models/user.dart' as local;
import '../../shared/app_colors.dart';
import '../../shared/loading.dart';
import '../MainScreen.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  Map<DateTime, Map<DateTime, double>> transactionsByWeek = {};
  model.Budget? usersBudget;
  Map<String, double> categorySpent = {};
  double totalSpentThisMonth = 0.0;
  var allTransactions = <local.Transaction>[];
  var transactionsThisMonth2 = <local.Transaction>[];


  void refreshHomePage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<local.User?>(context);
    return StreamProvider<List<local.Transaction>?>.value(
      value: DatabaseService(uid: user?.uid).transactions,
      initialData: null,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: AppColors.logoBlue,
          elevation: 0.0,
          title: Text('tiller', style: TextStyle(fontFamily: 'Quicksand', fontSize: 30, color: Colors.white)),
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.person, color: Colors.white),
              label: Text('logout', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: <Widget>[
                    FutureBuilder<List<local.Transaction>>(
                      future: DatabaseService(uid: user?.uid).transactions.first,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Loading();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                          return IconButton(
                            icon: Padding(
                              padding: const EdgeInsets.only(top: 200.0),
                              child: Icon(Icons.upload_file_rounded, size: 100.0),
                            ),
                            onPressed: () => uploadCSV(user!.uid, refreshHomePage),
                          );
                        } else {
                          var now = DateTime.now();
                          var monthStart = DateTime(now.year, now.month);
                          transactionsByWeek[monthStart] = {};
                          int daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
                          double accumulatedAmount = 0.0;
                          for (var j = 0; j < daysInMonth; j++) {
                            var date = DateTime(monthStart.year, monthStart.month, j + 1);
                            var negativeTransactions = (snapshot.data ?? []).where((transaction) =>
                            transaction.timestamp?.year == date.year &&
                                transaction.timestamp?.month == date.month &&
                                transaction.timestamp?.day == date.day &&
                                transaction.amount < 0
                            );
                            double negativeAmount = negativeTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
                            accumulatedAmount += negativeAmount;
                            transactionsByWeek[monthStart]![date] = accumulatedAmount;
                          }
                          var recentTransactions = snapshot.data!
                              .where((t) => t.timestamp != null)
                              .toList()
                            ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
                          var mostRecentTransaction = recentTransactions.first;
                          print("Print sattement of $recentTransactions");

                          // Calculate balance difference and arrow indicators
                          double? lastBalance = recentTransactions.length > 1 ? recentTransactions[1].balance : 0;
                          double? currentBalance = mostRecentTransaction.balance;
                          double? balanceDifference = currentBalance! - lastBalance!;
                          var arrowIcon = balanceDifference >= 0 ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_down_rounded;
                          var arrowColor = balanceDifference >= 0 ? Colors.green : Colors.red;


                          return Padding(
                            padding: EdgeInsets.only(left: 16.0, top: 20, right: 30.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${NumberFormat.currency(symbol: '\€', decimalDigits: 2, locale: 'en_US').format(mostRecentTransaction.balance)}',
                                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'Quicksand'),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.upload_file_rounded),
                                        onPressed: () {
                                          uploadCSV(user!.uid, refreshHomePage);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(arrowIcon, color: arrowColor),
                                          Text(
                                            '${NumberFormat.currency(symbol: '\€', decimalDigits: 2, locale: 'en_US').format(balanceDifference.abs())} today',
                                            style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Quicksand'),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Upload CSV',
                                        style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Quicksand'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                        FutureBuilder<List<local.Transaction>>(
                        future: DatabaseService(uid: user?.uid).transactions.first,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Loading();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                            return InkWell(
                              onTap: () => uploadCSV(user!.uid, refreshHomePage),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 100.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(text: 'Upload Your First Transactions '),
                                        TextSpan(
                                          text: 'Here!',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            var now = DateTime.now();
                            var monthStart = DateTime(now.year, now.month);
                            var monthEnd = DateTime(now.year, now.month + 1, 0);

                            var transactionsThisMonth = snapshot.data!.where((transaction) =>
                            transaction.timestamp != null &&
                                transaction.timestamp!.isAfter(monthStart) &&
                                transaction.timestamp!.isBefore(monthEnd) &&
                                transaction.amount < 0 //Consider only negative transactions
                            );
                            transactionsThisMonth2 = transactionsThisMonth.toList();
                            totalSpentThisMonth = transactionsThisMonth.fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
                            transactionsByWeek[monthStart] = {};
                            int daysInMonth = DateTime(monthStart.year, monthStart.month + 1, 0).day;
                            double accumulatedAmount = 0.0; // accumulated amount for the month
                            for (var j = 0; j < daysInMonth; j++) {
                              var date = DateTime(monthStart.year, monthStart.month, j + 1);
                              var negativeTransactions = (snapshot.data ?? []).where((transaction) =>
                              transaction.timestamp?.year == date.year &&
                                  transaction.timestamp?.month == date.month &&
                                  transaction.timestamp?.day == date.day &&
                                  transaction.amount < 0
                              );
                              double negativeAmount = negativeTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
                              accumulatedAmount += negativeAmount;
                              transactionsByWeek[monthStart]![date] = accumulatedAmount;
                            }
                            var recentTransactions = snapshot.data!
                                .where((t) => t.timestamp != null)
                                .toList()
                              ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
                            var mostRecentTransaction = recentTransactions.first;

                            //totalSpentThisMonth = transactionsByWeek[monthStart]!.values.reduce((a, b) => a + b);


                            if (transactionsByWeek[monthStart] == null || transactionsByWeek[monthStart]!.isEmpty) {
                              return Container();
                            } else {
                              return TransactionChart(transactionsByDay: transactionsByWeek[monthStart] ?? {});
                            }
                          }
                        },
                      ),
                    TransactionListLimited(),
                    FutureBuilder<model.Budget>(
                      future: DatabaseService(uid: user?.uid).budget.first,
                      builder: (context, budgetSnapshot) {
                        if (budgetSnapshot.connectionState == ConnectionState.waiting) {
                          return Loading();
                        } else if (budgetSnapshot.hasError) {
                         // return Text('Error: ${budgetSnapshot.error}');
                          return InkWell(
                            onTap: () {
                              MainScreen.of(context)?.changePage(2);
                            },
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(text: 'Create Your Budget on the '),
                                  TextSpan(
                                    text: 'Budget Page!!',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else if (budgetSnapshot.data == null) {
                          return Text('No transactions yet');
                        } else {
                          usersBudget = budgetSnapshot.data;
                          categorySpent = {};
                          for (var transaction in transactionsThisMonth2) {
                            if (usersBudget!.categoryLimits.containsKey(transaction.category)) {
                              categorySpent.update(transaction.category, (value) => value + transaction.amount.abs(), ifAbsent: () => transaction.amount.abs());
                            }
                          }
                          return Row(
                            children: [
                                BudgetProgress(
                                  categoryLimits: usersBudget?.categoryLimits ?? {},
                                  categorySpent: categorySpent,
                                  usersBudget: usersBudget,
                                  totalSpent: totalSpentThisMonth,
                                ),
                                PredictionNotification(totalSpentThisMonth: totalSpentThisMonth, allTransactions: allTransactions, usersBudget: usersBudget,),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }
}