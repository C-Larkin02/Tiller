import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proto_proj/screens/home/transaction_tile_limited.dart';
import 'package:proto_proj/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:proto_proj/models/transaction.dart' as local;
import 'package:proto_proj/screens/home/transaction_tile.dart';

import '../../shared/app_colors.dart';
import 'all_transactions_page.dart';


class TransactionListLimited extends StatefulWidget {
  @override
  _TransactionListLimitedState createState() => _TransactionListLimitedState();
}

class _TransactionListLimitedState extends State<TransactionListLimited> {
  @override
  Widget build(BuildContext context){
    final transactions = Provider.of<List<local.Transaction>?>(context);

    if (transactions == null || transactions.isEmpty) {
      // Return a placeholder or loading indicator
      //Check fixes a red screen error
      // return Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(15.0),
      //     child: Icon(Icons.sentiment_very_satisfied, size: 70.0, color: AppColors.logoBlue),
      //   ),
      // );
      return Container();

    }

    // Sort transactions chronilogically and take first 2
    final recentTransactions = transactions!
        .where((t) => t.timestamp != null)
        .toList()
      ..sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    final limitedTransactions = recentTransactions.take(3).toList();

    if (limitedTransactions.isEmpty) {
      // Return a placeholder or loading indicator
      // return Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(15.0),
      //     child: Icon(Icons.sentiment_very_satisfied, size: 70.0, color: AppColors.logoBlue),
      //   ),
      // );
      return Container();

    }

    return Container(
      height: 250,
      width: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 5, bottom: 5),
              child: Text(
                'TRANSACTIONS',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: limitedTransactions.length,
              itemBuilder: (context, index) {
                return TransactionTileLimited(transaction: limitedTransactions[index]);
              },
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllTransactionsPage(transactions: recentTransactions)),
              );
            },
            child: Text('See All', style: TextStyle(color: AppColors.logoBlue)),
          ),
        ],
      ),
    );
  }
}