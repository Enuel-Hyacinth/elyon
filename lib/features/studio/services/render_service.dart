import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../projects/models/project_model.dart';

class RenderService {
  //--------------------------------------------------
  // FIREBASE
  //--------------------------------------------------

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  //--------------------------------------------------
  // PROJECT COLLECTION
  //--------------------------------------------------

  CollectionReference<ProjectModel>
      get _projects =>
          _firestore
              .collection("projects")
              .withConverter<ProjectModel>(
                fromFirestore: (snapshot, _) =>
                    ProjectModel.fromMap(
                      snapshot.data()!,
                    ),
                toFirestore: (project, _) =>
                    project.toMap(),
              );

  //--------------------------------------------------
  // AUTH
  //--------------------------------------------------

  User? get currentUser =>
      _auth.currentUser;

  String get currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        "No authenticated user found.",
      );
    }

    return user.uid;
  }

  //--------------------------------------------------
  // SERVER TIMESTAMP
  //--------------------------------------------------

  FieldValue get serverTimestamp =>
      FieldValue.serverTimestamp();

  //--------------------------------------------------
  // STATUS CONSTANTS
  //--------------------------------------------------

  static const String created =
      "Created";

  static const String queued =
      "Queued";

  static const String rendering =
      "Rendering";

  static const String completed =
      "Completed";

  static const String failed =
      "Failed";

  static const String cancelled =
      "Cancelled";

  //--------------------------------------------------
  // PROGRESS CONSTANTS
  //--------------------------------------------------

  static const double minimumProgress = 0.0;

  static const double maximumProgress = 1.0;

  //--------------------------------------------------
  // CONFIGURATION
  //--------------------------------------------------

  static const Duration renderTimeout =
      Duration(
        minutes: 10,
      );
  //--------------------------------------------------
  // QUEUE PROJECT
  //--------------------------------------------------

  Future<void> queueProject(String projectId) async {
    await _projects.doc(projectId).update({
      "status": queued,
      "progress": minimumProgress,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // START RENDERING
  //--------------------------------------------------

  Future<void> startRendering(String projectId) async {
    await _projects.doc(projectId).update({
      "status": rendering,
      "progress": minimumProgress,
      "startedAt": serverTimestamp,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // UPDATE PROGRESS
  //--------------------------------------------------

  Future<void> updateRenderProgress({
    required String projectId,
    required double progress,
  }) async {
    final value = progress.clamp(
      minimumProgress,
      maximumProgress,
    );

    await _projects.doc(projectId).update({
      "progress": value,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // COMPLETE RENDER
  //--------------------------------------------------

  Future<void> completeRendering({
    required String projectId,
    required String thumbnail,
  }) async {
    await _projects.doc(projectId).update({
      "status": completed,
      "progress": maximumProgress,
      "thumbnail": thumbnail,
      "completedAt": serverTimestamp,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // FAIL RENDER
  //--------------------------------------------------

  Future<void> renderFailed({
    required String projectId,
    required String reason,
  }) async {
    await _projects.doc(projectId).update({
      "status": failed,
      "failureReason": reason,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // CANCEL RENDER
  //--------------------------------------------------

  Future<void> cancelRender(String projectId) async {
    await _projects.doc(projectId).update({
      "status": cancelled,
      "progress": minimumProgress,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // RETRY RENDER
  //--------------------------------------------------

  Future<void> retryRender(String projectId) async {
    await _projects.doc(projectId).update({
      "status": queued,
      "progress": minimumProgress,
      "failureReason": null,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // RESET PROJECT
  //--------------------------------------------------

  Future<void> resetProject(String projectId) async {
    await _projects.doc(projectId).update({
      "status": created,
      "progress": minimumProgress,
      "thumbnail": "",
      "failureReason": null,
      "lastModified": serverTimestamp,
    });
  }
  //--------------------------------------------------
  // PROJECT STREAM
  //--------------------------------------------------

  Stream<ProjectModel?> streamProject(
    String projectId,
  ) {
    return _projects
        .doc(projectId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return null;
      }

      return doc.data();
    });
  }

  //--------------------------------------------------
  // USER PROJECTS
  //--------------------------------------------------

  Stream<List<ProjectModel>> streamProjects() {
    return _projects
        .where(
          "userId",
          isEqualTo: currentUserId,
        )
        .orderBy(
          "lastModified",
          descending: true,
        )
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  //--------------------------------------------------
  // COMPLETED PROJECTS
  //--------------------------------------------------

  Stream<List<ProjectModel>>
      completedProjects() {
    return _projects
        .where(
          "userId",
          isEqualTo: currentUserId,
        )
        .where(
          "status",
          isEqualTo: completed,
        )
        .orderBy(
          "lastModified",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  //--------------------------------------------------
  // CURRENTLY RENDERING
  //--------------------------------------------------

  Stream<List<ProjectModel>>
      renderingProjects() {
    return _projects
        .where(
          "userId",
          isEqualTo: currentUserId,
        )
        .where(
          "status",
          isEqualTo: rendering,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  //--------------------------------------------------
  // QUEUED PROJECTS
  //--------------------------------------------------

  Stream<List<ProjectModel>>
      queuedProjectsStream() {
    return _projects
        .where(
          "userId",
          isEqualTo: currentUserId,
        )
        .where(
          "status",
          isEqualTo: queued,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data())
              .toList(),
        );
  }

  //--------------------------------------------------
  // HEALTH CHECK
  //--------------------------------------------------

  Future<bool> ping() async {
    try {
      await _firestore
          .collection("_health")
          .limit(1)
          .get();

      return true;
    } catch (_) {
      return false;
    }
  }

  //--------------------------------------------------
  // SERVICE AVAILABLE
  //--------------------------------------------------

  Future<bool> isAvailable() async {
    return await ping();
  }

  //--------------------------------------------------
  // ANALYTICS PLACEHOLDER
  //--------------------------------------------------

  Future<void> trackUsage({
    required String event,
    Map<String, dynamic>? parameters,
  }) async {
    // Firebase Analytics
    // Mixpanel
    // Amplitude
  }

  //--------------------------------------------------
  // ESTIMATE RENDER TIME
  //--------------------------------------------------

  Duration estimateRenderTime({
    required String duration,
    required String resolution,
  }) {
    int seconds = 30;

    if (duration.contains("60")) {
      seconds += 25;
    }

    if (resolution == "2K") {
      seconds += 15;
    }

    if (resolution == "4K") {
      seconds += 30;
    }

    return Duration(seconds: seconds);
  }
  //--------------------------------------------------
  // AI WORKFLOW PLACEHOLDER
  //--------------------------------------------------

  Future<void> startAIWorkflow(
    ProjectModel project,
  ) async {
    // Reserved for future AI orchestration.
  }

  //--------------------------------------------------
  // TRIGGER CLOUD RENDER
  //--------------------------------------------------

  Future<void> triggerRendering(
    String projectId,
  ) async {
    // Reserved for Cloud Functions /
    // Vertex AI /
    // Render Queue.
  }

  //--------------------------------------------------
  // DISPOSE
  //--------------------------------------------------

  void dispose() {}

}