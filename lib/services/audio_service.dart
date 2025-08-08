import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/foundation.dart';

class AudioService extends ChangeNotifier {
  static final AudioPlayer player = AudioPlayer();

  static String? currentlyPlayingUrl;
  static String? currentlyPlayingStationName;
  static String? currentlyPlayingCountry;
  static Uri? currentlyPlayingArtUri;
  static String? currentSongTitle;
  static bool isPlaying = false;

  static void init() {
    player.icyMetadataStream.listen((metadata) {
      currentSongTitle = metadata?.info?.title;
      _notify();
    });


    player.playerStateStream.listen((state) {
      isPlaying = state.playing;
      _notify();
    });
  }

  static Future<void> playStation({
    required String url,
    required String stationName,
    String? country,
    String? iconUrl,
  }) async {
    final artUri = (iconUrl != null && iconUrl.trim().isNotEmpty)
        ? Uri.parse(iconUrl)
        : Uri.parse('https://via.placeholder.com/300x300.png?text=Globe+Radio');

    final currentTag = player.audioSource?.sequence.first.tag;
    final isCurrent = currentTag != null && currentTag.id == url;

    if (!isCurrent) {
      await player.stop();
      await player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: stationName,
            artist: country ?? '',
            artUri: artUri,
          ),
        ),
      );
      await player.play();

      currentlyPlayingUrl = url;
      currentlyPlayingStationName = stationName;
      currentlyPlayingCountry = country;
      currentlyPlayingArtUri = artUri;
      currentSongTitle = null;
      _notify();
    } else {
      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
    }
  }

  static void _notify() {

    _instance.notifyListeners();
  }

  // Singleton
  static final AudioService _instance = AudioService._internal();
  AudioService._internal();
  factory AudioService() => _instance;
}
