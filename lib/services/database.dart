import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proto_proj/models/transaction.dart' as local;
import 'package:proto_proj/models/user.dart' as local;
import '../models/budget_model.dart' as model;

class DatabaseService {

  final String? uid;
  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference transactionCollection = FirebaseFirestore.instance.collection('transactions');
  final CollectionReference budgetCollection = FirebaseFirestore.instance.collection('budgets');


  Future updateUserData(String category, String description, double amount, DateTime timestamp, double? balance) async {
    return await transactionCollection.add({
      'category': category,
      'description': description,
      'amount': amount,
      'timestamp': timestamp,
      'uid': uid,
      'balance': balance,

    });
  }

  Future updateBudgetData(double weeklyLimit, double monthlyLimit, double yearlyLimit, Map<String, double> categoryLimits) async {
    return await budgetCollection.doc(uid).set({
      'weeklyLimit': weeklyLimit,
      'monthlyLimit': monthlyLimit,
      'yearlyLimit': yearlyLimit,
      'categoryLimits': categoryLimits,
      'uid': uid,
    });
  }

  Future generateDummyData(String category, String description, double amount) async {
    DateTime startDate = DateTime(2024, 1, 24);
    DateTime endDate = DateTime.now();

    int randomMillisecondsSinceEpoch = startDate.millisecondsSinceEpoch + Random().nextInt(endDate.millisecondsSinceEpoch - startDate.millisecondsSinceEpoch);

    DateTime randomDate = DateTime.fromMillisecondsSinceEpoch(randomMillisecondsSinceEpoch);
    return await transactionCollection.add({
      'category': category,
      'description': description,
      'amount': amount,
      'timestamp': randomDate,
      'uid': uid,
    });
  }


  //list of transactions from snapshot
    List<local.Transaction> _transactionListFromSnapshot(QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        //print("UID from document: ${doc.get('uid')}");
        return local.Transaction(
          category: doc.get('category') ?? '',
          description: doc.get('description') ?? '',
          amount: doc.get('amount') ?? 0.0,
          timestamp: doc.get('timestamp')?.toDate() ?? DateTime.now(),
          uid: doc.get('uid') ?? '',
          balance: doc.get('balance') ?? 0.0,
        );
      }).toList();
    }

  model.Budget _budgetFromSnapshot(QuerySnapshot snapshot) {
    if (snapshot.docChanges.isEmpty) {
      throw Exception('Go to the budget page to create your first Budget!');
    }

    var doc = snapshot.docChanges.first.doc;
    return model.Budget(
      uid: doc.get('uid') ?? '',
      categoryLimits: Map<String, double>.from(doc.get('categoryLimits') ?? {}),
      totalWeeklySpend: doc.get('weeklyLimit') ?? 0.0,
      totalMonthlySpend: doc.get('monthlyLimit') ?? 0.0,
      totalYearlySpend: doc.get('yearlyLimit') ?? 0.0,
    );
  }

Stream<List<local.Transaction>> get transactions {
    print('uid from getter: ${uid}');
  return transactionCollection.where('uid', isEqualTo: uid).snapshots()
    .map(_transactionListFromSnapshot);
}


  Stream<List<local.Transaction>> getTransactionsByCategory(String category) {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return transactionCollection
        .where('uid', isEqualTo: uid)
        .where('category', isEqualTo: category)
        .where('timestamp', isGreaterThanOrEqualTo: firstDayOfMonth)
        .where('timestamp', isLessThanOrEqualTo: lastDayOfMonth)
        .snapshots()
        .map(_transactionListFromSnapshot);
  }


  Stream<model.Budget> get budget {
    return budgetCollection.where('uid', isEqualTo: uid).snapshots()
        .map(_budgetFromSnapshot);
  }


}

