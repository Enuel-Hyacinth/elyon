import 'package:flutter/foundation.dart';

import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';

class StudioService {
  //--------------------------------------------------
  // DEPENDENCIES
  //--------------------------------------------------

  final ProjectService _projectService;

  StudioService({
    ProjectService? projectService,
  }) : _projectService =
            projectService ?? ProjectService();

  //--------------------------------------------------
  // GETTERS
  //--------------------------------------------------

  ProjectService get projects =>
      _projectService;

  //--------------------------------------------------
  // SAVE PROJECT
  //--------------------------------------------------

  Future<void> saveProject(
    ProjectModel project,
  ) async {
    try {
      await _projectService.updateProject(
        project,
      );

      debugPrint(
        "[Studio] Project saved.",
      );
    } catch (e) {
      debugPrint(
        "[Studio] Save failed: $e",
      );

      rethrow;
    }
  }

  //--------------------------------------------------
  // CREATE PROJECT
  //--------------------------------------------------

  Future<void> createProject(
    ProjectModel project,
  ) async {
    try {
      await _projectService.saveProject(
        project,
      );

      debugPrint(
        "[Studio] Project created.",
      );
    } catch (e) {
      debugPrint(
        "[Studio] Create failed: $e",
      );

      rethrow;
    }
  }

  //--------------------------------------------------
  // UPDATE PROJECT
  //--------------------------------------------------

  Future<void> updateProject(
    ProjectModel project,
  ) async {
    try {
      await _projectService.updateProject(
        project,
      );

      debugPrint(
        "[Studio] Project updated.",
      );
    } catch (e) {
      debugPrint(
        "[Studio] Update failed: $e",
      );

      rethrow;
    }
  }
  //--------------------------------------------------
  // LOAD PROJECT
  //--------------------------------------------------

  Future<ProjectModel?> loadProject(
    String projectId,
  ) async {
    try {
      return await _projectService.getProject(
        projectId,
      );
    } catch (e) {
      debugPrint(
        "[Studio] Load failed: $e",
      );

      return null;
    }
  }

  //--------------------------------------------------
  // LOAD ALL PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> loadProjects() async {
    try {
      return await _projectService.getProjects();
    } catch (e) {
      debugPrint(
        "[Studio] Load projects failed: $e",
      );

      return [];
    }
  }

  //--------------------------------------------------
  // PROJECT STREAM
  //--------------------------------------------------

  Stream<List<ProjectModel>> streamProjects() {
    return _projectService.streamProjects();
  }

  //--------------------------------------------------
  // DELETE PROJECT
  //--------------------------------------------------

  Future<void> deleteProject(
    String projectId,
  ) async {
    try {
      await _projectService.deleteProject(
        projectId,
      );

      debugPrint(
        "[Studio] Project deleted.",
      );
    } catch (e) {
      debugPrint(
        "[Studio] Delete failed: $e",
      );

      rethrow;
    }
  }

  //--------------------------------------------------
  // AUTO SAVE
  //--------------------------------------------------

  Future<void> autoSave(
    ProjectModel project,
  ) async {
    try {
      await saveProject(project);

      debugPrint(
        "[Studio] Auto-save complete.",
      );
    } catch (e) {
      debugPrint(
        "[Studio] Auto-save failed: $e",
      );
    }
  }

  //--------------------------------------------------
  // DUPLICATE PROJECT
  //--------------------------------------------------

  Future<void> duplicateProject(
    ProjectModel project,
  ) async {
    final duplicate = project.copyWith(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(),
      title: "${project.title} Copy",
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    await createProject(
      duplicate,
    );
  }
  //--------------------------------------------------
  // GET LAST PROJECT
  //--------------------------------------------------

  Future<ProjectModel?> getLastProject() async {
    try {
      return await _projectService.getLastProject();
    } catch (e) {
      debugPrint(
        "[Studio] Get last project failed: $e",
      );

      return null;
    }
  }

  //--------------------------------------------------
  // SEARCH PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> searchProjects(
    String keyword,
  ) async {
    try {
      return await _projectService.searchProjects(
        keyword,
      );
    } catch (e) {
      debugPrint(
        "[Studio] Search failed: $e",
      );

      return [];
    }
  }

  //--------------------------------------------------
  // FILTER BY STATUS
  //--------------------------------------------------

  Future<List<ProjectModel>> getProjectsByStatus(
    String status,
  ) async {
    try {
      return await _projectService.getProjectsByStatus(
        status,
      );
    } catch (e) {
      debugPrint(
        "[Studio] Filter failed: $e",
      );

      return [];
    }
  }

  //--------------------------------------------------
  // GENERATE PROJECT TITLE
  //--------------------------------------------------

  String generateTitle(
    String prompt,
  ) {
    final text = prompt.trim();

    if (text.isEmpty) {
      return "Untitled Project";
    }

    final words = text.split(RegExp(r'\s+'));

    if (words.length <= 6) {
      return text;
    }

    return "${words.take(6).join(" ")}...";
  }

  //--------------------------------------------------
  // THUMBNAIL PLACEHOLDER
  //--------------------------------------------------

  String generateThumbnail(
    ProjectModel project,
  ) {
    if (project.thumbnail.isNotEmpty) {
      return project.thumbnail;
    }

    return "";
  }

  //--------------------------------------------------
  // PROJECT VALIDATION
  //--------------------------------------------------

  bool validateProject(
    ProjectModel project,
  ) {
    return project.prompt.trim().isNotEmpty &&
        project.title.trim().isNotEmpty;
  }

  //--------------------------------------------------
  // HAS UNSAVED CHANGES
  //--------------------------------------------------

  bool hasChanges(
    ProjectModel original,
    ProjectModel updated,
  ) {
    return original.toMap().toString() !=
        updated.toMap().toString();
  }

  //--------------------------------------------------
  // UPDATE LAST MODIFIED
  //--------------------------------------------------

  ProjectModel touch(
    ProjectModel project,
  ) {
    return project.copyWith(
      lastModified: DateTime.now(),
    );
  }
  //--------------------------------------------------
  // PROJECT STATISTICS
  //--------------------------------------------------

  Future<int> totalProjects() async {
    final projects = await loadProjects();

    return projects.length;
  }

  //--------------------------------------------------
  // RECENT PROJECTS
  //--------------------------------------------------

  Future<List<ProjectModel>> recentProjects({
    int limit = 5,
  }) async {
    final projects = await loadProjects();

    if (projects.length <= limit) {
      return projects;
    }

    return projects.take(limit).toList();
  }

  //--------------------------------------------------
  // PROJECT EXISTS
  //--------------------------------------------------

  Future<bool> exists(
    String projectId,
  ) async {
    final project = await loadProject(
      projectId,
    );

    return project != null;
  }

  //--------------------------------------------------
  // REFRESH PROJECT
  //--------------------------------------------------

  Future<ProjectModel?> refreshProject(
    String projectId,
  ) async {
    return loadProject(projectId);
  }

  //--------------------------------------------------
  // HEALTH CHECK
  //--------------------------------------------------

  Future<bool> ping() async {
    try {
      await loadProjects();

      return true;
    } catch (_) {
      return false;
    }
  }

  //--------------------------------------------------
  // DEBUG INFO
  //--------------------------------------------------

  void log(
    String message,
  ) {
    debugPrint(
      "[StudioService] $message",
    );
  }

  //--------------------------------------------------
  // RESET
  //--------------------------------------------------

  void reset() {
    log("StudioService reset.");
  }
}