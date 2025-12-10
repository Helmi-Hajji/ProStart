import 'package:flutter/material.dart';

import '../utils/widgest.dart';

class QuizPage extends StatefulWidget {
  final String job;
  final List<Map<String, dynamic>> questions;

  const QuizPage({super.key, required this.job, required this.questions});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late List<Map<String, dynamic>> questions;
  TextEditingController codeController = TextEditingController();
  int currentIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    questions = widget.questions;
    codeController = TextEditingController();
  }

  void _answer(dynamic selectedAnswer, {bool isCoding = false}) {
    final question = questions[currentIndex];
    final questionType = question['type'];

    bool isCorrect = false;

    if (isCoding) {
      final correctCode = question['solution'];
      final userCode = codeController.text.trim();
      if (userCode.isNotEmpty && _normalizeCode(userCode) == _normalizeCode(correctCode)) {
        isCorrect = true;
      }
    } else if (questionType == 'true/false') {
      if (selectedAnswer.toString().toLowerCase() == question['answer'].toString().toLowerCase()) {
        isCorrect = true;
      }
    } else {
      final correctIndex = question['options'].indexOf(question['answer']);
      if (selectedAnswer == correctIndex) {
        isCorrect = true;
      }
    }

    if (isCorrect) {
      score++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        codeController.clear();
      });
    } else {
      final totalQuestions = questions.length;
      final percentage = score / totalQuestions;
      Navigator.pop(context, percentage);
    }
  }

  String _normalizeCode(String code) {
    return code
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'\n|\r'), '')
        .toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.job} Quiz'),
        centerTitle: true,
        backgroundColor: const Color(0xff06234a),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Question ${currentIndex + 1} of ${questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            if (question['type'] == 'coding') ...[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff1e1e1e),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  key: ValueKey(currentIndex),
                  controller: codeController,
                  maxLines: 10,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'SourceCodePro',
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Write your code here...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  cursorColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                text: "Submit",
                onTap: () => _answer(null, isCoding: true),
              ),
            ] else ...[
              ...List.generate(question['options'].length, (i) {
                final optionText = question['options'][i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: GradientButton(
                    text: optionText,
                    onTap: () => _answer(
                      question['type'] == 'true/false' ? optionText : i,
                    ),
                  ),
                );
              }),
            ]
          ],
        ),
      ),
    );
  }
}