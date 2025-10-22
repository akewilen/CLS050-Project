import 'package:flutter/material.dart';
import '../GameLogic.dart';
import 'comapre.dart';
import 'map_game.dart';
import '../components/country.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  Future<void> _openCompareModal({
    required CountryField compareField,
    required String topName,
    required String bottomName,
    required Country topCountry,
    required Country bottomCountry,
  }) async {
    // showGeneralDialog pushes a *modal route*, not a new page in your app flow.
    await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Compare',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.black, // or Colors.transparent + your own Scaffold
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.white,
              body: ComparePage(
                compareField: compareField,
                topCountry: topCountry,
                bottomCountry: bottomCountry,
                // When correct: call your game logic, then close the modal.
                correctCallback: () {
                  // your existing onCorrect:
                  _onCorrect();
                  Navigator.of(context).pop(true); // close the modal
                },
                // When wrong: keep modal open, but let your game logic react.
                wrongCallback: () {
                  _onWrong();
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _onCorrect() async {
    print("You were correct!");
    await GameLogic.nextRound();
    setState(() {
      // Trigger rebuild with new game state
    });
  }

  void _onWrong() async {
    print("You were wrong!");
    GameLogic.resetGame();
    await GameLogic.createGame();
    setState(() {
      // Trigger rebuild with new game state
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
  Widget build(BuildContext context) {
    final game = GameLogic.getCurrentGame();
    if (game == null) {
      // Handle error case
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Error: Game not initialized')),
        ),
      );
    }

    final firstCountry = game.getCurrentCountry();
    final secondCountry = game.getNextCountry();
    final firstCountryName = game.rounds[game.currentRoundIndex];
    final secondCountryName = game.rounds[game.currentRoundIndex + 1];
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
      home: MapGame(
        selectedCountry: firstCountryName,
        hiddenCountry: secondCountryName,
        onTargetFound: () async {
          // show the full-screen compare overlay
          await _openCompareModal(
            compareField: compareField,
            topName: firstCountryName,
            bottomName: secondCountryName,
            topCountry: topCountry,
            bottomCountry: bottomCountry,
          );
          // Uncomment setState to reselct the first country when guessed wrong
          //setState(() {});
        },
      ),
    );
  }
}
