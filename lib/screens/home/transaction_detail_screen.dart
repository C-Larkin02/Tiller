import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import 'package:flutter/material.dart';

import '../../shared/app_colors.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  TransactionDetailScreen({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.logoBlue,
        title: Text('Transaction Details', style: TextStyle(fontFamily: 'Lato' , color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Lato')),
              subtitle: Text(transaction.description ?? 'No Description'),
            ),
            ListTile(
              title: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Lato')),
              subtitle: Text(NumberFormat.currency(symbol: '\€', decimalDigits: 2, locale: 'en_US').format(transaction.amount)),
            ),
            ListTile(
              title: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Lato' )),
              subtitle: Text(transaction.category ?? 'No Category'),
            ),
            ListTile(
              title: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Lato' )),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(transaction.timestamp!)),
            ),
          ],
        ),
      ),
    );
  }
}