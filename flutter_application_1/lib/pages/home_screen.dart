import 'package:flutter/material.dart';
import './high_score.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mode = 'no_time';
  int _highest = 0;

  @override
  void initState() {
    super.initState();
    _loadHigh();
  }

  Future<void> _loadHigh() async {
    final hs = await HighScore.get();
    if (mounted) setState(() => _highest = hs);
  }

  void _start() => Navigator.pushNamed(context, '/game', arguments: {'mode': _mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Highest Score: $_highest',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('No Time'),
                  selected: _mode == 'no_time',
                  onSelected: (_) => setState(() => _mode = 'no_time'),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Timed'),
                  selected: _mode == 'timed',
                  onSelected: (_) => setState(() => _mode = 'timed'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play'),
              onPressed: _start,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
          ],
        ),
      ),
    );
  }
}
