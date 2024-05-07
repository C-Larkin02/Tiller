import 'package:flutter/material.dart';
import 'package:proto_proj/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:proto_proj/screens/home/transaction_detail_screen.dart';

import 'icon_by_category.dart';

class TransactionTileLimited extends StatelessWidget {
  final Transaction transaction;
  TransactionTileLimited({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailScreen(transaction: transaction),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconByCategory(transaction.category),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.description ?? 'No Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(transaction.category ?? 'No Category', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                Text(NumberFormat.currency(symbol: '\€', decimalDigits: 2, locale: 'en_US').format(transaction.amount), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}