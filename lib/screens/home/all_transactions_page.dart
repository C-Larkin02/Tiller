import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:proto_proj/screens/home/transaction_list.dart';
import 'package:proto_proj/shared/loading.dart';

import '../../models/transaction.dart' as local;
import '../../shared/app_colors.dart';

class AllTransactionsPage extends StatelessWidget {
  final List<local.Transaction> transactions;

  AllTransactionsPage({required this.transactions});

  Future<Widget> getWidgetFuture() async {
    await Future.delayed(Duration(seconds: 2));
    // Use the main UI thread
    return await compute(buildTransactionList, transactions);
  }

  static Widget buildTransactionList(List<local.Transaction> transactions) {
    return TransactionList(transactions: transactions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.logoBlue,
        title: Text('Transactions', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Widget>(
        future: getWidgetFuture(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
            return Loading();
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}