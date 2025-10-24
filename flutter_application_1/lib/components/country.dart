import 'package:flutter_application_1/API.dart';

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

  // Factory constructor to create a Country from a JSON map
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      json['name'] as String? ?? 'Unknown',
      json['population'] as int? ?? 0,
      (json['forestedArea'] as num?)?.toDouble() ?? 0.0,
      json['surfaceArea'] as int? ?? 0,
      (json['co2Emissions'] as num?)?.toDouble() ?? 0.0,
      (json['gdpPerCapita'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static Country fromCountryData(String name, CountryData data) {
    return Country(
      name,
      data.population,
      data.forestedArea.toDouble(),
      data.surfaceArea,
      data.co2Emissions.toDouble(),
      data.gdpPerCapita.toDouble(),
    );
  }

  // Factory constructor to create a Country from a map (often from JSON)
  factory Country.fromMap(Map<String, dynamic> data) {
    return Country(
      // Ensure key names match what's expected in the map
      data['name'] as String,
      data['population'] as int,
      (data['forestedArea'] as num).toDouble(), // Use 'num' for safety when parsing double
      data['surfaceArea'] as int,
      (data['co2Emissions'] as num).toDouble(),
      (data['gdpPerCapita'] as num).toDouble(),
    );
  }

  // Method to convert a Country instance to a Map (often for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'population': population,
      'forestedArea': forestedArea,
      'surfaceArea': surfaceArea,
      'co2Emissions': co2Emissions,
      'gdpPerCapita': gdpPerCapita,
    };
  }
}

enum CountryField {
  population,
  forestedArea,
  surfaceArea,
  co2Emissions,
  gdpPerCapita,
}