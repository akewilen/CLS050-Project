import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/GameLogic.dart';
import 'package:flutter_application_1/components/lobby.dart';
import 'package:flutter_application_1/components/quitbutton.dart';
import 'package:flutter_application_1/multiplayer/firestoreClasses.dart';
import 'package:flutter_application_1/pages/game_view.dart';
import 'package:flutter_application_1/pages/home_screen.dart';
import '../components/menu_btn.dart';

class LobbyScreen extends StatefulWidget {
  final String lobbyId;
  final bool isHost;

  const LobbyScreen({Key? key, required this.lobbyId, required this.isHost})
    : super(key: key);

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
      builder: (context) => GameView(
        timeRestriction: true,
        role: PlayerRole.multiplayerHost,
        lobbyId: id,
      ),
    ),
  );

  void _startMultiplayerAsGuest(String id) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GameView(
        timeRestriction: true,
        role: PlayerRole.multiplayerGuest,
        lobbyId: id,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _lobbyStream,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: Text("Loading...")));
            }

            if (snapshot.hasError) {
              print("StreamBuilder error: ${snapshot.error}");
              return const Scaffold(
                body: Center(child: Text('Something went wrong')),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("Lobby not found")),
              );
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

              return const Scaffold(
                body: Center(child: Text("Starting game...")),
              );
            }

            return Scaffold(
              body: Stack(
                children: [
                  Center(
                    child: widget.isHost
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "You are in a lobby with id: \n ${lobby.id}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 32),
                              lobby.guestId == null
                                  ? Text(
                                      "Waiting for a second player...",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    )
                                  : MenuBtn(
                                      onPressed: () {
                                        final docRef = FirebaseFirestore
                                            .instance
                                            .collection("lobbies")
                                            .doc(lobby.id);
                                        docRef.update({
                                          "status":
                                              GameStatus.waitingRoundInfo.value,
                                        });
                                      },
                                      btnText: 'Start game',
                                      icon: Icon(Icons.play_arrow),
                                    ),
                            ],
                          )
                        : const Text(
                            "Waiting for the host to start game...",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                  QuitButton(
                    onQuitConfirmed: () async {
                      final lobbyRef = FirebaseFirestore.instance
                          .collection("lobbies")
                          .doc(widget.lobbyId);

                      if (widget.isHost) {
                        // Delete the entire lobby if host leaves
                        await lobbyRef.delete();
                      } else {
                        // Get current lobby data to preserve host information
                        final docSnapshot = await lobbyRef.get();
                        final data = docSnapshot.data();
                        if (data != null) {
                          // Reset to just the host player
                          await lobbyRef.update({
                            'guestId': null,
                            'players': {
                              'host': {'name': 'John', 'score': 0},
                            },
                          });
                        }
                      }

                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
    );
  }
}
