import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        title: const Text("About ProStart", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff06234a),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Logo
              Image.asset(
                'assets/images/Logo.png',
                height: 300,
              ),
              const SizedBox(height: 20),
              // App Name
              const Text(
                "ProStart",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff06234a),
                ),
              ),
              const SizedBox(height: 10),
              // Message
              const Text(
                "Empowering your career journey. I'm here to assist you every step of the way!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              // Phone
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, color: Color(0xff06234a)),
                  SizedBox(width: 10),
                  Text("+216 26 419 733", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              // Email
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, color: Color(0xff06234a)),
                  SizedBox(width: 10),
                  Text("contact@prostart.tn", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 30),
              // Version and copyright
              const Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 5),
              const Text("© 2025 ProStart. All rights reserved.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
