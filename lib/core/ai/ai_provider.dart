import 'ai_service.dart';
import 'gemini_service.dart';

///--------------------------------------------------
/// AI PROVIDER
///--------------------------------------------------
///
/// Central location for selecting the AI engine.
///
/// Future:
///
/// Gemini
/// OpenAI
/// Claude
/// DeepSeek
/// Azure OpenAI
///
/// StudioController never needs to know
/// which provider is active.
///--------------------------------------------------

class AIProvider {
  AIProvider._();

  static final AIService instance =
      GeminiService();
}