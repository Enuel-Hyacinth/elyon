import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../user/services/user_service.dart';

/// ------------------------------------------------------------
/// AUTH SERVICE
/// ------------------------------------------------------------
///
/// Handles:
/// • Registration
/// • Login
/// • Logout
/// • Password Reset
/// • Email Verification
/// • User Synchronization
/// • Firebase Profile Updates
///
/// eLyon AI Studio
/// ------------------------------------------------------------
class AuthService {

  //------------------------------------------------------------
  // FIREBASE
  //------------------------------------------------------------

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  //------------------------------------------------------------
  // USER SERVICE
  //------------------------------------------------------------

  final UserService _userService =
      UserService();

  //------------------------------------------------------------
  // CURRENT USER
  //------------------------------------------------------------

  User? get currentUser =>
      _auth.currentUser;

  //------------------------------------------------------------
  // AUTH STREAM
  //------------------------------------------------------------

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  //------------------------------------------------------------
  // LOGIN STATUS
  //------------------------------------------------------------

  bool get isLoggedIn =>
      currentUser != null;

  //------------------------------------------------------------
  // DEBUG LOGGER
  //------------------------------------------------------------

  void log(String message) {

    if (kDebugMode) {

      debugPrint(
        "[Auth] $message",
      );

    }

  }

  //------------------------------------------------------------
  // REGISTER
  //------------------------------------------------------------

  Future<UserCredential> register({

    required String name,

    required String email,

    required String password,

  }) async {

    log("Creating user account...");

    final credential =
        await _auth.createUserWithEmailAndPassword(

      email: email.trim(),

      password: password.trim(),

    );

    //----------------------------------------------------------
    // UPDATE FIREBASE PROFILE
    //----------------------------------------------------------

    await credential.user?.updateDisplayName(

      name.trim(),

    );

    await credential.user?.reload();

    //----------------------------------------------------------
    // CREATE USER PROFILE
    //----------------------------------------------------------

    await _userService.createUserProfile(

      displayName: name.trim(),

      email: email.trim(),

    );

    log("Registration completed.");

    return credential;

  }
  //------------------------------------------------------------
  // LOGIN
  //------------------------------------------------------------

  Future<UserCredential> login({

    required String email,

    required String password,

  }) async {

    log("Signing in...");

    final credential =
        await _auth.signInWithEmailAndPassword(

      email: email.trim(),

      password: password.trim(),

    );

    await syncUserProfile();

    log("Login successful.");

    return credential;

  }

  //------------------------------------------------------------
  // LOGOUT
  //------------------------------------------------------------

  Future<void> logout() async {

    await _auth.signOut();

    log("User signed out.");

  }

  //------------------------------------------------------------
  // SYNC USER PROFILE
  //------------------------------------------------------------

  Future<void> syncUserProfile() async {

    final user = currentUser;

    if (user == null) {

      return;

    }

    final exists =
        await _userService.profileExists();

    if (!exists) {

      //--------------------------------------------------------
      // Create missing Firestore profile
      //--------------------------------------------------------

      await _userService.createUserProfile(

        displayName:
            user.displayName ?? "User",

        email:
            user.email ?? "",

      );

      log("User profile recreated.");

    } else {

      //--------------------------------------------------------
      // Update last login timestamp
      //--------------------------------------------------------

      await _userService.updateLastLogin();

      log("Last login updated.");

    }

  }

  //------------------------------------------------------------
  // RELOAD CURRENT USER
  //------------------------------------------------------------

  Future<void> reloadUser() async {

    await currentUser?.reload();

    log("User reloaded.");

  }

  //------------------------------------------------------------
  // UPDATE DISPLAY NAME
  //------------------------------------------------------------

  Future<void> updateDisplayName({

    required String displayName,

  }) async {

    final user = currentUser;

    if (user == null) {

      throw Exception("No authenticated user.");

    }

    await user.updateDisplayName(
      displayName.trim(),
    );

    await user.reload();

    await _userService.updateDisplayName(
      displayName.trim(),
    );

    log("Display name updated.");

  }
  //------------------------------------------------------------
  // SEND EMAIL VERIFICATION
  //------------------------------------------------------------

  Future<void> sendEmailVerification() async {

    final user = currentUser;

    if (user == null) {
      throw Exception(
        "No authenticated user.",
      );
    }

    if (!user.emailVerified) {

      await user.sendEmailVerification();

      log(
        "Verification email sent.",
      );

    }

  }

  //------------------------------------------------------------
  // PASSWORD RESET
  //------------------------------------------------------------

  Future<void> resetPassword({

    required String email,

  }) async {

    await _auth.sendPasswordResetEmail(

      email: email.trim(),

    );

    log(
      "Password reset email sent.",
    );

  }

  //------------------------------------------------------------
  // CHANGE PASSWORD
  //------------------------------------------------------------

  Future<void> changePassword({

    required String newPassword,

  }) async {

    final user = currentUser;

    if (user == null) {

      throw Exception(
        "No authenticated user.",
      );

    }

    await user.updatePassword(

      newPassword.trim(),

    );

    log(
      "Password updated.",
    );

  }

  //------------------------------------------------------------
  // DELETE ACCOUNT
  //------------------------------------------------------------

  Future<void> deleteAccount() async {

    final user = currentUser;

    if (user == null) {

      throw Exception(
        "No authenticated user.",
      );

    }

    try {

      await _firestore
          .collection("users")
          .doc(user.uid)
          .delete();

    } catch (_) {

      log(
        "Firestore profile not found.",
      );

    }

    await user.delete();

    log(
      "User account deleted.",
    );

  }

  //------------------------------------------------------------
  // REFRESH AUTH STATE
  //------------------------------------------------------------

  Future<void> refreshUser() async {

    await currentUser?.reload();

    log(
      "Auth state refreshed.",
    );

  }

  //------------------------------------------------------------
  // EMAIL VERIFIED
  //------------------------------------------------------------

  bool get isEmailVerified =>

      currentUser?.emailVerified ?? false;
  //------------------------------------------------------------
  // USER INFORMATION
  //------------------------------------------------------------

  String? get uid =>

      currentUser?.uid;

  String? get email =>

      currentUser?.email;

  String? get displayName =>

      currentUser?.displayName;

  String? get photoURL =>

      currentUser?.photoURL;

  //------------------------------------------------------------
  // ID TOKEN
  //------------------------------------------------------------

  Future<String?> getIdToken() async {

    return await currentUser?.getIdToken();

  }

  //------------------------------------------------------------
  // IS ANONYMOUS
  //------------------------------------------------------------

  bool get isAnonymous =>

      currentUser?.isAnonymous ?? false;

  //------------------------------------------------------------
  // AUTH PROVIDER
  //------------------------------------------------------------

  String get providerId {

    final providers =
        currentUser?.providerData;

    if (providers == null ||
        providers.isEmpty) {

      return "unknown";

    }

    return providers.first.providerId;

  }

  //------------------------------------------------------------
  // REAUTHENTICATE
  //------------------------------------------------------------

  Future<UserCredential> reauthenticate({

    required String email,

    required String password,

  }) async {

    final credential =
        EmailAuthProvider.credential(

      email: email.trim(),

      password: password.trim(),

    );

    return await currentUser!
        .reauthenticateWithCredential(
      credential,
    );

  }

  //------------------------------------------------------------
  // DISPOSE
  //------------------------------------------------------------

  void dispose() {

    log(
      "AuthService disposed.",
    );

  }

}