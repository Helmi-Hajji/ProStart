import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _changePassword() async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    try {
      User? user = _auth.currentUser;
      String email = user?.email ?? '';

      // Reauthenticate
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
      await user?.reauthenticateWithCredential(credential);

      // Update password
      await user?.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password changed successfully")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _logout() async {
    await _auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Settings"),
        backgroundColor: const Color(0xff06234a),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Change Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(width: 2.0, color: Color(0xff06234a)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(width: 2.0, color: Color(0xff06234a)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(width: 2.0, color: Color(0xff06234a)),
                ),
                prefixIcon: Icon(Icons.lock, color: Color(0xff06234a)),
                labelText: 'Current Password',
                labelStyle: TextStyle(color: Color(0xff06234a), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(width: 2.0, color: Color(0xff06234a)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(width: 2.0, color: Color(0xff06234a)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide(width: 2.0, color: Color(0xff06234a)),
                ),
                prefixIcon: Icon(Icons.lock, color: Color(0xff06234a)),
                labelText: 'New Password',
                labelStyle: TextStyle(color: Color(0xff06234a), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.lock_reset,color:  Colors.white,),
              label: const Text("Change Password",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff06234a),
                minimumSize: const Size.fromHeight(55),
              ),
              onPressed: _changePassword,
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout,color: Colors.red,),
              label: const Text("Logout",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff06234a),
                minimumSize: const Size.fromHeight(55),
              ),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}