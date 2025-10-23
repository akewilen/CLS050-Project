import 'API.dart';
import 'dart:math';

class Game {
  static const List<String> statNames = [
    'Surface Area',
    'Population',
    'CO2 Emissions',
    'Forested Area',
    'GDP per Capita',
  ];

  List<String> rounds = [];
  Map<int, CountryData?> countryStats =
      {}; // Using map to store only fetched countries
  List<String> roundStats =
      []; // Stores which stat is being compared in each round
  int playerHealth = 3;
  int currentRoundIndex = 1;
  int totalScore = 0;

  String getCurrentStat() => roundStats[currentRoundIndex];

  void addToScore(int points) {
    totalScore += points;
  }

  CountryData? getCurrentCountry() => countryStats[currentRoundIndex];
  CountryData? getNextCountry() => countryStats[currentRoundIndex + 1];
  bool hasNextRound() => currentRoundIndex < rounds.length - 2;
  bool isInitialized() => rounds.isNotEmpty;

  Future<void> nextRound() async {
    if (!hasNextRound()) {
      return;
    }
    currentRoundIndex++;
    await _fetchCountriesForCurrentRound();
  }

  Future<void> _fetchCountriesForCurrentRound() async {
    // Fetch current country if not already fetched
    if (!countryStats.containsKey(currentRoundIndex)) {
      final currentStats = await fetchCountryData(
        rounds[currentRoundIndex],
      );
      countryStats[currentRoundIndex] = currentStats;
    }

    // Fetch next country if not already fetched
    if (!countryStats.containsKey(currentRoundIndex + 1)) {
      final nextStats = await fetchCountryData(
        rounds[currentRoundIndex + 1],
      );
      countryStats[currentRoundIndex + 1] = nextStats;
    }
  }
}

class GameLogic {
  static Future<Game> createGame() async {
    final game = Game();
    // Create a copy of the countries list and shuffle it
    game.rounds = List<String>.from(europeanCountries)..shuffle(Random());

    // Generate random stats for each round
    final random = Random();
    for (int i = 0; i < game.rounds.length - 1; i++) {
      game.roundStats.add(
        Game.statNames[random.nextInt(Game.statNames.length)],
      );
    }

    // Only fetch the first two countries
    await game._fetchCountriesForCurrentRound();
    return game;
  }

  static dynamic _getStatValue(CountryData? country, String statName) {
    if (country == null) return 'N/A';
    switch (statName) {
      case 'Surface Area':
        return country.surfaceArea;
      case 'Population':
        return country.population;
      case 'CO2 Emissions':
        return country.co2Emissions;
      case 'Forested Area':
        return country.forestedArea;
      case 'GDP per Capita':
        return country.gdpPerCapita;
      default:
        return 'Unknown stat';
    }
  }

  static Future<void> testPrintAllRounds() async {
    print("Starting game sequence test...");
    final game = await createGame();

    print("\nRound 1:");
    print("Comparing: ${game.getCurrentStat()}");
    print("Country 1: ${game.rounds[0]}");
    print(
      "Stats: ${game.countryStats[0]?.surfaceArea}, ${game.countryStats[0]?.population}, ${game.countryStats[0]?.co2Emissions}, ${game.countryStats[0]?.forestedArea}, ${game.countryStats[0]?.gdpPerCapita}",
    );
    print("Country 2: ${game.rounds[1]}");
    print(
      "Stats: ${game.countryStats[1]?.surfaceArea}, ${game.countryStats[1]?.population}, ${game.countryStats[1]?.co2Emissions}, ${game.countryStats[1]?.forestedArea}, ${game.countryStats[1]?.gdpPerCapita}",
    );

    // while (await nextRound()) {
    //   print("\nRound ${game.currentRoundIndex + 1}:");
    //   print("Comparing: ${game.getCurrentStat()}");
    //   print("Country 1: ${game.rounds[game.currentRoundIndex]}");
    //   print(
    //     "Stats: ${game.countryStats[game.currentRoundIndex]?.surfaceArea}, ${game.countryStats[game.currentRoundIndex]?.population}, ${game.countryStats[game.currentRoundIndex]?.co2Emissions}, ${game.countryStats[game.currentRoundIndex]?.forestedArea}, ${game.countryStats[game.currentRoundIndex]?.gdpPerCapita}",
    //   );
    //   print("Country 2: ${game.rounds[game.currentRoundIndex + 1]}");
    //   print(
    //     "Stats: ${game.countryStats[game.currentRoundIndex + 1]?.surfaceArea}, ${game.countryStats[game.currentRoundIndex + 1]?.population}, ${game.countryStats[game.currentRoundIndex + 1]?.co2Emissions}, ${game.countryStats[game.currentRoundIndex + 1]?.forestedArea}, ${game.countryStats[game.currentRoundIndex + 1]?.gdpPerCapita}",
    //   );
    // }
    // print("\nTest complete!");
  }

  static const List<String> europeanCountries = [
    'Albania',
    'Bosnia and Herzegovina',
    'Bulgaria',
    'Cyprus',
    'Denmark',
    'Ireland',
    'Estonia',
    'Austria',
    'Czechia',
    'Finland',
    'France',
    'Germany',
    'Greece',
    'Croatia',
    'Hungary',
    'Iceland',
    'Italy',
    'Latvia',
    'Belarus',
    'Lithuania',
    'Slovakia',
    'North Macedonia',
    'Malta',
    'Belgium',
    'Luxembourg',
    'Montenegro',
    'Netherlands',
    'Norway',
    'Poland',
    'Portugal',
    'Romania',
    'Moldova',
    'Slovenia',
    'Spain',
    'Sweden',
    'Switzerland',
    'Turkey',
    'United Kingdom',
    'Ukraine',
    'Serbia',
    'Russia',
  ];
}


/*

Old list, in case I didn't check the names correctly

    'Albania',
    'Armenia',
    'Austria',
    'Azerbaijan',
    'Belarus',
    'Belgium',
    'Bosnia and Herzegovina',
    'Bulgaria',
    'Croatia',
    'Cyprus',
    'Czechia',
    'Denmark',
    'Estonia',
    'Finland',
    'France',
    'Georgia',
    'Germany',
    'Greece',
    'Hungary',
    'Iceland',
    'Ireland',
    'Italy',
    'Kazakhstan',
    'Kosovo',
    'Latvia',
    'Lithuania',
    'Luxembourg',
    'Malta',
    'Moldova',
    'Montenegro',
    'Netherlands',
    'North Macedonia',
    'Norway',
    'Poland',
    'Portugal',
    'Romania',
    'Russia',
    'Serbia',
    'Slovakia',
    'Slovenia',
    'Spain',
    'Sweden',
    'Switzerland',
    'Turkey',
    'Ukraine',
    'United Kingdom',
*/