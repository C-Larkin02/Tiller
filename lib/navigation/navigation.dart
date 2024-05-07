import 'package:flutter/material.dart';
import 'package:proto_proj/screens/home/home.dart';
import 'package:proto_proj/screens/Analytics/analytics.dart';
import '../screens/Budget/budget.dart';

class Navigation {
  static Widget getPage(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return Home();
      case 1:
        return Analytics();
      case 2:
        return Budget();
      default:
        return Home();
    }
  }
}
