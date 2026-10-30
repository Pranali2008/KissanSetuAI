import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';

class VoiceAssistantService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isListening = false;

  VoiceAssistantService() {
    _tts.setLanguage("en-US");
    _tts.setPitch(1.0);
    _tts.setSpeechRate(0.5);
  }

  // Play audio tones for voice start/stop
  Future<void> _playBeepTone() async {
    SystemSound.play(SystemSoundType.click);
  }

  Future<void> startListening(Function(String) onResult) async {
    bool available = await _speech.initialize();
    if (available) {
      await _playBeepTone(); // Start tone
      isListening = true;
      _speech.listen(onResult: (val) {
        onResult(val.recognizedWords);
      });
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    isListening = false;
    await _playBeepTone(); // End tone
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // General Agriculture AI Knowledge Handler for ALL crops & farming queries
  String answerAgricultureQuery(String query) {
    String q = query.toLowerCase();
    
    if (q.contains('lady finger') || q.contains('ladyfinger') || q.contains('okra') || q.contains('bhendi')) {
      return "Ladyfinger (Okra) requires warm climates (25-35°C). Soil pH 6.0-6.8. Sowing season: Feb-March & June-July. Recommended seeds: 3-4 kg/acre. Requires watering every 4-5 days.";
    } else if (q.contains('chili') || q.contains('chilli')) {
      return "Chili crops need well-drained loamy soil. Ideal temperature: 20-30°C. Common diseases: Leaf curl virus & thrips. Spray Neem oil or recommended insecticides early.";
    } else if (q.contains('broccoli')) {
      return "Broccoli grows best in cool weather (15-20°C). Requires fertile, rich soil with pH 6.0-7.0. Harvest heads when tight and dark green before flowers open.";
    } else if (q.contains('apple')) {
      return "Apples require temperate climate with chilling hours (under 7°C). Well-drained loamy soil with pH 5.5-6.5. Pruning and scab control are critical for good yield.";
    } else {
      return "For $query: Maintain soil pH between 6.0 to 7.5. Provide balanced NPK fertilizers, adequate drip irrigation, and timely pest inspection during early vegetative growth.";
    }
  }
}