// ignore_for_file: unused_import, prefer_const_constructors, avoid_print

import 'package:blood/auth_pages/get.dart'; // Make sure this path is correct
import 'package:blood/home/home_screen.dart'; // Correct path
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:blood/auth_pages/login_page.dart'; // Correct path
import 'package:blood/services/database.dart'; // Correct path

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<void> signInWithGoogle(context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Image.asset(
          'assets/gifs/removed_blood.gif', // Check asset path in pubspec.yaml
          width: 100,
          height: 100,
        ),
      ),
    );

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        Navigator.pop(context); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Google Sign-In aborted"),
        ));
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        Map<String, dynamic> userInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          "id": userDetails.uid,
        };

        await DatabaseMethods()
            .addUser(userDetails.uid, userInfoMap)
            .then((value) {
          Navigator.pop(context); // Dismiss loading dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DonationEligibilityForm(
                name: userDetails.displayName ?? "", // Provide default value
                email: userDetails.email ?? "", // Provide default value
                imgUrl: userDetails.photoURL ?? "", // Provide default value
                user: userDetails, // Pass the User object
              ),
            ),
          );
        });
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("FirebaseAuthException: ${e.message}"),
      ));
      print("FirebaseAuthException: ${e.code} - ${e.message}");
    } on PlatformException catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      if (e.code == 'network_error') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Network error occurred. Please check your connection."),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("PlatformException: ${e.message}"),
        ));
      }
      print("PlatformException: ${e.code} - ${e.message}");
    } catch (e) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred: $e"),
      ));
      print("General Exception: $e");
    }
  }
}
