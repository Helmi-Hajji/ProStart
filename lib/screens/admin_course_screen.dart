import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCourseScreen extends StatefulWidget {
  const AdminCourseScreen({super.key});

  @override
  State<AdminCourseScreen> createState() => _AdminCourseScreenState();
}

class _AdminCourseScreenState extends State<AdminCourseScreen> {
  final List<String> jobRoles = [
    "Data Analyst",
    "Business Analyst",
    "Data Scientist",
    "Web Developer",
    "Mobile Developer",
    "ERP Consultant",
    "IT Support Specialist",
    "Digital Marketing Analyst",
    "AI Engineer",
  ];

  String _jobToKey(String job) => job.toLowerCase().replaceAll(' ', '_');

  void _showCourseDialog({
    required String jobKey,
    DocumentSnapshot? existingDoc,
  }) {
    final data = existingDoc?.data() as Map<String, dynamic>? ?? {};

    TextEditingController overview = TextEditingController(text: data['Overview'] ?? '');
    TextEditingController platform = TextEditingController(text: data['Platform'] ?? '');
    TextEditingController website = TextEditingController(text: data['Website'] ?? '');
    TextEditingController cost = TextEditingController(text: data['Cost'] ?? '');
    TextEditingController duration = TextEditingController(text: data['Duration'] ?? '');
    TextEditingController docIdController = TextEditingController();

    bool certification = (data['Certification']?.toString().toLowerCase().contains("yes") ?? false) ||
        (data['Certification']?.toString().toLowerCase().contains("optional") ?? false);
    bool international = (data['International Recognition']?.toString().toLowerCase() == "yes");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingDoc == null ? "Add Course" : "Edit Course"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: overview, decoration: const InputDecoration(labelText: "Overview")),
              TextField(controller: platform, decoration: const InputDecoration(labelText: "Platform")),
              TextField(controller: website, decoration: const InputDecoration(labelText: "Website")),
              TextField(controller: cost, decoration: const InputDecoration(labelText: "Cost")),
              TextField(controller: duration, decoration: const InputDecoration(labelText: "Duration")),
              TextField(
                controller: TextEditingController(text: data['Certification'] ?? ''),
                decoration: const InputDecoration(labelText: "Certification (e.g., Yes, No, Optional)"),
                onChanged: (value) => data['Certification'] = value,
              ),
              TextField(
                controller: TextEditingController(text: data['International Recognition'] ?? ''),
                decoration: const InputDecoration(labelText: "International Recognition (Yes/No)"),
                onChanged: (value) => data['International Recognition'] = value,
              ),
              if (existingDoc == null)
                TextField(
                  controller: docIdController,
                  decoration: const InputDecoration(labelText: "Course ID (e.g., course1, course2)"),
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
            child: Text(existingDoc == null ? "Add" : "Update"),
            onPressed: () async {
              final courseData = {
                "Overview": overview.text,
                "Platform": platform.text,
                "Website": website.text,
                "Cost": cost.text,
                "Duration": duration.text,
                "Certification": data['Certification'],
                "International Recognition": data['International Recognition'],
              };

              final ref = FirebaseFirestore.instance
                  .collection("courses")
                  .doc(jobKey)
                  .collection("courses");

              if (existingDoc == null) {
                if (docIdController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a Course ID")),
                  );
                  return;
                }
                await ref.doc(docIdController.text.trim()).set(courseData);
              } else {
                await ref.doc(existingDoc.id).update(courseData);
              }

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Widget _buildCourseList(String jobKey) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("courses")
          .doc(jobKey)
          .collection("courses")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("No courses yet."),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, cIndex) {
            var data = docs[cIndex].data() as Map<String, dynamic>;
            var doc = docs[cIndex];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['Overview'] ?? 'No title',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text("Platform: ${data['Platform']}"),
                    Text("Cost: ${data['Cost']}"),
                    Text("Duration: ${data['Duration']}"),
                    Text("Certification: ${data['Certification']}"),
                    Text("International: ${data['International Recognition']}"),
                    Text("Website: ${data['Website']}"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showCourseDialog(jobKey: jobKey, existingDoc: doc),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("courses")
                                .doc(jobKey)
                                .collection("courses")
                                .doc(doc.id)
                                .delete();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Courses Manager"),
        backgroundColor: const Color(0xff06234a),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: jobRoles.length,
        itemBuilder: (context, index) {
          String job = jobRoles[index];
          String jobKey = _jobToKey(job);

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 4,
            child: ExpansionTile(
              title: Text(job, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [
                _buildCourseList(jobKey),
                TextButton.icon(
                  onPressed: () => _showCourseDialog(jobKey: jobKey),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Course"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}