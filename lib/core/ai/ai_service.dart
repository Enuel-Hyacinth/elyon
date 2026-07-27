import 'package:flutter/foundation.dart';

///--------------------------------------------------
/// AI SERVICE
///--------------------------------------------------
///
/// This is the central AI abstraction used
/// throughout eLyon.
///
/// StudioController communicates ONLY with this
/// service and never directly with Gemini/OpenAI.
///--------------------------------------------------

abstract class AIService {
  //--------------------------------------------------
  // PROMPT TOOLS
  //--------------------------------------------------

  Future<String> enhancePrompt(
    String prompt,
  );

  Future<String> rewritePrompt(
    String prompt,
  );

  Future<List<String>> generateStoryboard(
    String prompt,
  );

  //--------------------------------------------------
  // MOVIE GENERATION
  //--------------------------------------------------

  Future<String> generateMovie({
    required String prompt,
    required String style,
    required String language,
    required String voice,
    required String resolution,
    required String aspectRatio,
    required String duration,
  });

  //--------------------------------------------------
  // IMAGE GENERATION
  //--------------------------------------------------

  Future<String> generateThumbnail(
    String prompt,
  );

  //--------------------------------------------------
  // SCRIPT
  //--------------------------------------------------

  Future<String> generateScript(
    String prompt,
  );

  //--------------------------------------------------
  // TITLE
  //--------------------------------------------------

  Future<String> generateTitle(
    String prompt,
  );
}
