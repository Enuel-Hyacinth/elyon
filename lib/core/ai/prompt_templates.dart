class PromptTemplates {
  static String build({
    required String prompt,
    required String style,
    required String intent,
    required String language,
    required String voice,
    required String ratio,
    required String duration,
  }) {
    return """
Create a $duration $intent video.

Visual Style:
$style

Language:
$language

Voice:
$voice

Aspect Ratio:
$ratio

Prompt:
$prompt

Generate cinematic scenes with detailed lighting, camera movement, character consistency, realistic emotions, and smooth transitions.
""";
  }
}