import 'package:flutter/material.dart';
import 'package:proto_proj/shared/loading.dart';
import 'package:proto_proj/models/transaction.dart' as local;
import 'package:proto_proj/screens/home/transaction_tile.dart';
import 'package:intl/intl.dart';

class TransactionList extends StatelessWidget {
  final List<local.Transaction> transactions;

  TransactionList({required this.transactions});

  Future<List<Widget>> buildTransactionTiles() async {
    // Group transactions by date
    var groupedTransactions = <String, List<local.Transaction>>{};
    for (var transaction in transactions) {
      var dateString = DateFormat('MMM dd, yyyy').format(transaction.timestamp!);
      if (!groupedTransactions.containsKey(dateString)) {
        groupedTransactions[dateString] = [];
      }
      groupedTransactions[dateString]!.add(transaction);
    }

    // Building a list of widgets that includes a header for each date and the corresponding transactions for that date
    var widgets = <Widget>[];
    for (var entry in groupedTransactions.entries) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: 16.0, top: 16.00),
          child: Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
        ),
      ); //Header for the date value
      widgets.addAll(entry.value.map((transaction) => TransactionTile(transaction: transaction)).toList());
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder<List<Widget>>(
      future: buildTransactionTiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return Loading();
        } else {
          return ListView(
            children: snapshot.data!,
          );
        }
      },
    );
  }
}