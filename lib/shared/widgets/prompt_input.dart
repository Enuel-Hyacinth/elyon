import 'package:flutter/material.dart';

class PromptInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onVoice;

  const PromptInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            maxLines: 5,
            minLines: 3,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText:
                  "Describe your idea...\n\nExample:\nCreate a 30-second Pixar-style animation about a brave lion saving his village.",
              hintStyle: TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),

          const Divider(),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Attachment feature coming soon.",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.attach_file),
                tooltip: "Attach",
              ),

              IconButton(
                onPressed: onVoice,
                icon: const Icon(Icons.mic),
                tooltip: "Voice",
              ),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: onSend,
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Create"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}