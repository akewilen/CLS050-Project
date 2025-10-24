import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/API.dart';
import 'package:flutter_application_1/components/lobby.dart';
import 'package:flutter_application_1/multiplayer/firestoreClasses.dart';
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

  Future<void> _initializeGame() async {
    currentGame = await GameLogic.createGame();

    if (widget.role != PlayerRole.singleplayer) {
      _lobbyStream = FirebaseFirestore.instance
          .collection('lobbies')
          .doc(widget.lobbyId)
          .snapshots();

      final docRef = db.collection("lobbies").doc(widget.lobbyId);
      var doc = await docRef.get();

      if (!mounted) return;

      lobby = GameLobby.fromFirestore(doc);
      print("initial lobby: ${lobby.toJson()}");

      subscribeToLobbyUpdates();
      reactToLobby();
    }

    // Call setState *after* game is initialized to trigger the build.
    setState(() {});
  }

  void reactToLobby() {
    // Only the host needs to control the lobby
    if (widget.role != PlayerRole.multiplayerHost) return;

    // Upload the current round info to the server
    if (lobby.status == GameStatus.waitingRoundInfo.value) {
      print("Host will upload round to server.");
      Country? top = getTopCountry();
      Country? bottom = getBottomCountry();
      String currentStat = currentGame.getCurrentStat();

      if ((top == null) || (bottom == null)) {
        print("Error when reacting to round change. Top or bottom country was not loaded hence cannot update the server.");
        return;
      }

      if (widget.lobbyId.isEmpty) {
        print("Error: Lobby ID is null or empty. Cannot write document.");
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
      };

      final docRef = db.collection("lobbies").doc(widget.lobbyId);

      docRef.update(updateData)
        .then((_) {
          print("Lobby document successfully written!");
        })
        .catchError((e) {
          print("Error writing document to Firestore: $e");
        });
      return;
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
        print("New lobby: ${lobby.toJson()}");

        // Update the UI with the new lobby
        setState(() {});

        if ((lobby.status == GameStatus.finished.value) || (lobby.status == GameStatus.canceled.value)) {
          _lobbySubscription?.cancel();
          return;
        }

        // When a round finishes and status is 'waiting', the host will react.
        if (lobby.status == GameStatus.waitingRoundInfo.value) {
          reactToLobby();
        }
      },
      onError: (error) {
        print("There was an error fetching the lobby from the stream: $error");
      },
    );
  }

  Country? getTopCountry() {
    CountryData? stats = currentGame.getCurrentCountry();
    if (stats == null) {
      return null;
    }
    return Country.fromCountryData(currentGame.rounds[currentGame.currentRoundIndex], stats);
  }

  Country? getBottomCountry() {
    CountryData? stats = currentGame.getNextCountry();
    if (stats == null) {
      return null;
    }
    return Country.fromCountryData(currentGame.rounds[currentGame.currentRoundIndex + 1], stats);
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
  }

  void _onWrong() async {
    int finalScore = currentGame.totalScore;
    // Add the current round's score before ending if it's time restricted mode
    if (widget.timeRestriction && _currentScore > 0) {
      finalScore = currentGame.totalScore;
    }
    await HighScore.setIfHigher(finalScore);
    final highScore = await HighScore.get();

    currentGame = await GameLogic.createGame();
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
      print("Waiting for the next round!");
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
      print("Guessing on the map!");
      print("Topcountry: ${round.topCountry!.name}");
      print("Bottomcountry: ${round.bottomCountry!.name}");
      print("Statistic: ${round.statistic!}");

      // Return the Stack directly
      return Stack(
        children: [
          MapGame(
            selectedCountry: round.topCountry!.name,
            hiddenCountry: round.bottomCountry!.name,
            onTargetFound: () async {
              setState(() {
                _isMapTimerActive = false;
              });
              _addScore(_currentScore);
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