import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

// Project Services
import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';
import '../../projects/presentation/project_library_screen.dart';

// Core AI
import '../../../core/ai/intent_service.dart';
import '../../../core/ai/prompt_enhancer.dart';
import '../../../core/ai/studio_router.dart';
import '../../../core/ai/suggestion_service.dart';

// AI Director Widgets
import '../widgets/director_avatar.dart';
import '../widgets/director_message.dart';
import '../widgets/orion_thinking_dialog.dart';

// Shared Widgets
import '../../../shared/widgets/prompt_input.dart';
import '../../../shared/widgets/quick_action_chip.dart';

class AIDirectorScreen extends StatefulWidget {
  const AIDirectorScreen({super.key});

  @override
  State<AIDirectorScreen> createState() =>
      _AIDirectorScreenState();
}

class _AIDirectorScreenState
    extends State<AIDirectorScreen> {

  //------------------------------------------------------
  // SERVICES
  //------------------------------------------------------

  final ProjectService _projectService =
      ProjectService();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final Uuid _uuid = const Uuid();

  //------------------------------------------------------
  // CONTROLLERS
  //------------------------------------------------------

  final TextEditingController promptController =
      TextEditingController();

  //------------------------------------------------------
  // STATE
  //------------------------------------------------------

  bool isLoading = false;

  List<String> suggestions = [];

  //------------------------------------------------------
  // LIFECYCLE
  //------------------------------------------------------

  @override
  void initState() {
    super.initState();

    promptController.addListener(_updateSuggestions);
  }

  void _updateSuggestions() {
    setState(() {
      suggestions =
          SuggestionService.getSuggestions(
        promptController.text,
      );
    });
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  // Helper method
  void fillPrompt(String prompt) {
    promptController.text = prompt;
    promptController.selection = TextSelection.fromPosition(
      TextPosition(offset: prompt.length),
    );
  }

  // Main business logic
  Future<void> sendPrompt() async {

    // prevent multiple button taps while Orion is processing
    if (isLoading) return;

  final prompt = promptController.text.trim();

  if (prompt.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please enter a prompt."),
      ),
    );
    return;
  }

  final user = _auth.currentUser;

  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Please log in first."),
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  FocusScope.of(context).unfocus();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const OrionThinkingDialog(),
  );

  try {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    final enhancedPrompt =
        PromptEnhancer.enhance(prompt);

    final intent =
        IntentService.detectIntent(
      enhancedPrompt,
    );

    final project = ProjectModel(
      id: _uuid.v4(),

      userId: user.uid,

      title: prompt.length > 40
          ? "${prompt.substring(0, 40)}..."
          : prompt,

      prompt: prompt,

      enhancedPrompt: enhancedPrompt,

      intent: intent.name,

      status: "created",

      creditsUsed: 5,

      thumbnail: "",

      runwayJobId: "",

      style: "Pixar",

      language: "English",

      voice: "Default",

      aspectRatio: "16:9",

      resolution: "1080p",

      duration: "30 Seconds",

      progress: 0,

      createdAt: DateTime.now(),

      lastModified: DateTime.now(),
    );

    await _projectService.saveProject(project);

    debugPrint(
      "Project '${project.title}' saved successfully.",
    );

    if (!mounted) return;

    Navigator.pop(context);

    StudioRouter.openStudio(
      context,
      intent,
    );
  } catch (e) {
    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    }

    debugPrint(e.toString());
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Orion"),
      centerTitle: true,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //---------------------------------------
            // ORION
            //---------------------------------------

            const Center(
              child: DirectorAvatar(),
            ),

            const SizedBox(height: 28),

            const Center(
              child: DirectorMessage(
                userName: "Enuel",
              ),
            ),

            const SizedBox(height: 36),

            //---------------------------------------
            // POPULAR IDEAS
            //---------------------------------------

            const Text(
              "? Popular Ideas",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [

                  QuickActionChip(
                    icon: Icons.movie_creation_outlined,
                    label: "Pixar Animation",
                    onTap: () => fillPrompt(
                      "Create a 30-second Pixar-style animation about friendship.",
                    ),
                  ),

                  QuickActionChip(
                    icon: Icons.auto_stories,
                    label: "Story Movie",
                    onTap: () => fillPrompt(
                      "Turn my story into a cinematic animated movie.",
                    ),
                  ),

                  QuickActionChip(
                    icon: Icons.restaurant,
                    label: "Restaurant Advert",
                    onTap: () => fillPrompt(
                      "Create a modern restaurant advertisement.",
                    ),
                  ),

                  QuickActionChip(
                    icon: Icons.school,
                    label: "Science Lesson",
                    onTap: () => fillPrompt(
                      "Create an educational science lesson animation.",
                    ),
                  ),

                  QuickActionChip(
                    icon: Icons.music_note,
                    label: "Music Video",
                    onTap: () => fillPrompt(
                      "Create an animated music video.",
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 32),

            //---------------------------------------
            // PROMPT
            //---------------------------------------

            const Text(
              "Describe your idea",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

              PromptInput(
  controller: promptController,
  onSend: sendPrompt,
  onVoice: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "? Voice Assistant coming soon!",
        ),
      ),
    );
  },
),

const SizedBox(height: 24),

//---------------------------------------
// SMART SUGGESTIONS
//---------------------------------------

if (suggestions.isNotEmpty) ...[

  const Text(
    "? Orion Suggestions",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 14),

  ...suggestions.map(
    (suggestion) => Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Card(
        elevation: 0,
        color: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: ListTile(
          leading: const Icon(
            Icons.auto_awesome,
            color: Color(0xFF6C63FF),
          ),
          title: Text(
            suggestion,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.white54,
          ),
          onTap: () {
            fillPrompt(suggestion);
          },
        ),
      ),
    ),
  ),

  const SizedBox(height: 30),
],

  //---------------------------------------
// DASHBOARD ACTIONS
//---------------------------------------

const SizedBox(height: 20),

const Divider(),

const SizedBox(height: 20),

const Text(
  "Quick Access",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 20),

Row(
  children: [

    Expanded(
      child: FilledButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProjectLibraryScreen(),
            ),
          );         
        },
        icon: const Icon(Icons.folder_copy_outlined),
        label: const Text("Projects"),
      ),
    ),

    const SizedBox(width: 12),

    Expanded(
      child: FilledButton.icon(
        onPressed: () {

          // TODO:
          // Open Credits Screen

        },
        icon: const Icon(Icons.stars_outlined),
        label: const Text("Credits"),
      ),
    ),

  ],
),

const SizedBox(height: 14),

SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () {

      // TODO:
      // Open Settings

    },
    icon: const Icon(Icons.settings_outlined),
    label: const Text("Settings"),
  ),
),

const SizedBox(height: 40),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(.05),
    borderRadius: BorderRadius.circular(18),
  ),
  child: Column(
    children: const [

      Icon(
        Icons.auto_awesome,
        size: 40,
        color: Color(0xFF6C63FF),
      ),

      SizedBox(height: 14),

      Text(
        "Powered by Orion AI",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),

      SizedBox(height: 8),

      Text(
        "Your Creative Director for storytelling, animation, marketing and education.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey,
          height: 1.5,
        ),
      ),

    ],
  ),
),

const SizedBox(height: 50),

Center(
  child: Text(
    "eLyon Studio v1.0",
    style: TextStyle(
      color: Colors.grey.shade600,
      fontSize: 13,
    ),
  ),
),

const SizedBox(height: 20),

          ],
        ),
      ),
    ),
  );
}
}