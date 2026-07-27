import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/project_model.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _projectsRef {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in.");
    }

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("projects");
  }

  /// Create a new project
  Future<void> saveProject(ProjectModel project) async {
    await _projectsRef
        .doc(project.id)
        .set(project.toMap());
  }

  /// Update an existing project
  Future<void> updateProject(ProjectModel project) async {
    await _projectsRef
        .doc(project.id)
        .update(project.toMap());
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    await _projectsRef
        .doc(projectId)
        .delete();
  }

  /// Get all projects
  Future<List<ProjectModel>> getProjects() async {
    final snapshot = await _projectsRef
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProjectModel.fromMap(doc.data()))
        .toList();
  }

  /// Real-time project stream
  Stream<List<ProjectModel>> streamProjects() {
    return _projectsRef
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ProjectModel.fromMap(doc.data()),
              )
              .toList(),
        );
  }

  /// Get latest project
  Future<ProjectModel?> getLastProject() async {
    final snapshot = await _projectsRef
        .orderBy("createdAt", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return ProjectModel.fromMap(
      snapshot.docs.first.data(),
    );
  }

  /// Get one project by ID
  Future<ProjectModel?> getProject(String projectId) async {
    final doc = await _projectsRef.doc(projectId).get();

    if (!doc.exists) {
      return null;
    }

    return ProjectModel.fromMap(doc.data()!);
  }

  /// Search projects by title
  Future<List<ProjectModel>> searchProjects(String keyword) async {
    final projects = await getProjects();

    return projects.where((project) {
      return project.title
          .toLowerCase()
          .contains(keyword.toLowerCase());
    }).toList();
  }

  /// Filter projects by status
  Future<List<ProjectModel>> getProjectsByStatus(
    String status,
  ) async {
    final snapshot = await _projectsRef
        .where("status", isEqualTo: status)
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ProjectModel.fromMap(doc.data()))
        .toList();
  }
}