import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String apiKey = String.fromEnvironment('GEMINI_API_KEY');

  late final GenerativeModel? model;

  AIService() {
    model = apiKey.isEmpty
        ? null
        : GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  Future<String> sendMessage(String message) async {
    final configuredModel = model;

    if (configuredModel == null) {
      return 'AI is not configured. Add GEMINI_API_KEY with --dart-define.';
    }

    try {
      final response = await configuredModel.generateContent([
        Content.text(message),
      ]);

      return response.text ?? 'No response';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
