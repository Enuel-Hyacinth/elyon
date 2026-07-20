import 'package:flutter/material.dart';

import '../widgets/onboarding_page.dart';

import '../../auth/presentation/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      "icon": Icons.auto_awesome,
      "title": "AI Business Assistant",
      "description":
          "Manage your business smarter with powerful AI tools.",
    },
    {
      "icon": Icons.analytics_outlined,
      "title": "Business Analytics",
      "description":
          "Track sales, customers and business performance in real time.",
    },
    {
      "icon": Icons.rocket_launch,
      "title": "Grow Faster",
      "description":
          "Automate your workflow and focus on growing your business.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    icon: pages[index]["icon"],
                    title: pages[index]["title"],
                    description: pages[index]["description"],
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  TextButton(
                    onPressed: () {
                      _controller.jumpToPage(2);
                    },
                    child: const Text("Skip"),
                  ),

                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? const Color(0xFFD4AF37)
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {

                      if (currentPage < pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const LoginScreen(),
  ),
);
                      }

                    },
                    child: Text(
                      currentPage == pages.length - 1
                          ? "Get Started"
                          : "Next",
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}