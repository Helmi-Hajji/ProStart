import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prostart/screens/auth_page.dart';
import '../utils/utils.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    Utils.showLoadingDialog(
      context,
      animationAsset: 'assets/animations/reset_password.json',
    );
    await Future.delayed(const Duration(seconds: 7));
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage("Please enter your email!");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessage("Password reset email sent! Check your inbox.");
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Notification"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Utils.hideLoadingDialog(context);
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff0694df), Color(0xff06234a)],
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 100.0, left: 50, right: 50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lock_outline, color: Colors.white, size: 70),
                          SizedBox(height: 20),
                          Text(
                            "Forget Password?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "No worries, we’ll send you reset instructions",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 500.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          color: Colors.white,
                        ),
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
                          child: Column(
                            children: [
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  prefixIcon: const Icon(Icons.mail, color: Color(0xff0694df)),
                                  labelText: "Enter Your Email",
                                  labelStyle: const TextStyle(color: Color(0xff0694df), fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _resetPassword,
                                child: Container(
                                  height: 60,
                                  width: 310,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xff0694df), Color(0xff06234a)],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AuthPage()),
                                  );
                                },
                                child: const Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: Color(0xff06234a),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
