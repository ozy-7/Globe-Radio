import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static AudioPlayer get player => _player;


  static Stream<IcyMetadata?> get metadataStream => _player.icyMetadataStream;


  static Stream<PlayerState> get playerStateStream => _player.playerStateStream;


  static String? get currentStationUrl {
    if (_player.audioSource?.sequence.isNotEmpty == true) {
      return _player.audioSource!.sequence.first.tag.id;
    }
    return null;
  }


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

      final isCurrent = currentStationUrl == url;

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
      if (kDebugMode) {
        print("Error playing stream: $e");
      }
    }
  }

  static Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      if (kDebugMode) {
        print("Error pausing: $e");
      }
    }
  }

  static Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      if (kDebugMode) {
        print("Error resuming: $e");
      }
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      if (kDebugMode) {
        print("Error stopping: $e");
      }
    }
  }
}
