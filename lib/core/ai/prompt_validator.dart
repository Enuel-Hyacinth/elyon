class PromptValidator {
  static String? validate(String prompt) {
    if (prompt.trim().isEmpty) {
      return "Please enter a prompt.";
    }

    if (prompt.trim().length < 8) {
      return "Prompt is too short.";
    }

    return null;
  }
}