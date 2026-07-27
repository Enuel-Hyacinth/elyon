class PromptRequest {
  final String prompt;
  final String style;
  final String intent;
  final String language;
  final String voice;
  final String aspectRatio;
  final String duration;

  const PromptRequest({
    required this.prompt,
    required this.style,
    required this.intent,
    required this.language,
    required this.voice,
    required this.aspectRatio,
    required this.duration,
  });
}