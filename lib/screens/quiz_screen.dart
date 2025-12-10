import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prostart/screens/quiz_questions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/utils.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static final Map<String, double> jobProgress = {
    "Data Scientist": 0.0,
    "Business Analyst": 0.0,
    "AI Engineer": 0.0,
    "IT Support Specialist": 0.0,
    "Mobile Developer": 0.0,
    "Web Developer": 0.0,
    "ERP Consultant": 0.0,
    "Digital Marketing Analyst": 0.0,
    "Data Analyst": 0.0,
  };

  static String? matchedJob;

  void _startQuiz(String job) async {
    Utils.showLoadingDialog(context);
    final questions = await fetchQuizQuestions(job);
    Utils.hideLoadingDialog(context);

    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No questions found for $job")),
      );
      return;
    }

    final mappedQuestions = questions.map((q) => {
      'question': q['question'],
      'options': q['options'],
      'answer': q['answer'],
      'type': q['type'],
      'solution': q['solution'],
    }).toList();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(job: job, questions: mappedQuestions),
      ),
    );

    if (result != null && result is double) {
      setState(() {
        jobProgress[job] = result;
        _updateMatchedJob();
      });
      await incrementUsageCounter("quizAttempts");
    }
  }

  void _updateMatchedJob() async {
    Utils.showLoadingDialog(context);
    final sorted = jobProgress.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topJob = sorted.first.value > 0 ? sorted.first.key : null;

    setState(() {
      matchedJob = topJob;
    });

    if (topJob != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'matchedJob': topJob});
        }
      } catch (e) {
        print('🔥 Failed to update matched job: $e');
      }
    }
    Utils.hideLoadingDialog(context);
  }

  Future<List<Map<String, dynamic>>> fetchQuizQuestions(String job) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> questions = [];

    try {
      final snapshot = await firestore
          .collection('quizzes')
          .doc(job.toLowerCase().replaceAll(' ', '_'))
          .collection('questions')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('question') &&
            data.containsKey('answer') &&
            data.containsKey('type')) {
          questions.add({
            'question': data['question'],
            'options': data['type'] == 'coding'
                ? ["Write your answer here", "Skip", "Ask AI Help"]
                : data['type'] == 'true/false'
                ? ["True", "False"]
                : List<String>.from(data['options'] ?? []),
            'answer': data['type'] == 'coding' ? 0 : data['answer'],
            'type': data['type'],
            'solution': data['answer'], // for review
          });
        }
      }
    } catch (e) {
      print("Error fetching questions: $e");
    }

    return questions;
  }

  Future<void> incrementUsageCounter(String fieldName) async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user != null) {
      final usageDoc = firestore.collection("users").doc(user.uid).collection("analytics").doc("usage");
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(usageDoc);
        if (snapshot.exists) {
          final current = snapshot.data()?[fieldName] ?? 0;
          transaction.update(usageDoc, {
            fieldName: current + 1,
          });
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
                  "ProStart Quiz",
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
      body: Column(
        children: [
          if (matchedJob != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '🎯 Top Match: $matchedJob',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0694df),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: jobProgress.length,
              itemBuilder: (context, index) {
                final job = jobProgress.keys.elementAt(index);
                final progress = jobProgress[job]!;
                final isTopMatch = job == matchedJob;

                return GestureDetector(
                  onTap: () => _startQuiz(job),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade200,
                        child: const Icon(Icons.work, color: Colors.white),
                      ),
                      title: Text(
                        job,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isTopMatch ? Colors.green : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      trailing: isTopMatch
                          ? const Icon(Icons.emoji_events, color: Colors.amber)
                          : const Icon(Icons.play_arrow, color: Color(0xff0694df)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}