import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/studio/presentation/studio_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

import 'bottom_navigation.dart';
import 'navigation_controller.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationController(),
      child: Consumer<NavigationController>(
        builder: (context, controller, child) {
          return Scaffold(
            body: IndexedStack(
              index: controller.currentIndex,
              children: const [
                DashboardScreen(),
                ProjectsScreen(),
                StudioScreen(),
                ProfileScreen(),
              ],
            ),
            bottomNavigationBar:
                const ElyonBottomNavigation(),
          );
        },
      ),
    );
  }
}