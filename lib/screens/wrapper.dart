import 'package:flutter/material.dart';
import 'package:proto_proj/screens/authenticate/authenticate.dart';
import 'package:proto_proj/screens/home/home.dart';
import 'package:provider/provider.dart';
import 'package:proto_proj/models/user.dart' as local;
import 'package:proto_proj/screens/MainScreen.dart';
import '../navigation/navigation.dart';

class wrapper extends StatelessWidget {
  const wrapper({super.key});
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<local.User?>(context);
    print(user);
    return user == null ? Authenticate() : MainScreen();

  }
}