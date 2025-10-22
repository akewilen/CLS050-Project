import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/components/lobby.dart';
import 'package:flutter_application_1/multiplayer/firestoreClasses.dart';
import 'package:flutter_application_1/pages/home_screen.dart';

class LobbyScreen extends StatefulWidget {
  final String lobbyId;

  const LobbyScreen({Key? key, required this.lobbyId}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _lobbyStream;
  StreamSubscription? _lobbySubscription; // 1. To manage the listener

  @override
  void initState() {
    super.initState();
    _lobbyStream = FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .snapshots();

    _subscribeToLobbyUpdates();
  }

  void _subscribeToLobbyUpdates() {
    _lobbySubscription = _lobbyStream.listen(
      (docSnapshot) {
        // Check if the document exists and the widget is still on screen
        if (!docSnapshot.exists || !mounted) {
          return;
        }
        final doc = docSnapshot as DocumentSnapshot<Object?>;
        final lobby = GameLobby.fromFirestore(doc);

        if (lobby.status == GameStatus.playing.value) {
          _lobbySubscription?.cancel();

          print("Host started the game. Implement game functionality");
        }
      },
      onError: (error) {
        print("Lobby stream error: $error");
      },
    );
  }

  @override
  void dispose() {
    _lobbySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _lobbyStream,
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("Lobby not found");
        }

        // extract the inner DocumentSnapshot and cast to the expected type
        final doc = snapshot.data! as DocumentSnapshot<Object?>;
        final lobby = GameLobby.fromFirestore(doc);

        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("You are in a lobby with id: ${lobby.id}"),
              Text((lobby.players.length == 1) ? "You are alone in the lobby" : "You are with 2 players. The game can be started,"),
              ElevatedButton.icon(
                label: Text("Start game"),
                onPressed: () {
                  final docRef = FirebaseFirestore.instance.collection("lobbies").doc(lobby.id);
                  docRef.update({
                    "status": GameStatus.playing.value,
                  });
                },
              )
            ]
          ),
        );
      },
    );
  }
}