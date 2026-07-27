import 'package:flutter/foundation.dart';

import '../../features/projects/models/project_model.dart';
import '../../features/projects/services/project_service.dart';
import '../../features/studio/services/render_service.dart';
import '../../features/user/services/user_service.dart';

import 'gemini_service.dart';

class WorkflowService {

  //--------------------------------------------------
  // CREDIT COSTS
  //--------------------------------------------------

  static const int videoGenerationCost = 20;
  static const int imageGenerationCost = 5;
  static const int voiceGenerationCost = 2;
  static const int directorGenerationCost = 10;

  //--------------------------------------------------
  // DEPENDENCIES
  //--------------------------------------------------

  final GeminiService _geminiService;
  final ProjectService _projectService;
  final RenderService _renderService;
  final UserService _userService;

  WorkflowService({
    GeminiService? geminiService,
    ProjectService? projectService,
    RenderService? renderService,
    UserService? userService,
  })  : _geminiService = geminiService ?? GeminiService(),
        _projectService = projectService ?? ProjectService(),
        _renderService = renderService ?? RenderService(),
        _userService = userService ?? UserService();

  //--------------------------------------------------
  // GETTERS
  //--------------------------------------------------

  GeminiService get gemini => _geminiService;
  ProjectService get projects => _projectService;
  RenderService get renders => _renderService;
  UserService get users => _userService;

  //--------------------------------------------------
  // WORKFLOW STATE
  //--------------------------------------------------

  bool _busy = false;
  bool get isBusy => _busy;

  String? _lastError;
  String? get lastError => _lastError;

  //--------------------------------------------------
  // AI Provider
  //--------------------------------------------------

  String _provider = "Gemini";
  String get provider => _provider;

  //--------------------------------------------------
  // DEBUG LOGGER
  //--------------------------------------------------

  void log(String message) {
    if (kDebugMode) {
      debugPrint("[Workflow] $message");
    }
  }
  //--------------------------------------------------
  // VALIDATION
  //--------------------------------------------------

  bool validatePrompt(String prompt) {
    return prompt.trim().length >= 5;
  }

  int estimateTokens(String prompt) {
    return (prompt.length / 4).ceil();
  }

  bool canEnhance(String prompt) {
    return validatePrompt(prompt);
  }

  //--------------------------------------------------
  // CREATE AI PROJECT
  //--------------------------------------------------

  Future<ProjectModel> createAIProject({
    required String prompt,
    required String style,
    required String language,
    required String voice,
    required String resolution,
    required String aspectRatio,
    required String duration,
  }) async {
    log("Starting AI workflow...");

    if (!validatePrompt(prompt)) {
      throw Exception("Prompt is invalid.");
    }

    //--------------------------------------------------
    // VERIFY USER CREDITS
    //--------------------------------------------------

    final availableCredits =
        await _userService.currentCredits();

    if (availableCredits < videoGenerationCost) {
      throw Exception("INSUFFICIENT_CREDITS");
    }

    //--------------------------------------------------
    // ENHANCE PROMPT
    //--------------------------------------------------

    final enhancedPrompt =
        await enhancePrompt(prompt);

    //--------------------------------------------------
    // DEDUCT CREDITS
    //--------------------------------------------------

    await _userService.deductCredits(
      amount: videoGenerationCost,
    );

    try {
      //--------------------------------------------------
      // CREATE PROJECT
      //--------------------------------------------------

      final project =
          await _projectService.createProject(
        prompt: prompt,
        enhancedPrompt: enhancedPrompt,
        style: style,
        language: language,
        voice: voice,
        resolution: resolution,
        aspectRatio: aspectRatio,
        duration: duration,
      );

      //--------------------------------------------------
      // QUEUE RENDER
      //--------------------------------------------------

      await _renderService.queueProject(
        project.id,
      );

      return project;
    } catch (e) {
      //--------------------------------------------------
      // REFUND CREDITS
      //--------------------------------------------------

      await _userService.addCredits(
        amount: videoGenerationCost,
      );

      rethrow;
    }
  }

  //--------------------------------------------------
  // QUICK CREATE
  //--------------------------------------------------

  Future<ProjectModel> quickCreate({
    required String prompt,
  }) {
    return createAIProject(
      prompt: prompt,
      style: "Pixar",
      language: "English",
      voice: "Narrator",
      resolution: "1080p",
      aspectRatio: "16:9",
      duration: "30 Seconds",
    );
  }

  //--------------------------------------------------
  // CREATE DRAFT
  //--------------------------------------------------

  Future<ProjectModel> createDraft({
    required String prompt,
  }) {
    return _projectService.createProject(
      prompt: prompt,
      enhancedPrompt: prompt,
      style: "Pixar",
      language: "English",
      voice: "Narrator",
      resolution: "1080p",
      aspectRatio: "16:9",
      duration: "30 Seconds",
    );
  }

  //--------------------------------------------------
  // START RENDER
  //--------------------------------------------------

  Future<ProjectModel> startRender({
    required ProjectModel project,
  }) async {
    await _renderService.queueProject(project.id);

    await _renderService.startRendering(
      project.id,
    );

    return project.copyWith(
      status: ProjectStatus.rendering,
      progress: 0,
    );
  }

  //--------------------------------------------------
  // UPDATE PROGRESS
  //--------------------------------------------------

  Future<void> updateProgress({
    required String projectId,
    required double progress,
  }) async {
    await _renderService.updateRenderProgress(
      projectId: projectId,
      progress: progress,
    );
  }

  //--------------------------------------------------
  // COMPLETE RENDER
  //--------------------------------------------------

  Future<void> completeRender({
    required String projectId,
    required String thumbnail,
  }) async {
    await _renderService.completeRendering(
      projectId: projectId,
      thumbnail: thumbnail,
    );
  }

  //--------------------------------------------------
  // FAIL RENDER
  //--------------------------------------------------

  Future<void> failRender({
    required String projectId,
    required String reason,
  }) async {
    await _renderService.renderFailed(
      projectId: projectId,
      reason: reason,
    );
  }

  //--------------------------------------------------
  // CANCEL
  //--------------------------------------------------

  Future<void> cancelRender(
    String projectId,
  ) async {
    await _renderService.cancelRender(
      projectId,
    );
  }

  //--------------------------------------------------
  // RETRY
  //--------------------------------------------------

  Future<void> retryRender(
    String projectId,
  ) async {
    await _renderService.retryRender(
      projectId,
    );
  }
  //--------------------------------------------------
  // UPDATE RENDER PROGRESS
  //--------------------------------------------------

  Future<void> updateProgress({
    required String projectId,
    required double progress,
  }) async {
    await _renderService.updateRenderProgress(
      projectId: projectId,
      progress: progress,
    );

    log(
      "Render Progress: ${(progress * 100).toStringAsFixed(0)}%",
    );
  }

  //--------------------------------------------------
  // COMPLETE RENDER
  //--------------------------------------------------

  Future<void> completeRender({
    required String projectId,
    required String thumbnail,
  }) async {
    await _renderService.completeRendering(
      projectId: projectId,
      thumbnail: thumbnail,
    );

    log("Render completed.");
  }

  //--------------------------------------------------
  // FAIL RENDER
  //--------------------------------------------------

  Future<void> failRender({
    required String projectId,
    required String reason,
  }) async {
    await _renderService.renderFailed(
      projectId: projectId,
      reason: reason,
    );

    log("Render failed: $reason");
  }

  //--------------------------------------------------
  // CANCEL RENDER
  //--------------------------------------------------

  Future<void> cancelRender(
    String projectId,
  ) async {
    await _renderService.cancelRender(projectId);

    log("Render cancelled.");
  }

  //--------------------------------------------------
  // RETRY RENDER
  //--------------------------------------------------

  Future<void> retryRender(
    String projectId,
  ) async {
    await _renderService.retryRender(projectId);

    log("Retry requested.");
  }

  //--------------------------------------------------
  // WORKFLOW STATE
  //--------------------------------------------------

  bool _busy = false;

  bool get isBusy => _busy;

  String? _lastError;

  String? get lastError => _lastError;

  void _setBusy(bool value) {
    _busy = value;

    log("Workflow Busy: $value");
  }

  void _setError(String? error) {
    _lastError = error;

    if (error != null) {
      log(error);
    }
  }

  //--------------------------------------------------
  // SAFE EXECUTION
  //--------------------------------------------------

  Future<T> execute<T>(
    Future<T> Function() action,
  ) async {
    _setBusy(true);
    _setError(null);

    try {
      return await action();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  //--------------------------------------------------
  // ROLLBACK PROJECT
  //--------------------------------------------------

  Future<void> rollbackProject(
    String projectId,
  ) async {
    try {
      await _projectService.deleteProject(projectId);

      log("Rollback completed.");
    } catch (_) {
      log("Rollback skipped.");
    }
  }

  //--------------------------------------------------
  // RETRY WORKFLOW
  //--------------------------------------------------

  Future<ProjectModel> retryWorkflow({
    required ProjectModel project,
  }) async {
    log("Retrying workflow...");

    await retryRender(project.id);

    return project.copyWith(
      status: ProjectService.statusQueued,
      progress: 0,
    );
  }

  //--------------------------------------------------
  // HEALTH CHECK
  //--------------------------------------------------

  Future<bool> healthCheck() async {
    final firestore = await _projectService.ping();
    final render = await _renderService.ping();

    return firestore && render;
  }

  //--------------------------------------------------
  // RESET
  //--------------------------------------------------

  void reset() {
    _setBusy(false);
    _setError(null);

    log("Workflow reset.");
  }

  //--------------------------------------------------
  // RUN COMPLETE WORKFLOW
  //--------------------------------------------------

  Future<ProjectModel> runWorkflow({
    required String prompt,
    required String style,
    required String language,
    required String voice,
    required String resolution,
    required String aspectRatio,
    required String duration,
  }) async {
    return execute(() async {
      final project = await createAIProject(
        prompt: prompt,
        style: style,
        language: language,
        voice: voice,
        resolution: resolution,
        aspectRatio: aspectRatio,
        duration: duration,
      );

      await startRender(project: project);

      return project;
    });
  }
  //--------------------------------------------------
  // AI PROVIDER
  //--------------------------------------------------

  String _provider = "Gemini";

  String get provider => _provider;

  void changeProvider(String value) {
    _provider = value;
    log("Provider changed to $value");
  }

  //--------------------------------------------------
  // ANALYTICS
  //--------------------------------------------------

  Future<void> analytics(String event) async {
    log("Analytics: $event");

    // Future integrations:
    // Firebase Analytics
    // Mixpanel
    // Amplitude
  }

  //--------------------------------------------------
  // EXECUTION TIME
  //--------------------------------------------------

  Future<T> measure<T>(
    String name,
    Future<T> Function() action,
  ) async {
    final stopwatch = Stopwatch()..start();

    final result = await action();

    stopwatch.stop();

    log(
      "$name completed in ${stopwatch.elapsedMilliseconds} ms",
    );

    return result;
  }

  //--------------------------------------------------
  // SHUTDOWN
  //--------------------------------------------------

  Future<void> shutdown() async {
    reset();

    log("Workflow shutdown.");
  }

  //--------------------------------------------------
  // VERSION
  //--------------------------------------------------

  String get version => "Workflow Engine v1.0.0";
}