import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/lobby.dart';
import 'package:flutter_application_1/multiplayer/lobbyPage.dart';
import 'package:flutter_application_1/themes/app_theme.dart';
import './high_score.dart';
import '../components/menu_btn.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'game_view.dart';

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
      builder: (context) => GameView(
        timeRestriction: _mode == 'timed',
        role: PlayerRole.singleplayer,
        lobbyId: "",
      ),
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

    print("Lobby created with id: $lobbyId");
    // screenStatus = HomescreenStatus.lobbyAdmin;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LobbyScreen(lobbyId: lobbyId, isHost: true),
      ),
    );
  }

  void _joinLobby(BuildContext context) {
    void joinLobbyAttempt(String lobbyId) {
      final docRef = db.collection("lobbies").doc(lobbyId);
      docRef.get().then((DocumentSnapshot doc) {
        if (!doc.exists) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Lobby not found')));
          return;
        }

        final data = doc.data() as Map<String, dynamic>;

        // Check if the lobby is in the right status to join
        if (data['status'] != 'lobby') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This lobby is not available to join'),
            ),
          );
          return;
        }

        // Check if the lobby already has a guest
        if (data['guestId'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This lobby is already full')),
          );
          return;
        }

        final Map<String, dynamic> guestPlayerData = {
          "name": "Guest",
          "score": 0,
          "readyForNextRound": false,
          "lastAnswerTime": null,
        };

        docRef.update({"guestId": "2", "players.guest": guestPlayerData});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LobbyScreen(lobbyId: lobbyId, isHost: false),
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
        Expanded(
          child: Container(
            alignment: AlignmentGeometry.center,
            child: Text(
              'Highscore: $_highest',
              style: AppTheme.highScoreTextStyle,
            ),
          ),
        ),
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
        const SizedBox(height: 16),
        MenuBtn(
          onPressed: _start,
          btnText: 'Singleplayer',
          icon: Icon(Icons.play_arrow),
        ),
        const SizedBox(height: 24),
        const Divider(color: AppTheme.liPuTransp),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            alignment: AlignmentGeometry.topCenter,
            child: MenuBtn(
              onPressed: () =>
                  setState(() => screenStatus = HomescreenStatus.multiplayer),
              btnText: 'Multiplayer',
              icon: Icon(Icons.group),
            ),
          ),
        ),
      ],
    );
  }

  // "Subpage" for multiplayer
  Widget _buildMultiplayerSetup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MenuBtn(
          onPressed: _createLobby,
          btnText: 'Create session',
          icon: Icon(Icons.add),
        ),
        const SizedBox(height: 12),
        MenuBtn(
          onPressed: () => _joinLobby(context),
          btnText: 'Join session',
          icon: Icon(Icons.login),
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
          onPressed: () => print("TODO"),
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Start Game'),
          onPressed: () => print("TODO"),
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 48)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: screenStatus != HomescreenStatus.home
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    setState(() => screenStatus = HomescreenStatus.home),
              )
            : null,
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
    barrierDismissible: true,
    barrierColor: Colors.transparent,
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
              return null;
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
