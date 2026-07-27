import 'package:flutter/material.dart';

class AIPromptActions extends StatelessWidget {
  final bool isGenerating;

  final VoidCallback onEnhance;

  final VoidCallback onClear;

  final VoidCallback onGenerate;

  const AIPromptActions({
    super.key,
    required this.isGenerating,
    required this.onEnhance,
    required this.onClear,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [

        FilledButton.icon(
          onPressed:
              isGenerating
                  ? null
                  : onEnhance,

          icon: const Icon(
            Icons.auto_fix_high,
          ),

          label: const Text(
            "Enhance Prompt with AI",
          ),
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed:
              isGenerating
                  ? null
                  : onClear,

          icon: const Icon(
            Icons.delete_outline,
          ),

          label: const Text(
            "Clear Prompt",
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 54,

          child: FilledButton.icon(
            onPressed:
                isGenerating
                    ? null
                    : onGenerate,

            icon: isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.movie_creation,
                  ),

            label: Text(
              isGenerating
                  ? "Generating..."
                  : "Generate Project",
            ),
          ),
        ),
      ],
    );
  }
}