import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms and Conditions", style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xff06234a),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
Your App's Terms and Conditions

1. Usage
   - You agree to use ProStart only for personal, non-commercial purposes.

2. Data Privacy
   - We collect basic user data (such as name, email, and CVs) to personalize your experience. We do not sell or share your data.

3. Content
   - All learning content and AI-generated feedback are for educational purposes only and may not guarantee job placement.

3. Account
   -You are responsible for keeping your login information secure. Any misuse of your account is your responsibility.
   
3. Changes
   -We may update these terms at any time. Continued use of the app implies acceptance of the updated terms.
   
If you disagree with any of these terms, you should stop using ProStart.
            ''',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
