// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'donor_goal_screen.dart';
import 'donor_list_screen.dart';
import 'emergency_alert_screen.dart';
import 'package:blood/home/drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DonorGoalScreen(),
    DonorListScreen(),
    RequestPage(),
  ];

  // Define app bar titles for each page
  final List<String> _titles = [
    'Donor Goals',
    'Donor List',
    'Emergency Requests'
  ];

  void _onItemTapped(int index) {
    if (index != 1) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.red,
      title: Text(
        _titles[_selectedIndex],
        style: TextStyle(color: Colors.white),
      ),
      actions: _selectedIndex == 0
          ? [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  // Add goal action
                },
              ),
            ]
          : _selectedIndex == 1
              ? [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Search donors action
                    },
                  ),
                ]
              : [
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () {
                      // Filter requests action
                    },
                  ),
                ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: AppDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Container(
            height: kBottomNavigationBarHeight + bottomPadding,
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _onItemTapped(0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: _selectedIndex == 0 ? Colors.red : Colors.grey,
                        ),
                        Text(
                          'Goals',
                          style: TextStyle(
                            color:
                                _selectedIndex == 0 ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: SizedBox()), // Space for FAB
                Expanded(
                  child: InkWell(
                    onTap: () => _onItemTapped(2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning,
                          color: _selectedIndex == 2 ? Colors.red : Colors.grey,
                        ),
                        Text(
                          'Alerts',
                          style: TextStyle(
                            color:
                                _selectedIndex == 2 ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        child: Icon(Icons.bloodtype, color: Colors.white),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
