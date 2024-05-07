import 'package:flutter/material.dart';
import 'package:proto_proj/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proto_proj/services/auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:proto_proj/models/user.dart' as local;
import 'second_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<local.User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        home: wrapper(),
      ),
    );
  }
}




