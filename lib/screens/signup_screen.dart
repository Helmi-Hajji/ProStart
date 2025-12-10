import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prostart/screens/main_screen.dart';
import '../utils/utils.dart';
import 'auth_page.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isChecked = false;

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage("Passwords do not match!");
      return;
    }

    if (!_isChecked) {
      _showMessage("You must agree to the Terms & Privacy to continue.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Utils.showLoadingDialog(context);

    await Future.delayed(const Duration(milliseconds: 1500));

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        print("✅ Firebase Auth Success! UID: ${user.uid}");

        Map<String, dynamic> userData = {
          "fullName": _fullNameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "uid": user.uid,
        };

        print("📤 Attempting to store user in Firestore: $userData");

        await _firestore.collection("users").doc(user.uid).set(userData);

        print("✅ Firestore Write Success!");


        _showMessage("Account created successfully!");

        Utils.hideLoadingDialog(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } catch (e, stacktrace) {
      print("❌ Error during sign-up: $e");
      print(stacktrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      resizeToAvoidBottomInset: true,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50, top: 330),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextField(_fullNameController, Icons.person, "Full Name"),
                      const SizedBox(height: 15),
                      buildTextField(_emailController, Icons.mail, "Email Address"),
                      const SizedBox(height: 15),
                      buildTextField(_phoneController, Icons.phone, "Phone Number"),
                      const SizedBox(height: 15),
                      buildTextField(_passwordController, Icons.lock, "Password", isPassword: true),
                      const SizedBox(height: 15),
                      buildTextField(_confirmPasswordController, Icons.lock, "Retype Password", isPassword: true),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                          const Text("I agree to the Terms & Privacy"),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _isLoading ? null : _signUp,
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
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthPage()),
                          );
                        },
                        child: const Text(
                          "Have an account? Sign In",
                          style: TextStyle(color: Color(0xff06234a), fontWeight: FontWeight.bold),
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
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff0694df), Color(0xff06234a)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 50, left: 50, right: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Let's",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                        Text(
                          "Create\nYour\nAccount",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, IconData icon, String label, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(width: 2.0, color: Color(0xff0694df)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(width: 2.0, color: Color(0xff0694df)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(width: 2.0, color: Color(0xff0694df)),
        ),
        prefixIcon: Icon(icon, color: const Color(0xff0694df)),
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xff0694df), fontWeight: FontWeight.bold),
      ),
    );
  }
}