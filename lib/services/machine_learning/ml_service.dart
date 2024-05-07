import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:proto_proj/models/transaction.dart' as local;

Future<List<local.Transaction>> getPrediction(List<local.Transaction> transactions) async {

  List<Map<String, dynamic>> transactionData = transactions.map((transaction) => {
    'category': transaction.category,
    'description': transaction.description,
    'amount': transaction.amount,
    'timestamp': transaction.timestamp?.toIso8601String(),
    'uid': transaction.uid,
    'balance': transaction.balance,
  }).toList();

  var response = await http.post(
    //Uri.parse('http://10.0.2.2:5000'),
    Uri.parse('https://7069-64-43-50-168.ngrok-free.app'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(transactionData),
  );
  if (response.statusCode == 200) {
    var list = jsonDecode(response.body) as List;
    return list.map((item) => local.Transaction.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load prediction');
  }
}