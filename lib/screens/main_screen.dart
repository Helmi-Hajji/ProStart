import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'account_screen.dart';
import 'courses_screen.dart';
import 'cv_screen.dart';
import 'quiz_screen.dart';
import 'home_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const CVScreen(),
    const QuizScreen(),
    const CoursesScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color(0xff06234a),
        buttonBackgroundColor: const Color(0xff06234a),
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          Icon(FluentIcons.home_24_filled, color: Colors.white, size: 30),
          Icon(Icons.description, color: Colors.white, size: 30),
          Icon(Icons.quiz_rounded, color: Colors.white, size: 30),
          Icon(FluentIcons.hat_graduation_12_filled, color: Colors.white, size: 30),
          Icon(FluentIcons.settings_16_regular, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}