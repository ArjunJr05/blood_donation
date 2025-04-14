import 'package:blood/applicant/applicant.dart';
import 'package:blood/applicant/emphome.dart';
import 'package:blood/auth_pages/login_page.dart';
import 'package:blood/employee/emphome.dart';
import 'package:blood/employee/leave.dart';
import 'package:blood/hr/dashboard.dart';
import 'package:blood/hr/hrhome.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zuulrceeulkhmozxkszi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp1dWxyY2VldWxraG1venhrc3ppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxNzMxMTksImV4cCI6MjA1NDc0OTExOX0.IRas5s67thDuTRGvTJDwI7WDfiW0u8pRid-jPxpfTzE',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leave Request',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF777DF1), // Set primary color
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF777DF1),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF777DF1), // Apply color to buttons
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF777DF1), width: 2),
          ),
        ),
      ),
      home: HRHomeScreen(),
    );
  }
}
