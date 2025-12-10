import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => isLastPage = (index == 2));
            },
            children: [
              buildPage(
                image: "assets/images/cv_analysis.png",
                title: "AI-Powered CV Analysis",
                description: "Optimize your resume with AI and get better job recommendations.",
              ),
              buildPage(
                image: "assets/images/career_quiz.png",
                title: "Career Discovery Quiz",
                description: "Find the perfect career path based on your skills and interests.",
              ),
              buildPage(
                image: "assets/images/course_recommendation.png",
                title: "Personalized Course Recommendations",
                description: "Get AI-driven learning suggestions to boost your career prospects.",
              ),
            ],
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.blueAccent,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => _controller.jumpToPage(2),
              child: const Text("Skip", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: isLastPage
                ? ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text("Get Started", style: TextStyle(color: Colors.white,fontSize: 18),),
            ).animate().slideX(begin: 1, duration: 500.ms)
                : IconButton(
              icon: const Icon(Icons.arrow_forward, size: 30, color: Colors.blueAccent),
              onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.ease),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({required String image, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 250).animate().fade(duration: 800.ms),
          const SizedBox(height: 30),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent))
              .animate()
              .slideY(begin: 1, duration: 500.ms),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ).animate().fade(duration: 600.ms),
        ],
      ),
    );
  }
}