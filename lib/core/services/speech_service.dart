import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../constants/app_constants.dart';
import '../utils/number_parser.dart';

/// Wrapper around the speech_to_text package.
/// Supports switching between Arabic (ar_SA) and English (en_US)
/// locales on demand, and exposes a stream of recognized words.
class SpeechService extends ChangeNotifier {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final SpeechToText _speech = SpeechToText();

  bool _available = false;
  bool _listening = false;
  String _currentLocaleId = AppConstants.localeEnglish;
  String _lastWords = '';

  bool get isAvailable => _available;
  bool get isListening => _listening;
  String get lastWords => _lastWords;
  String get currentLocaleId => _currentLocaleId;

  /// Initialise the engine. Returns whether speech is available.
  Future<bool> init() async {
    if (_available) return true;
    _available = await _speech.initialize(
      onStatus: (status) {
        final listening = status == 'listening';
        if (listening != _listening) {
          _listening = listening;
          notifyListeners();
        }
      },
      onError: (SpeechRecognitionError error) {
        debugPrint('Speech error: ${error.errorMsg}');
        _listening = false;
        notifyListeners();
      },
    );
    return _available;
  }

  /// Returns the locales installed on the device (for diagnostics).
  Future<List<LocaleName>> locales() async {
    return _speech.locales();
  }

  /// Start listening in the given locale ('ar' or 'en').
  Future<void> startListening({
    String language = 'en',
    void Function(String)? onResult,
  }) async {
    if (!_available) {
      final ok = await init();
      if (!ok) return;
    }
    _currentLocaleId = language == 'ar'
        ? AppConstants.localeArabic
        : AppConstants.localeEnglish;
    _lastWords = '';
    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        notifyListeners();
        onResult?.call(_lastWords);
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      listenOptions: SpeechListenOptions(
        localeId: _currentLocaleId,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
    _listening = true;
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _listening = false;
    notifyListeners();
  }

  Future<void> cancel() async {
    await _speech.cancel();
    _listening = false;
    notifyListeners();
  }

  /// Convenience: listen once and parse a spoken number into an integer.
  /// Supports Arabic (واحد، عشرون...) and English (one, twenty...) words.
  Future<int?> listenForNumber({String language = 'en'}) async {
    String captured = '';
    await startListening(
      language: language,
      onResult: (words) => captured = words,
    );
    // Wait up to 6 seconds for a final result
    for (int i = 0; i < 60 && _listening; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await stopListening();
    final value = NumberParser.parse(captured, language: language);
    return value;
  }
}
