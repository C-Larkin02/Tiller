import 'package:flutter/material.dart';
import 'package:proto_proj/shared/app_colors.dart';
import 'package:proto_proj/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:proto_proj/services/auth.dart';
import '../../models/transaction.dart' as local;
import '../../models/user.dart' as local;
import '../../services/database.dart';
import 'package:proto_proj/models/budget_model.dart' as model;

import 'budget_category_detail_screen.dart';

class Budget extends StatefulWidget {
  const Budget({super.key});

  @override
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  final AuthService _auth = AuthService();
  int hasBudget = 0;
  model.Budget? budget;
  List<String> selectedCategories = [];
  Map<String, double> categoryLimits = {};
  String? currentCategory;
  double monthlySpend = 0;
  bool presentForm = false;
  Map<String, double> categorySpent = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final double limit = 0.0;
  Map<String, TextEditingController> _controllers = {};






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
        body: _buildWidgetBasedOnState(),
      ),
    );
  }

  // Widget _buildWidgetBasedOnState() {
  //   switch (hasBudget) {
  //     case 0:
  //       return _PromptBuildBudgetForm();
  //     case 1:
  //       return _buildBudgetForm();
  //     case 2:
  //       return _buildBudgetView();
  //     default:
  //       return Container();
  //   }
  // }

  Widget _buildWidgetBasedOnState() {
    final user = Provider.of<local.User?>(context);
    return StreamBuilder<model.Budget>(
      stream: DatabaseService(uid: user?.uid).budget,
      builder: (BuildContext context, AsyncSnapshot<model.Budget> snapshot) {
        if (presentForm) {
          print(presentForm);
          return _buildBudgetForm();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return _PromptBuildBudgetForm();
        } else if (snapshot.hasData) {
          print(snapshot.data?.toString() ?? 'No data');
          return _buildBudgetView(snapshot.data!);
        } else {
          return _PromptBuildBudgetForm();
        }
      },
    );
  }


  Widget _buildBudgetForm() {
    double limit = 0.0;
    //final TextEditingController _controller2 = TextEditingController(text: limit.toString());
    final user = Provider.of<local.User?>(context);
    //final TextEditingController _controller = TextEditingController();
    //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


    // category Options List
    List<String> categoryOptions = [
      'Savings',
      'Transfer',
      'Currency Exchange',
      'Food & Drinks',
      'Groceries',
      'Education',
      'Shopping',
      'Utilities',
      'Postal Services',
      'Investments',
      'Health & Wellness',
      'Transportation',
      'Travel',
      'Entertainment',
      'Healthcare',
      'Financial Services',
      'Income',
      'Expenses',
      'Charity',
      'Cash',
      'Cryptocurrency',
      'Retail',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Create Your Budget',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Monthly Spend'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Handle changes to monthly spend field
                monthlySpend = double.tryParse(value) ?? 0;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a number';
                } else if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Limit on a Category:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Select Category'),
                        value: currentCategory,
                        onChanged: (category) {
                          setState(() {
                            currentCategory = category;
                          });
                        },
                        items: categoryOptions.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(AppColors.logoBlue),
                      ),
                      onPressed: () {
                        if (currentCategory != null && !categoryLimits.containsKey(currentCategory)) {
                          setState(() {
                            categoryLimits[currentCategory!] = 0;
                            currentCategory = null;
                          });
                        }
                      },
                      child: Text('Add', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: categoryLimits.entries.map((entry) {
                String category = entry.key;
                double limit = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(category),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _controllers.putIfAbsent(
                              category,
                                  () => TextEditingController()
                          ),
                          //initialValue: limit.toString(),
                          decoration: InputDecoration(labelText: 'Max Spend'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a number';
                            } else if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            setState(() {
                              categoryLimits[category] = double.tryParse(value!) ?? 0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColors.logoBlue),
              ),
              onPressed: () {
                _formKey.currentState!.save();
                if (_formKey.currentState!.validate()) {
                  budget = model.Budget.initial(user?.uid ?? '');
                  budget?.categoryLimits = categoryLimits;
                  budget?.totalMonthlySpend = monthlySpend;
                  budget?.totalYearlySpend = monthlySpend * 12;
                  budget?.totalWeeklySpend = monthlySpend / 4;
                  print(budget?.toString() ?? 'Budget is null');
                  //double weeklyLimit, double monthlyLimit, double yearlyLimit, Map<String, double> categoryLimits
                  DatabaseService(uid: user?.uid).updateBudgetData(
                      budget!.totalWeeklySpend, budget!.totalMonthlySpend, budget!.totalYearlySpend, budget!.categoryLimits
                  );

                  setState(() {
                    presentForm = false;
                    hasBudget = 2;
                    _buildWidgetBasedOnState();
                  });
                  //selectedCategories = [];
                  //categoryLimits = {};
                  //monthlySpend = 0;
                }
              },
              child: Text('Submit', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColors.contentColorRed),
              ),
              onPressed: () {
                setState(() {
                  categoryLimits.clear();
                  monthlySpend = 0;
                });
              },
              child: Text('Clear Categories', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }




  Widget _buildBudgetView(model.Budget budget) {
    final user = Provider.of<local.User?>(context);
    model.Budget usersBudget = budget;
    return FutureBuilder<List<local.Transaction>>(
      future: DatabaseService(uid: user?.uid).transactions.first,
      builder: (BuildContext context, AsyncSnapshot<List<local.Transaction>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {

          //initialise variables required for the budget view
          List<local.Transaction> transactions = snapshot.data!;
          DateTime now = DateTime.now();
          List<local.Transaction> thisMonthTransactions = transactions.where((transaction) {
            return transaction.timestamp?.year == now.year && transaction.timestamp?.month == now.month;
          }).toList();

          double spentThisMonth = thisMonthTransactions.fold(0, (previousValue, transaction) {
            double transactionAmount = transaction.amount ?? 0;
            if (transactionAmount < 0) {
              return previousValue + transactionAmount;
            } else {
              return previousValue;
            }
          });
          spentThisMonth = -spentThisMonth;
          //print('Spent this month $spentThisMonth');
          double maxMonthSpend = usersBudget.totalMonthlySpend;
          double progress = spentThisMonth / maxMonthSpend;
          Map<String, double> categoryProgress = calculateCategoryProgress(usersBudget.categoryLimits, thisMonthTransactions);
          List<Widget> categoryProgressBars = generateCategoryProgressBars(usersBudget.categoryLimits, categoryProgress);
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: ListView(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Budget Overview',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [ Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Remaining Budget',
                      style: TextStyle(fontSize: 18, fontFamily: 'Lato', fontWeight: FontWeight.bold),
                    ),
                  ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            presentForm = true;
                          });
                        },
                        child: Text('Edit', style: TextStyle(fontSize: 15, fontFamily: 'Lato', fontWeight: FontWeight.bold, color: AppColors.logoBlue),
                        ),
                      ),
                    ),
                  ]
                ),
                SizedBox(height: 1.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      '\u20AC${(maxMonthSpend - spentThisMonth).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    color: Colors.white,
                    width: 320,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                      child: LinearProgressIndicator(
                        minHeight: 15,
                        value: progress,
                        backgroundColor: Colors.grey[350],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 0.8 ? Colors.red : AppColors.contentColorBlue,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Spent: \u20AC${spentThisMonth.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 15, fontFamily: 'Lato'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        'From: \u20AC$maxMonthSpend',
                        style: TextStyle(fontSize: 15, fontFamily: 'Lato'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Budget Category',
                        style: TextStyle(fontSize: 20, fontFamily: 'Lato', fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            presentForm = true;
                          });
                        },
                        child: Text('Add', style: TextStyle(fontSize: 15, fontFamily: 'Lato', fontWeight: FontWeight.bold, color: AppColors.logoBlue), ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                ...categoryProgressBars,
              ],
            ),
          );
        } else {
          return Text('No transactions found');
        }
      },
    );
  }
  Widget _PromptBuildBudgetForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Create Your Budget',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColors.logoBlue),
              ),
              onPressed: () {
                // Perform actions when the form is submitted, like updating the budget in the database
                setState(() {
                  presentForm = true;
                  hasBudget = 1;
                });
              },
              child: Text('Create Budget', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }


  Map<String, double> calculateCategoryProgress(Map<String, double> categoryLimits, List<local.Transaction> transactions) {
    categorySpent = {};

    List<local.Transaction> filteredTransactions = transactions.where((transaction) => transaction.amount < 0).toList();


    // Calculateing total amount spent in each category
    for (var transaction in filteredTransactions) {
      if (categoryLimits.containsKey(transaction.category)) {
        categorySpent.update(transaction.category, (value) => value + transaction.amount.abs(), ifAbsent: () => transaction.amount.abs());
      }
    }

    // Calculate progress
    Map<String, double> categoryProgress = {};
    categoryLimits.forEach((category, limit) {
      double spent = categorySpent[category] ?? 0;
      double progress;
      if (limit == 0) {
        progress = 0.0;
      } else {
        progress = spent / limit;
      }
      categoryProgress[category] = progress;
      print('category: $category, limit: $limit, spent: $spent, progress: ${categoryProgress[category]}');
    });

    return categoryProgress;
  }

  List<Widget> generateCategoryProgressBars(Map<String, double> categoryLimits, Map<String, double> categoryProgress) {
    List<Widget> categoryProgressBars = [];

    categoryLimits.forEach((category, limit) {
      IconData categoryIcon;
      switch (category) {
        case 'Savings':
          categoryIcon = Icons.monetization_on;
          break;
        case 'Transfer':
          categoryIcon = Icons.swap_horiz;
          break;
        case 'Currency Exchange':
          categoryIcon = Icons.attach_money;
          break;
        case 'Food & Drinks':
          categoryIcon = Icons.restaurant;
          break;
        case 'Groceries':
          categoryIcon = Icons.shopping_cart;
          break;
        case 'Education':
          categoryIcon = Icons.school;
          break;
        case 'Shopping':
          categoryIcon = Icons.shopping_bag;
          break;
        case 'Utilities':
          categoryIcon = Icons.lightbulb;
          break;
        case 'Postal Services':
          categoryIcon = Icons.local_post_office;
          break;
        case 'Investments':
          categoryIcon = Icons.trending_up;
          break;
        case 'Health & Wellness':
          categoryIcon = Icons.favorite;
          break;
        case 'Transportation':
          categoryIcon = Icons.directions_car;
          break;
        case 'Travel':
          categoryIcon = Icons.airplanemode_active;
          break;
        case 'Entertainment':
          categoryIcon = Icons.movie;
          break;
        case 'Healthcare':
          categoryIcon = Icons.local_hospital;
          break;
        case 'Financial Services':
          categoryIcon = Icons.account_balance;
          break;
        case 'Income':
          categoryIcon = Icons.attach_money;
          break;
        case 'Expenses':
          categoryIcon = Icons.money_off;
          break;
        case 'Charity':
          categoryIcon = Icons.favorite_border;
          break;
        case 'Cash':
          categoryIcon = Icons.attach_money;
          break;
        case 'Cryptocurrency':
          categoryIcon = Icons.monetization_on;
          break;
        case 'Retail':
          categoryIcon = Icons.store;
          break;
        default:
          categoryIcon = Icons.category;
      }

      categoryProgressBars.add(
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BudgetCategoryDetailScreen(
                    category: category,
                    spent: categorySpent[category] ?? 0,
                    limit: categoryLimits[category] ?? 0,
                  ),
                ),
              );
            },
            child: Card(
          color: Colors.white,
          margin: EdgeInsets.all(8.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Icon(categoryIcon, color: AppColors.logoBlue),
                    ),
                    SizedBox(width: 8.0),
                    Text(category, style: TextStyle(fontSize: 15, fontFamily: 'Lato', fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        'Spent: \u20AC${(categorySpent[category] ?? 0).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 15, fontFamily: 'Lato'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        'Of: \u20AC${categoryLimits[category]}',
                        style: TextStyle(fontSize: 15, fontFamily: 'Lato'),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 320,
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                      child: LinearProgressIndicator(
                        minHeight: 15,
                        value: categoryProgress[category],
                        backgroundColor: Colors.grey[350],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          categoryProgress[category]! > 0.8 ? Colors.red : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
          ),
      );
    });

    return categoryProgressBars;
  }
}