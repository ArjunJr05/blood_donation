import 'package:blood/applicant/applicant.dart';

import 'package:blood/hr/attendance.dart';
import 'package:blood/hr/dashboard.dart';
import 'package:blood/hr/leave_applied.dart';
import 'package:blood/hr/resume.dart';
import 'package:blood/hr/resume2.dart';
import 'package:flutter/material.dart';

import '../home/drawer.dart';

class HRHomeScreen extends StatefulWidget {
  @override
  _HRHomeScreenState createState() => _HRHomeScreenState();
}

class _HRHomeScreenState extends State<HRHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HRDashboard(),
    PostJobScreen(), // Corrected class name to match the import
    HRLeaveRequestsScreen(),
    HRResumeScreen()
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
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'Leave Applied',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Resume',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
