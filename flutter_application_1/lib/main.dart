import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/country.dart';
import 'API.dart';
import 'GameLogic.dart';

// Project dependencies
import 'package:flutter_application_1/pages/compare.dart';

void main() async {

  // Api key loading
  WidgetsFlutterBinding.ensureInitialized();
  await loadEnv();
  print('API Key loaded: ${getApiKey() != null}');

  //test a full game sequence (rounds + stats+ api)
  //await GameLogic.testPrintAllRounds();

  
  runApp(const MyApp());
}


void correctPrint() {
  print("You were correct!");

}

void wrongPrint() {
  print("You were wrong!");
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countries',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ComparePage(
        compareField: CountryField.population,
        topCountry: swedenTest,
        bottomCountry: italyTest,
        correctCallback: correctPrint,
        wrongCallback: wrongPrint,
      ),
    );
  }
}
