import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:proto_proj/models/transaction.dart' as local;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proto_proj/models/user.dart' as local;

Future<List<local.Transaction>> importTransactions(local.User user, String filePath) async {
  final input = new File(filePath).openRead();
  final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();

  List<local.Transaction> transactions = [];

  for (var i = 1; i < fields.length; i++) {
    transactions.add(local.Transaction(
      category: fields[i][0],
      description: fields[i][4],
      amount: double.parse(fields[i][5]),
      timestamp: DateTime.parse(fields[i][2]),
      uid: user.uid,
    ));
  }

  return transactions;
}