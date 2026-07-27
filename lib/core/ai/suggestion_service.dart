class SuggestionService {
  static List<String> getSuggestions(String text) {
    final query = text.toLowerCase();

    if (query.contains("lion")) {
      return [
        "? Create a Pixar lion animation",
        "? Lion king inspired story",
        "? Wildlife documentary",
        "? Cinematic lion trailer",
      ];
    }

    if (query.contains("restaurant")) {
      return [
        "? Restaurant advert",
        "? Grand opening commercial",
        "? Food promotion",
        "? Instagram food reel",
      ];
    }

    if (query.contains("teacher") ||
        query.contains("lesson") ||
        query.contains("school")) {
      return [
        "? Mathematics lesson",
        "? Science animation",
        "? Geography class",
        "? Classroom explainer",
      ];
    }

    if (query.contains("music")) {
      return [
        "? Music video",
        "? Concert trailer",
        "? Album promotion",
        "? Lyric animation",
      ];
    }

    if (query.contains("fashion")) {
      return [
        "? Fashion advert",
        "? Product showcase",
        "? Luxury brand commercial",
        "? Instagram campaign",
      ];
    }

    return [];
  }
}