import 'package:flutter/foundation.dart';

class NavigationController extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  //--------------------------------------------------
  // CURRENT TAB HELPERS
  //--------------------------------------------------

  bool get isHome => _currentIndex == 0;

  bool get isProjects => _currentIndex == 1;

  bool get isStudio => _currentIndex == 2;

  bool get isProfile => _currentIndex == 3;

  //--------------------------------------------------
  // CHANGE TAB
  //--------------------------------------------------

  void changeTab(int index) {
    if (_currentIndex == index) return;

    _currentIndex = index;

    notifyListeners();
  }

  //--------------------------------------------------
  // SHORTCUTS
  //--------------------------------------------------

  void goHome() {
    changeTab(0);
  }

  void goProjects() {
    changeTab(1);
  }

  void goStudio() {
    changeTab(2);
  }

  void goProfile() {
    changeTab(3);
  }
}