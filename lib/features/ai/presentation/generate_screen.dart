import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';

import '../../../core/ai/models/prompt_request.dart';
import '../../../core/ai/prompt_engine.dart';

import '../services/ai_generation_service.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController promptController =
      TextEditingController();

  final ProjectService projectService =
      ProjectService();

  final AIGenerationService aiService =
      AIGenerationService();

  final uuid = const Uuid();

  bool isGenerating = false;

  String animationStyle = "Pixar";
  String duration = "30 Seconds";
  String aspectRatio = "16:9";
  String voice = "English";
  String quality = "HD";

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  Future<void> generateAnimation() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login first."),
        ),
      );
      return;
    }

    if (promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a prompt."),
        ),
      );
      return;
    }

    setState(() {
      isGenerating = true;
    });

    try {
      final request = PromptRequest(
        prompt: promptController.text.trim(),
        style: animationStyle,
        intent: "Animation",
        language: "English",
        voice: voice,
        aspectRatio: aspectRatio,
        duration: duration,
      );

      final enhancedPrompt = PromptEngine.generate(request);

      final project = ProjectModel(
        id: uuid.v4(),
        userId: user.uid,

        title: promptController.text.length > 40
            ? "${promptController.text.substring(0, 40)}..."
            : promptController.text,

        prompt: promptController.text.trim(),

        enhancedPrompt: enhancedPrompt,

        intent: "Animation",

        status: "Generating",

        creditsUsed: 1,

        thumbnail: "",

        runwayJobId: "",

        style: animationStyle,

        language: "English",

        voice: voice,

        aspectRatio: aspectRatio,

        resolution: quality,

        duration: request.duration,

        progress: 0,

        createdAt: DateTime.now(),

        lastModified: DateTime.now(),
      );

      await projectService.saveProject(project);

      await aiService.generateAnimation(
        prompt: enhancedPrompt,
        style: animationStyle,
        duration: duration,
        aspectRatio: aspectRatio,
        voice: voice,
        quality: quality,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Project saved successfully."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Animation"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "What would you like to create today?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Describe your animation in as much detail as possible.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 25),

              TextField(
                controller: promptController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText:
                      "Example:\nA young lion walking through a futuristic city at sunset with cinematic lighting.",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 25),
              buildDropdown(
                "Animation Style",
                animationStyle,
                const [
                  "Pixar",
                  "Anime",
                  "Disney",
                  "Ghibli",
                  "Realistic",
                  "3D Cartoon",
                ],
                (value) {
                  setState(() {
                    animationStyle = value!;
                  });
                },
              ),

              buildDropdown(
                "Duration",
                duration,
                const [
                  "15 Seconds",
                  "30 Seconds",
                  "60 Seconds",
                  "2 Minutes",
                  "5 Minutes",
                ],
                (value) {
                  setState(() {
                    duration = value!;
                  });
                },
              ),

              buildDropdown(
                "Aspect Ratio",
                aspectRatio,
                const [
                  "16:9",
                  "9:16",
                  "1:1",
                  "4:5",
                ],
                (value) {
                  setState(() {
                    aspectRatio = value!;
                  });
                },
              ),

              buildDropdown(
                "Voice",
                voice,
                const [
                  "English",
                  "French",
                  "Spanish",
                  "Arabic",
                  "None",
                ],
                (value) {
                  setState(() {
                    voice = value!;
                  });
                },
              ),

              buildDropdown(
                "Quality",
                quality,
                const [
                  "HD",
                  "Full HD",
                  "2K",
                  "4K",
                ],
                (value) {
                  setState(() {
                    quality = value!;
                  });
                },
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isGenerating
                      ? null
                      : generateAnimation,
                  icon: isGenerating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    isGenerating
                        ? "Generating..."
                        : "Generate Animation",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildDropdown(
    String title,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}