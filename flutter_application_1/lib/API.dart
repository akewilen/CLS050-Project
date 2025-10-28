import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

String? _apiKey;

class CountryData {
  final int surfaceArea;
  final int population;
  final int co2Emissions;
  final int forestedArea;
  final int gdpPerCapita;

  CountryData({
    required this.surfaceArea,
    required this.population,
    required this.co2Emissions,
    required this.forestedArea,
    required this.gdpPerCapita,
  });

  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      surfaceArea: int.parse(json['surface_area'].toString()),
      population: int.parse(json['population'].toString()),
      co2Emissions: double.parse(json['co2_emissions'].toString()).round(),
      forestedArea: double.parse(json['forested_area'].toString()).round(),
      gdpPerCapita: double.parse(json['gdp_per_capita'].toString()).round(),
    );
  }
}

Future<void> loadEnv() async {
  try {
    _apiKey = API_KEY;
    print('Successfully loaded API key');
  } catch (e) {
    print('Error reading API key: $e');
    _apiKey = null;
  }
}

String? getApiKey() => _apiKey;

Future<CountryData?> fetchCountryData(String countryName) async {
  if (_apiKey == null) {
    print('API key not loaded');
    return null;
  }

  try {
    final response = await http.get(
      Uri.parse('https://api.api-ninjas.com/v1/country?name=$countryName'),
      headers: {'X-Api-Key': _apiKey!},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return CountryData.fromJson(data[0]);
      } else {
        print('No data found for country: $countryName');
        return null;
      }
    } else {
      print('Failed to fetch data: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching country data: $e');
    return null;
  }
}

