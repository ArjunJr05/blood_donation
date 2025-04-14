import 'dart:ui';
import 'package:blood/applicant/emphome.dart';
import 'package:blood/employee/emphome.dart';
import 'package:blood/error%20handling/error.dart';
import 'package:blood/home/drawer.dart';
import 'package:blood/hr/dashboard.dart';
import 'package:blood/hr/hrhome.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _role = 'HR';
  bool _isOTPSent = false;
  bool _isLoading = false;
  bool _isNewUser = false;

  Future<bool> _checkUserExists(String email) async {
    try {
      final response =
          await supabase.from('users').select().eq('email', email).single();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.green : null,
        action: isError && _isOTPSent
            ? SnackBarAction(
                label: 'Resend OTP',
                textColor: Colors.white,
                onPressed: _resendOTP,
              )
            : null,
      ),
    );
  }

  bool _isValidEmailDomain(String email) {
    final domain = email.split('@').last;
    return (domain == 'smvec.ac.in' && _role != 'Applicant') ||
        _role == 'Applicant';
  }

  Future<void> _createOrUpdateUser(String email) async {
    try {
      final userId = supabase.auth.currentUser!.id;

      if (_isNewUser) {
        await supabase.from('users').insert({
          'id': userId,
          'email': email,
          'role': _role,
          'name': _nameController.text.trim(),
          'password': _passwordController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });
      } else {
        await supabase.from('users').upsert({
          'id': userId,
          'email': email,
          'role': _role,
        });
      }
    } catch (e) {
      ErrorService.showError(context, 'Error updating user data: $e');
    }
  }

  void _showNewUserDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Complete Your Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Set Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty ||
                  _passwordController.text.trim().isEmpty) {
                ErrorService.showError(context, 'Please fill all fields');
                return;
              }
              Navigator.pop(context);
              _verifyOTP();
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      if (!_isValidEmailDomain(email)) {
        _showSnackbar('Invalid email domain!', isError: true);
        return;
      }

      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );

      setState(() {
        _isOTPSent = true;
        _otpController.clear();
      });

      _showSnackbar('New OTP sent to your email');
    } catch (e) {
      _showSnackbar('Failed to send OTP: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginOrSendOTP() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();

      if (email.isEmpty) {
        throw 'Please enter your email';
      }

      if (!_isValidEmailDomain(email)) {
        throw 'Invalid email domain!';
      }

      _isNewUser = !(await _checkUserExists(email));

      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );

      setState(() => _isOTPSent = true);

      if (_isNewUser) {
        _showNewUserDialog();
      }

      ErrorService.showSuccess(context, 'OTP sent to your email');
    } catch (e) {
      ErrorService.showError(context, e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final otpCode = _otpController.text.trim();

      final response = await supabase.auth.verifyOTP(
        email: email,
        token: otpCode,
        type: OtpType.email,
      );

      if (response.session != null) {
        await _createOrUpdateUser(email);
        _navigateToRoleHomeScreen();
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('PostgrestException')) {
        _showSnackbar(
            'Authentication successful, but there was an error updating user data. Please try again.',
            isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToRoleHomeScreen() {
    switch (_role) {
      case 'HR':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HRHomeScreen()),
        );
        break;
      case 'Employee':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmpHomeScreen()),
        );
        break;
      case 'Applicant':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppHomeScreen()),
        );
        break;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          width: screenWidth,
          height: screenHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please login to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10000, sigmaY: 10000),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(19, 206, 198, 198),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person),
                                hintText: ("Name"),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.8),
                              ),
                              obscureText: true,
                            ),
                            const SizedBox(height: 16),
                            if (_isOTPSent)
                              TextField(
                                controller: _otpController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_clock),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.8),
                                ),
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 20),
                            const Text(
                              "Select Role:",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _RoleButton(
                                  icon: Icons.work,
                                  label: "HR",
                                  isSelected: _role == 'HR',
                                  onTap: () => setState(() => _role = 'HR'),
                                ),
                                _RoleButton(
                                  icon: Icons.person,
                                  label: "Employee",
                                  isSelected: _role == 'Employee',
                                  onTap: () =>
                                      setState(() => _role = 'Employee'),
                                ),
                                _RoleButton(
                                  icon: Icons.assignment_ind,
                                  label: "Applicant",
                                  isSelected: _role == 'Applicant',
                                  onTap: () =>
                                      setState(() => _role = 'Applicant'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isOTPSent ? _verifyOTP : _loginOrSendOTP),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isOTPSent ? "Verify OTP" : "Login / Send OTP",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isOTPSent ? _resendOTP : null,
                  child: Text(
                    _isOTPSent ? "Resend OTP" : "",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth / 5,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7C4DFF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
