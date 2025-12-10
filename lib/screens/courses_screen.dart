import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String? matchedJob;
  List<Map<String, dynamic>> courses = [];

  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchMatchedJobAndCourses();
  }

  Future<void> fetchMatchedJobAndCourses() async {
    if (user == null) return;

    final userDoc = await firestore.collection('users').doc(user!.uid).get();
    final job = userDoc.data()?['matchedJob'];

    if (job != null) {
      final snapshot = await firestore
          .collection('courses')
          .doc(job.toLowerCase().replaceAll(' ', '_'))
          .collection('courses')
          .get();

      setState(() {
        matchedJob = job;
        courses = snapshot.docs.map((doc) => doc.data()).toList();
      });

    }
  }

  Future<void> incrementUsageCounter(String fieldName) async {
    if (user == null) return;

    final usageDoc = firestore
        .collection("users")
        .doc(user!.uid)
        .collection("analytics")
        .doc("usage");

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(usageDoc);
      if (snapshot.exists) {
        final current = snapshot.data()?[fieldName] ?? 0;
        transaction.update(usageDoc, {fieldName: current + 1});
      } else {
        transaction.set(usageDoc, {fieldName: 1});
      }
    });
  }

  void showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open course website')),
    );
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
                  "Recommended Courses",
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
      body: matchedJob == null
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
          ? const Center(child: Text("No courses found for your matched job."))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['Overview'] ?? 'No overview available',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff06234a),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (course.containsKey('Certification'))
                        Chip(
                          label: Text(
                            course['Certification'] == 'No'
                                ? 'No Certification'
                                : 'Certification: ${course['Certification']}',
                          ),
                          backgroundColor: course['Certification'] == 'No'
                              ? Colors.red[100]
                              : Colors.green[100],
                          labelStyle: TextStyle(
                            color: course['Certification'] == 'No'
                                ? Colors.red[900]
                                : Colors.green[900],
                          ),
                        ),
                      if (course['International Recognition'] == 'Yes')
                        Chip(
                          label: const Text('Internationally Recognized'),
                          backgroundColor: Colors.blue[100],
                          labelStyle: const TextStyle(color: Colors.blue),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(course['Platform'] ?? 'Unknown'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(course['Duration'] ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(course['Cost'] == null
                          ? 'N/A'
                          : course['Cost'] == 'Free'
                          ? 'Free'
                          : '${course['Cost']}'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0694df),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final url = course['Website'] ?? '';
                        final uri = Uri.tryParse(url);
                        if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
                          await incrementUsageCounter("courseClicks");
                          launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                        } else {
                          showErrorSnackBar();
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text(
                        "Visit Course",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}