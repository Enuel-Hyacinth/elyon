import 'models/prompt_request.dart';
import 'prompt_enhancer.dart';
import 'prompt_templates.dart';
import 'prompt_validator.dart';

class PromptEngine {
  static String generate(PromptRequest request) {
    final error = PromptValidator.validate(request.prompt);

    if (error != null) {
      throw Exception(error);
    }

    final enhanced = PromptEnhancer.enhance(request.prompt);

    return PromptTemplates.build(
      prompt: enhanced,
      style: request.style,
      intent: request.intent,
      language: request.language,
      voice: request.voice,
      ratio: request.aspectRatio,
      duration: request.duration,
    );
  }
}