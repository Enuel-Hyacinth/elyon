class GenerationRequest {
  final String prompt;
  final String style;
  final String duration;
  final String aspectRatio;
  final String voice;
  final String quality;

  const GenerationRequest({
    required this.prompt,
    required this.style,
    required this.duration,
    required this.aspectRatio,
    required this.voice,
    required this.quality,
  });
}