import 'package:provider/provider.dart';
import '../../models/budget_model.dart'as model;
import '../../services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:proto_proj/screens/Analytics/transactions_bar_chart.dart';
import '../../shared/NavBar.dart';
import '../../models/user.dart' as local;
import 'package:proto_proj/models/transaction.dart' as local;
import '../../services/auth.dart';
import 'package:provider/provider.dart';
import 'package:proto_proj/services/database.dart';
import '../../shared/app_colors.dart';
import '../../shared/bar_chart_sample2.dart';
import '../../shared/chart_holder.dart';
import '../../shared/line_chart_4.dart';
import '../../shared/loading.dart';
import '../../shared/pie_chart.dart';
import '../MainScreen.dart';
import '../home/transaction_chart.dart';
import 'package:intl/intl.dart';
import 'package:proto_proj/services/machine_learning/ml_service.dart';





class Analytics extends StatefulWidget {
  @override
  _AnalyticsState createState() => _AnalyticsState();
  List<bool> _selections = List.generate(3, (_) => false);

}



class _AnalyticsState extends State<Analytics> {


  final AuthService _auth = AuthService();
  String _currentFilter = 'Week';
  int _currentPeriod = 0;
  List<bool> _selections = List.generate(3, (_) => false);

  List<local.Transaction>? predictedTransactions;

  @override
  void initState() {
    super.initState();
    displayPrediction().then((value) {
      setState(() {
        predictedTransactions = value;
      });
    });
  }


  Future<List<local.Transaction>> displayPrediction() async {
    print(predictedTransactions?.isEmpty);
    if (predictedTransactions != null && predictedTransactions!.isNotEmpty) {
      return predictedTransactions!;
    }
    //print('Python script was Called!!');
    final user = Provider.of<local.User?>(context, listen: false);

    // Listen to the transactions stream and wait for the first piece of data
    List<local.Transaction>? transactions = await DatabaseService(
        uid: user?.uid).transactions.first;

    if (transactions != null) {
      try {
        List<local.Transaction> prediction = await getPrediction(transactions);
        prediction.forEach((transaction) {
          //print('Transaction: ${transaction.toString()}');
        });
        return prediction;
      } catch (e) {
        print('Failed to load prediction: $e');
        return [];
      }
    } else {
      print('No transactions available');
      return [];
    }
  }


  DateTime get _startOfPeriod {
    var now = DateTime.now();
    switch (_currentFilter) {
      case 'Week':
        return DateTime(
            now.year, now.month, now.day - now.weekday - _currentPeriod * 7);
      case 'Month':
        return DateTime(now.year, now.month - _currentPeriod, 1);
      case 'Year':
        return DateTime(now.year - _currentPeriod, 1, 1);
      default:
        throw Exception('Invalid filter: $_currentFilter');
    }
  }

  DateTime get _endOfPeriod {
    var now = DateTime.now();
    switch (_currentFilter) {
      case 'Week':
        return DateTime(now.year, now.month,
            now.day - now.weekday + 7 - _currentPeriod * 7);
      case 'Month':
        return DateTime(now.year, now.month - _currentPeriod + 1, 0);
      case 'Year':
        return DateTime(now.year - _currentPeriod + 1, 1, 0);
      default:
        throw Exception('Invalid filter: $_currentFilter');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<local.User?>(context);
    return StreamProvider<List<local.Transaction>?>.value(
      value: DatabaseService(uid: user?.uid).transactions,
      initialData: null,
      child: FutureBuilder<model.Budget>(
        future: DatabaseService(uid: user?.uid).budget.first,
        builder: (context, budgetSnapshot) {
          if (budgetSnapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          } else if (budgetSnapshot.hasError) {
            return Scaffold(
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
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: InkWell(
                    onTap: () {
                      MainScreen.of(context)?.changePage(2);
                    },
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(text: 'First, Create Your Budget on the ', style: TextStyle(fontSize: 15.0)),
                          TextSpan(
                            text: 'Budget Page!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.blue,
                                decoration: TextDecoration.underline
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            model.Budget userBudget = budgetSnapshot.data!;
            // Now you can use userBudget in your widget tree
            return Scaffold(
              backgroundColor: Colors.grey[100],
              appBar: AppBar(
                backgroundColor: AppColors.logoBlue,
                elevation: 0.0,
                title: Text('tiller', style: TextStyle(fontFamily: 'Quicksand', fontSize: 30, color: Colors.white)),
                actions: <Widget>[
                  TextButton.icon(
                    icon: Icon(Icons.person, color: Colors.white),
                    label: Text(
                        'logout', style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      await _auth.signOut();
                    },
                  ),
                ],
              ),
                            body: RefreshIndicator(
                              onRefresh: () async {
                                // await DatabaseService(uid: user?.uid).updateTransactions();
                                setState(() {}); // Calling setState will refresh the UI
                              },
                              child: Center(
                              child: FutureBuilder<List<local.Transaction>>(
                              future: DatabaseService(uid: user?.uid).transactions.first,
                              builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                              return Loading();
                              } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                              } else {
                              if (predictedTransactions == null) {
                              return Loading();
                              } else {
                              Map<DateTime, double> predictedTransactionsByDay = {};
                              Map<DateTime, double> predictedBalanceByDay = {};

                              //populate the two Maps from the predicted transactions
                              for (var transaction in predictedTransactions!) {
                                var date = DateTime(
                                  transaction.timestamp!.year,
                                  transaction.timestamp!.month,
                                  transaction.timestamp!.day,
                                );
                                predictedTransactionsByDay[date] =
                                    (predictedTransactionsByDay[date] ?? 0) +
                                        transaction.amount;
                                predictedBalanceByDay[date] =
                                transaction.balance!;
                              }

                              // Initialize transactionsByDay with zeros
                              Map<DateTime, double> transactionsByDay = {};
                              Map<DateTime, double> balanceByDay = {};
                              int numDays;
                              switch (_currentFilter) {
                                case 'Week':
                                  numDays = 7;
                                  break;
                                case 'Month':
                                  numDays = DateTime(
                                      _startOfPeriod.year,
                                      _startOfPeriod.month + 1, 0)
                                      .day;
                                  break;
                                case 'Year':
                                  numDays = 12;
                                  break;
                                default:
                                  throw Exception(
                                      'Invalid filter: $_currentFilter');
                              }
                              for (var i = 0; i < numDays; i++) {
                                var date;
                                switch (_currentFilter) {
                                  case 'Week':
                                  case 'Month':
                                    date = DateTime(_startOfPeriod.year, _startOfPeriod.month, _startOfPeriod.day + i);
                                    break;
                                  case 'Year':
                                    date = DateTime(_startOfPeriod.year, _startOfPeriod.month + i, 1);
                                    break;
                                  default:
                                    throw Exception('Invalid filter: $_currentFilter');
                                }
                                transactionsByDay[date] = 0.0;
                                balanceByDay[date] = 0.0;
                              }

                              // Filter the transactions to include only those within the current period
                              var transactionsInPeriod = snapshot.data!.where((
                                  transaction) {
                                var date = transaction.timestamp!;
                                return date.isAfter(_startOfPeriod) &&
                                    date.isBefore(_endOfPeriod);
                              }).toList();

                              Map<DateTime, DateTime> lastTransactionByMonth = {};

                              //Map<DateTime, double> transactionsByDay = {};
                              for (var transaction in transactionsInPeriod) {
                                DateTime date;
                                switch (_currentFilter) {
                                  case 'Week':
                                  case 'Month':
                                    date = DateTime(transaction.timestamp!.year,
                                        transaction.timestamp!.month,
                                        transaction.timestamp!.day);
                                    break;
                                  case 'Year':
                                    date = DateTime(transaction.timestamp!.year,
                                        transaction.timestamp!.month,
                                        1); // Set day to 1
                                    break;
                                  default:
                                    throw Exception(
                                        'Invalid filter: $_currentFilter');
                                }

                                transactionsByDay[date] =
                                    (transactionsByDay[date] ??
                                        0) + transaction.amount;

                                balanceByDay[date] = transaction.balance!;
                              }

                              for (var entry in predictedTransactionsByDay
                                  .entries) {
                                var date = entry.key;
                                var predictedAmount = entry.value;

                                // Update transactionsByDay and balanceByDay with the predicted values
                                if (date.isAfter(DateTime.now()) &&
                                    date.isBefore(_endOfPeriod) &&
                                    date.isAfter(_startOfPeriod)) {
                                  transactionsByDay[date] = predictedAmount;
                                }
                              }

                              for (var entry in predictedBalanceByDay.entries) {
                                var date = entry.key;
                                var predictedAmount = entry.value;

                                // Update transactionsByDay and balanceByDay with the predicted values
                                if (date.isAfter(DateTime.now()) && date.isBefore(_endOfPeriod) && date.isAfter(_startOfPeriod)) {
                                  if (_currentFilter == 'Year') {
                                    // when filter is Year sum up the predicted values for each month
                                    var monthDate = DateTime(date.year, date.month, 1);
                                    balanceByDay[monthDate] = (balanceByDay[monthDate] ?? 0) + predictedAmount;
                                  } else {
                                    balanceByDay[date] = predictedAmount;
                                  }
                                }
                              }
                              return ListView(
                                children: [
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Analytics',
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ToggleButtons(
                                        renderBorder: true,
                                        borderWidth: 2,
                                        borderRadius: BorderRadius.circular(10),
                                        selectedColor: Colors.blue[400],
                                        color: Colors.blue,
                                        fillColor: Colors.blue.withOpacity(0.1),
                                        constraints: BoxConstraints(
                                            minWidth: 100, minHeight: 30),
                                        children: <Widget>[
                                          Text('Week', style: TextStyle(color: AppColors.logoBlue, fontWeight: FontWeight.bold)),
                                          Text('Month', style: TextStyle(color: AppColors.logoBlue, fontWeight: FontWeight.bold)),
                                          Text('Year', style: TextStyle(color: AppColors.logoBlue, fontWeight: FontWeight.bold)),
                                        ],
                                        isSelected: _selections,
                                        onPressed: (int index) {
                                          setState(() {
                                            for (int i = 0; i <
                                                _selections.length; i++) {
                                              _selections[i] = i == index;
                                            }
                                            switch (index) {
                                              case 0:
                                                _currentFilter = 'Week';
                                                break;
                                              case 1:
                                                _currentFilter = 'Month';
                                                break;
                                              case 2:
                                                _currentFilter = 'Year';
                                                break;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.arrow_back),
                                          onPressed: () {
                                            setState(() {
                                              _currentPeriod++;
                                            });
                                          },
                                        ),
                                        Text(
                                          _currentFilter == 'Week'
                                              ? '${DateFormat('dd-MMM-yyyy')
                                              .format(
                                              _startOfPeriod)} - ${DateFormat(
                                              'dd-MMM-yyyy').format(
                                              _endOfPeriod)}'
                                              : _currentFilter == 'Month'
                                              ? '${DateFormat('MMM-yyyy').format(
                                              _startOfPeriod)}'
                                              : '${DateFormat('yyyy').format(
                                              _startOfPeriod)}',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.arrow_forward),
                                          onPressed: () {
                                            setState(() {
                                              _currentPeriod--;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
                                    child: ChartHolder(
                                      chartWidget: Container(
                                        height: 300,
                                        width: 300,
                                        child: LineChartSample4(
                                          currentFilter: _currentFilter,
                                          transactionsByDay: balanceByDay,
                                          spendingLimit: userBudget.totalMonthlySpend,
                                        ),
                                      ),
                                      chartName: 'Balance',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
                                    child: ChartHolder(
                                      chartWidget: Container(
                                        height: 300,
                                        width: 300,
                                        child: BarChartSample2(
                                          currentFilter: _currentFilter,
                                          transactionsInPeriod: DateTime.now().isBefore(_endOfPeriod) && predictedTransactions != null
                                              ? [
                                            ...transactionsInPeriod,
                                            ...predictedTransactions!
                                          ]
                                              : transactionsInPeriod,
                                          startOfPeriod: _startOfPeriod,
                                        ),
                                      ),
                                      chartName: 'Transactions',
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
                                    child: ChartHolder(
                                      chartWidget: Container(
                                        height: 300,
                                        width: 300,
                                        child: PieChartSample1(
                                          transactionsInPeriod: DateTime.now().isBefore(_endOfPeriod) && predictedTransactions != null
                                              ? [
                                            ...transactionsInPeriod,
                                            ...predictedTransactions!
                                          ]
                                              : transactionsInPeriod,
                                        ),
                                      ),
                                      chartName: 'Spending By Category',
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: TransactionChart(
                                  //     transactionsByDay: transactionsByDay,
                                  //   ),
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: ChartHolder(
                                  //     chartWidget: TransactionBarChart(
                                  //       transactionsByDay: transactionsByDay,
                                  //     ),
                                  //     chartName: 'Transaction Bar Chart',
                                  //   ),
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: ElevatedButton(
                                  //     onPressed: () async {
                                  //       List<local
                                  //           .Transaction> predictedTransactions = await displayPrediction();
                                  //       predictedTransactionsByDay = {};
                                  //       for (var transaction in predictedTransactions) {
                                  //         var date = DateTime(
                                  //           transaction.timestamp!.year,
                                  //           transaction.timestamp!.month,
                                  //           transaction.timestamp!.day,
                                  //         );
                                  //         predictedTransactionsByDay![date] =
                                  //             (predictedTransactionsByDay![date] ??
                                  //                 0) +
                                  //                 transaction.amount;
                                  //       }
                                  //
                                  //       // Filter the predicted transactions based on the selected filter
                                  //       predictedTransactionsByDay =
                                  //           predictedTransactionsByDay!.entries
                                  //               .where((entry) =>
                                  //           entry.key.isAfter(_startOfPeriod) &&
                                  //               entry.key.isBefore(_endOfPeriod))
                                  //               .fold<Map<DateTime, double>>(
                                  //               {}, (map, entry) {
                                  //             map[entry.key] = entry.value;
                                  //             return map;
                                  //           });
                                  //
                                  //       setState(() {});
                                  //     },
                                  //     child: Text('Display Prediction'),
                                  //   ),
                                  // ),
                                ],
                              );
                                                        }//Marked
                                                  }
                                                },
                                              ),
                                            ),
                            ),
            );
          }
        },
      ),
    );
  }
}