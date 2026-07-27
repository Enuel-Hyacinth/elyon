import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';

class DashboardService {
  DashboardService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final ProjectService _projectService =
      ProjectService();

  User? get currentUser => _auth.currentUser;
  /// Get the current user's profile document
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;

    if (user == null) {
      return null;
    }

    final doc = await _firestore
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    return doc.data();
  }

  /// Get the user's available credits
  Future<int> getCredits() async {
    final profile = await getUserProfile();

    if (profile == null) {
      return 0;
    }

    return profile["credits"] ?? 0;
  }

  /// Get the user's subscription plan
  Future<String> getPlan() async {
    final profile = await getUserProfile();

    if (profile == null) {
      return "Free";
    }

    return profile["plan"] ?? "Free";
  }

  /// Get the user's display name
  Future<String> getDisplayName() async {
    final profile = await getUserProfile();

    if (profile == null) {
      return currentUser?.displayName ?? "User";
    }

    return profile["name"] ??
        currentUser?.displayName ??
        "User";
  }
  /// Get the most recent project
  Future<ProjectModel?> getLatestProject() async {
    return await _projectService.getLastProject();
  }

  /// Get all projects
  Future<List<ProjectModel>> getProjects() async {
    return await _projectService.getProjects();
  }

  /// Stream projects in real time
  Stream<List<ProjectModel>> streamProjects() {
    return _projectService.streamProjects();
  }

  /// Get the current user's email
  String getEmail() {
    return currentUser?.email ?? "";
  }

  /// Check whether a user is logged in
  bool isLoggedIn() {
    return currentUser != null;
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}