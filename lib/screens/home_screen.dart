import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  String userName = "";
  String profileImageUrl = "";
  bool _hasIncremented = false;
  int appOpens = 0;
  int cvAnalysis = 0;
  int quizAttempts = 0;
  int courseClicks = 0;
  int streak = 0;
  String todayDate = DateTime.now().toIso8601String().split("T").first;

  final List<String> motivationalQuotes = [
    "“Opportunities don't happen. You create them.”",
    "“Success is where preparation and opportunity meet.”",
    "“The best way to predict the future is to create it.”",
    "“Push yourself, because no one else is going to do it for you.”",
    "“Your journey starts now—take the first step today!”",
    "“Every expert was once a beginner. Keep going!",
    "“Small progress is still progress. Don’t stop!”",
    "“Believe in yourself—Tunisian talent changes the world!”",
    "“Consistency beats perfection. Show up every day!”",
    "“Your CV is your story—make it unforgettable.”",
    "“The job market is tough, but so are you.”",
    "“Quitting is not an option. You’re almost there!”",
    "“The future belongs to those who prepare today.”",
    "“Learning something new today is winning.”",
    "“You’re not behind—everyone has their own path.”",
    "“Stay curious, stay committed, stay ProStart.”",
    "“You’re closer than you think. Keep pushing!”",
    "“Skills open doors. Keep building yours.”",
    "“Confidence comes from preparation. Let’s go!”",
    "“Be proud of how far you’ve come.”",
    "“Turn your setbacks into comebacks.”",
    "“Dream it. Plan it. Do it.”",
    "“One quiz, one course, one win at a time.”",
  ];

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchUserStats();
    _handleStreakTracking();
    if (!_hasIncremented) {
      _incrementAppOpenCount();
      _hasIncremented = true;
    }
  }

  Future<void> _handleStreakTracking() async {
    if (user == null) return;

    final usageDoc = firestore.collection("users").doc(user!.uid).collection("analytics").doc("usage");
    final snapshot = await usageDoc.get();

    if (!snapshot.exists) {
      await usageDoc.set({
        "streak": 1,
        "lastAppOpen": todayDate,
      });
      setState(() => streak = 1);
    } else {
      final data = snapshot.data()!;
      final lastDate = data["lastAppOpen"] ?? "";
      final lastDateObj = DateTime.tryParse(lastDate) ?? DateTime.now().subtract(const Duration(days: 2));

      final difference = DateTime.now().difference(lastDateObj).inDays;

      if (difference == 1) {
        await usageDoc.update({
          "streak": (data["streak"] ?? 0) + 1,
          "lastAppOpen": todayDate,
        });
        setState(() => streak = (data["streak"] ?? 0) + 1);
      } else if (difference > 1) {
        await usageDoc.update({
          "streak": 1,
          "lastAppOpen": todayDate,
        });
        setState(() => streak = 1);
      } else {
        setState(() => streak = data["streak"] ?? 1);
      }
    }
  }

  void fetchUserStats() async {
    var doc = await FirebaseFirestore.instance.collection('userStats').doc(user!.uid).get();

    if (doc.exists) {
      setState(() {
        appOpens = doc.data()?['appOpens'] ?? 0;
        cvAnalysis = doc.data()?['cvAnalysis'] ?? 0;
        quizAttempts = doc.data()?['quizAttempts'] ?? 0;
        courseClicks = doc.data()?['courseClicks'] ?? 0;
      });
    }
  }

  Future<void> _incrementAppOpenCount() async {
    if (user != null) {
      final usageDoc = firestore
          .collection("users")
          .doc(user!.uid)
          .collection("analytics")
          .doc("usage");

      final today = DateTime.now().toIso8601String().split("T").first;

      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(usageDoc);
        if (!snapshot.exists) {
          transaction.set(usageDoc, {
            "appOpens": 1,
            "cvAnalysisCount": 0,
            "quizAttempts": 0,
            "courseClicks": 0,
            "lastAppOpen": today,
            "streak": 1,
          });
        } else {
          final data = snapshot.data()!;
          final String lastOpenDate = data["lastAppOpen"] ?? "";

          if (lastOpenDate != today) {
            transaction.update(usageDoc, {
              "appOpens": (data["appOpens"] ?? 0) + 1,
              "lastAppOpen": today,
            });
          }
        }
      });

      setState(() {
        _loadUserData();
      });
    }
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc = await firestore.collection("users").doc(user!.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          userName = data["fullName"] ?? "";
          profileImageUrl = data["profileImageUrl"] ?? "";
        });
      }
    }
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color startColor, Color endColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: endColor.withOpacity(0.4), blurRadius: 8, offset: const Offset(2, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text("$value", style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final greeting = getGreeting();
    final quote = (motivationalQuotes..shuffle()).first;

    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff06234a),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: profileImageUrl.isNotEmpty &&
                  File(profileImageUrl).existsSync()
                  ? FileImage(File(profileImageUrl))
                  : const AssetImage("assets/images/default_profile.png")
              as ImageProvider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$greeting, $userName",
                style: const TextStyle(fontSize: 18, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff0694df), Color(0xff06234a)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                quote,
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Your Dashboard",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<DocumentSnapshot>(
              future: firestore
                  .collection("users")
                  .doc(user!.uid)
                  .collection("analytics")
                  .doc("usage")
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                appOpens = data["appOpens"] ?? 0;
                cvAnalysis = data["cvAnalysisCount"] ?? 0;
                quizAttempts = data["quizAttempts"] ?? 0;
                courseClicks = data["courseClicks"] ?? 0;

                return Row(
                  children: [
                    _buildStatCard("App Opens", appOpens, Icons.open_in_browser, Colors.teal, Colors.green),
                    _buildStatCard("CV Analyses", cvAnalysis, Icons.description, Colors.indigo, Colors.blue),
                    _buildStatCard("Quizzes", quizAttempts, Icons.quiz, Colors.deepPurple, Colors.purple),
                    _buildStatCard("Course Clicks", courseClicks, Icons.school, Colors.orange, Colors.deepOrange),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            const Text(
              "Your Analytics",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 270,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 7, offset: Offset(0, 4)),
                ],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [
                    appOpens.toDouble(),
                    cvAnalysis.toDouble(),
                    quizAttempts.toDouble(),
                    courseClicks.toDouble()
                  ].reduce((a, b) => a > b ? a : b) + 5,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text("Opens");
                            case 1:
                              return const Text("CVs");
                            case 2:
                              return const Text("Quizzes");
                            case 3:
                              return const Text("Courses");
                            default:
                              return const Text("");
                          }
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: appOpens.toDouble(), color: Colors.green)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: cvAnalysis.toDouble(), color: Colors.blue)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: quizAttempts.toDouble(), color: Colors.purple)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: courseClicks.toDouble(), color: Colors.orange)]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                  const SizedBox(width: 10),
                  Text("You're on a $streak-day streak! 🔥", style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}