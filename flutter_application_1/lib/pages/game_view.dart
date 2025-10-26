import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/API.dart';
import 'package:flutter_application_1/components/lobby.dart';
import 'package:flutter_application_1/multiplayer/firestoreClasses.dart';
import 'package:flutter_application_1/pages/mulitplayer_scorescreen.dart';
import '../GameLogic.dart';
import '../components/timer_indicator.dart';
import 'compare.dart';
import 'map_game.dart';
import '../components/country.dart';
import 'score_screen.dart';
import 'high_score.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum PlayerRole {
  singleplayer,
  multiplayerHost,
  multiplayerGuest,
}

class GameView extends StatefulWidget {
  const GameView({
    super.key,
    required this.timeRestriction,
    required this.role,
    required this.lobbyId,
  });

  final bool timeRestriction;
  final PlayerRole role;
  final String lobbyId;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  int _currentScore = 50;
  bool _isMapTimerActive = true;
  bool _isCompareTimerActive = true;
  Game currentGame = Game();

  // --- Multiplayer properties ---
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _lobbyStream;
  StreamSubscription? _lobbySubscription;
  final db = FirebaseFirestore.instance;
  GameLobby lobby = GameLobby.createEmptyLobby();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _lobbySubscription?.cancel();
    super.dispose();
  }

  static Game? _sharedGame;

  Future<void> _initializeGame() async {
    // Always create a new game instance for multiplayer games
    if (widget.role != PlayerRole.singleplayer || _sharedGame == null || !_sharedGame!.isInitialized()) {
      _sharedGame = await GameLogic.createGame();
      currentGame = _sharedGame!;
      print("Game started - Total rounds: ${currentGame.rounds.length}");
    } else {
      currentGame = _sharedGame!;
    }

    if (widget.role != PlayerRole.singleplayer) {
      _lobbyStream = FirebaseFirestore.instance
          .collection('lobbies')
          .doc(widget.lobbyId)
          .snapshots();

      final docRef = db.collection("lobbies").doc(widget.lobbyId);
      var doc = await docRef.get();

      if (!mounted) return;

      lobby = GameLobby.fromFirestore(doc);
      //print("initial lobby: ${lobby.toJson()}");

      subscribeToLobbyUpdates();
      reactToLobby();
    }

    // Call setState *after* game is initialized to trigger the build.
    setState(() {});
  }

  Future<void> reactToLobby() async {
    // Only the host needs to control the lobby
    if (widget.role != PlayerRole.multiplayerHost) return;


    if (widget.lobbyId.isEmpty) {
        print("Error: Lobby ID is null or empty. Cannot write document.");
        return;
      }

    // Upload the current round info to the server
    if (lobby.status == GameStatus.waitingRoundInfo.value) {
      // Ensure we're using the correct round data
      if (widget.role == PlayerRole.multiplayerGuest && currentGame.currentRoundIndex != lobby.currentRound) {
        currentGame.currentRoundIndex = lobby.currentRound;
      }
      
      print("Round ${currentGame.currentRoundIndex} started");
      Country? top = getTopCountry();
      Country? bottom = getBottomCountry();
      String currentStat = currentGame.getCurrentStat();

      if ((top == null) || (bottom == null)) {
        print("Error when reacting to round change. Top or bottom country was not loaded hence cannot update the server.");
        return;
      }

      final Map<String, dynamic> newRoundInfo = RoundInfo(
        topCountry: top,
        bottomCountry: bottom,
        statistic: currentStat,
        roundEndTime: null,
        roundWinnerId: null,
      ).toJson();

      final Map<String, dynamic> updateData = {
        'roundInfo': newRoundInfo,
        'currentRound': currentGame.currentRoundIndex,
        'status': GameStatus.playingMap.value,
        'players.host.readyForNextRound': false,
        'players.guest.readyForNextRound': false,
      };

      final docRef = db.collection("lobbies").doc(widget.lobbyId);

      docRef.update(updateData)
        .catchError((e) {
          print("Error: Failed to update game state");
        });
      return;
    }

    // Fetch next round if both players are ready and we're in the correct state
    if (lobby.status == GameStatus.playingMap.value &&  // Only advance during play state
        lobby.players['host']?.readyForNextRound == true &&
        lobby.players['guest']?.readyForNextRound == true &&
        lobby.currentRound == currentGame.currentRoundIndex) {  // Ensure we're on the same round
      print("Round ${currentGame.currentRoundIndex} - Both players have finished");
      
      final bool hasNextRound = currentGame.hasNextRound();
      
      if (hasNextRound) {
        await currentGame.nextRound(); // Wait for the next round to be fully loaded
        final newRoundIndex = currentGame.currentRoundIndex;
        print("Advancing to round $newRoundIndex");
        
        // Check if this is the last round
        if (newRoundIndex >= lobby.totalRounds) {
          print("Final round completed - Game finished");
          // Game is finished, update lobby state
          final Map<String, dynamic> updateData = {
            'currentRound': newRoundIndex,
            'status': GameStatus.finished.value,
            'players.host.readyForNextRound': false,
            'players.guest.readyForNextRound': false
          };
          final docRef = db.collection("lobbies").doc(widget.lobbyId);
          await docRef.update(updateData);
          return;
        }
        
        // Not the last round, continue normally
        final Map<String, dynamic> updateData = {
          'currentRound': newRoundIndex,
          'status': GameStatus.waitingRoundInfo.value,
          'players.host.readyForNextRound': false,
          'players.guest.readyForNextRound': false
        };
        
        print("Updating lobby with round $newRoundIndex");
        final docRef = db.collection("lobbies").doc(widget.lobbyId);
        await docRef.update(updateData);
        return; // Exit after updating the round
      } else {
        // Game is finished
        final Map<String, dynamic> updateData = {
          'status': GameStatus.finished.value,
          'players.host.readyForNextRound': false,
          'players.guest.readyForNextRound': false
        };

      print("Updating lobby with new round data. Round index: ${currentGame.currentRoundIndex}");
      final docRef = db.collection("lobbies").doc(widget.lobbyId);

      docRef.update(updateData)
        .then((_) {
          print("Successfully pushed finishing state to Firestore!");
        })
        .catchError((e) {
          print("Error writing finishing state to Firestore: $e");
        });
      return;
    }
  }
}


  void subscribeToLobbyUpdates() {
    _lobbySubscription = _lobbyStream.listen(
      (docSnapshot) {
        // Check if the document exists and the widget is still on screen
        if (!docSnapshot.exists || !mounted) {
          return;
        }

        lobby = GameLobby.fromFirestore(docSnapshot);

        // Update the UI with the new lobby
        setState(() {});

        if (lobby.status == GameStatus.finished.value) {
          _lobbySubscription?.cancel();
          // Reset game instances for next game
          _sharedGame = null;
          currentGame = Game();
          
          // Navigate to the multiplayer score screen
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MultiplayerScoreScreen(
                hostId: widget.role == PlayerRole.multiplayerHost ? 'You' : 'Host',
                guestId: widget.role == PlayerRole.multiplayerGuest ? 'You' : 'Guest',
                hostScore: lobby.players['host']?.score ?? 0,
                guestScore: lobby.players['guest']?.score ?? 0,
              ),
            ),
            ModalRoute.withName('/'),
          );
          return;
        } else if (lobby.status == GameStatus.canceled.value) {
          _lobbySubscription?.cancel();
          if (!mounted) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
          return;
        }

      // When status is waiting, host will handle next round setup
        if (lobby.status == GameStatus.waitingRoundInfo.value && widget.role == PlayerRole.multiplayerHost) {
          print("Handling waiting state, current round: ${currentGame.currentRoundIndex}");
          Future.microtask(() => reactToLobby());
        }

        // Only host should handle round advancement through reactToLobby
        if (widget.role == PlayerRole.multiplayerHost) {
          // Add a small delay to ensure all state updates are processed
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) reactToLobby();
          });
        }
      },
      onError: (error) {
        print("There was an error fetching the lobby from the stream: $error");
      },
    );
  }

  Country? getTopCountry() {
    try {
      CountryData? stats = currentGame.getCurrentCountry();
      if (stats == null) {
        return null;
      }
      return Country.fromCountryData(currentGame.rounds[currentGame.currentRoundIndex], stats);
    } catch (e) {
      return null;
    }
  }

  Country? getBottomCountry() {
    try {
      CountryData? stats = currentGame.getNextCountry();
      if (stats == null) {
        return null;
      }
      return Country.fromCountryData(currentGame.rounds[currentGame.currentRoundIndex + 1], stats);
    } catch (e) {
      return null;
    }
  }

  Future<void> _openCompareModal({
    required CountryField compareField,
    required Country topCountry,
    required Country bottomCountry,
  }) async {
    _isCompareTimerActive = true;
    await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Compare',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.black,
          child: Stack(
            children: [
              ComparePage(
                compareField: compareField,
                topCountry: topCountry,
                bottomCountry: bottomCountry,
                correctCallback: () {
                  _onCorrect();
                },
                wrongCallback: () {
                  _onWrong();
                },
                roundNumber: currentGame.currentRoundIndex,
              ),
              if (widget.timeRestriction)
                Positioned(
                  top: 20,
                  right: 20,
                  child: TimerIndicator(
                    isActive: _isCompareTimerActive,
                    onScore: _updateScore,
                    onTimeUp: _handleTimeUp,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _addScore(int score) {
    currentGame.addToScore(score);
    _currentScore = 50;
  }

  void _onCorrect() async {
    if (widget.role == PlayerRole.singleplayer) {
      setState(() {
        _isCompareTimerActive = false;
      });
      print('compareview score: $_currentScore');
      _addScore(_currentScore);
      await currentGame.nextRound();
      if (!mounted) return;

      // Pop back to map view
      Navigator.pop(context);

      // Reset state for new round
      setState(() {
        _currentScore = 50;
        //_selectedIndex = null;
        //_hasSelectedCountry = false;
        _isMapTimerActive = true; // Restart timer for new round
      });
      return;
    }
    final RoundInfo oldRound = lobby.roundInfo;
    final Map<String, dynamic> newRoundInfo = RoundInfo(
      topCountry: oldRound.topCountry,
      bottomCountry: oldRound.bottomCountry,
      statistic: oldRound.statistic,
      roundEndTime: null,
      roundWinnerId: (widget.role == PlayerRole.multiplayerHost) ? "host" : "guest",
    ).toJson();

    // Update the player's ready status based on their role
    final String playerPath = widget.role == PlayerRole.multiplayerHost ? 'players.host.readyForNextRound' : 'players.guest.readyForNextRound';
    
    final Map<String, dynamic> updateData = {
      'roundInfo': newRoundInfo,
      playerPath: true,  // Set the player as ready for the next round
    };

    final docRef = db.collection("lobbies").doc(widget.lobbyId);
    docRef.update(updateData)
      .then((_) {
        print("Player ${widget.role == PlayerRole.multiplayerHost ? 'Host' : 'Guest'} finished round ${currentGame.currentRoundIndex}");
      })
      .catchError((e) {
        print("Error: Failed to update player status");
      });
  }

  void _onWrong() async {
    if (widget.role == PlayerRole.singleplayer) {
      int finalScore = currentGame.totalScore;
      // Add the current round's score before ending if it's time restricted mode
      if (widget.timeRestriction && _currentScore > 0) {
        finalScore = currentGame.totalScore;
      }
      await HighScore.setIfHigher(finalScore);
      final highScore = await HighScore.get();

      // Reset both shared and current game instances for new singleplayer session
      _sharedGame = await GameLogic.createGame();
      currentGame = _sharedGame!;
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        //change to: pushAndRemoveUntil... replace both compare och map in the navigation stack
        context,
        MaterialPageRoute(
          builder: (context) => ScoreScreen(
            timeRestriction: widget.timeRestriction,
            highScore: highScore,
            finalScore: finalScore,
          ),
        ),
        ModalRoute.withName('/'),
      );
      return;
    }

    // For multiplayer, update the ready status
    final String playerPath = widget.role == PlayerRole.multiplayerHost ? 'players.host.readyForNextRound' : 'players.guest.readyForNextRound';
    
    final Map<String, dynamic> updateData = {
      playerPath: true,  // Set the player as ready for the next round
    };

    final docRef = db.collection("lobbies").doc(widget.lobbyId);
    docRef.update(updateData)
      .catchError((e) {
        print("Error: Failed to update player status");
      });
  }

  void _handleTimeUp() {
    if (mounted) {
      setState(() {
        _isMapTimerActive = false;
        _isCompareTimerActive = false;
      });
      _onWrong();
    }
  }

  void _updateScore(int score) {
    setState(() {
      _currentScore = score;
    });
  }

  CountryField _getCompareField(String statName) {
    switch (statName) {
      case 'Surface Area':
        return CountryField.surfaceArea;
      case 'Population':
        return CountryField.population;
      case 'CO2 Emissions':
        return CountryField.co2Emissions;
      case 'Forested Area':
        return CountryField.forestedArea;
      case 'GDP per Capita':
        return CountryField.gdpPerCapita;
      default:
        return CountryField.population; // fallback
    }
  }

  // --- (Screen building functions) ---
  Widget _singlePlayerScreen(BuildContext context) {
    final compareField = _getCompareField(currentGame.getCurrentStat());
    final Country? topCountry = getTopCountry();
    final Country? bottomCountry = getBottomCountry();

    if (topCountry == null || bottomCountry == null) {
      return const Center(child: Text('Error: Countries not loaded'));
    }

    // Return the Stack directly
    return Stack(
      children: [
        MapGame(
          selectedCountry: currentGame.rounds[currentGame.currentRoundIndex],
          hiddenCountry: currentGame.rounds[currentGame.currentRoundIndex + 1],
          onTargetFound: () async {
            setState(() {
              _isMapTimerActive = false;
            });
            print('mapview score: $_currentScore');
            _addScore(_currentScore);
            await _openCompareModal(
              compareField: compareField,
              topCountry: topCountry,
              bottomCountry: bottomCountry,
            );
          },
          onWrong: _onWrong,
        ),
        if (widget.timeRestriction)
          Positioned(
            top: 20,
            right: 20,
            child: TimerIndicator(
              isActive: _isMapTimerActive,
              onScore: _updateScore,
              onTimeUp: _handleTimeUp,
            ),
          ),
      ],
    );
  }

  Widget _multiPlayerScreen(BuildContext context) {
    if (lobby.status == GameStatus.waitingRoundInfo.value) {
      print("Waiting screen - Current game round: ${currentGame.currentRoundIndex}");
      if (widget.role == PlayerRole.multiplayerHost) {
        print("Host's next countries: ${currentGame.rounds[currentGame.currentRoundIndex]} -> ${currentGame.rounds[currentGame.currentRoundIndex + 1]}");
      }
      // Return the Center widget directly
      return const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Waiting for the next round..."),
            SizedBox(width: 10),
            CircularProgressIndicator(),
          ],
        ),
      );
    }

    final RoundInfo round = lobby.roundInfo;

    if ((round.topCountry == null) || (round.bottomCountry == null) || (round.statistic == null)) {
      return const Center(
        child: Text("Error: Round data is missing from the lobby."),
      );
    }

    if (lobby.status == GameStatus.playingMap.value) {
      // Only guest should sync their round with the lobby
      if (widget.role == PlayerRole.multiplayerGuest && currentGame.currentRoundIndex != lobby.currentRound) {
        print("Guest syncing game round from ${currentGame.currentRoundIndex} to ${lobby.currentRound}");
        currentGame.currentRoundIndex = lobby.currentRound;
      }

      return Stack(
        children: [
          MapGame(
            selectedCountry: round.topCountry!.name,
            hiddenCountry: round.bottomCountry!.name,
            onTargetFound: () async {
              setState(() {
                _isMapTimerActive = false;
              });
              await _openCompareModal(
                compareField: _getCompareField(round.statistic!),
                topCountry: round.topCountry!,
                bottomCountry: round.bottomCountry!,
              );
            },
            onWrong: _onWrong,
          ),
          if (widget.timeRestriction)
            Positioned(
              top: 20,
              right: 20,
              child: TimerIndicator(
                isActive: _isMapTimerActive,
                onScore: _updateScore,
                onTimeUp: _handleTimeUp,
              ),
            ),
        ],
      );
    }

    // Fallback for others
    return Center(
      child: Text("Not implemented for status: ${lobby.status}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          // Show loading indicator if game isn't ready
          if (!currentGame.isInitialized()) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show the correct screen based on role
          if (widget.role == PlayerRole.singleplayer) {
            return _singlePlayerScreen(context);
          } else {
            return _multiPlayerScreen(context);
          }
        },
      ),
    );
  }
}