import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/project_model.dart';

class ProjectService {

  //--------------------------------------------------
  // FIREBASE
  //--------------------------------------------------

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  //--------------------------------------------------
  // AUTH
  //--------------------------------------------------

  User? get currentUser => _auth.currentUser;

  String get currentUserId {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        "No authenticated user.",
      );
    }

    return user.uid;
  }

  //--------------------------------------------------
  // COLLECTION
  //--------------------------------------------------

  CollectionReference<ProjectModel> get _projects =>
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
  // SERVER TIMESTAMP
  //--------------------------------------------------

  FieldValue get serverTimestamp =>
      FieldValue.serverTimestamp();

  //--------------------------------------------------
  // PROJECT STATUS
  //--------------------------------------------------

  static const String statusCreated =
      "Created";

  static const String statusQueued =
      "Queued";

  static const String statusRendering =
      "Rendering";

  static const String statusCompleted =
      "Completed";

  static const String statusFailed =
      "Failed";

  static const String statusCancelled =
      "Cancelled";

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
    String title = "Untitled Project",
    String intent = "general",
    int creditsUsed = 20,
  }) async {
    final user = currentUser;

    if (user == null) {
      throw Exception(
        "No authenticated user.",
      );
    }

    final doc = _projects.doc();

    final now = DateTime.now();

    final project = ProjectModel(
      id: doc.id,
      userId: user.uid,

      title: title,

      prompt: prompt,
      enhancedPrompt: enhancedPrompt,

      intent: intent,

      status: statusCreated,

      creditsUsed: creditsUsed,

      thumbnail: "",

      runwayJobId: "",

      style: style,
      language: language,
      voice: voice,
      aspectRatio: aspectRatio,
      resolution: resolution,
      duration: duration,

      progress: 0,

      createdAt: now,
      lastModified: now,
    );

    await doc.set(project);

    return project;
  }
  //--------------------------------------------------
  // SAVE PROJECT
  //--------------------------------------------------

  Future<void> saveProject(
    ProjectModel project,
  ) async {
    await _projects
        .doc(project.id)
        .set(project);

Future<void> updateRunwayJob(

  String projectId,

  String jobId,

) async {

  await _projects.doc(projectId).update({

    "runwayJobId": jobId,

    "lastModified": serverTimestamp,

  });

}
  }

  //--------------------------------------------------
  // UPDATE PROJECT
  //--------------------------------------------------

  Future<void> updateProject(
    ProjectModel project,
  ) async {
    final updated = project.copyWith(
      lastModified: DateTime.now(),
    );

    await _projects
        .doc(updated.id)
        .update(updated.toMap());
  }

  //--------------------------------------------------
  // DELETE PROJECT
  //--------------------------------------------------

  Future<void> deleteProject(
    String projectId,
  ) async {
    await _projects
        .doc(projectId)
        .delete();
  }

  //--------------------------------------------------
  // ARCHIVE PROJECT
  //--------------------------------------------------

  Future<void> archiveProject(
    String projectId,
  ) async {
    await _projects
        .doc(projectId)
        .update({
      "status": statusCancelled,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // GET PROJECT
  //--------------------------------------------------

  Future<ProjectModel?> getProject(
    String projectId,
  ) async {
    final snapshot =
        await _projects
            .doc(projectId)
            .get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  //--------------------------------------------------
  // GET ALL PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> getProjects() async {
    final snapshot =
        await _projects
            .where(
              "userId",
              isEqualTo: currentUserId,
            )
            .orderBy(
              "lastModified",
              descending: true,
            )
            .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  //--------------------------------------------------
  // LOAD PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> loadProjects() {
    return getProjects();
  }

  //--------------------------------------------------
  // STREAM ALL PROJECTS
  //--------------------------------------------------

  Stream<List<ProjectModel>>
      streamProjects() {
    return _projects
        .where(
          "userId",
          isEqualTo: currentUserId,
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
  // STREAM SINGLE PROJECT
  //--------------------------------------------------

  Stream<ProjectModel?> streamProject(
    String projectId,
  ) {
    return _projects
        .doc(projectId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return snapshot.data();
    });
  }
  //--------------------------------------------------
  // GET LAST PROJECT
  //--------------------------------------------------

  Future<ProjectModel?> getLastProject() async {
    final snapshot = await _projects
        .where(
          "userId",
          isEqualTo: currentUserId,
        )
        .orderBy(
          "createdAt",
          descending: true,
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();
  }

  //--------------------------------------------------
  // SEARCH PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> searchProjects(
    String keyword,
  ) async {
    final projects = await getProjects();

    final search = keyword.trim().toLowerCase();

    return projects.where((project) {
      return project.title
              .toLowerCase()
              .contains(search) ||
          project.prompt
              .toLowerCase()
              .contains(search) ||
          project.enhancedPrompt
              .toLowerCase()
              .contains(search);
    }).toList();
  }

  //--------------------------------------------------
  // PROJECTS BY STATUS
  //--------------------------------------------------

  Future<List<ProjectModel>> getProjectsByStatus(
    String status,
  ) async {
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
  }

  //--------------------------------------------------
  // PROJECT COUNT
  //--------------------------------------------------

  Future<int> projectCount() async {
    final projects = await getProjects();

    return projects.length;
  }

  //--------------------------------------------------
  // COMPLETED PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>>
      completedProjects() async {
    return getProjectsByStatus(
      statusCompleted,
    );
  }

  //--------------------------------------------------
  // RENDERING PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>>
      renderingProjects() async {
    return getProjectsByStatus(
      statusRendering,
    );
  }

  //--------------------------------------------------
  // QUEUED PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>>
      queuedProjects() async {
    return getProjectsByStatus(
      statusQueued,
    );
  }

  //--------------------------------------------------
  // CREATED PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>>
      createdProjects() async {
    return getProjectsByStatus(
      statusCreated,
    );
  }

  //--------------------------------------------------
  // FAILED PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>>
      failedProjects() async {
    return getProjectsByStatus(
      statusFailed,
    );
  }

  //--------------------------------------------------
  // CANCELLED PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>>
      cancelledProjects() async {
    return getProjectsByStatus(
      statusCancelled,
    );
  }
  //--------------------------------------------------
  // UPDATE PROJECT STATUS
  //--------------------------------------------------

  Future<void> updateStatus({
    required String projectId,
    required String status,
  }) async {
    await _projects
        .doc(projectId)
        .update({
      "status": status,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // UPDATE PROJECT PROGRESS
  //--------------------------------------------------

  Future<void> updateProgress({
    required String projectId,
    required double progress,
  }) async {
    await _projects
        .doc(projectId)
        .update({
      "progress": progress,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // RESET PROJECT STATUS
  //--------------------------------------------------

  Future<void> resetProjectStatus(
    String projectId,
  ) async {
    await _projects
        .doc(projectId)
        .update({
      "status": statusCreated,
      "progress": 0.0,
      "lastModified": serverTimestamp,
    });
  }

  //--------------------------------------------------
  // PROJECT EXISTS
  //--------------------------------------------------

  Future<bool> projectExists(
    String projectId,
  ) async {
    final snapshot = await _projects
        .doc(projectId)
        .get();

    return snapshot.exists;
  }

//--------------------------------------------------
// UPDATE RUNWAY JOB
//--------------------------------------------------

Future<void> updateRunwayJob(
  String projectId,
  String jobId,
) async {

  await _projects.doc(projectId).update({

    "runwayJobId": jobId,

    "lastModified": serverTimestamp,

  });

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
  // DISPOSE
  //--------------------------------------------------

  void dispose() {}

}
