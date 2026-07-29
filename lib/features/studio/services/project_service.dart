import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../projects/models/project_model.dart';

class ProjectService {
  //--------------------------------------------------
  // FIREBASE
  //--------------------------------------------------

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  //--------------------------------------------------
  // TYPED COLLECTION
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
  // CURRENT USER
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

      status: "Created",

      creditsUsed: 20,

      thumbnail: "",

      runwayJobId: "",

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
      await doc.set(project);

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
      lastModified: DateTime.now(),
    );

    try {

      await _projects
          .doc(updated.id)
          .set(updated);

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

    final updated = project.copyWith(
      lastModified: DateTime.now(),
    );

    try {

      await _projects
          .doc(updated.id)
          .set(updated);

    } on FirebaseException catch (e) {

      throw Exception(
        "Unable to save project: ${e.message}",
      );

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
          .map(
            (doc) => doc.data(),
          )
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
              .map(
                (doc) => doc.data(),
              )
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
  // DELETE PROJECT
  //--------------------------------------------------

  Future<void> deleteProject(
    String projectId,
  ) async {
    try {
      await _projects
          .doc(projectId)
          .delete();
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
      await _projects
          .doc(projectId)
          .update({
        "status": "Deleted",
        "deletedAt": serverTimestamp,
        "lastModified": serverTimestamp,
      });
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to delete project: ${e.message}",
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
      await _projects
          .doc(projectId)
          .update({
        "status": "Created",
        "deletedAt": null,
        "lastModified": serverTimestamp,
      });
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
      await _projects
          .doc(projectId)
          .update({
        "status": "Archived",
        "lastModified": serverTimestamp,
      });
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to archive project: ${e.message}",
      );
    }
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
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to count projects: ${e.message}",
      );
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
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to load recent projects: ${e.message}",
      );
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
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to load projects: ${e.message}",
      );
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
    } on FirebaseException catch (e) {
      throw Exception(
        "Unable to search projects: ${e.message}",
      );
    }
  }

  //--------------------------------------------------
  // LOAD MORE PROJECTS
  //--------------------------------------------------

  Future<QuerySnapshot<ProjectModel>>
      loadMoreProjects({
    DocumentSnapshot<ProjectModel>?
        lastDocument,
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
    final projects =
        await loadProjects();

    return {
      "total": projects.length,
      "completed": projects
          .where(
            (p) =>
                p.status == "Completed",
          )
          .length,
      "rendering": projects
          .where(
            (p) =>
                p.status == "Rendering",
          )
          .length,
      "draft": projects
          .where(
            (p) =>
                p.status == "Created",
          )
          .length,
    };
  }

  //--------------------------------------------------
  // BATCH SAVE
  //--------------------------------------------------

  Future<void> saveProjectsBatch(
    List<ProjectModel> projects,
  ) async {
    final batch =
        _firestore.batch();

    for (final project
        in projects) {
      batch.set(
        _projects.doc(project.id),
        project.copyWith(
          lastModified:
              DateTime.now(),
        ),
      );
    }

    await batch.commit();
  }

  //--------------------------------------------------
  // BATCH DELETE
  //--------------------------------------------------

  Future<void> deleteProjects(
    List<String> projectIds,
  ) async {
    final batch =
        _firestore.batch();

    for (final id
        in projectIds) {
      batch.delete(
        _projects.doc(id),
      );
    }

    await batch.commit();
  }

  //--------------------------------------------------
  // FIRESTORE TRANSACTION
  //--------------------------------------------------

  Future<T> runTransaction<T>(
    Future<T> Function(
      Transaction transaction,
    )
        action,
  ) async {
    return await _firestore
        .runTransaction<T>(
      (transaction) async {
        return await action(
          transaction,
        );
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
        .split(
          RegExp(r'\s+'),
        )
        .where(
          (word) =>
              word.isNotEmpty,
        )
        .take(5)
        .join(" ");

    if (words.isEmpty) {
      return "Untitled Project";
    }

    return words;
  }
}