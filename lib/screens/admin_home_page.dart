import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'admin_course_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_quiz_screen.dart';
import 'admin_settings_screen.dart';
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardScreen(), // Users + Analytics
    const AdminQuizScreen(),      // Quiz CRUD
    const AdminCourseScreen(),    // Course CRUD
    const AdminSettingsScreen(),  // Change password + Logout
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
          Icon(FluentIcons.home_24_filled, color: Colors.white),
          Icon(Icons.quiz, color: Colors.white),
          Icon(Icons.school, color: Colors.white),
          Icon(Icons.settings, color: Colors.white),
        ],
      ),
    );
  }
}
