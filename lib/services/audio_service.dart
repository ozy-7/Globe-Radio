import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static AudioPlayer get player => _player;

  /// Radyo yayını çal
  static Future<void> playStream({
    required String url,
    required String stationName,
    String country = '',
    String? iconUrl,
  }) async {
    try {
      final artUri = (iconUrl != null && iconUrl.trim().isNotEmpty)
          ? Uri.parse(iconUrl)
          : Uri.parse('https://via.placeholder.com/300x300.png?text=Globe+Radio');

      final currentTag = _player.audioSource?.sequence.isNotEmpty == true
          ? _player.audioSource!.sequence.first.tag
          : null;

      final isCurrent = currentTag != null && currentTag.id == url;

      if (!isCurrent) {
        await _player.stop();
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(url),
            tag: MediaItem(
              id: url,
              title: stationName,
              artist: country,
              artUri: artUri,
            ),
          ),
        );
        await _player.play();
      } else {
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
      }
    } catch (e) {
      print("Error playing stream: $e");
    }
  }

  /// Duraklat
  static Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      print("Error pausing: $e");
    }
  }

  /// Devam ettir
  static Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      print("Error resuming: $e");
    }
  }

  /// Durdur
  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      print("Error stopping: $e");
    }
  }
}
