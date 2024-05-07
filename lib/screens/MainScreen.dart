import 'package:flutter/material.dart';

import '../Navigation/navigation.dart';
import '../shared/NavBar.dart';


class MainScreen extends StatefulWidget {
  static _MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainScreenState>();

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigation.getPage(_currentIndex),
      bottomNavigationBar: NavBar(
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
      ),
    );
  }
}