import 'ai_intent.dart';

class IntentService {
  static AIIntent detectIntent(String prompt) {
    final text = prompt.toLowerCase();

    // Animation
    if (text.contains("animation") ||
        text.contains("pixar") ||
        text.contains("cartoon") ||
        text.contains("3d")) {
      return AIIntent.animation;
    }

    // Story
    if (text.contains("story") ||
        text.contains("movie") ||
        text.contains("novel")) {
      return AIIntent.story;
    }

    // Marketing
    if (text.contains("advert") ||
        text.contains("advertisement") ||
        text.contains("marketing") ||
        text.contains("business") ||
        text.contains("product")) {
      return AIIntent.marketing;
    }

    // Education
    if (text.contains("lesson") ||
        text.contains("teacher") ||
        text.contains("school") ||
        text.contains("student")) {
      return AIIntent.education;
    }

    // Music
    if (text.contains("music") ||
        text.contains("song") ||
        text.contains("lyrics")) {
      return AIIntent.music;
    }

    return AIIntent.unknown;
  }
}