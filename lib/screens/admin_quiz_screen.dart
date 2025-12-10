import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminQuizScreen extends StatefulWidget {
  const AdminQuizScreen({super.key});

  @override
  State<AdminQuizScreen> createState() => _AdminQuizScreenState();
}

class _AdminQuizScreenState extends State<AdminQuizScreen> {
  final List<String> jobRoles = [
    "Business Analyst",
    "Data Scientist",
    "Web Developer",
    "Mobile Developer",
    "ERP Consultant",
    "IT Support Specialist",
    "Digital Marketing Analyst",
    "Data Analyst",
  ];

  String _jobToKey(String job) => job.toLowerCase().replaceAll(' ', '_');

  void _showAddOrEditDialog(String jobKey, {DocumentSnapshot? docToEdit}) {
    final quizNameController = TextEditingController();
    String question = docToEdit?.get("question") ?? '';
    String correctAnswer = docToEdit?.get("answer") ?? '';
    String selectedType = docToEdit?.get("type") ?? 'mcq';

    List<String> options = [];

    if (docToEdit?.data() != null && (docToEdit!.data() as Map<String, dynamic>).containsKey('options')) {
      var rawOptions = docToEdit.get('options');
      if (rawOptions is List) {
        options = List<String>.from(rawOptions);
      }
    }

// Ensure at least 4 options if MCQ; otherwise empty
    if (selectedType == 'mcq') {
      while (options.length < 4) {
        options.add('');
      }
    } else {
      options = ['', '', '', '']; // Or just [] depending on your UI expectations
    }

    final questionController = TextEditingController(text: question);
    final answerController = TextEditingController(text: correctAnswer);
    final optionControllers = List.generate(
      4,
          (i) => TextEditingController(text: options.length > i ? options[i] : ''),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(docToEdit == null ? "Add Question" : "Edit Question"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  if (docToEdit == null)
                    TextField(
                      decoration: const InputDecoration(labelText: "Quiz Name (e.g., Q1, Q2)"),
                      controller: quizNameController,
                    ),
                  // Question input
                  TextField(
                    decoration: const InputDecoration(labelText: "Question"),
                    controller: questionController,
                  ),

                  const SizedBox(height: 10),

                  // Type dropdown
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(value: "mcq", child: Text("Multiple Choice")),
                      DropdownMenuItem(value: "true/false", child: Text("True / False")),
                      DropdownMenuItem(value: "coding", child: Text("Coding")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                    decoration: const InputDecoration(labelText: "Question Type"),
                  ),

                  const SizedBox(height: 10),

                  // MCQ Options
                  if (selectedType == "mcq") ...[
                    for (int i = 0; i < 4; i++)
                      TextField(
                        decoration: InputDecoration(labelText: "Option ${String.fromCharCode(65 + i)}"),
                        controller: optionControllers[i],
                      ),
                  ],

                  const SizedBox(height: 10),

                  // Answer field
                  TextField(
                    decoration: const InputDecoration(labelText: "Correct Answer"),
                    controller: answerController,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text("Save"),
                onPressed: () async {
                  final questionText = questionController.text.trim();
                  final answerText = answerController.text.trim();
                  final optionsList = optionControllers.map((c) => c.text.trim()).toList();

                  Map<String, dynamic> data = {
                    "question": questionText,
                    "answer": answerText,
                    "type": selectedType,
                  };

                  if (selectedType == "mcq") {
                    data["options"] = optionsList;
                  }

                  final ref = FirebaseFirestore.instance
                      .collection("quizzes")
                      .doc(jobKey)
                      .collection("questions");

                  if (docToEdit == null) {
                    final quizName = quizNameController.text.trim();
                    if (quizName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Quiz name cannot be empty.")),
                      );
                      return;
                    }
                    await ref.doc(quizName).set(data);
                  } else {
                    await ref.doc(docToEdit.id).update(data);
                  }

                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Quiz Manager"),
        backgroundColor: const Color(0xff06234a),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: jobRoles.length,
        itemBuilder: (context, index) {
          String job = jobRoles[index];
          String jobKey = _jobToKey(job);

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: ExpansionTile(
              title: Text(job, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("quizzes")
                      .doc(jobKey)
                      .collection("questions")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    if (docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text("No questions yet."),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      itemBuilder: (context, qIndex) {
                        final doc = docs[qIndex];
                        final data = doc.data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          child: Card(
                            color: Colors.grey[100],
                            child: ListTile(
                              title: Text(
                                data["question"] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  if (data["type"] == "mcq" && data["options"] != null)
                                    ...List.generate(
                                      (data["options"] as List).length,
                                          (i) => Text("• ${data["options"][i]}", style: const TextStyle(fontSize: 13)),
                                    ),
                                  if (data["type"] != "mcq")
                                    Text("Type: ${data["type"]}", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                                  const SizedBox(height: 6),
                                  Text("Correct: ${data["answer"]}", style: const TextStyle(fontStyle: FontStyle.italic)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showAddOrEditDialog(jobKey, docToEdit: doc),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection("quizzes")
                                          .doc(jobKey)
                                          .collection("questions")
                                          .doc(doc.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showAddOrEditDialog(jobKey),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Question"),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}