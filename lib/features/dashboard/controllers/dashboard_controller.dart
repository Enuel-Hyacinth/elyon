import 'dart:async';

import 'package:flutter/material.dart';

import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';
import '../../user/services/user_service.dart';

class DashboardController extends ChangeNotifier {
  //--------------------------------------------------
  // SERVICES
  //--------------------------------------------------

  final ProjectService _projectService =
      ProjectService();

  final UserService _userService =
      UserService();

  //--------------------------------------------------
  // PROJECT STATUS
  //--------------------------------------------------

  static const String statusCreated =
      "created";

  static const String statusQueued =
      "queued";

  static const String statusRendering =
      "rendering";

  static const String statusCompleted =
      "completed";

  static const String statusFailed =
      "failed";

  //--------------------------------------------------
  // STATE
  //--------------------------------------------------

  bool _loading = false;

  bool get loading => _loading;

  List<ProjectModel> _projects = [];

  List<ProjectModel> get projects =>
      _projects;

  StreamSubscription<List<ProjectModel>>?
      _subscription;

  //--------------------------------------------------
  // USER
  //--------------------------------------------------

  String _userName = "Creator";

  String get userName => _userName;

  int _credits = 0;

  int get credits => _credits;

  String _plan = "Free";

  String get plan => _plan;

  //--------------------------------------------------
  // ACTIVE PROJECT
  //--------------------------------------------------

  ProjectModel? _selectedProject;

  ProjectModel? get selectedProject =>
      _selectedProject;

  //--------------------------------------------------
  // QUICK GETTERS
  //--------------------------------------------------

  bool get hasProjects =>
      _projects.isNotEmpty;

  int get totalProjects =>
      _projects.length;

  ProjectModel? get latestProject {
    if (_projects.isEmpty) {
      return null;
    }

    return _projects.first;
  }

  int get completedProjects =>
      _projects
          .where(
            (p) =>
                p.status ==
                statusCompleted,
          )
          .length;

  int get renderingProjects =>
      _projects
          .where(
            (p) =>
                p.status ==
                statusRendering,
          )
          .length;

  int get draftProjects =>
      _projects
          .where(
            (p) =>
                p.status ==
                statusCreated,
          )
          .length;
  //--------------------------------------------------
  // INITIALIZE
  //--------------------------------------------------

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    await refresh();

    _listenToProjects();

    _loading = false;
    notifyListeners();
  }

  //--------------------------------------------------
  // REFRESH
  //--------------------------------------------------

  Future<void> refresh() async {
    try {
      //--------------------------------------------------
      // LOAD PROJECTS
      //--------------------------------------------------

      _projects =
          await _projectService.getProjects();

      //--------------------------------------------------
      // LOAD USER
      //--------------------------------------------------

      final profile =
          await _userService.getCurrentUserProfile();

      if (profile != null) {
        _userName =
            profile.displayName;

        _credits =
            profile.credits;

        _plan =
            profile.subscription;
      }
    } catch (e) {
      debugPrint(
        "[Dashboard] Refresh failed: $e",
      );

      _projects = [];
    }

    notifyListeners();
  }

  //--------------------------------------------------
  // PROJECT STREAM
  //--------------------------------------------------

  void _listenToProjects() {
    _subscription?.cancel();

    _subscription =
        _projectService
            .streamProjects()
            .listen(
      (projects) {
        _projects = projects;

        notifyListeners();
      },
      onError: (error) {
        debugPrint(
          "[Dashboard] Stream error: $error",
        );
      },
    );
  }

  //--------------------------------------------------
  // FIND PROJECT
  //--------------------------------------------------

  ProjectModel? findProject(
    String projectId,
  ) {
    try {
      return _projects.firstWhere(
        (project) =>
            project.id ==
            projectId,
      );
    } catch (_) {
      return null;
    }
  }

  //--------------------------------------------------
  // RECENT PROJECTS
  //--------------------------------------------------

  List<ProjectModel> get recentProjects {
    if (_projects.length <= 5) {
      return _projects;
    }

    return _projects
        .take(5)
        .toList();
  }

  //--------------------------------------------------
  // CONTINUE PROJECT
  //--------------------------------------------------

  ProjectModel? get continueProject {
    if (_selectedProject != null) {
      return _selectedProject;
    }

    if (_projects.isEmpty) {
      return null;
    }

    return _projects.first;
  }

  bool get hasContinueProject =>
      continueProject != null;
  //--------------------------------------------------
  // SELECT PROJECT
  //--------------------------------------------------

  void selectProject(
    ProjectModel project,
  ) {
    _selectedProject = project;

    notifyListeners();
  }

  //--------------------------------------------------
  // CLEAR SELECTION
  //--------------------------------------------------

  void clearSelection() {
    _selectedProject = null;

    notifyListeners();
  }

  //--------------------------------------------------
  // DASHBOARD STATISTICS
  //--------------------------------------------------

  Map<String, int> get statistics {
    return {
      "total": totalProjects,
      "completed": completedProjects,
      "rendering": renderingProjects,
      "draft": draftProjects,
    };
  }

  //--------------------------------------------------
  // ACTIVE RENDER
  //--------------------------------------------------

  bool get hasRenderingProject =>
      renderingProjects > 0;

  //--------------------------------------------------
  // COMPLETION RATE
  //--------------------------------------------------

  double get completionRate {
    if (_projects.isEmpty) {
      return 0;
    }

    return completedProjects /
        _projects.length;
  }

  //--------------------------------------------------
  // COMPLETED PROJECTS
  //--------------------------------------------------

  List<ProjectModel> get completedList {
    return _projects
        .where(
          (project) =>
              project.status ==
              statusCompleted,
        )
        .toList();
  }

  //--------------------------------------------------
  // RENDERING PROJECTS
  //--------------------------------------------------

  List<ProjectModel> get renderingList {
    return _projects
        .where(
          (project) =>
              project.status ==
              statusRendering,
        )
        .toList();
  }

  //--------------------------------------------------
  // DRAFT PROJECTS
  //--------------------------------------------------

  List<ProjectModel> get draftList {
    return _projects
        .where(
          (project) =>
              project.status ==
              statusCreated,
        )
        .toList();
  }

  //--------------------------------------------------
  // FAILED PROJECTS
  //--------------------------------------------------

  List<ProjectModel> get failedList {
    return _projects
        .where(
          (project) =>
              project.status ==
              statusFailed,
        )
        .toList();
  }

  //--------------------------------------------------
  // QUEUED PROJECTS
  //--------------------------------------------------

  List<ProjectModel> get queuedList {
    return _projects
        .where(
          (project) =>
              project.status ==
              statusQueued,
        )
        .toList();
  }
  //--------------------------------------------------
  // REMOVE PROJECT
  //--------------------------------------------------

  Future<void> removeProject(
    String projectId,
  ) async {
    try {
      await _projectService.deleteProject(
        projectId,
      );
    } catch (e) {
      debugPrint(
        "[Dashboard] Delete failed: $e",
      );
    }
  }

  //--------------------------------------------------
  // ARCHIVE PROJECT
  //--------------------------------------------------

  Future<void> archiveProject(
    String projectId,
  ) async {
    debugPrint(
      "[Dashboard] Archive requested for $projectId "
      "(not implemented).",
    );
  }

  //--------------------------------------------------
  // RESET
  //--------------------------------------------------

  void reset() {
    _projects = [];

    _selectedProject = null;

    _loading = false;

    notifyListeners();
  }

  //--------------------------------------------------
  // DISPOSE
  //--------------------------------------------------

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }
}