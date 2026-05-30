import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  static final SpeechToText _speech = SpeechToText();

  static bool _isInitialized = false;

  static Future<bool> initialize() async {
    if (_isInitialized) {
      return true;
    }

    _isInitialized = await _speech.initialize();

    return _isInitialized;
  }

  static Future<void> startListening({
    required Function(String text) onResult,
  }) async {
    if (_speech.isListening) {
      await _speech.stop();
    }

    await _speech.listen(
      listenOptions: SpeechListenOptions(
        partialResults: false,
        cancelOnError: true,
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 2),
      ),

      onResult: (result) async {
        if (!result.finalResult) {
          return;
        }

        final text = result.recognizedWords;

        /// STOP FIRST
        await _speech.stop();

        /// THEN RETURN RESULT
        onResult(text);
      },
    );
  }

  static Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
