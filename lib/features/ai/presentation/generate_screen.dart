import 'package:flutter/material.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> {
  final TextEditingController promptController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Animation"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
              style: TextStyle(color: Colors.grey),
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
              [
                "Pixar",
                "Anime",
                "Disney",
                "Ghibli",
                "Realistic",
                "3D Cartoon"
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
              [
                "15 Seconds",
                "30 Seconds",
                "60 Seconds",
                "2 Minutes",
                "5 Minutes"
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
              [
                "16:9",
                "9:16",
                "1:1",
                "4:5"
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
              [
                "English",
                "French",
                "Spanish",
                "Arabic",
                "None"
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
              [
                "HD",
                "Full HD",
                "2K",
                "4K"
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
                icon: const Icon(Icons.auto_awesome),
                label: const Text(
                  "Generate Animation",
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("AI generation coming soon..."),
                    ),
                  );
                },
              ),
            ),
          ],
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
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem(
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