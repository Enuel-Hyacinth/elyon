import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/studio_controller.dart';

class PromptEditor extends StatelessWidget {
  final StudioController controller;

  const PromptEditor({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final int characters =
        controller.promptController.text.length;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //--------------------------------------------------
            // TITLE
            //--------------------------------------------------

            Row(
              children: [

                const Icon(Icons.edit_note),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "AI Prompt",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Text(
                  "$characters characters",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 18),

            //--------------------------------------------------
            // PROMPT FIELD
            //--------------------------------------------------

            TextField(
              controller: controller.promptController,
              minLines: 8,
              maxLines: 12,
              decoration: InputDecoration(
                hintText:
                    "Describe the animation you want AI to generate...",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) {
                controller.updatePrompt(value);
              },
            ),

            const SizedBox(height: 18),

            //--------------------------------------------------
            // ACTIONS
            //--------------------------------------------------

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [

                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          "AI Prompt Enhancement coming soon.",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Enhance"),
                ),

                OutlinedButton.icon(
                  onPressed: () {
                    controller.promptController.clear();
                    controller.updatePrompt("");
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Clear"),
                ),
                                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: controller.promptController.text,
                      ),
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Prompt copied to clipboard.",
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_all_outlined),
                  label: const Text("Copy"),
                ),

                OutlinedButton.icon(
                  onPressed: () {
                    controller.markDirty();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Draft marked for auto-save.",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Save Draft"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            //--------------------------------------------------
            // PROMPT TIPS
            //--------------------------------------------------

            Card(
              elevation: 0,
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Tip: Describe the subject, environment, camera movement, lighting, animation style, mood and duration for better AI results.",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            //--------------------------------------------------
            // AUTO SAVE STATUS
            //--------------------------------------------------

            Row(
              children: [
                Icon(
                  controller.autoSaved
                      ? Icons.cloud_done
                      : Icons.cloud_upload,
                  color: controller.autoSaved
                      ? Colors.green
                      : Colors.orange,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Text(
                  controller.autoSaved
                      ? "All changes saved"
                      : "Waiting for auto-save...",
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}