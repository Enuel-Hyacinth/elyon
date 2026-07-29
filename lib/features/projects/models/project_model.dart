import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String userId;

  final String title;
  final String prompt;
  final String enhancedPrompt;

  final String intent;
  final String status;

  final int creditsUsed;

  final String thumbnail;

  final String style;

  final String language;

  final String voice;

  final String aspectRatio;

  final String resolution;

  final String duration;

  final double progress;

  final DateTime createdAt;

  final DateTime lastModified;

  const ProjectModel({
    required this.id,
    required this.userId,

    required this.title,
    required this.prompt,
    required this.enhancedPrompt,

    required this.intent,
    required this.status,

    required this.creditsUsed,

    required this.thumbnail,

    required this.style,

    required this.language,

    required this.voice,

    required this.aspectRatio,

    required this.resolution,

    required this.duration,

    required this.progress,

    required this.createdAt,

    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,

      'title': title,
      'prompt': prompt,
      'enhancedPrompt': enhancedPrompt,

      'intent': intent,
      'status': status,

      'creditsUsed': creditsUsed,

      'thumbnail': thumbnail,

      'style': style,

      'language': language,

      'voice': voice,

      'aspectRatio': aspectRatio,

      'resolution': resolution,

      'duration': duration,

      'progress': progress,

      'createdAt': Timestamp.fromDate(createdAt),

      'lastModified': Timestamp.fromDate(lastModified),
    };
  }
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] ?? '',

      userId: map['userId'] ?? '',

      title: map['title'] ?? '',

      prompt: map['prompt'] ?? '',

      enhancedPrompt: map['enhancedPrompt'] ?? '',

      intent: map['intent'] ?? '',

      status: map['status'] ?? '',

      creditsUsed: map['creditsUsed'] ?? 0,

      thumbnail: map['thumbnail'] ?? '',

      style: map['style'] ?? 'Pixar',

      language: map['language'] ?? 'English',

      voice: map['voice'] ?? 'Female',

      aspectRatio: map['aspectRatio'] ?? '16:9',

      resolution: map['resolution'] ?? 'HD',

      duration: map['duration'] is int
          ? "${map['duration']} Seconds"
          : (map['duration'] ?? "30 Seconds").toString(),

      progress: (map['progress'] ?? 0).toDouble(),

      createdAt: (map['createdAt'] as Timestamp).toDate(),

      lastModified: (map['lastModified'] as Timestamp).toDate(),
    );
  }
  ProjectModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? prompt,
    String? enhancedPrompt,
    String? intent,
    String? status,
    int? creditsUsed,
    String? thumbnail,
    String? style,
    String? language,
    String? voice,
    String? aspectRatio,
    String? resolution,
    String? duration,
    double? progress,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      enhancedPrompt: enhancedPrompt ?? this.enhancedPrompt,
      intent: intent ?? this.intent,
      status: status ?? this.status,
      creditsUsed: creditsUsed ?? this.creditsUsed,
      thumbnail: thumbnail ?? this.thumbnail,
      style: style ?? this.style,
      language: language ?? this.language,
      voice: voice ?? this.voice,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      resolution: resolution ?? this.resolution,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}