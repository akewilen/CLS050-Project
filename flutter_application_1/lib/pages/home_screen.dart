import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/lobby.dart';
import 'package:flutter_application_1/multiplayer/lobbyPage.dart';
import './high_score.dart';
import 'game_view.dart';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _mode = 'no_time';
  int _highest = 0;
  HomescreenStatus screenStatus = HomescreenStatus.home;
  final uuid = const Uuid();
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadHigh();
  }

  Future<void> _loadHigh() async {
    final hs = await HighScore.get();
    if (mounted) setState(() => _highest = hs);
  }

  // single player
  void _start() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GameView(timeRestriction: _mode == 'timed'),
    ),
  );

  // multiplayer
  void _createLobby() {
    final lobby = setupLobby("1", "John", 5);

    String lobbyId = uuid.v4().toString();

    db
        .collection("lobbies")
        .doc(lobbyId)
        .set(lobby)
        .onError((e, _) => print("Error writing document: $e"));

    // screenStatus = HomescreenStatus.lobbyAdmin;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LobbyScreen(lobbyId: lobbyId)),
    );
  }

  void _joinLobby(BuildContext context) {
    void joinLobbyAttempt(String lobbyId) {
      final docRef = db.collection("lobbies").doc(lobbyId);
      docRef.get().then((DocumentSnapshot doc) {
        final data = doc.data();

        final Map<String, dynamic> guestPlayerData = {
          "name": "guestName",
          "score": 0,
          "readyForNextRound": false,
          "lastAnswerTime": null,
        };

        docRef.update({"guestId": "2", "players.2": guestPlayerData});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LobbyScreen(lobbyId: lobbyId),
          ),
        );
      }, onError: (e) => print("Error getting document: $e"));
    }

    showJoinLobbyDialog(context, joinLobbyAttempt);
  }

  // Main menu
  Widget _buildMainHome() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Highest Score: $_highest',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
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
          onPressed: () =>
              setState(() => screenStatus = HomescreenStatus.multiplayer),
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Singleplayer'),
          onPressed: _start,
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
      ],
    );
  }

  // "Subpage" for multiplayer
  Widget _buildMultiplayerSetup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Create session'),
          onPressed: _createLobby,
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Join session'),
          onPressed: () => _joinLobby(context),
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
      ],
    );
  }

  // "Subpage" for user creating a lobby
  Widget _buildAdminLobby() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Lobby ID: ..."),
        ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Delete Lobby'),
          onPressed: _createLobby,
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Start Game'),
          onPressed: () => _joinLobby(context),
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Conditionally show a back button
        leading: (screenStatus == HomescreenStatus.multiplayer)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    setState(() => screenStatus = HomescreenStatus.home),
              )
            : null,
        // Title based on whether multiplayer is selected or not
        title: Text(
          (screenStatus == HomescreenStatus.home) ? 'Home' : 'Multiplayer',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        // Conditionally render the correct UI
        child: Center(
          child: switch (screenStatus) {
            HomescreenStatus.home => _buildMainHome(),
            HomescreenStatus.multiplayer => _buildMultiplayerSetup(),
            HomescreenStatus.lobbyAdmin => _buildAdminLobby(),
            _ => const Text('Unknown Screen Status'),
          },
        ),
      ),
    );
  }
}

enum HomescreenStatus { home, multiplayer, lobbyAdmin, lobbyGuest }

void showJoinLobbyDialog(BuildContext context, void Function(String) callback) {
  // Use a TextEditingController to easily read the input value
  final TextEditingController lobbyIdController = TextEditingController();

  // A GlobalKey for the form to handle validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Join Lobby'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: lobbyIdController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter Lobby ID',
              labelText: 'Lobby ID',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a Lobby ID';
              }
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Passing null means the user cancelled the action
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(lobbyIdController.text);
              }
            },
            child: const Text('Join'),
          ),
        ],
      );
    },
  ).then((lobbyId) {
    if (lobbyId != null) {
      callback(lobbyId.replaceAll(" ", ""));
    } else {
      print('Lobby join cancelled.');
    }
  });
}
