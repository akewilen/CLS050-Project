import 'package:flutter/material.dart';
import 'API.dart';
import 'GameLogic.dart';
import 'components/country.dart';
import 'pages/comapre.dart';
import 'pages/home_screen.dart';
import 'pages/score_screen.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {

  // Api key loading
  WidgetsFlutterBinding.ensureInitialized();
  await loadEnv();
  print('API Key loaded: ${getApiKey() != null}');

  //test a full game sequence (rounds + stats+ api)
  //await GameLogic.testPrintAllRounds();
  await GameLogic.createGame();

  // Setting up firebase
  // see: https://firebase.google.com/docs/flutter/setup?authuser=0&platform=ios
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}




class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final game = GameLogic.getCurrentGame();
    if (game == null) {
      // Handle error case
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: Game not initialized'),
          ),
        ),
      );
    }

    final currentCountry = game.getCurrentCountry();
    final nextCountry = game.getNextCountry();
    final compareField = _getCompareField(game.getCurrentStat());

    if (currentCountry == null || nextCountry == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error: Countries not loaded'),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Countries',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ComparePage(
        compareField: compareField,
        topCountry: Country(
          game.rounds[game.currentRoundIndex],
          currentCountry.population,
          currentCountry.forestedArea.toDouble(),
          currentCountry.surfaceArea,
          currentCountry.co2Emissions.toDouble(),
          currentCountry.gdpPerCapita.toDouble(),
        ),
        bottomCountry: Country(
          game.rounds[game.currentRoundIndex + 1],
          nextCountry.population,
          nextCountry.forestedArea.toDouble(),
          nextCountry.surfaceArea,
          nextCountry.co2Emissions.toDouble(),
          nextCountry.gdpPerCapita.toDouble(),
        ),
        correctCallback: _onCorrect,
        wrongCallback: _onWrong,
      ),
    );
  }
}
