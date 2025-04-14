// ignore_for_file: use_key_in_widget_constructors

import 'package:blood/employee/a.dart';
import 'package:blood/employee/leave.dart';
import 'package:blood/home/drawer.dart';
import 'package:flutter/material.dart';

class EmpHomeScreen extends StatefulWidget {
  @override
  _EmpHomeScreenState createState() => _EmpHomeScreenState();
}

class _EmpHomeScreenState extends State<EmpHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    LeaveFormScreen(),
    VerificationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF777DF1),
        selectedItemColor: Colors.white, // Selected icon color
        unselectedItemColor:
            const Color.fromARGB(255, 202, 200, 200), // Unselected icon color
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Leave Form',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: 'Verification',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
