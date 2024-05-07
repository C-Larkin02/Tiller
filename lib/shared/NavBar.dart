import 'package:flutter/material.dart';
import 'package:proto_proj/Navigation/navigation.dart';
import 'app_colors.dart';

class NavBar extends StatefulWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  NavBar({required this.onTabTapped, required this.currentIndex});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.logoBlue,
      currentIndex: widget.currentIndex,
      onTap: (index) {
        widget.onTabTapped(index);
      },
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.euro),
          label: 'Budget',
        ),
      ],
    );
  }
}
