import 'package:flutter/material.dart';

class PromptWorkspace extends StatelessWidget {
  final TextEditingController controller;
  final bool isGenerating;
  final ValueChanged<String>? onChanged;

  const PromptWorkspace({
    super.key,
    required this.controller,
    required this.isGenerating,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "AI Prompt Workspace",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Describe your animation in as much detail as possible.",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              enabled: !isGenerating,
              maxLines: 12,
              minLines: 10,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText:
                    "Example:\n\nCreate a cinematic drone shot of a futuristic Lagos skyline at sunset with flying vehicles and warm lighting...",

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide:
                      const BorderSide(
                    color: Colors.indigo,
                    width: 2,
                  ),
                ),

                contentPadding:
                    const EdgeInsets.all(20),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [

                Icon(
                  Icons.tips_and_updates,
                  color: Colors.amber.shade700,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    "Better prompts produce better videos.",
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}