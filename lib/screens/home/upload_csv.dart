import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:proto_proj/services/database.dart';
import 'package:intl/intl.dart';
import 'package:proto_proj/shared/transaction_categorizer.dart';
import '../../models/transaction.dart' as local;

void uploadCSV(String uid, Function callback) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);

  if (result != null) {
    File file = File(result.files.single.path!);

    List<List<dynamic>> fields = CsvToListConverter().convert(await file.readAsString());

    if (fields.isNotEmpty) {
      fields.removeAt(0);
    }
    print("My Data ${fields}");

    Map<String, String> keywordToCategory = TransactionCategorizer.keywordToCategory;

    for (var row in fields) {
      String dateString = row[2].toString();
      DateTime? timestamp;
      try {
        timestamp = DateFormat('dd/MM/yyyy HH:mm').parse(dateString);
      } catch (e) {
        print('Error parsing date: $e');
      }

      // Create Transaction object
      local.Transaction transaction = local.Transaction(
        category: keywordToCategory.entries.firstWhere(
                (entry) => row[4].toString().contains(entry.key),
            orElse: () => MapEntry('', row[0].toString())
        )?.value ?? row[0].toString(),
        description: row[4].toString(),
        amount: double.tryParse(row[5].toString()) ?? 0.0,
        timestamp: timestamp,
        uid: uid,
        balance: double.tryParse(row[9].toString()) ?? 0.0,
      );

      //Check if timestamp is null
      if (transaction.timestamp == null) {
        throw Exception('Failed to parse transaction timestamp.');
      }

      await DatabaseService(uid: uid).updateUserData(
        transaction.category,
        transaction.description,
        transaction.amount,
        transaction.timestamp!,
        transaction.balance,
      );
    }
    callback();
  } else {

  }
}