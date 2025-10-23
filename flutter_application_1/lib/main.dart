import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_screen.dart';
import 'API.dart';
import 'GameLogic.dart';
import 'components/country.dart';
import 'pages/comapre.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
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

    return MaterialApp(
      title: 'Countries',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
