import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import '../services/audio_service.dart';

class SearchRadioScreen extends StatefulWidget {
  const SearchRadioScreen({super.key});

  @override
  State<SearchRadioScreen> createState() => _SearchRadioScreenState();
}

class _SearchRadioScreenState extends State<SearchRadioScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;


  String? currentTitle;
  bool isPlaying = false;

  final String apiUrl = 'https://globe-radio-backend.onrender.com/search?q=';

  @override
  void initState() {
    super.initState();

    AudioService.player.icyMetadataStream.listen((metadata) {
      setState(() {
        currentTitle = metadata?.info?.title;
      });
    });

    AudioService.player.playerStateStream.listen((state) {
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



  @override
  void dispose() {
    _controller.dispose();
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
                  final stationUrl = station['url_resolved'] ?? station['url'];

                  return StreamBuilder<PlayerState>(
                    stream: AudioService.player.playerStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      final isPlaying = state?.playing ?? false;

                      final isCurrent = AudioService.player.audioSource?.sequence != null &&
                          AudioService.player.audioSource!.sequence.first.tag.id == stationUrl;

                      return ListTile(
                        title: Text("${station['name'] ?? 'Unknown'} - ${station['country'] ?? ''}"),
                        subtitle: isCurrent
                            ? StreamBuilder<IcyMetadata?>(
                          stream: AudioService.player.icyMetadataStream,
                          builder: (context, snapshot) {
                            final title = snapshot.data?.info?.title;
                            if (title != null && title.isNotEmpty) {
                              return Text(title, style: const TextStyle(fontStyle: FontStyle.italic));
                            }
                            return const SizedBox.shrink();
                          },
                        )
                            : null,
                        trailing: IconButton(
                          icon: Icon(isCurrent && isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            final stationUrl = station['url_resolved'] ?? station['url'];
                            if (stationUrl != null && stationUrl.toString().isNotEmpty) {
                              AudioService.playStream(
                                url: stationUrl,
                                stationName: station['name'] ?? 'Unknown Station',
                                country: station['country'] ?? '',
                                iconUrl: station['favicon'],
                              );
                            }
                          },
                        ),
                        onTap: () {
                          final stationUrl = station['url_resolved'] ?? station['url'];
                          if (stationUrl != null && stationUrl.toString().isNotEmpty) {
                            AudioService.playStream(
                              url: stationUrl,
                              stationName: station['name'] ?? 'Unknown Station',
                              country: station['country'] ?? '',
                              iconUrl: station['favicon'],
                            );
                          }
                        },
                      );
                    },
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
