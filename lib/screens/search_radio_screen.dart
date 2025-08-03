import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';



class SearchRadioScreen extends StatefulWidget {
  const SearchRadioScreen({super.key});

  @override
  State<SearchRadioScreen> createState() => _SearchRadioScreenState();
}

class _SearchRadioScreenState extends State<SearchRadioScreen> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  String? _currentlyPlayingUrl;
  String? currentTitle;
  bool isPlaying = false;

  final String apiUrl = 'https://globe-radio-backend.onrender.com/search?q=';

  @override
  void initState() {
    super.initState();

    _player.icyMetadataStream.listen((metadata) {
      setState(() {
        currentTitle = metadata?.info?.title;
      });
    });

    _player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  Future<void> searchRadios(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => isLoading = true);

    final url = Uri.parse('$apiUrl${Uri.encodeComponent(query)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        results = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Search error: ${response.statusCode}")),
      );
    }
  }

  void playStream(Map<String, dynamic> station) async {
    try {
      final url = station['url_resolved'] ?? station['url'];
      final stationName = station['name'] ?? 'Unknown Station';
      final country = station['country'] ?? '';
      final iconUrl = station['favicon'];
      final artUri = (iconUrl != null && iconUrl.toString().trim().isNotEmpty)
          ? Uri.parse(iconUrl)
          : Uri.parse('https://via.placeholder.com/300x300.png?text=Globe+Radio');

      if (_currentlyPlayingUrl != url) {
        await _player.stop();
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(url),
            tag: MediaItem(
              id: url,
              title: stationName,
              artist: currentTitle ?? country,
              artUri: artUri,
            ),
          ),
        );
        await _player.play();

        setState(() {
          _currentlyPlayingUrl = url;
        });
      } else {
        if (_player.playing) {
          _player.pause();
        } else {
          _player.play();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stream error: $e")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Stations')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: searchRadios,
              decoration: InputDecoration(
                hintText: 'Search station...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchRadios(_controller.text),
                ),
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : results.isEmpty
                ? const Text("No results.")
                : Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final station = results[index];
                  final isCurrent = _currentlyPlayingUrl ==
                      (station['url_resolved'] ?? station['url']);
                  return ListTile(
                    title: Text(
                      "${station['name'] ?? 'Unknown'} - ${station['country'] ?? ''}",
                    ),
                    subtitle: isCurrent && currentTitle != null
                        ? Text(
                      currentTitle!,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic),
                    )
                        : null,
                    trailing: IconButton(
                      icon: Icon(
                        isCurrent && isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () => playStream(station),
                    ),
                    onTap: () => playStream(station),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
