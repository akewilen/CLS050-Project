import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/lobby.dart';
import './high_score.dart';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void startMultiplayer() => print("TODO");

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
              icon: const Icon(Icons.group),
              label: const Text('Multiplayer'),
              onPressed: _start,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Singleplayer'),
              onPressed: _start,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiplayerSetupScreen extends StatelessWidget {
  // Create new document on firestore
  // Receive ID of the document/lobby
  // see wait screen until friend has joined
  void createLobby() {
    final db = FirebaseFirestore.instance;

    final lobby = setupLobby("1", "John", 5);

    db
    .collection("lobbies")
    .doc(uuid.v4().toString())
    .set(lobby)
    .onError((e, _) => print("Error writing document: $e"));
  }

  void joinLobby() => print("TODO");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiplayer')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              label: const Text('Create session'),
              onPressed: createLobby,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
            ElevatedButton.icon(
              label: const Text('Join session'),
              onPressed: joinLobby,
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
            ),
          ],
        ),
      ),
    );
  }
}