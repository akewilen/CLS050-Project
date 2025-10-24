import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/GameLogic.dart';
import 'package:flutter_application_1/components/lobby.dart';
import 'package:flutter_application_1/multiplayer/firestoreClasses.dart';
import 'package:flutter_application_1/pages/game_view.dart';
import 'package:flutter_application_1/pages/home_screen.dart';

class LobbyScreen extends StatefulWidget {
  final String lobbyId;
  final bool isHost;

  const LobbyScreen({Key? key, required this.lobbyId, required this.isHost}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _lobbyStream;

  @override
  void initState() {
    super.initState();
    _lobbyStream = FirebaseFirestore.instance
        .collection('lobbies')
        .doc(widget.lobbyId)
        .snapshots();
  }

  void _startMultiplayerAsHost(String id) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GameView(timeRestriction: false, role: PlayerRole.multiplayerHost, lobbyId: id),
    ),
  );

  void _startMultiplayerAsGuest(String id) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GameView(timeRestriction: false, role: PlayerRole.multiplayerGuest, lobbyId: id,),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _lobbyStream,
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: Text("Loading...")));
        }

        if (snapshot.hasError) {
          print("StreamBuilder error: ${snapshot.error}");
          return const Scaffold(body: Center(child: Text('Something went wrong')));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Lobby not found")));
        }

        final doc = snapshot.data! as DocumentSnapshot<Object?>;
        final lobby = GameLobby.fromFirestore(doc);

        if (lobby.status == GameStatus.waitingRoundInfo.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (widget.isHost) {
                _startMultiplayerAsHost(widget.lobbyId);
              } else {
                _startMultiplayerAsGuest(widget.lobbyId);
              }
            }
          });

          return const Scaffold(body: Center(child: Text("Starting game...")));
        }

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
                    "status": GameStatus.waitingRoundInfo.value,
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