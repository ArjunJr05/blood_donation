// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart'; // Imports the Flutter Material Design library.
import 'package:blood/auth_pages/login_page.dart'; // Imports the login page from a relative path.
import 'history_screen.dart'; // Imports the history screen widget.
import 'profile_screen.dart'; // Imports the profile screen widget.
import 'package:cloud_firestore/cloud_firestore.dart'; // Imports the Cloud Firestore package.
import 'package:firebase_auth/firebase_auth.dart'; // Imports the Firebase Authentication package.

class AppDrawer extends StatefulWidget {
  // Defines a StatefulWidget called AppDrawer.
  @override // Overrides the createState method.
  _AppDrawerState createState() =>
      _AppDrawerState(); // Returns an instance of _AppDrawerState.
}

class _AppDrawerState extends State<AppDrawer> {
  // Defines the state class for AppDrawer.
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Creates an instance of FirebaseAuth.
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Creates an instance of FirebaseFirestore.
  Map<String, dynamic>?
      _cachedUserData; // Declares a nullable map to store user data.
  bool _isLoading = true; // Declares a boolean to track loading state.
  String? _error; // Declares a nullable string to store error messages.

  @override // Overrides the initState method.
  void initState() {
    // Initializes the state.
    super.initState(); // Calls the superclass's initState method.
    _loadUserData(); // Calls the _loadUserData method.
  }

  Future<void> _loadUserData() async {
    // Defines an asynchronous function to load user data.
    try {
      // Starts a try-catch block to handle potential errors.
      setState(() {
        // Calls setState to rebuild the widget.
        _isLoading = true; // Sets _isLoading to true.
        _error = null; // Sets _error to null.
      });

      User? currentUser =
          _auth.currentUser; // Gets the currently logged-in user.
      if (currentUser != null) {
        // Checks if a user is logged in.
        _firestore.collection('User').doc(currentUser.uid).snapshots().listen(
          // Listens to real-time updates for the user's document.
          (snapshot) {
            // Callback function for when the snapshot changes.
            if (mounted) {
              // Checks if the widget is still mounted.
              setState(() {
                // Calls setState to rebuild the widget.
                _cachedUserData =
                    snapshot.data(); // Stores the user data from the snapshot.
                _isLoading = false; // Sets _isLoading to false.
              });
            }
          },
          onError: (error) {
            // Callback function for when an error occurs.
            if (mounted) {
              // Checks if the widget is still mounted.
              setState(() {
                // Calls setState to rebuild the widget.
                _error = error.toString(); // Stores the error message.
                _isLoading = false; // Sets _isLoading to false.
              });
            }
          },
        );
      }
    } catch (e) {
      // Catches any exceptions that occur.
      if (mounted) {
        // Checks if the widget is still mounted.
        setState(() {
          // Calls setState to rebuild the widget.
          _error = e.toString(); // Stores the error message.
          _isLoading = false; // Sets _isLoading to false.
        });
      }
    }
  }

  Widget _buildUserHeader() {
    // Defines a function to build the user header.
    if (_isLoading) {
      // Checks if the data is still loading.
      return UserAccountsDrawerHeader(
        // Returns a UserAccountsDrawerHeader widget.
        accountName:
            Text('Loading...'), // Displays "Loading..." as the account name.
        accountEmail:
            Text(''), // Displays an empty string as the account email.
        currentAccountPicture: CircleAvatar(
          // Displays a circular progress indicator.
          backgroundColor:
              Colors.redAccent, // Sets the background color to redAccent.
          child: CircularProgressIndicator(
              color: Colors
                  .white), // Displays a white circular progress indicator.
        ),
        decoration: BoxDecoration(
            color: Colors
                .white), // Sets the background color of the header to white.
      );
    }

    if (_error != null) {
      // Checks if an error occurred.
      return UserAccountsDrawerHeader(
        // Returns a UserAccountsDrawerHeader widget.
        accountName: Text(
            'Error loading data'), // Displays "Error loading data" as the account name.
        accountEmail:
            Text(''), // Displays an empty string as the account email.
        currentAccountPicture: CircleAvatar(
          // Displays an error icon.
          backgroundColor:
              Colors.redAccent, // Sets the background color to redAccent.
          child: Icon(Icons.error,
              color: Colors.white), // Displays a white error icon.
        ),
        decoration: BoxDecoration(
            color: Colors
                .white), // Sets the background color of the header to white.
      );
    }

    final name = _cachedUserData?['name'] ??
        'No Name'; // Gets the user's name or defaults to "No Name".
    final email = _cachedUserData?['email'] ??
        'No Email'; // Gets the user's email or defaults to "No Email".
    final imgUrl = _cachedUserData?['imgUrl'] ??
        ''; // Gets the user's image URL or defaults to an empty string.

    return UserAccountsDrawerHeader(
      // Returns a UserAccountsDrawerHeader widget.
      accountName: Text(
        // Displays the user's name.
        name,
        style: TextStyle(color: Colors.black), // Sets the text color to black.
      ),
      accountEmail: Text(
        // Displays the user's email.
        email,
        style: TextStyle(color: Colors.black), // Sets the text color to black.
      ),
      currentAccountPicture: imgUrl
              .isNotEmpty // Checks if an image URL is available.
          ? CircleAvatar(
              // Displays the user's image.
              backgroundImage:
                  NetworkImage(imgUrl), // Loads the image from the network.
              backgroundColor:
                  Colors.transparent, // Makes the background transparent.
            )
          : CircleAvatar(
              // Displays the user's initial.
              backgroundColor:
                  Colors.redAccent, // Sets the background color to redAccent.
              child: Text(
                // Displays the first letter of the name.
                name.isNotEmpty
                    ? name[0].toUpperCase()
                    : '?', // Gets the first letter or defaults to '?'.
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white), // Sets the font size and color.
              ),
            ),
      decoration: BoxDecoration(
          color: Colors
              .white), // Sets the background color of the header to white.
    );
  }

  @override // Overrides the build method.
  Widget build(BuildContext context) {
    // Builds the widget.
    return Drawer(
      // Returns a Drawer widget.
      child: Column(
        // Returns a Column widget.
        children: [
          // Contains the children of the Column.
          _buildUserHeader(), // Calls the _buildUserHeader function to build the user header.
          Divider(), // Adds a divider.
          ListTile(
            // Returns a ListTile widget for History.
            leading: Icon(Icons.history), // Displays a history icon.
            title: Text('History'), // Displays "History" as the title.
            onTap: () {
              // Callback function for when the tile is tapped.
              Navigator.push(
                // Navigates to the HistoryScreen.
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
          ListTile(
            // Returns a ListTile widget for Profile.
            leading: Icon(Icons.person), // Displays a person icon.
            title: Text('Profile'), // Displays "Profile" as the title.
            onTap: () {
              // Callback function for when the tile is tapped.
              Navigator.push(
                // Navigates to the ProfileScreen.
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
          ListTile(
            // Returns a ListTile widget for Settings.
            leading: Icon(Icons.settings), // Displays a settings icon.
            title: Text('Settings'), // Displays "Settings" as the title.
            onTap: () {}, // Empty callback function.
          ),
          ListTile(
            // Returns a ListTile widget for Logout.
            leading: Icon(Icons.logout), // Displays a logout icon.
            title: Text('Logout'), // Displays "Logout" as the title.
            onTap: () async {
              // Asynchronous callback function for when the tile is tapped.
              await _auth.signOut(); // Signs the user out.
              Navigator.pushAndRemoveUntil(
                // Navigates to the LoginPage and removes all previous routes.
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
