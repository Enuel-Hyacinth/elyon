import 'package:flutter/material.dart';

import '../controllers/studio_controller.dart';

class PreviewPanel extends StatelessWidget {
  final StudioController controller;

  const PreviewPanel({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          //--------------------------------------------------
          // HEADER
          //--------------------------------------------------

          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [

                const Icon(Icons.ondemand_video),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    "Live Preview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  tooltip: "Full Screen",
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Full-screen preview coming soon.",
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fullscreen),
                ),
              ],
            ),
          ),

          //--------------------------------------------------
          // PREVIEW AREA
          //--------------------------------------------------

          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: controller.previewVideo != null &&
              controller.previewVideo!.isNotEmpty

        //--------------------------------------------------
        // VIDEO READY
        //--------------------------------------------------
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 80,
                ),

                const SizedBox(height: 12),

                const Text(
                  "Video Ready",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  controller.previewVideo!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),

              ],
            ),
          )

        //--------------------------------------------------
        // THUMBNAIL
        //--------------------------------------------------
        : controller.previewImage != null &&
                controller.previewImage!.isNotEmpty

            ? Image.network(
                controller.previewImage!,
                fit: BoxFit.cover,
              )

            //--------------------------------------------------
            // PLACEHOLDER
            //--------------------------------------------------
            : const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 90,
                  color: Colors.grey,
                ),
              ),
  ),
),

          const SizedBox(height: 16),

                    //--------------------------------------------------
          // RENDER STATUS
          //--------------------------------------------------

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  controller.generating
                      ? Icons.autorenew
                      : Icons.check_circle,
                  color: controller.generating
                      ? Colors.orange
                      : Colors.green,
                ),

                const SizedBox(width: 10),

                Text(
                  controller.generating
                      ? "Rendering AI Preview..."
                      : "Preview Ready",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          //--------------------------------------------------
          // PROGRESS
          //--------------------------------------------------

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: controller.generating
                  ? (controller.progress == 0
                      ? null
                      : controller.progress)
                  : 1,
            ),
          ),

          const SizedBox(height: 20),

          //--------------------------------------------------
          // TIMELINE
          //--------------------------------------------------

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Timeline",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      "Timeline editor coming soon",
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //--------------------------------------------------
          // BEFORE / AFTER
          //--------------------------------------------------

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [

                Expanded(
                  child: Card(
                    child: SizedBox(
                      height: 120,
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: const [

                            Icon(Icons.description),

                            SizedBox(height: 8),

                            Text("Original Prompt"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Card(
                    child: SizedBox(
                      height: 120,
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: const [

                            Icon(Icons.auto_awesome),

                            SizedBox(height: 8),

                            Text("AI Output"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //--------------------------------------------------
          // FOOTER
          //--------------------------------------------------

          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Text(
              controller.generating
                  ? "Rendering animation..."
                  : "Ready for generation",
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}