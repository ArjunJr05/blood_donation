// login_page.dart
import 'package:blood/auth_pages/get.dart';
import 'package:blood/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_pass.dart';
import 'sign_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final user = userCredential.user;
        final name = user?.displayName ?? '';
        final imgUrl = user?.photoURL ?? '';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DonationEligibilityForm(
              name: name,
              email: _emailController.text,
              imgUrl: imgUrl,
              user: user,
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = '';
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided';
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(errorMessage, style: TextStyle(fontSize: 16)),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerWidth = screenSize.width * 0.85;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            behaviour: RandomParticleBehaviour(
              options: ParticleOptions(
                baseColor: Colors.red,
                spawnOpacity: 0.8,
                opacityChangeRate: 0.25,
                minOpacity: 0.1,
                maxOpacity: 0.4,
                particleCount: 100,
                spawnMaxRadius: 10,
                spawnMaxSpeed: 50,
                spawnMinSpeed: 10,
              ),
            ),
            vsync: this,
            child: Container(),
          ),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenSize.height),
              child: Center(
                child: Container(
                  width: containerWidth > 400 ? 400 : containerWidth,
                  margin: EdgeInsets.symmetric(vertical: 20),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Welcome Back!",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              prefixIcon: Icon(Icons.email),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 10)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              prefixIcon: Icon(Icons.lock),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 10)),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ForgotPasswordPage()));
                            },
                            child: Text('Forgot Password?',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 14)),
                          ),
                        ),
                        if (_isLoading)
                          Container(
                            height: 80,
                            width: 80,
                            child: Image.asset('assets/gifs/removed_blood.gif',
                                fit: BoxFit.cover),
                          )
                        else
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Login',
                                    style: TextStyle(fontSize: 16)),
                              ),
                              SizedBox(height: 15),
                              Text("or login with",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 14)),
                              SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      AuthMethods().signInWithGoogle(context);
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 35,
                                      child: Image.asset(
                                          "assets/images/google.png",
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  SizedBox(width: 20),
                                  Container(
                                    height: 45,
                                    width: 45,
                                    child: Image.asset("assets/images/fb.png",
                                        fit: BoxFit.cover),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14)),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignupPage()));
                              },
                              child: Text('Sign Up',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
