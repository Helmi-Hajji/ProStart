import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prostart/infos.dart';
import '../terms_conditions_page.dart';
import 'auth_page.dart';
import 'change_password_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  File? _image;
  final picker = ImagePicker();

  String userName = "";
  String email = "";
  String phone = "";
  String profileImageUrl = "";

  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await firestore.collection("users").doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userName = data["fullName"] ?? "";
          email = data["email"] ?? user!.email!;
          phone = data["phone"] ?? "";
          profileImageUrl = data["profileImageUrl"] ?? "";
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && user != null) {
      final file = File(pickedFile.path);
      setState(() => _image = file);

      await firestore.collection("users").doc(user!.uid).update({
        "profileImageUrl": file.path,
      });

      profileImageUrl = file.path;
    }
  }

  void _editInfo(String label, String value, String field) {
    TextEditingController controller = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter new $label'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await firestore.collection("users").doc(user!.uid).update({
                field: controller.text,
              });
              setState(() {
                if (field == "fullName") userName = controller.text;
                if (field == "email") email = controller.text;
                if (field == "phone") phone = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String title, IconData icon, String value, String field) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xff06234a)),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.edit, color: Colors.grey),
      onTap: () => _editInfo(title, value, field),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false, // Hides the back button
          backgroundColor: const Color(0xff06234a),
          titleSpacing: 0,
          title: Row(
            children: [
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 40),
                child: Image.asset(
                  "assets/images/Logo.png",
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (profileImageUrl.isNotEmpty && File(profileImageUrl).existsSync()
                    ? FileImage(File(profileImageUrl))
                    : const AssetImage("assets/images/default_profile.png") as ImageProvider),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            _buildSectionTitle("Account settings"),
            _buildListItem("Name", Icons.person, userName, "fullName"),
            _buildListItem("Email", Icons.email, email, "email"),
            _buildListItem("Phone", Icons.phone, phone, "phone"),
            ListTile(
              leading: const Icon(Icons.password, color: Color(0xff06234a)),
              title: const Text("Update Password"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),

            // About Section
            _buildSectionTitle("About"),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xff06234a)),
              title: const Text("Infos"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InfoScreen()),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.feed_outlined, color: Color(0xff06234a)),
              title: const Text("Terms and Conditions"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsConditionsPage()),
                );
              },
            ),

            _buildSectionTitle("Disconnect"),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log out"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
