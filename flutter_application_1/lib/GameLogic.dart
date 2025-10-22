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
  int currentRoundIndex = 0;

  String getCurrentStat() => roundStats[currentRoundIndex];

  CountryData? getCurrentCountry() => countryStats[currentRoundIndex];
  CountryData? getNextCountry() => countryStats[currentRoundIndex + 1];
  bool hasNextRound() => currentRoundIndex < rounds.length - 2;
}

class GameLogic {
  static Game? _currentGame;

  static Future<Game?> createGame() async {
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
    await _fetchCountriesForCurrentRound(game);

    _currentGame = game;
    return game;
  }

  static Future<void> _fetchCountriesForCurrentRound(Game game) async {
    // Fetch current country if not already fetched
    if (!game.countryStats.containsKey(game.currentRoundIndex)) {
      final currentStats = await fetchCountryData(
        game.rounds[game.currentRoundIndex],
      );
      game.countryStats[game.currentRoundIndex] = currentStats;
    }

    // Fetch next country if not already fetched
    if (!game.countryStats.containsKey(game.currentRoundIndex + 1)) {
      final nextStats = await fetchCountryData(
        game.rounds[game.currentRoundIndex + 1],
      );
      game.countryStats[game.currentRoundIndex + 1] = nextStats;
    }
  }

  static Game? getCurrentGame() {
    if (_currentGame != null) {
      final game = _currentGame!;
      final current = game.getCurrentCountry();
      final next = game.getNextCountry();
      print('\n=== Round ${game.currentRoundIndex + 1} ===');
      print('Comparing: ${game.getCurrentStat()}');
      print(
        '${game.rounds[game.currentRoundIndex]} vs ${game.rounds[game.currentRoundIndex + 1]}',
      );
      print('Current values:');
      print(
        '- ${game.rounds[game.currentRoundIndex]}: ${_getStatValue(current, game.getCurrentStat())}',
      );
      print(
        '- ${game.rounds[game.currentRoundIndex + 1]}: ${_getStatValue(next, game.getCurrentStat())}',
      );
    }
    return _currentGame;
  }

  static Future<bool> nextRound() async {
    if (_currentGame == null || !_currentGame!.hasNextRound()) {
      return false;
    }
    _currentGame!.currentRoundIndex++;
    await _fetchCountriesForCurrentRound(_currentGame!);
    return true;
  }

  static void resetGame() {
    _currentGame = null;
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
    if (game == null) {
      print("Failed to create game");
      return;
    }

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

    while (await nextRound()) {
      print("\nRound ${game.currentRoundIndex + 1}:");
      print("Comparing: ${game.getCurrentStat()}");
      print("Country 1: ${game.rounds[game.currentRoundIndex]}");
      print(
        "Stats: ${game.countryStats[game.currentRoundIndex]?.surfaceArea}, ${game.countryStats[game.currentRoundIndex]?.population}, ${game.countryStats[game.currentRoundIndex]?.co2Emissions}, ${game.countryStats[game.currentRoundIndex]?.forestedArea}, ${game.countryStats[game.currentRoundIndex]?.gdpPerCapita}",
      );
      print("Country 2: ${game.rounds[game.currentRoundIndex + 1]}");
      print(
        "Stats: ${game.countryStats[game.currentRoundIndex + 1]?.surfaceArea}, ${game.countryStats[game.currentRoundIndex + 1]?.population}, ${game.countryStats[game.currentRoundIndex + 1]?.co2Emissions}, ${game.countryStats[game.currentRoundIndex + 1]?.forestedArea}, ${game.countryStats[game.currentRoundIndex + 1]?.gdpPerCapita}",
      );
    }
    print("\nTest complete!");
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
    'Lichtenstein',
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