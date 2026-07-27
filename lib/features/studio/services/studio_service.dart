import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../projects/models/project_model.dart';

class StudioService {
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

  CollectionReference<ProjectModel> get _projects =>
      _firestore
          .collection('projects')
          .withConverter<ProjectModel>(
            fromFirestore: (snapshot, _) =>
                ProjectModel.fromMap(snapshot.data()!),
            toFirestore: (project, _) =>
                project.toMap(),
          );

  //--------------------------------------------------
  // PROJECT STATUS
  //--------------------------------------------------

  static const String statusCreated = "Created";
  static const String statusQueued = "Queued";
  static const String statusRendering = "Rendering";
  static const String statusCompleted = "Completed";
  static const String statusFailed = "Failed";
  static const String statusCancelled = "Cancelled";
  static const String statusArchived = "Archived";
  static const String statusDeleted = "Deleted";

  //--------------------------------------------------
  // AUTH HELPERS
  //--------------------------------------------------

  User? get currentUser => _auth.currentUser;

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
  // FIRESTORE HELPERS
  //--------------------------------------------------

  FieldValue get serverTimestamp =>
      FieldValue.serverTimestamp();

  //--------------------------------------------------
  // TITLE GENERATOR
  //--------------------------------------------------

  String _generateTitle(String prompt) {
    final words = prompt
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .take(5)
        .join(' ');

    if (words.isEmpty) {
      return "Untitled Project";
    }

    return words;
  }
  //--------------------------------------------------
  // CREATE PROJECT
  //--------------------------------------------------

  Future<ProjectModel> createProject({
    required String prompt,
    required String enhancedPrompt,
    required String style,
    required String language,
    required String voice,
    required String resolution,
    required String aspectRatio,
    required String duration,
  }) async {
    final doc = _projects.doc();

    final project = ProjectModel(
      id: doc.id,
      userId: currentUserId,
      title: _generateTitle(prompt),
      prompt: prompt,
      enhancedPrompt: enhancedPrompt,
      intent: "video",
      status: statusCreated,
      creditsUsed: 20,
      thumbnail: "",
      style: style,
      language: language,
      voice: voice,
      aspectRatio: aspectRatio,
      resolution: resolution,
      duration: duration,
      progress: 0,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    try {
      await doc.set(
        project.copyWith(
          createdAt: DateTime.now(),
          lastModified: DateTime.now(),
        ),
      );

      return project;
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to create project: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // UPDATE PROJECT
  //--------------------------------------------------

  Future<ProjectModel> updateProject({
    required ProjectModel project,
    String? prompt,
    String? enhancedPrompt,
    String? style,
    String? language,
    String? voice,
    String? resolution,
    String? aspectRatio,
    String? duration,
    String? status,
    double? progress,
    String? thumbnail,
  }) async {
    final updated = project.copyWith(
      prompt: prompt,
      enhancedPrompt: enhancedPrompt,
      style: style,
      language: language,
      voice: voice,
      resolution: resolution,
      aspectRatio: aspectRatio,
      duration: duration,
      status: status,
      progress: progress,
      thumbnail: thumbnail,
      lastModified: DateTime.now(),
    );

    try {
      await _projects.doc(updated.id).set(updated);

      return updated;
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to update project: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // SAVE PROJECT
  //--------------------------------------------------

  Future<void> saveProject(
    ProjectModel project,
  ) async {
    try {
      final updated = project.copyWith(
        lastModified: DateTime.now(),
      );

      await _projects.doc(updated.id).set(updated);
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to save project: ${e.message}",
      );
    }
  }
  //--------------------------------------------------
  // DELETE PROJECT
  //--------------------------------------------------

  Future<void> deleteProject(
    String projectId,
  ) async {
    try {
      await _projects.doc(projectId).delete();
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to delete project: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // SOFT DELETE PROJECT
  //--------------------------------------------------

  Future<void> softDeleteProject(
    String projectId,
  ) async {
    try {
      await _projects.doc(projectId).update({
        "status": statusDeleted,
        "deletedAt": serverTimestamp,
        "lastModified": serverTimestamp,
      });

      await logEvent(
        action: "soft_delete",
        projectId: projectId,
      );
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to archive project: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // RESTORE PROJECT
  //--------------------------------------------------

  Future<void> restoreProject(
    String projectId,
  ) async {
    try {
      await _projects.doc(projectId).update({
        "status": statusCreated,
        "deletedAt": null,
        "lastModified": serverTimestamp,
      });

      await logEvent(
        action: "restore_project",
        projectId: projectId,
      );
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to restore project: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // ARCHIVE PROJECT
  //--------------------------------------------------

  Future<void> archiveProject(
    String projectId,
  ) async {
    try {
      await _projects.doc(projectId).update({
        "status": statusArchived,
        "lastModified": serverTimestamp,
      });

      await logEvent(
        action: "archive_project",
        projectId: projectId,
      );
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to archive project: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // AUDIT LOG
  //--------------------------------------------------

  Future<void> logEvent({
    required String action,
    required String projectId,
  }) async {
    try {
      await _firestore.collection("auditLogs").add({
        "userId": currentUserId,
        "projectId": projectId,
        "action": action,
        "timestamp": serverTimestamp,
      });
    } catch (_) {
      // Never allow logging failures
      // to interrupt the main workflow.
    }
  }
  //--------------------------------------------------
  // LOAD USER PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> loadProjects() async {
    try {
      final snapshot = await _projects
          .where(
            "userId",
            isEqualTo: currentUserId,
          )
          .orderBy(
            "lastModified",
            descending: true,
          )
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to load projects: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // LOAD SINGLE PROJECT
  //--------------------------------------------------

  Future<ProjectModel?> getProject(
    String projectId,
  ) async {
    try {
      final doc = await _projects
          .doc(projectId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to load project: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // REAL-TIME PROJECT STREAM
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
  // SINGLE PROJECT STREAM
  //--------------------------------------------------

  Stream<ProjectModel?> streamProject(
    String projectId,
  ) {
    return _projects
        .doc(projectId)
        .snapshots()
        .map(
          (doc) {
            if (!doc.exists) {
              return null;
            }

            return doc.data();
          },
        );
  }
  //--------------------------------------------------
  // GENERATE PROJECT TITLE
  //--------------------------------------------------

  String _generateTitle(
    String prompt,
  ) {
    final words = prompt
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (word) => word.isNotEmpty,
        )
        .take(5)
        .join(' ');

    if (words.isEmpty) {
      return "Untitled Project";
    }

    return words;
  }

  //--------------------------------------------------
  // PROJECT EXISTS
  //--------------------------------------------------

  Future<bool> exists(
    String projectId,
  ) async {
    try {
      final doc = await _projects
          .doc(projectId)
          .get();

      return doc.exists;
    } on FirebaseException {
      return false;
    }
  }

  //--------------------------------------------------
  // PROJECT COUNT
  //--------------------------------------------------

  Future<int> countProjects() async {
    try {
      final snapshot = await _projects
          .where(
            "userId",
            isEqualTo: currentUserId,
          )
          .get();

      return snapshot.docs.length;
    } on FirebaseException {
      return 0;
    }
  }

  //--------------------------------------------------
  // RECENT PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> recentProjects() async {
    try {
      final snapshot = await _projects
          .where(
            "userId",
            isEqualTo: currentUserId,
          )
          .orderBy(
            "lastModified",
            descending: true,
          )
          .limit(5)
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } on FirebaseException {
      return [];
    }
  }

  //--------------------------------------------------
  // PROJECTS BY STATUS
  //--------------------------------------------------

  Future<List<ProjectModel>> projectsByStatus(
    String status,
  ) async {
    try {
      final snapshot = await _projects
          .where(
            "userId",
            isEqualTo: currentUserId,
          )
          .where(
            "status",
            isEqualTo: status,
          )
          .orderBy(
            "lastModified",
            descending: true,
          )
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } on FirebaseException {
      return [];
    }
  }

  //--------------------------------------------------
  // SEARCH PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> searchProjects(
    String keyword,
  ) async {
    try {
      final snapshot = await _projects
          .where(
            "userId",
            isEqualTo: currentUserId,
          )
          .orderBy("title")
          .startAt([keyword])
          .endAt(["$keyword\uf8ff"])
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    } on FirebaseException {
      return [];
    }
  }
  //--------------------------------------------------
  // BATCH SAVE PROJECTS
  //--------------------------------------------------

  Future<void> saveProjectsBatch(
    List<ProjectModel> projects,
  ) async {
    final batch = _firestore.batch();

    for (final project in projects) {
      batch.set(
        _projects.doc(project.id),
        project.copyWith(
          lastModified: DateTime.now(),
        ),
      );
    }

    await batch.commit();
  }

  //--------------------------------------------------
  // BATCH DELETE PROJECTS
  //--------------------------------------------------

  Future<void> deleteProjects(
    List<String> projectIds,
  ) async {
    final batch = _firestore.batch();

    for (final id in projectIds) {
      batch.delete(
        _projects.doc(id),
      );
    }

    await batch.commit();
  }

  //--------------------------------------------------
  // LOAD MORE PROJECTS (Pagination)
  //--------------------------------------------------

  Future<QuerySnapshot<ProjectModel>>
      loadMoreProjects({
    DocumentSnapshot<ProjectModel>? lastDocument,
    int limit = 20,
  }) async {
    Query<ProjectModel> query = _projects
        .where(
          "userId",
          isEqualTo: currentUserId,
        )
        .orderBy(
          "lastModified",
          descending: true,
        )
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(
        lastDocument,
      );
    }

    return await query.get();
  }

  //--------------------------------------------------
  // PROJECT STATISTICS
  //--------------------------------------------------

  Future<Map<String, int>>
      projectStatistics() async {
    final projects = await loadProjects();

    return {
      "total": projects.length,

      "completed": projects
          .where(
            (p) =>
                p.status == statusCompleted,
          )
          .length,

      "rendering": projects
          .where(
            (p) =>
                p.status == statusRendering,
          )
          .length,

      "queued": projects
          .where(
            (p) =>
                p.status == statusQueued,
          )
          .length,

      "draft": projects
          .where(
            (p) =>
                p.status == statusCreated,
          )
          .length,
    };
  }

  //--------------------------------------------------
  // QUEUE PROJECT
  //--------------------------------------------------

  Future<void> queueProject(
    String projectId,
  ) async {
    await _projects.doc(projectId).update({
      "status": statusQueued,
      "progress": 0.0,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // START RENDERING
  //--------------------------------------------------

  Future<void> startRendering(
    String projectId,
  ) async {
    await _projects.doc(projectId).update({
      "status": statusRendering,
      "progress": 0.0,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // UPDATE RENDER PROGRESS
  //--------------------------------------------------

  Future<void> updateRenderProgress({
    required String projectId,
    required double progress,
  }) async {
    await _projects.doc(projectId).update({
      "progress": progress,
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
      "status": statusCompleted,
      "progress": 1.0,
      "thumbnail": thumbnail,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // RENDER FAILED
  //--------------------------------------------------

  Future<void> renderFailed({
    required String projectId,
    required String reason,
  }) async {
    await _projects.doc(projectId).update({
      "status": statusFailed,
      "failureReason": reason,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // RETRY RENDER
  //--------------------------------------------------

  Future<void> retryRender(
    String projectId,
  ) async {
    await _projects.doc(projectId).update({
      "status": statusQueued,
      "progress": 0.0,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // CANCEL RENDER
  //--------------------------------------------------

  Future<void> cancelRender(
    String projectId,
  ) async {
    await _projects.doc(projectId).update({
      "status": statusCancelled,
      "progress": 0.0,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // PROGRESS STREAM
  //--------------------------------------------------

  Stream<double> renderProgress(
    String projectId,
  ) {
    return _projects
        .doc(projectId)
        .snapshots()
        .map(
          (doc) =>
              doc.data()?.progress ?? 0.0,
        );
  }

  //--------------------------------------------------
  // IS RENDERING
  //--------------------------------------------------

  Future<bool> isRendering(
    String projectId,
  ) async {
    final project =
        await getProject(projectId);

    return project?.status ==
        statusRendering;
  }

  //--------------------------------------------------
  // QUEUED PROJECTS COUNT
  //--------------------------------------------------

  Future<int> queuedProjects() async {
    final snapshot = await _projects
        .where(
          "userId",
          isEqualTo: currentUserId,
        )
        .where(
          "status",
          isEqualTo: statusQueued,
        )
        .get();

    return snapshot.docs.length;
  }

  //--------------------------------------------------
  // FIRESTORE TRANSACTION
  //--------------------------------------------------

  Future<T> runTransaction<T>(
    Future<T> Function(
      Transaction transaction,
    ) action,
  ) async {
    return _firestore.runTransaction<T>(
      (transaction) async {
        return await action(transaction);
      },
    );
  }

  //--------------------------------------------------
  // ANALYTICS HOOK
  //--------------------------------------------------

  Future<void> trackUsage({
    required String event,
  }) async {
    // Future:
    // Firebase Analytics
    // Mixpanel
    // Amplitude
  }

  //--------------------------------------------------
  // AI WORKFLOW
  //--------------------------------------------------

  Future<void> startAIWorkflow(
    ProjectModel project,
  ) async {
    // Future:
    // Gemini
    // OpenAI
    // Claude
    // Veo
    // Runway
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
}