import 'package:intl/intl.dart';

class Transaction{
  //final String id;
  final String category;
  final String description;
  final double amount;
  DateTime? timestamp;
  final String uid;
  final double? balance;



  Transaction({required this.category, required this.description, required this.amount, this.timestamp, required this.uid, this.balance});

  Transaction.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        amount = json['amount'],
        timestamp = DateTime.parse(json['timestamp']),
        description = json['description'],
        category = json['category'],
        balance = json['balance'];

  @override
  String toString() {
    return 'Transaction: {'
        'uid: $uid, '
        'amount: ${amount.toStringAsFixed(2)}, '
        'timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp!)}, '
        'description: $description, '
        'category: $category'
        'balance: $balance'
        '}';
  }
}