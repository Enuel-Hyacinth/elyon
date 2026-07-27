import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../projects/models/project_model.dart';

import '../services/studio_service.dart';
import '../services/studio_autosave_service.dart';

import '../../../core/ai/ai_provider.dart';
import '../../../core/ai/ai_service.dart';
import '../../../core/ai/workflow_service.dart';

class StudioController extends ChangeNotifier {
  StudioController() {
    promptController.addListener(_onPromptChanged);
  }

  //--------------------------------------------------
  // SERVICES
  //--------------------------------------------------

  final AIService _ai =
      AIProvider.instance;

  final WorkflowService _workflow =
      WorkflowService();

  final StudioService _studioService =
      StudioService();

  final StudioAutoSaveService _autoSaveService =
      StudioAutoSaveService();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  //--------------------------------------------------
  // AUTH
  //--------------------------------------------------

  User? get currentUser =>
      _auth.currentUser;

  String? get currentUserId =>
      _auth.currentUser?.uid;

  //--------------------------------------------------
  // PROJECT
  //--------------------------------------------------

  ProjectModel? _project;

  ProjectModel? get project =>
      _project;

  //--------------------------------------------------
  // PROMPT
  //--------------------------------------------------

  final TextEditingController
      promptController =
          TextEditingController();

  //--------------------------------------------------
  // HISTORY
  //--------------------------------------------------

  final List<String> history = [];

  //--------------------------------------------------
  // PREVIEW
  //--------------------------------------------------

  String? previewImage;

  //--------------------------------------------------
  // GENERATION STATE
  //--------------------------------------------------

  bool _generating = false;

  bool get generating =>
      _generating;

  bool _busy = false;

  bool get busy =>
      _busy;

  double _progress = 0;

  double get progress =>
      _progress;

  //--------------------------------------------------
  // SAVE STATE
  //--------------------------------------------------

  bool autoSaved = true;

  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges =>
      _hasUnsavedChanges;

  //--------------------------------------------------
  // CREDITS
  //--------------------------------------------------

  int creditsRemaining = 250;

  static const int
      creditsRequired = 20;

  bool get hasCredits =>
      creditsRemaining >=
      creditsRequired;

  //--------------------------------------------------
  // STUDIO SETTINGS
  //--------------------------------------------------

  String _style = "Cinematic";

  String get style => _style;

  String _language = "English";

  String get language =>
      _language;

  String _voice = "Female";

  String get voice => _voice;

  String _resolution = "1080p";

  String get resolution =>
      _resolution;

  String _aspectRatio = "16:9";

  String get aspectRatio =>
      _aspectRatio;

  String _duration =
      "30 Seconds";

  String get duration =>
      _duration;

  //--------------------------------------------------
  // QUICK GETTERS
  //--------------------------------------------------

  bool get hasProject =>
      _project != null;

  bool get canGenerate =>
      !_generating &&
      promptController.text
          .trim()
          .isNotEmpty &&
      hasCredits;

  int get promptLength =>
      promptController.text.length;
  //--------------------------------------------------
  // LOAD PROJECT
  //--------------------------------------------------

  void loadProject(ProjectModel project) {
    _project = project;

    promptController.text =
        project.enhancedPrompt;

    _style = project.style;
    _language = project.language;
    _voice = project.voice;
    _resolution = project.resolution;
    _aspectRatio = project.aspectRatio;
    _duration = project.duration;

    _progress = project.progress;

    previewImage = project.thumbnail;

    autoSaved = true;
    _hasUnsavedChanges = false;

    notifyListeners();
  }

  //--------------------------------------------------
  // PROMPT CHANGED
  //--------------------------------------------------

  void _onPromptChanged() {
    _hasUnsavedChanges = true;
    autoSaved = false;

    notifyListeners();
  }

  //--------------------------------------------------
  // UPDATE PROMPT
  //--------------------------------------------------

  void updatePrompt(String value) {
    if (promptController.text == value) {
      return;
    }

    promptController.text = value;

    promptController.selection =
        TextSelection.fromPosition(
      TextPosition(
        offset: value.length,
      ),
    );

    history.add(value);

    markDirty();
  }

  //--------------------------------------------------
  // ENHANCE PROMPT
  //--------------------------------------------------

  Future<void> enhancePrompt() async {
    final prompt =
        promptController.text.trim();

    if (prompt.isEmpty) return;

    _setBusy(true);

    try {
      final enhanced =
          await _ai.enhancePrompt(prompt);

      promptController.text = enhanced;

      promptController.selection =
          TextSelection.fromPosition(
        TextPosition(
          offset: enhanced.length,
        ),
      );

      history.add(enhanced);

      markDirty();
    } catch (e) {
      debugPrint(
        "Prompt enhancement failed: $e",
      );
    } finally {
      _setBusy(false);
    }
  }

  //--------------------------------------------------
  // SETTINGS
  //--------------------------------------------------

  void setStyle(String value) {
    if (_style == value) return;

    _style = value;
    markDirty();
  }

  void setLanguage(String value) {
    if (_language == value) return;

    _language = value;
    markDirty();
  }

  void setVoice(String value) {
    if (_voice == value) return;

    _voice = value;
    markDirty();
  }

  void setResolution(String value) {
    if (_resolution == value) return;

    _resolution = value;
    markDirty();
  }

  void setAspectRatio(String value) {
    if (_aspectRatio == value) return;

    _aspectRatio = value;
    markDirty();
  }

  void setDuration(String value) {
    if (_duration == value) return;

    _duration = value;
    markDirty();
  }

  //--------------------------------------------------
  // DIRTY STATE
  //--------------------------------------------------

  void markDirty() {
    _hasUnsavedChanges = true;
    autoSaved = false;

    _autoSaveService.scheduleAutoSave(
      save: saveProject,
    );

    notifyListeners();
  }

  //--------------------------------------------------
  // SAVE PROJECT
  //--------------------------------------------------

  Future<void> saveProject() async {
    if (_project == null) return;

    if (!_hasUnsavedChanges) return;

    try {
      await _studioService.saveProject(
        _project!,
      );

      autoSaved = true;
      _hasUnsavedChanges = false;

      notifyListeners();
    } catch (e) {
      debugPrint(
        "Save failed: $e",
      );
    }
  }

  //--------------------------------------------------
  // BUSY STATE
  //--------------------------------------------------

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }
  //--------------------------------------------------
  // GENERATE PROJECT
  //--------------------------------------------------

  Future<void> generateProject(
    BuildContext context,
  ) async {
    final prompt = promptController.text.trim();

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a prompt."),
        ),
      );
      return;
    }

    if (!hasCredits) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Insufficient credits."),
        ),
      );
      return;
    }

    _isGenerating = true;
    _progress = 0;
    notifyListeners();

    try {
      final project = await _workflow.runWorkflow(
        prompt: prompt,
        style: _style,
        language: _language,
        voice: _voice,
        resolution: _resolution,
        aspectRatio: _aspectRatio,
        duration: _duration,
      );

      _currentProject = project;

      _listenToProgress(project.id);
      _listenToProject(project.id);

      useCredit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Generation started successfully.",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  //--------------------------------------------------
  // LISTEN TO PROJECT
  //--------------------------------------------------

  void _listenToProject(
    String projectId,
  ) {
    _workflow
        .streamProject(projectId)
        .listen((project) {
      if (project == null) return;

      _currentProject = project;
      notifyListeners();
    });
  }

  //--------------------------------------------------
  // LISTEN TO PROGRESS
  //--------------------------------------------------

  void _listenToProgress(
    String projectId,
  ) {
    _workflow
        .renderProgress(projectId)
        .listen((value) {
      _progress = value;
      notifyListeners();
    });
  }

  //--------------------------------------------------
  // CREDIT ENGINE
  //--------------------------------------------------

  void useCredit() {
    if (creditsRemaining >= creditsRequired) {
      creditsRemaining -= creditsRequired;
      notifyListeners();
    }
  }

  //--------------------------------------------------
  // UPDATE PROGRESS
  //--------------------------------------------------

  void updateProgress(
    double value,
  ) {
    _progress = value;
    notifyListeners();
  }

  //--------------------------------------------------
  // CANCEL GENERATION
  //--------------------------------------------------

  void cancelGeneration() {
    _isGenerating = false;
    _progress = 0;
    notifyListeners();
  }

  //--------------------------------------------------
  // CLEAR PROMPT
  //--------------------------------------------------

  void clearPrompt() {
    promptController.clear();
    history.clear();
    markDirty();
  }
  //--------------------------------------------------
  // LOAD PROJECT
  //--------------------------------------------------

  void loadProject(ProjectModel project) {
    _currentProject = project;

    promptController.text = project.enhancedPrompt;

    _style = project.style;
    _language = project.language;
    _voice = project.voice;
    _resolution = project.resolution;
    _aspectRatio = project.aspectRatio;
    _duration = project.duration;

    _progress = project.progress;

    notifyListeners();
  }

  //--------------------------------------------------
  // CLEAR PROMPT
  //--------------------------------------------------

  void clearPrompt() {
    promptController.clear();
    notifyListeners();
  }

  //--------------------------------------------------
  // RESET STUDIO
  //--------------------------------------------------

  void reset() {
    _currentProject = null;

    promptController.clear();

    previewImage = null;

    history.clear();

    _progress = 0;

    _isGenerating = false;

    _busy = false;

    _style = "Cinematic";
    _language = "English";
    _voice = "Female";
    _resolution = "1080p";
    _aspectRatio = "16:9";
    _duration = "30 Seconds";

    notifyListeners();
  }

  //--------------------------------------------------
  // PROJECT STREAM
  //--------------------------------------------------

  Stream<ProjectModel?> streamCurrentProject() {
    if (_currentProject == null) {
      return const Stream.empty();
    }

    return _workflow.streamProject(
      _currentProject!.id,
    );
  }

  //--------------------------------------------------
  // SAVE PROJECT
  //--------------------------------------------------

  Future<void> saveProject() async {
    if (_currentProject == null) return;

    await _studioService.saveProject(
      _currentProject!,
    );
  }

  //--------------------------------------------------
  // DISPOSE
  //--------------------------------------------------

  @override
  void dispose() {
    promptController.removeListener(
      _onPromptChanged,
    );

    promptController.dispose();

    _autoSaveService.dispose();

    super.dispose();
  }
}