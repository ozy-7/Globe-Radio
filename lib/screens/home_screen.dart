import 'package:flutter/material.dart';
import 'search_radio_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Globe Radio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildButton(context, 'Search Stations', Icons.search, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchRadioScreen()),
              );
            }),
            _buildButton(context, 'Favorite Stations', Icons.favorite, () {
              // TODO
            }),
            _buildButton(context, 'Recently Played', Icons.history, () {
              // TODO
            }),
            _buildButton(context, 'Browse by Genre', Icons.music_note, () {
              // TODO
            }),
            _buildButton(context, 'Browse by Country', Icons.public, () {
              // TODO
            }),
            _buildButton(context, 'Top Stations', Icons.trending_up, () {
              // TODO
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
