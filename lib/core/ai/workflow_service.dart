import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../features/projects/models/project_model.dart';
import '../../features/projects/services/project_service.dart';
import '../../features/studio/services/render_service.dart';
import '../../features/user/services/user_service.dart';

import 'ai_provider.dart';
import 'ai_service.dart';


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

  final AIService _aiService;
  final ProjectService _projectService;
  final RenderService _renderService;
  final UserService _userService;

  WorkflowService({

    AIService? aiService,

    ProjectService? projectService,

    RenderService? renderService,

    UserService? userService,

  })  : _aiService =
            aiService ??
            AIProvider.instance,

        _projectService =
            projectService ??
            ProjectService(),

        _renderService =
            renderService ??
            RenderService(),

        _userService =
            userService ??
            UserService();

  //--------------------------------------------------
  // GETTERS
  //--------------------------------------------------

  AIService get ai =>
      _aiService;

  ProjectService get projects =>
      _projectService;

  RenderService get renders =>
      _renderService;

  UserService get users =>
      _userService;

  //--------------------------------------------------
  // WORKFLOW STATE
  //--------------------------------------------------

  bool _busy = false;

  bool get isBusy =>
      _busy;

  String? _lastError;

  String? get lastError =>
      _lastError;

  //--------------------------------------------------
  // AI PROVIDER
  //--------------------------------------------------

  String _provider = "Gemini";

  String get provider =>
      _provider;

  //--------------------------------------------------
  // LOGGER
  //--------------------------------------------------

  void log(
    String message,
  ) {

    if (kDebugMode) {

      debugPrint(
        "[Workflow] $message",
      );

    }

  }

  //--------------------------------------------------
  // INTERNAL STATE
  //--------------------------------------------------

  void _setBusy(
    bool value,
  ) {

    _busy = value;

    log(
      "Workflow Busy: $value",
    );

  }

  void _setError(
    String? error,
  ) {

    _lastError = error;

    if (error != null) {

      log(error);

    }

  }

  //--------------------------------------------------
  // CHANGE PROVIDER
  //--------------------------------------------------

  void changeProvider(
    String value,
  ) {

    _provider = value;

    log(
      "Provider changed to $value",
    );

  }

  //--------------------------------------------------
  // VERSION
  //--------------------------------------------------

  String get version =>
      "Workflow Engine v1.0.0";
  //--------------------------------------------------
  // VALIDATION
  //--------------------------------------------------

  bool validatePrompt(
    String prompt,
  ) {

    return prompt.trim().length >= 5;

  }

  int estimateTokens(
    String prompt,
  ) {

    return (prompt.length / 4).ceil();

  }

  bool canEnhance(
    String prompt,
  ) {

    return validatePrompt(prompt);

  }

  //--------------------------------------------------
  // ENHANCE PROMPT
  //--------------------------------------------------

  Future<String> enhancePrompt(
    String prompt,
  ) async {

    if (!canEnhance(prompt)) {
      return prompt;
    }

    return await _aiService.enhancePrompt(
        prompt,
    );

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

    log(
      "Starting AI workflow...",
    );

    if (!validatePrompt(prompt)) {

      throw Exception(
        "Prompt is invalid.",
      );

    }

    //--------------------------------------------------
    // VERIFY USER CREDITS
    //--------------------------------------------------

    final credits =
        await _userService.currentCredits();

    if (credits <
        videoGenerationCost) {

      throw Exception(
        "INSUFFICIENT_CREDITS",
      );

    }

    //--------------------------------------------------
    // ENHANCE PROMPT
    //--------------------------------------------------

    final enhancedPrompt =
        await enhancePrompt(
      prompt,
    );

    //--------------------------------------------------
    // DEDUCT CREDITS
    //--------------------------------------------------

    await _userService.deductCredits(
      amount: videoGenerationCost,
    );

    try {

      final project =
          await _projectService.createProject(

        prompt: prompt,

        enhancedPrompt:
            enhancedPrompt,

        style: style,

        language: language,

        voice: voice,

        resolution: resolution,

        aspectRatio: aspectRatio,

        duration: duration,

      );

      await _renderService.queueProject(
  project.id,
);


final jobId =
    await _aiService.generateMovie(

  prompt: enhancedPrompt,

  style: style,

  language: language,

  voice: voice,

  resolution: resolution,

  aspectRatio: aspectRatio,

  duration: duration,

);

log(
  "Runway Job: $jobId",
);

await _projectService.updateRunwayJob(

  project.id,

  jobId,

);

await _waitForRunway(
  project.id,
  jobId,
);

unawaited(
  pollRunwayJob(
    projectId: project.id,
    jobId: jobId,
  ),
);
  

return project;

    } catch (e) {

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

      style: "Cinematic",

      language: "English",

      voice: "Female",

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

      style: "Cinematic",

      language: "English",

      voice: "Female",

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

    await _renderService.queueProject(
      project.id,
    );

    await _renderService.startRendering(
      project.id,
    );

    return project.copyWith(
      status: RenderService.rendering,
      progress: 0,
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

  required String videoUrl,

}) async {

  await _renderService.completeRendering(

    projectId: projectId,

    thumbnail: thumbnail,

    videoUrl: videoUrl,

  );

  log(
    "Render completed.",
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

    log(
      "Render failed: $reason",
    );

  }

  //--------------------------------------------------
  // CANCEL RENDER
  //--------------------------------------------------

  Future<void> cancelRender(
    String projectId,
  ) async {

    await _renderService.cancelRender(
      projectId,
    );

    log(
      "Render cancelled.",
    );

  }

  //--------------------------------------------------
  // RETRY RENDER
  //--------------------------------------------------

  Future<void> retryRender(
    String projectId,
  ) async {

    await _renderService.retryRender(
      projectId,
    );

    log(
      "Retry requested.",
    );

  }

  //--------------------------------------------------
  // EXECUTE SAFELY
  //--------------------------------------------------

  Future<T> execute<T>(
    Future<T> Function() action,
  ) async {

    _setBusy(true);

    _setError(null);

    try {

      return await action();

    } catch (e) {

      _setError(
        e.toString(),
      );

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

      await _projectService.deleteProject(
        projectId,
      );

      log(
        "Rollback completed.",
      );

    } catch (_) {

      log(
        "Rollback skipped.",
      );

    }

  }

  //--------------------------------------------------
  // RETRY WORKFLOW
  //--------------------------------------------------

  Future<ProjectModel> retryWorkflow({

    required ProjectModel project,

  }) async {

    await retryRender(
      project.id,
    );

    return project.copyWith(

      status: RenderService.queued,

      progress: 0,

    );

  }
  //--------------------------------------------------
  // HEALTH CHECK
  //--------------------------------------------------

  Future<bool> healthCheck() async {

    try {

      return await _renderService.ping();

    } catch (_) {

      return false;

    }

  }

  //--------------------------------------------------
  // RESET WORKFLOW
  //--------------------------------------------------

  void reset() {

    _setBusy(false);

    _setError(null);

    log(
      "Workflow reset.",
    );

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

      final project =
          await createAIProject(

        prompt: prompt,

        style: style,

        language: language,

        voice: voice,

        resolution: resolution,

        aspectRatio: aspectRatio,

        duration: duration,

      );

      await startRender(
        project: project,
      );

      return project;

    });

  }

  //--------------------------------------------------
// WAIT FOR RUNWAY
//--------------------------------------------------

Future<void> _waitForRunway(

  String projectId,

  String jobId,

) async {

  while (true) {

    await Future.delayed(

      const Duration(seconds: 5),

    );

    final job = await _aiService.getJob(

      jobId,

    );

    if (job.status == "SUCCEEDED") {

      await completeRender(

        projectId: projectId,

        thumbnail: job.thumbnailUrl ?? "",

        videoUrl: job.videoUrl ?? "",

      );

      break;

    }

    if (

        job.status == "FAILED" ||

        job.status == "CANCELLED"

    ) {

      await failRender(

        projectId: projectId,

        reason: job.status,

      );

      break;

    }

    await updateProgress(

  projectId: projectId,

  progress: 0.5,

);

  }

}

  //--------------------------------------------------
  // ANALYTICS
  //--------------------------------------------------

  Future<void> analytics(
    String event,
  ) async {

    log(
      "Analytics: $event",
    );

    // Future integrations:
    //
    // Firebase Analytics
    // Mixpanel
    // Amplitude
    // PostHog

  }

  //--------------------------------------------------
  // EXECUTION TIMER
  //--------------------------------------------------

  Future<T> measure<T>(

    String name,

    Future<T> Function() action,

  ) async {

    final stopwatch =
        Stopwatch()..start();

    final result =
        await action();

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

    log(
      "Workflow shutdown.",
    );

  }


  //--------------------------------------------------
// POLL RUNWAY JOB
//--------------------------------------------------

Future<void> pollRunwayJob({

  required String projectId,

  required String jobId,

}) async {

  log("Polling Runway Job: $jobId");

  while (true) {

    await Future.delayed(

      const Duration(seconds: 5),

    );

    final job = await _aiService.getJob(jobId);
    
    if (job.isCompleted) {

      await completeRender(

        projectId: projectId,

        thumbnail: job.thumbnailUrl ?? "",

        videoUrl: job.videoUrl ?? "",

      );

      log(

        "Runway render completed.",

      );

      break;

    }

    if (job.isFailed) {

      await failRender(

        projectId: projectId,

        reason: "Runway render failed.",

      );

      break;

    }

    await updateProgress(

      projectId: projectId,

      progress: 0.5,

    );

  }

}
      
    
//--------------------------------------------------
// STREAM PROJECT
//--------------------------------------------------

Stream<ProjectModel?> streamProject(
  String projectId,
) {
  return _renderService.streamProject(
    projectId,
  );
}

//--------------------------------------------------
// RENDER PROGRESS
//--------------------------------------------------

Stream<double> renderProgress(
  String projectId,
) {
  return _renderService
      .streamProject(projectId)
      .map((project) => project?.progress ?? 0.0);
}
}