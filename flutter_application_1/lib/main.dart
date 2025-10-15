import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/country.dart';

// Project dependencies
import 'package:flutter_application_1/pages/compare.dart';

void main() {
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
