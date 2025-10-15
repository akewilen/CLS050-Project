import 'package:flutter/material.dart';

class Country {
  String name;
  int population;
  double forestedArea;

  Country(this.name, this.population, this.forestedArea);
}

final swedenTest = Country('Sweden', 10400000, 69.0);
final italyTest = Country('Italy', 0, 30.0);

enum CountryField {
  population,
  forestedArea,
}