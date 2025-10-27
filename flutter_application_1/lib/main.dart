import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_screen.dart';
import 'package:flutter_application_1/themes/app_theme.dart';
import 'API.dart';

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppTheme.windowBase,
        appBarTheme: AppBarTheme(
          backgroundColor: AppTheme.windowBase,
          foregroundColor: AppTheme.lightPurple,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
