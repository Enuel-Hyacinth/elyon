import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/greeting.dart';
import '../../../shared/widgets/credits_card.dart';
import '../../../shared/widgets/dashboard_card.dart';
import '../../generator/presentation/generator_screen.dart';
import '../../ai/presentation/generate_screen.dart';
import '../../projects/presentation/projects_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("eLyon"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: "AI",
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: "Projects",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            Text(
              "${getGreeting()}, Enuel ?",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              user?.email ?? "",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            const CreditsCard(
              credits: 20,
            ),

            const SizedBox(height: 30),

            DashboardCard(
              icon: Icons.auto_awesome,
              title: "Generate Animation",
              subtitle: "Create AI-powered videos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GenerateScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            DashboardCard(
              icon: Icons.folder_open,
              title: "My Projects",
              subtitle: "View previously generated videos",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProjectsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            DashboardCard(
              icon: Icons.style,
              title: "AI Templates",
              subtitle: "Choose a ready-made animation style",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            DashboardCard(
              icon: Icons.settings,
              title: "Settings",
              subtitle: "Manage your account",
              onTap: () {},
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}