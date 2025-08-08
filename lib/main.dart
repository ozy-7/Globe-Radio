import 'package:flutter/material.dart';
import 'package:globe_radio/services/audio_service.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  AudioService.init();
  runApp(const GlobeRadioApp());
}

class GlobeRadioApp extends StatelessWidget {
  const GlobeRadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Globe Radio',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
