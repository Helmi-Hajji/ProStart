import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<Map<String, dynamic>> fetchUsageStats(String userId) async {
    final usageDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('analytics')
        .doc('usage')
        .get();
    return usageDoc.exists ? usageDoc.data()! : {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xff06234a),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userDocs = userSnapshot.data?.docs
              .where((doc) => (doc.data() as Map<String, dynamic>)['email'] != 'helmi@topadmin.com')
              .toList();

          if (userDocs == null || userDocs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              // Total users summary
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Total Users: ${userDocs.length}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // User usage cards
              ...userDocs.map((user) {
                final userId = user.id;
                final data = user.data() as Map<String, dynamic>;
                final name = data['fullName'] ?? 'Unnamed';
                final matchedJob = data['matchedJob'] ?? 'Not matched';

                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchUsageStats(userId),
                  builder: (context, usageSnapshot) {
                    final usage = usageSnapshot.data ?? {};
                    return UserUsageCard(
                      name: name,
                      lastOpen: usage['lastAppOpen'] ?? 'N/A',
                      usage: usage,
                      matchedJob: matchedJob,
                    );
                  },
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class UserUsageCard extends StatelessWidget {
  final String name;
  final String lastOpen;
  final String matchedJob;
  final Map<String, dynamic> usage;

  const UserUsageCard({
    super.key,
    required this.name,
    required this.lastOpen,
    required this.usage,
    required this.matchedJob,
  });

  @override
  Widget build(BuildContext context) {
    final quiz = (usage['quizAttempts'] ?? 0).toDouble();
    final cv = (usage['cvAnalysisCount'] ?? 0).toDouble();
    final course = (usage['courseClicks'] ?? 0).toDouble();
    final opens = (usage['appOpens'] ?? 0).toDouble();
    final total = quiz + cv + course + opens;

    // Avoid divide by zero
    final List<PieChartSectionData> chartData = total == 0
        ? []
        : [
      PieChartSectionData(
        value: quiz,
        title: '${((quiz / total) * 100).round()}%\n$quiz',
        color: Colors.purple,
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: cv,
        title: '${((cv / total) * 100).round()}%\n$cv',
        color: Colors.blue,
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: course,
        title: '${((course / total) * 100).round()}%\n$course',
        color: Colors.orange,
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: opens,
        title: '${((opens / total) * 100).round()}%\n$opens',
        color: Colors.green,
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Last Open: $lastOpen",
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("Matched Job: $matchedJob",
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// Pie Chart with legend
            Row(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: chartData.isEmpty
                        ? const Center(child: Text('No usage data'))
                        : PieChart(
                      PieChartData(
                        sections: chartData,
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendDot('Quiz Attemps', Colors.purple),
                    _buildLegendDot('CV Analysis', Colors.blue),
                    _buildLegendDot('Courses Clicks', Colors.orange),
                    _buildLegendDot('App Opens', Colors.green),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}