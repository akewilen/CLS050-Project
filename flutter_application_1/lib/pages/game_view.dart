import 'package:flutter/material.dart';
import '../GameLogic.dart';
import '../components/timer_indicator.dart';
import 'comapre.dart';
import 'home_screen.dart';
import 'map_game.dart';
import '../components/country.dart';
import 'score_screen.dart';
import 'high_score.dart';

class GameView extends StatefulWidget {
  const GameView({
    super.key,
    required this.timeRestriction,
    //required this.compareCountry,
  });

  final bool timeRestriction;
  //final String compareCountry;

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  int _currentScore = 50;
  bool _isTimerActive = true;

  Future<void> _openCompareModal({
    required CountryField compareField,
    required Country topCountry,
    required Country bottomCountry,
  }) async {
    // showGeneralDialog pushes a *modal route*, not a new page in your app flow.
    _isTimerActive = true;
    await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Compare',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.black, // or Colors.transparent + your own Scaffold
          child: Stack(
            children: [
              ComparePage(
                compareField: compareField,
                topCountry: topCountry,
                bottomCountry: bottomCountry,
                // When correct: call your game logic, then close the modal.
                correctCallback: () {
                  // your existing onCorrect:
                  _onCorrect();
                },
                // When wrong: keep modal open, but let your game logic react.
                wrongCallback: () {
                  _onWrong();
                },
              ),
              if (widget.timeRestriction)
                Positioned(
                  top: 20,
                  right: 20,
                  child: TimerIndicator(
                    isActive: _isTimerActive,
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

  void _addScore(Game game, int score) {
    game.addToScore(score);
    _currentScore = 50;
  }

  void _onCorrect() async {
    setState(() {
      _isTimerActive = false;
    });
    final game = GameLogic.getCurrentGame();
    if (game != null) {
      print('campareview score: $_currentScore');
      _addScore(game, _currentScore);
      // Points have already been added in the compare view
      await GameLogic.nextRound();
      if (!mounted) return;

      // Pop back to map view
      Navigator.pop(context);

      // Reset state for new round
      setState(() {
        _currentScore = 50;
        //_selectedIndex = null;
        //_hasSelectedCountry = false;
        _isTimerActive = true; // Restart timer for new round
      });
    }
  }

  void _onWrong() async {
    final game = GameLogic.getCurrentGame();
    int finalScore = game?.totalScore ?? 0;
    // Add the current round's score before ending if it's time restricted mode
    if (widget.timeRestriction && _currentScore > 0 && game != null) {
      finalScore = game.totalScore;
    }
    await HighScore.setIfHigher(finalScore);
    final highScore = await HighScore.get();

    GameLogic.resetGame();
    if (!mounted) return;

    Navigator.pushReplacement(
      //pushAndRemoveUntil... replace both compare och map in the navigation stack
      context,
      MaterialPageRoute(
        builder: (context) => ScoreScreen(
          timeRestriction: widget.timeRestriction,
          highScore: highScore,
          finalScore: finalScore,
        ),
      ),
    );
  }

  void _handleTimeUp() {
    if (mounted) {
      setState(() {
        _isTimerActive = false;
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

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await GameLogic.createGame();

    final game = GameLogic.getCurrentGame();

    if (game != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = GameLogic.getCurrentGame();

    if (game == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final firstCountry = game.getCurrentCountry();
    final secondCountry = game.getNextCountry();
    final compareField = _getCompareField(game.getCurrentStat());

    if (firstCountry == null || secondCountry == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: Countries not loaded')),
        ),
      );
    }

    final topCountry = Country(
      game.rounds[game.currentRoundIndex],
      firstCountry.population,
      firstCountry.forestedArea.toDouble(),
      firstCountry.surfaceArea,
      firstCountry.co2Emissions.toDouble(),
      firstCountry.gdpPerCapita.toDouble(),
    );

    final bottomCountry = Country(
      game.rounds[game.currentRoundIndex + 1],
      secondCountry.population,
      secondCountry.forestedArea.toDouble(),
      secondCountry.surfaceArea,
      secondCountry.co2Emissions.toDouble(),
      secondCountry.gdpPerCapita.toDouble(),
    );

    return MaterialApp(
      title: 'Countries',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Stack(
        children: [
          MapGame(
            selectedCountry: game.rounds[game.currentRoundIndex],
            hiddenCountry: game.rounds[game.currentRoundIndex + 1],
            onTargetFound: () async {
              // show the full-screen compare overlay
              setState(() {
                _isTimerActive = false;
              });
              print('mapview score: $_currentScore');
              _addScore(game, _currentScore);
              await _openCompareModal(
                compareField: compareField,
                topCountry: topCountry,
                bottomCountry: bottomCountry,
              );
              // Uncomment setState to reselct the first country when guessed wrong
              //setState(() {});
            },
            onWrong: _onWrong,
          ),
          if (widget.timeRestriction)
            Positioned(
              top: 20,
              right: 20,
              child: TimerIndicator(
                isActive: _isTimerActive,
                onScore: _updateScore,
                onTimeUp: _handleTimeUp,
              ),
            ),
        ],
      ),
    );
  }
}
