import 'dart:async';

import '../../projects/models/project_model.dart';

enum GenerationStage {
  idle,
  validating,
  preparing,
  uploadingAssets,
  generatingPrompt,
  rendering,
 postProcessing,
 completed,
 failed,
 cancelled,
}

class GenerationProgress {
  final GenerationStage stage;
  final double progress;
  final String message;

  const GenerationProgress({
    required this.stage,
    required this.progress,
    required this.message,
  });
}

class GenerationResult {
  final bool success;
  final String? outputUrl;
  final String? thumbnailUrl;
  final String? error;

  const GenerationResult({
    required this.success,
    this.outputUrl,
    this.thumbnailUrl,
    this.error,
  });
}

class AIGenerationPipeline {
  bool _cancelled = false;

  final StreamController<GenerationProgress> _progressController =
      StreamController.broadcast();

  Stream<GenerationProgress> get progressStream =>
      _progressController.stream;

  void cancel() {
    _cancelled = true;

    _progressController.add(
      const GenerationProgress(
        stage: GenerationStage.cancelled,
        progress: 0,
        message: "Generation cancelled.",
      ),
    );
  }

  Future<GenerationResult> generate(
    ProjectModel project,
  ) async {
    _cancelled = false;

    try {
      await _emit(
        GenerationStage.validating,
        0.05,
        "Validating project...",
      );

      if (_cancelled) {
        return _cancelledResult();
      }

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      await _emit(
        GenerationStage.preparing,
        0.15,
        "Preparing generation pipeline...",
      );

      if (_cancelled) {
        return _cancelledResult();
      }

      await Future.delayed(
        const Duration(seconds: 1),
      );

      await _emit(
        GenerationStage.uploadingAssets,
        0.30,
        "Uploading assets...",
      );

      if (_cancelled) {
        return _cancelledResult();
      }

      await Future.delayed(
        const Duration(seconds: 1),
      );

      await _emit(
        GenerationStage.generatingPrompt,
        0.45,
        "Enhancing AI prompt...",
      );

      if (_cancelled) {
        return _cancelledResult();
      }

      await Future.delayed(
        const Duration(seconds: 2),
      );

      await _emit(
        GenerationStage.rendering,
        0.75,
        "Rendering AI content...",
      );

      if (_cancelled) {
        return _cancelledResult();
      }

      await Future.delayed(
        const Duration(seconds: 3),
      );

      await _emit(
        GenerationStage.postProcessing,
        0.95,
        "Applying finishing touches...",
      );

      if (_cancelled) {
        return _cancelledResult();
      }

      await Future.delayed(
        const Duration(seconds: 1),
      );

      await _emit(
        GenerationStage.completed,
        1.0,
        "Generation complete.",
      );

      return const GenerationResult(
        success: true,
        outputUrl:
            "https://elyon.ai/generated/video.mp4",
        thumbnailUrl:
            "https://elyon.ai/generated/thumb.jpg",
      );
    } catch (e) {
      _progressController.add(
        GenerationProgress(
          stage: GenerationStage.failed,
          progress: 0,
          message: e.toString(),
        ),
      );

      return GenerationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _emit(
    GenerationStage stage,
    double progress,
    String message,
  ) async {
    _progressController.add(
      GenerationProgress(
        stage: stage,
        progress: progress,
        message: message,
      ),
    );
  }

  GenerationResult _cancelledResult() {
    return const GenerationResult(
      success: false,
      error: "Generation cancelled.",
    );
  }

  void dispose() {
    _progressController.close();
  }
}