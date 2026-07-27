import 'dart:async';

import 'package:flutter/material.dart';

import '../../projects/models/project_model.dart';

import '../../studio/services/project_service.dart';
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
  // STATE
  //--------------------------------------------------

  bool _loading = false;

  bool get loading => _loading;

  List<ProjectModel> _projects = [];

  List<ProjectModel> get projects => _projects;

  StreamSubscription<List<ProjectModel>>?
      _subscription;

//--------------------------------------------------
// USER STATE
//--------------------------------------------------

String _userName = "Creator";

String get userName => _userName;

int _credits = 0;

int get credits => _credits;

String _plan = "Free";

String get plan => _plan;

  //--------------------------------------------------
  // QUICK GETTERS
  //--------------------------------------------------

  ProjectModel? get latestProject {

    if (_projects.isEmpty) {
      return null;
    }

    return _projects.first;

  }

  bool get hasProjects =>
      _projects.isNotEmpty;

  int get totalProjects =>
      _projects.length;

  int get completedProjects =>
      _projects
          .where(
            (p) =>
                p.status ==
                ProjectService.statusCompleted,
          )
          .length;

  int get renderingProjects =>
      _projects
          .where(
            (p) =>
                p.status ==
                ProjectService.statusRendering,
          )
          .length;

  int get draftProjects =>
      _projects
          .where(
            (p) =>
                p.status ==
                ProjectService.statusCreated,
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
        await _projectService.loadProjects();

    //--------------------------------------------------
    // LOAD USER PROFILE
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
      "Dashboard Refresh Error: $e",
    );

    _projects = [];

  }

  notifyListeners();

}

  //--------------------------------------------------
  // REAL-TIME PROJECT LISTENER
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

      onError: (_) {},

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

            project.id == projectId,

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

    return _projects.take(5).toList();

  }
  //--------------------------------------------------
  // ACTIVE PROJECT
  //--------------------------------------------------

  ProjectModel? _selectedProject;

  ProjectModel? get selectedProject =>
      _selectedProject;

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

  //--------------------------------------------------
  // HAS CONTINUE PROJECT
  //--------------------------------------------------

  bool get hasContinueProject =>

      continueProject != null;

  //--------------------------------------------------
  // DASHBOARD SUMMARY
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
  // COMPLETION %
  //--------------------------------------------------

  double get completionRate {

    if (_projects.isEmpty) {

      return 0;

    }

    return completedProjects /
        _projects.length;

  }

  //--------------------------------------------------
  // RECENT COMPLETED
  //--------------------------------------------------

  List<ProjectModel> get completedList {

    return _projects.where(

      (project) =>

          project.status ==
          ProjectService.statusCompleted,

    ).toList();

  }

  //--------------------------------------------------
  // RECENT RENDERING
  //--------------------------------------------------

  List<ProjectModel> get renderingList {

    return _projects.where(

      (project) =>

          project.status ==
          ProjectService.statusRendering,

    ).toList();

  }

  //--------------------------------------------------
  // RECENT DRAFTS
  //--------------------------------------------------

  List<ProjectModel> get draftList {

    return _projects.where(

      (project) =>

          project.status ==
          ProjectService.statusCreated,

    ).toList();

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
        "Delete Project Error: $e",
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

      await _projectService.archiveProject(
        projectId,
      );

    } catch (e) {

      debugPrint(
        "Archive Project Error: $e",
      );

    }

  }

  //--------------------------------------------------
  // RESET DASHBOARD
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