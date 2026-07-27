class PromptEnhancer {
  static String enhance(String prompt) {
    final text = prompt.trim();

    if (text.isEmpty) return "";

    return """
Create a high-quality AI-generated project based on the following idea:

$text

Requirements:

? Cinematic quality
? Professional storytelling
? High-resolution visuals
? Beautiful lighting
? Smooth camera movement
? Detailed environment
? Emotionally engaging
? Modern artistic style
? Suitable for social media

Generate the best possible creative result.
""";
  }
}