import 'package:flutter/material.dart';
import 'package:blood/auth_pages/login_page.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final SupabaseClient _supabase = Supabase.instance.client;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  void _loadUserEmail() {
    final User? currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _userEmail = currentUser.email;
        _isLoading = false;
      });
    }
  }

  Widget _buildUserHeader() {
    if (_isLoading) {
      return UserAccountsDrawerHeader(
        accountName: Text('Loading...', style: TextStyle(color: Colors.black)),
        accountEmail: Text('', style: TextStyle(color: Colors.black)),
        currentAccountPicture: CircleAvatar(
          backgroundColor: Color(0xFF7C4DFF),
          child: CircularProgressIndicator(color: Colors.white),
        ),
        decoration: BoxDecoration(color: Colors.white),
      );
    }

    return UserAccountsDrawerHeader(
      accountName: Text(
        _userEmail ?? '',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        _userEmail ?? '',
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Color(0xFF7C4DFF),
        child: Text(
          (_userEmail ?? '?')[0].toUpperCase(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      decoration: BoxDecoration(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildUserHeader(),
          Divider(),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await _supabase.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
