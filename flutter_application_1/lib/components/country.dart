import 'package:flutter/material.dart';

class Country {
  String name;
  int population;
  double forestedArea;
  int surfaceArea;
  double co2Emissions;
  double gdpPerCapita;

  Country(
    this.name,
    this.population,
    this.forestedArea,
    this.surfaceArea,
    this.co2Emissions,
    this.gdpPerCapita,
  );
}

enum CountryField {
  population,
  forestedArea,
  surfaceArea,
  co2Emissions,
  gdpPerCapita,
}