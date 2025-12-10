import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/utils.dart';

class CVScreen extends StatefulWidget {
  const CVScreen({super.key});

  @override
  _CVScreenState createState() => _CVScreenState();
}

class _CVScreenState extends State<CVScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get user => _auth.currentUser;

  File? _cvFile;
  bool _isUploading = false;
  String? _formattedFeedback;

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadAndAnalyzeCV() async {
    if (_cvFile == null) return;

    setState(() {
      _isUploading = true;
      _formattedFeedback = null;
      Utils.showLoadingDialog(
        context,
        animationAsset: 'assets/animations/cv_animation.json',
      );
    });

    try {
      var uri = Uri.parse('http://10.0.2.2:8000/analyze-cv/');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', _cvFile!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        var feedback = jsonResponse['feedback'];

        setState(() {
          _formattedFeedback = _formatFeedback(feedback);
        });

        await incrementUsageCounter("cvAnalysisCount");
      } else {
        setState(() {
          _formattedFeedback = "❌ Error: ${response.statusCode} - ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _formattedFeedback = "⚠️ An error occurred while processing your CV.\nDetails: $e";
      });
    }finally {
      Utils.hideLoadingDialog(context);
      setState(() => _isUploading = false);
    }
  }

  String _formatFeedback(Map<String, dynamic> feedback) {
    if (feedback.isEmpty) {
      return "✅ Your CV looks great! No major improvements needed.";
    }

    String formatted = "📌 CV Analysis Feedback:\n\n";
    feedback.forEach((section, comment) {
      formatted += "🔹 $section: $comment\n\n";
    });

    return formatted;
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xff0694df), Color(0xff06234a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> incrementUsageCounter(String fieldName) async {
    if (user != null) {
      final usageDoc = firestore.collection("users").doc(user!.uid).collection("analytics").doc("usage");
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(usageDoc);
        if (snapshot.exists) {
          final current = snapshot.data()?[fieldName] ?? 0;
          transaction.update(usageDoc, {
            fieldName: current + 1,
          });
        } else {
          transaction.set(usageDoc, {fieldName: 1});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
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
                  "CV Analysis",
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              "assets/images/cv_analysis.png",
              height: 180,
            ),
            const SizedBox(height: 20),
            const Text(
              "I'm here to help you improve your CV and land your dream job!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xff06234a),
              ),
            ),
            const SizedBox(height: 30),
            _buildGradientButton(text: 'Pick CV (PDF)', onTap: _pickCV),
            if (_cvFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Selected: ${_cvFile!.path.split('/').last}',
                  style: const TextStyle(
                    color: Color(0xff06234a),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            _buildGradientButton(
              text: 'Upload & Analyze',
              onTap: _uploadAndAnalyzeCV,
              isLoading: _isUploading,
            ),
            if (_formattedFeedback != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _formattedFeedback!,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}