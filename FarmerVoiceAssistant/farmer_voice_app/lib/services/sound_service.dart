import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Sound and haptic feedback service to indicate voice listening start and stop
class SoundService {
  /// Plays a distinct tone/alert and haptic pulse when mic listening starts
  static Future<void> playListeningStart() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
      if (!kIsWeb) {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  /// Plays a distinct tone/click and haptic pulse when mic listening stops
  static Future<void> playListeningStop() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      if (!kIsWeb) {
        await HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }
}