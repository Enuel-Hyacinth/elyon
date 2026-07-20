class ProjectModel {
  final String uid;
  final String prompt;
  final String style;
  final String duration;
  final String aspectRatio;
  final String voice;
  final String quality;
  final String status;
  final String videoUrl;

  const ProjectModel({
    required this.uid,
    required this.prompt,
    required this.style,
    required this.duration,
    required this.aspectRatio,
    required this.voice,
    required this.quality,
    required this.status,
    required this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "prompt": prompt,
      "style": style,
      "duration": duration,
      "aspectRatio": aspectRatio,
      "voice": voice,
      "quality": quality,
      "status": status,
      "videoUrl": videoUrl,
      "createdAt": DateTime.now(),
    };
  }
}