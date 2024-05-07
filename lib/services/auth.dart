import 'dart:math';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proto_proj/models/user.dart' as local;
import 'package:proto_proj/services/database.dart';
import 'package:proto_proj/services/ImportData/csv_importer.dart' as csvImporter;
import 'package:flutter/services.dart' show rootBundle;
//import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../models/transaction.dart' as local;
import '../shared/transaction_categorizer.dart';


class AuthService{


  final FirebaseAuth _auth = FirebaseAuth.instance;


  //create user object based on FirebaseUser
  local.User? _userFromFirebaseUser(User? user){
    return user != null ? local.User(uid: user.uid) : null;
  }

  //auth user stream
  Stream<local.User?> get user {
    return _auth.authStateChanges()
        .map<local.User?>((User? user) => _userFromFirebaseUser(user));
  }

  //anonymous sign in
  Future signInAnon() async {
    try{
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user!;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  //email and password sign in
  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user!;



      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }


  //email and password registeration
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;

      local.User? userModel = _userFromFirebaseUser(user);

      if (userModel == null) {
        throw Exception('Failed to create local user model.');
      }

      // Load CSV file as a string
      // String data = await rootBundle.loadString(
      //     'assets/account-statement_2020-09-01_2024-03-31_en-ie_568cc3.csv');

      // Parse CSV data
      //List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(data);

      //Map<String, String> keywordToCategory = TransactionCategorizer.keywordToCategory;


      // Convert each row to a Transaction and add it to the database
      // for (var row in rowsAsListOfValues) {
      //   try {
      //     String dateString = row[2].toString();
      //     DateTime? timestamp;
      //     try {
      //       timestamp = DateFormat('dd/MM/yyyy HH:mm').parse(dateString);
      //     } catch (e) {
      //       print('Error parsing date: $e');
      //     }
      //
      //     // Create the Transaction object with the parsed timestamp
      //     // local.Transaction transaction = local.Transaction(
      //     //   category: row[0].toString(),
      //     //   description: row[4].toString(),
      //     //   amount: double.tryParse(row[5].toString()) ?? 0.0,
      //     //   timestamp: timestamp,
      //     //   uid: userModel.uid,
      //     //   balance: double.tryParse(row[9].toString()) ?? 0.0,
      //     //
      //     // );
      //
      //     // local.Transaction transaction = local.Transaction(
      //     //   category: keywordToCategory.entries.firstWhere(
      //     //           (entry) => row[4].toString().contains(entry.key),
      //     //       orElse: () => MapEntry('', row[0].toString())
      //     //   )?.value ?? row[0].toString(),
      //     //   description: row[4].toString(),
      //     //   amount: double.tryParse(row[5].toString()) ?? 0.0,
      //     //   timestamp: timestamp,
      //     //   uid: userModel.uid,
      //     //   balance: double.tryParse(row[9].toString()) ?? 0.0,
      //     // );
      //
      //     // if (transaction.timestamp == null) {
      //     //   throw Exception('Failed to parse transaction timestamp.');
      //     // }
      //
      //
      //     // Update user data with the transaction details
      //     // await DatabaseService(uid: userModel.uid).updateUserData(
      //     //   transaction.category,
      //     //   transaction.description,
      //     //   transaction.amount,
      //     //   transaction.timestamp!,
      //     //   transaction.balance,
      //     // );
      //
      //   } catch (e) {
      //     print('Error processing transaction: $e');
      //   }
      // }

      return user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }


  //sign out
  Future signOut() async {
    try{
      await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}