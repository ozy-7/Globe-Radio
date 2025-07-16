import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const GlobeRadioApp());
}

class GlobeRadioApp extends StatelessWidget {
  const GlobeRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Globe Radio Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SearchRadioScreen(),
    );
  }
}

class SearchRadioScreen extends StatefulWidget {
  const SearchRadioScreen({super.key});

  @override
  State<SearchRadioScreen> createState() => _SearchRadioScreenState();
}

class _SearchRadioScreenState extends State<SearchRadioScreen> {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  List results = [];
  bool isLoading = false;

  String? _currentlyPlayingUrl;
  String? _currentlyPlayingName;
  String? _currentlyPlayingCountry;
  String? currentTitle;
  bool isPlaying = false;


  final String bonsaiUsername = 'e0zk42nhkp';
  final String bonsaiPassword = 'h09w8k79sy';
  final String bonsaiDomain = 'globe-radio-search-1981816204.eu-central-1.bonsaisearch.net';

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

    final credentials = base64Encode(utf8.encode('$bonsaiUsername:$bonsaiPassword'));

    final url = Uri.https(
      bonsaiDomain,
      '/radio_stations/_search',
      {'q': 'name:$query'},
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final hits = data['hits']['hits'];
      setState(() {
        results = hits.map((e) => e['_source']).toList();
        isLoading = false;
      });
    } else {
      print("Arama hatası: ${response.statusCode} ${response.body}");
      setState(() => isLoading = false);
    }
  }


  void playStream(Map station) async {
    try {
      if (_currentlyPlayingUrl != station['url']) {
        await _player.setUrl(station['url']);
        _player.play();
        setState(() {
          _currentlyPlayingUrl = station['url'];
          _currentlyPlayingName = station['name'];
          _currentlyPlayingCountry = station['country'];
        });
      } else {
        if (_player.playing) {
          _player.pause();
        } else {
          _player.play();
        }
      }
    } catch (e) {
      print("Stream hatası: $e");
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
      appBar: AppBar(title: const Text('Globe Radio - Search')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onSubmitted: searchRadios,
              decoration: InputDecoration(
                hintText: 'İstasyon ara...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => searchRadios(_controller.text),
                ),
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final station = results[index];
                  final isCurrent = _currentlyPlayingUrl == station['url'];
                  return ListTile(
                    title: Text(
                      "${station['name'] ?? 'Unknown'} - ${station['country'] ?? ''}",
                    ),
                    subtitle: isCurrent && currentTitle != null
                        ? Text(
                      currentTitle!,
                      style: const TextStyle(fontStyle: FontStyle.italic),
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
