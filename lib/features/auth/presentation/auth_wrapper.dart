import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/navigation/main_navigation_screen.dart';
import 'login_screen.dart';
import '../../user/services/user_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({
    super.key,
  });

  @override
  State<AuthWrapper> createState() =>
      _AuthWrapperState();
}

class _AuthWrapperState
    extends State<AuthWrapper> {

  final UserService _userService =
      UserService();

  bool _syncing = false;

  bool _profileSynced = false;

  Future<void> _syncProfile() async {

    if (_syncing) return;

    _syncing = true;

    try {

      final exists =
          await _userService.profileExists();

      if (!exists) {

        final user =
            FirebaseAuth.instance.currentUser;

        if (user != null) {

          await _userService.createUserProfile(

            displayName:
                user.displayName ?? "User",

            email:
                user.email ?? "",

          );

        }

      } else {

        await _userService.updateLastLogin();

      }

    } catch (e) {

      debugPrint(
        "Profile sync failed: $e",
      );

    }

    _syncing = false;

  }

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream:
          FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {

        //--------------------------------------------------
        // Loading
        //--------------------------------------------------

        if (snapshot.hasData) {

  if (!_profileSynced) {

    _profileSynced = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {

      _syncProfile();

    });

  }

  return const MainNavigationScreen();

}

        //--------------------------------------------------
        // Logged In
        //--------------------------------------------------

        if (snapshot.hasData) {

          _syncProfile();

          return const MainNavigationScreen();

        }

        //--------------------------------------------------
        // Logged Out
        //--------------------------------------------------

        _profileSynced = false;

          return const LoginScreen();

      },
    );

  }

}