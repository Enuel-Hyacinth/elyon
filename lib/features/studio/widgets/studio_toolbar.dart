import 'package:flutter/material.dart';

import '../controllers/studio_controller.dart';

class StudioToolbar extends StatelessWidget {
  final StudioController controller;

  const StudioToolbar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        child: Row(
          children: [
            _buildProjectSection(),

            const SizedBox(width: 24),

            _buildAutoSaveIndicator(),

            const Spacer(),

            _buildCreditsChip(),

            const SizedBox(width: 20),

            _buildToolbarActions(context),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------
  // PROJECT NAME
  //--------------------------------------------------

  Widget _buildProjectSection() {
    return Expanded(
      flex: 3,
      child: TextField(
        controller: TextEditingController(
          text: controller.project?.title ?? "Untitled Project",
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Project Name",
        ),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        onSubmitted: (value) {
          if (controller.project != null) {
            controller.project =
                controller.project!.copyWith(title: value);
            controller.markDirty();
          }
        },
      ),
    );
  }

  //--------------------------------------------------
  // AUTO SAVE
  //--------------------------------------------------

  Widget _buildAutoSaveIndicator() {
    final saved = controller.autoSaved;

    return Row(
      children: [
        Icon(
          saved ? Icons.cloud_done : Icons.cloud_upload,
          color: saved ? Colors.green : Colors.orange,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          saved ? "Saved" : "Saving...",
          style: TextStyle(
            color: saved ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  //--------------------------------------------------
  // CREDITS
  //--------------------------------------------------

  Widget _buildCreditsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.stars,
            color: Colors.amber,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            "${controller.creditsRemaining} Credits",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  // ACTIONS
  //--------------------------------------------------

  Widget _buildToolbarActions(BuildContext context) {
    return Row(
      children: [
                _actionButton(
          tooltip: "Undo",
          icon: Icons.undo,
          onPressed: () {
            // TODO: Undo
          },
        ),

        _actionButton(
          tooltip: "Redo",
          icon: Icons.redo,
          onPressed: () {
            // TODO: Redo
          },
        ),

        _actionButton(
          tooltip: "AI Assist",
          icon: Icons.auto_awesome,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("AI Assist coming soon"),
              ),
            );
          },
        ),

        _actionButton(
          tooltip: "History",
          icon: Icons.history,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "${controller.history.length} history item(s)",
                ),
              ),
            );
          },
        ),

        _actionButton(
          tooltip: "Export",
          icon: Icons.download,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Export started"),
              ),
            );
          },
        ),

        _actionButton(
          tooltip: "Settings",
          icon: Icons.settings,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Studio settings"),
              ),
            );
          },
        ),
      ],
    );
  }

  //--------------------------------------------------
  // TOOLBAR BUTTON
  //--------------------------------------------------

  Widget _actionButton({
    required String tooltip,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          icon: Icon(icon),
          splashRadius: 22,
          onPressed: onPressed,
        ),
      ),
    );
  }
}