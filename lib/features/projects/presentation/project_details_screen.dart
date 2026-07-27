import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ai/ai_intent.dart';
import '../../../core/ai/studio_router.dart';

import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState
    extends State<ProjectDetailsScreen> {

  final ProjectService _projectService =
      ProjectService();

  final Uuid _uuid = const Uuid();

  AIIntent _getIntent() {
    switch (widget.project.intent) {
      case "animation":
        return AIIntent.animation;

      case "story":
        return AIIntent.story;

      case "marketing":
        return AIIntent.marketing;

      case "education":
        return AIIntent.education;

      case "music":
        return AIIntent.music;

      default:
        return AIIntent.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Project Details"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //---------------------------------
            // TITLE
            //---------------------------------

            Text(
              widget.project.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Chip(
              label: Text(
                widget.project.intent.toUpperCase(),
              ),
            ),

            const SizedBox(height: 25),

            //---------------------------------
            // STATUS
            //---------------------------------

            _buildInfoTile(
              "Status",
              widget.project.status,
            ),

            _buildInfoTile(
              "Credits Used",
              widget.project.creditsUsed.toString(),
            ),

            _buildInfoTile(
              "Style",
              widget.project.style,
            ),

            _buildInfoTile(
              "Language",
              widget.project.language,
            ),

            _buildInfoTile(
              "Voice",
              widget.project.voice,
            ),

            _buildInfoTile(
              "Resolution",
              widget.project.resolution,
            ),

            _buildInfoTile(
              "Aspect Ratio",
              widget.project.aspectRatio,
            ),

            _buildInfoTile(
              "Duration",
              "${widget.project.duration} sec",
            ),

            const SizedBox(height: 30),

            //---------------------------------
            // PROGRESS
            //---------------------------------

            const Text(
              "Progress",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: widget.project.progress / 100,
              minHeight: 8,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(height: 30),

            //---------------------------------
            // ORIGINAL PROMPT
            //---------------------------------

            const Text(
              "Original Prompt",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.project.prompt,
                ),
              ),
            ),

            const SizedBox(height: 25),

            //---------------------------------
            // ENHANCED PROMPT
            //---------------------------------

            const Text(
              "Enhanced Prompt",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.project.enhancedPrompt,
                ),
              ),
            ),

            const SizedBox(height: 30),

            //---------------------------------
            // DATES
            //---------------------------------

            _buildInfoTile(
              "Created",
              widget.project.createdAt.toString(),
            ),

            _buildInfoTile(
              "Last Modified",
              widget.project.lastModified.toString(),
            ),

            const SizedBox(height: 40),

            //---------------------------------
            // BUTTONS
            //---------------------------------

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text("Continue Editing"),
                onPressed: () {
                  StudioRouter.openStudio(
                    context,
                    _getIntent(),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text(
                  "Duplicate Project",
                ),
                onPressed: () async {

                  final copiedProject = ProjectModel(
                    id: _uuid.v4(),

                    userId: widget.project.userId,

                    title:
                        "${widget.project.title} (Copy)",

                    prompt: widget.project.prompt,

                    enhancedPrompt:
                        widget.project.enhancedPrompt,

                    intent: widget.project.intent,

                    status: "created",

                    creditsUsed:
                        widget.project.creditsUsed,

                    thumbnail:
                        widget.project.thumbnail,

                    style:
                        widget.project.style,

                    language:
                        widget.project.language,

                    voice:
                        widget.project.voice,

                    aspectRatio:
                        widget.project.aspectRatio,

                    resolution:
                        widget.project.resolution,

                    duration:
                        widget.project.duration,

                    progress: 0,

                    createdAt: DateTime.now(),

                    lastModified: DateTime.now(),
                  );

                  await _projectService.saveProject(
                    copiedProject,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Project duplicated successfully.",
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text(
                  "Delete Project",
                ),
                onPressed: () async {

                  final confirm =
                      await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text(
                        "Delete Project",
                      ),
                      content: const Text(
                        "Are you sure you want to delete this project?",
                      ),
                      actions: [

                        TextButton(
                          onPressed: () =>
                              Navigator.pop(
                            context,
                            false,
                          ),
                          child: const Text(
                            "Cancel",
                          ),
                        ),

                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(
                            context,
                            true,
                          ),
                          child: const Text(
                            "Delete",
                          ),
                        ),

                      ],
                    ),
                  );

                  if (confirm != true) return;

                  await _projectService.deleteProject(
                    widget.project.id,
                  );

                  if (!mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Project deleted successfully.",
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [

          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(value),
          ),

        ],
      ),
    );
  }
}