import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation_controller.dart';

class ElyonBottomNavigation extends StatelessWidget {
  const ElyonBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, controller, child) {
        return NavigationBar(
          selectedIndex: controller.currentIndex,

          onDestinationSelected:
              controller.changeTab,

          height: 72,

          labelBehavior:
              NavigationDestinationLabelBehavior
                  .alwaysShow,

          destinations: const [

            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: "Home",
            ),

            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder),
              label: "Projects",
            ),

            NavigationDestination(
              icon: Icon(Icons.movie_creation_outlined),
              selectedIcon:
                  Icon(Icons.movie_creation),
              label: "Studio",
            ),

            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        );
      },
    );
  }
}