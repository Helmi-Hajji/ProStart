import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prostart/screens/account_screen.dart';

import '../utils/utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // added
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  bool _loading = false;
  String _errorMessage = "";

  Future<void> _changePassword() async {
    setState(() {
      _loading = true;
      _errorMessage = "";
      Utils.showLoadingDialog(
        context,
        animationAsset: 'assets/animations/loading_animation.json',
      );
    });

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _loading = false;
        _errorMessage = "New passwords do not match.";
      });
      return;
    }

    try {
      // Reauthenticate
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentPasswordController.text,
      );

      await user!.reauthenticateWithCredential(cred);

      // Change password
      await user!.updatePassword(_newPasswordController.text);

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AccountScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = "Failed to change password: ${e.toString()}";
        Utils.hideLoadingDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff06234a),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 15),
              buildTextField(_currentPasswordController, Icons.lock, "Current Password", isPassword: true),
              const SizedBox(height: 15),
              buildTextField(_newPasswordController, Icons.lock, "New Password", isPassword: true),
              const SizedBox(height: 15),
              buildTextField(_confirmPasswordController, Icons.lock_reset, "Confirm New Password", isPassword: true),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _loading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _changePassword();
                  }
                },
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
                      'Change Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
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
