import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart' as local;
import '../../models/user.dart' as local;
import '../../services/database.dart';
import '../../shared/app_colors.dart';
import '../../shared/loading.dart';
import '../home/transaction_list.dart';


class BudgetCategoryDetailScreen extends StatelessWidget {
  final String category;
  final double spent;
  final double limit;

  BudgetCategoryDetailScreen({
    required this.category,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<local.User?>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.logoBlue,
        title: Text('Category Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(category, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Lato')),
              //subtitle: Text(category),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 100,
                  width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text('Spent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Lato')),
                      subtitle: Text('\€${spent.toStringAsFixed(2)}'),
                    ),
                  ),
                Container(
                  height: 100,
                  width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text('Limit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Lato')),
                      subtitle: Text('\€${limit.toStringAsFixed(2)}'),
                    ),
                  ),
              ],
            ),
            ListTile(
              title: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Lato')),
              //subtitle: Text(category),
            ),
            FutureBuilder<List<local.Transaction>>(
              future: DatabaseService(uid: user?.uid).getTransactionsByCategory(category).first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                  return Loading();
                } else {
                  return Expanded(child: TransactionList(transactions: snapshot.data!));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}