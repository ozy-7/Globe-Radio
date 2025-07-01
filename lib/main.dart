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
      title: 'Globe Radio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RadioListScreen(),
    );
  }
}

class RadioListScreen extends StatefulWidget {
  const RadioListScreen({super.key});

  @override
  State<RadioListScreen> createState() => _RadioListScreenState();
}

class _RadioListScreenState extends State<RadioListScreen> {
  List stations = [];
  final player = AudioPlayer();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  Future<void> fetchStations() async {
    final url = Uri.parse('https://de1.api.radio-browser.info/json/stations/bycountry/Germany');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        stations = json.decode(response.body);
        isLoading = false;
      });
    } else {
      print("Failed to load stations");
    }
    //print("Received station count: ${stations.length}");
  }

  void playStream(String url) async {
    try {
      await player.setUrl(url);
      player.play();
    } catch (e) {
      print("Error playing stream: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Globe Radio - Germany'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final station = stations[index];
          return ListTile(
            title: Text(station['name'] ?? 'Unknown'),
            subtitle: Text(station['url'] ?? ''),
            onTap: () {
              playStream(station['url']);
            },
          );
        },
      ),
    );
  }
}
