import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/studio_controller.dart';

import '../widgets/prompt_workspace.dart';
import '../widgets/prompt_character_counter.dart';
import '../widgets/ai_prompt_actions.dart';

import '../../dashboard/widgets/continue_project_card.dart';



class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() =>
      _StudioScreenState();
}

class _StudioScreenState
    extends State<StudioScreen> {

  late final StudioController controller;

  @override
  void initState() {
    super.initState();

    controller = StudioController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
final screenWidth =
    MediaQuery.of(context).size.width;

final isWideScreen = screenWidth >= 900;

final horizontalPadding =
    isWideScreen ? 80.0 : 20.0;

    return ChangeNotifierProvider.value(
      value: controller,
      child: Consumer<StudioController>(
        builder: (context, controller, child) {
          return Scaffold(
  backgroundColor:
      Theme.of(context).colorScheme.surface,

  floatingActionButton: FloatingActionButton.extended(
    onPressed: controller.canGenerate
        ? () => controller.generateProject(context)
        : null,
    icon: const Icon(Icons.auto_awesome),
    label: const Text("Quick Generate"),
  ),

  body: GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus();
    },

    child: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
//--------------------------------------------------
// STUDIO HEADER
//--------------------------------------------------

Row(
  children: [

    Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Text(
            "AI Studio",
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 6),

          Text(
            "Create AI-powered animations with eLyon",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),

    if (controller.isGenerating)
      const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
        ),
      ),
  ],
),

const SizedBox(height: 24),
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.all(18),
    child: Row(
      children: [

        const CircleAvatar(
          radius: 24,
          child: Icon(Icons.bolt),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              Text(
                "${controller.creditsRemaining} Credits",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                controller.autoSaved
                    ? "All changes saved"
                    : "Saving...",
                style: TextStyle(
                  color: controller.autoSaved
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        FilledButton.icon(
          onPressed: controller.reset,
          icon: const Icon(Icons.add),
          label: const Text("New"),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 28),
//--------------------------------------------------
// PROMPT WORKSPACE
//--------------------------------------------------

PromptWorkspace(
  controller: controller.promptController,
  isGenerating: controller.isGenerating,
  onChanged: controller.updatePrompt,
),

const SizedBox(height: 12),
PromptCharacterCounter(
  currentLength: controller.promptLength,
  maxLength: 2000,
),

const SizedBox(height: 28),
//--------------------------------------------------
// AI PROMPT ACTIONS
//--------------------------------------------------

AIPromptActions(
  isGenerating: controller.isGenerating,

  onEnhance: controller.enhancePrompt,

  onClear: controller.clearPrompt,

  onGenerate: () {
    controller.generateProject(
      context,
    );
  },
),

//--------------------------------------------------
// GENERATE MOVIE
//--------------------------------------------------

SizedBox(
  width: double.infinity,
  child: FilledButton.icon(
    onPressed: controller.canGenerate
        ? () => controller.generateProject(
              context,
            )
        : null,

    icon: controller.isGenerating
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(
            Icons.movie_creation_outlined,
          ),

    label: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Text(
        controller.isGenerating
            ? "Generating..."
            : "Generate Movie",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
),

const SizedBox(height: 30),
//--------------------------------------------------
// CONTINUE PROJECT
//--------------------------------------------------

if (controller.hasProject)
  ContinueProjectCard(
    project: controller.currentProject,

    onContinue: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Opening Studio Timeline...",
          ),
        ),
      );

      // Future:
      // Navigator.pushNamed(
      //   context,
      //   "/studio-timeline",
      // );
    },

    onCreate: () {
      controller.reset();
    },
  )
else
  Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [

          const Icon(
            Icons.movie_creation_outlined,
            size: 48,
          ),

          const SizedBox(height: 16),

          const Text(
            "No Active Project",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Generate your first AI animation to begin.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: controller.canGenerate
                ? () => controller.generateProject(
                      context,
                    )
                : null,

            icon: const Icon(Icons.auto_awesome),

            label: const Text(
              "Create First Project",
            ),
          ),
        ],
      ),
    ),
  ),

const SizedBox(height: 30),
//--------------------------------------------------
// LIVE RENDERING
//--------------------------------------------------

if (controller.isGenerating)
  Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              const Icon(
                Icons.auto_awesome,
                color: Colors.deepPurple,
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  "AI Rendering",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),

              Text(
                "${(controller.progress * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(12),

            child: LinearProgressIndicator(
              value: controller.progress,
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [

              const Icon(
                Icons.movie_creation_outlined,
                size: 18,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  controller.progress < 0.30
                      ? "Analyzing prompt..."
                      : controller.progress < 0.60
                          ? "Creating storyboard..."
                          : controller.progress < 0.90
                              ? "Rendering animation..."
                              : "Finalizing project...",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(
            "Estimated time remaining: 30–60 seconds",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  ),

const SizedBox(height: 30),
//--------------------------------------------------
// GENERATED OUTPUT
//--------------------------------------------------

const Text(
  "Generated Output",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 18),
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  clipBehavior: Clip.antiAlias,
  child: Column(
    children: [
      Container(
        height: 240,
        width: double.infinity,

        decoration: BoxDecoration(
          color: Colors.grey.shade200,
        ),

        child: controller.previewImage != null
            ? Image.network(
                controller.previewImage!,
                fit: BoxFit.cover,
              )
            : Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: const [

                  Icon(
                    Icons.movie_creation_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 16),

                  Text(
                    "No preview available yet",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
      Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [

            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    controller.hasProject
                        ? () {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Download coming soon.",
                                ),
                              ),
                            );

                          }
                        : null,

                icon: const Icon(
                  Icons.download,
                ),

                label: const Text(
                  "Download",
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: FilledButton.icon(
                onPressed:
                    controller.hasProject
                        ? () {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Share feature coming soon.",
                                ),
                              ),
                            );

                          }
                        : null,

                icon: const Icon(
                  Icons.share,
                ),

                label: const Text(
                  "Share",
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}