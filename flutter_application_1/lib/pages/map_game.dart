import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../GameLogic.dart';
import '../components/country.dart';
import '../components/timer_indicator.dart';
import './comapre.dart';
import './high_score.dart';
import './home_screen.dart';

class MapGame extends StatefulWidget {
  final bool timeRestriction;
  
  const MapGame({
    super.key,
    required this.timeRestriction,
  });

  @override
  State<MapGame> createState() => _MapGameState();
}

class _MapGameState extends State<MapGame> {
  late MapShapeSource _shapeSource;
  late MapZoomPanBehavior _zoomPan;
  String? _targetCountry;
  int? _selectedIndex;
  bool _hasSelectedCountry = false;
  int _currentScore = 50;
  bool _isTimerActive = true;

  CountryField _getCompareField(String statName) {
    switch (statName) {
      case 'Surface Area':
        return CountryField.surfaceArea;
      case 'Population':
        return CountryField.population;
      case 'CO2 Emissions':
        return CountryField.co2Emissions;
      case 'Forested Area':
        return CountryField.forestedArea;
      case 'GDP per Capita':
        return CountryField.gdpPerCapita;
      default:
        return CountryField.population; // fallback
    }
  }

  void _onCorrect() async {
    final game = GameLogic.getCurrentGame();
    if (game != null) {
      // Points have already been added in the compare view
      await GameLogic.nextRound();
      if (!mounted) return;
      
      // Pop back to map view
      Navigator.pop(context);
      
      // Reset state for new round
      setState(() {
        _currentScore = 50;
        _targetCountry = game.rounds[game.currentRoundIndex];
        _selectedIndex = null;
        _hasSelectedCountry = false;
        _isTimerActive = true;  // Restart timer for new round
      });
    }
  }

  void _onWrong() async {
    final game = GameLogic.getCurrentGame();
    int finalScore = game?.totalScore ?? 0;
    // Add the current round's score before ending if it's time restricted mode
    if (widget.timeRestriction && _currentScore > 0 && game != null) {
      finalScore = game.totalScore;
    }
    await HighScore.setIfHigher(finalScore);
    final highScore = await HighScore.get();
    
    GameLogic.resetGame();
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Game Over')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Game Over!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  'Score: $finalScore',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  'High Score: $highScore',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapGame(
                              timeRestriction: widget.timeRestriction,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Play Again'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Home'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTimeUp() {
    _onWrong();
  }

  void _updateScore(int score) {
    setState(() {
      _currentScore = score;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await GameLogic.createGame();
    
    final game = GameLogic.getCurrentGame();
    if (game != null) {
      setState(() {
        _targetCountry = game.rounds[game.currentRoundIndex];
      });
    }

    _shapeSource = MapShapeSource.asset(
      'assets/europe.geojson',
      shapeDataField: 'NAME',
      dataCount: EuropeMapData.countries.length,
      primaryValueMapper: (int index) => EuropeMapData.countries[index],
      shapeColorValueMapper: (int index) => Colors.grey.shade200,
    );

    _zoomPan = MapZoomPanBehavior(
      enablePanning: true,
      enableDoubleTapZooming: true,
      focalLatLng: const MapLatLng(55.5260, 15.2551), // Europe-ish center
      zoomLevel: 2.0,
      minZoomLevel: 1.0,
      maxZoomLevel: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_targetCountry == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          SfMaps(
            layers: [
              MapShapeLayer(
                source: _shapeSource,
                zoomPanBehavior: _zoomPan,
                selectedIndex: _selectedIndex ?? -1,
                selectionSettings: const MapSelectionSettings(
                  color: Colors.green,
                  strokeColor: Colors.white,
                  strokeWidth: 1.2,
                ),
                onSelectionChanged: (int index) {
                  setState(() {
                    _selectedIndex = index;
                    _hasSelectedCountry = true;
                  });
                },
              ),
            ],
          ),
          if (widget.timeRestriction) Positioned(
            top: 20,
            left: 20,
            child: TimerIndicator(
              isActive: _isTimerActive,
              onScore: _updateScore,
              onTimeUp: _handleTimeUp,
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _hasSelectedCountry ? () {
                // Check if selected country matches target
                final selectedCountry = _selectedIndex != null ? 
                  EuropeMapData.countries[_selectedIndex!] : null;
                
                if (selectedCountry == _targetCountry) {
                  // Stop this view's timer and add the map score
                  setState(() {
                    _isTimerActive = false;
                  });
                  
                  final game = GameLogic.getCurrentGame();
                  if (game != null && widget.timeRestriction) {
                    // Add the map score immediately when correct country is found
                    game.addToScore(_currentScore);
                  }
                  
                  if (game != null) {
                    final currentCountry = game.getCurrentCountry();
                    final nextCountry = game.getNextCountry();
                    if (currentCountry != null && nextCountry != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComparePage(
                            timeRestriction: widget.timeRestriction,
                            compareField: _getCompareField(game.getCurrentStat()),
                            topCountry: Country(
                              game.rounds[game.currentRoundIndex],
                              currentCountry.population,
                              currentCountry.forestedArea.toDouble(),
                              currentCountry.surfaceArea,
                              currentCountry.co2Emissions.toDouble(),
                              currentCountry.gdpPerCapita.toDouble(),
                            ),
                            bottomCountry: Country(
                              game.rounds[game.currentRoundIndex + 1],
                              nextCountry.population,
                              nextCountry.forestedArea.toDouble(),
                              nextCountry.surfaceArea,
                              nextCountry.co2Emissions.toDouble(),
                              nextCountry.gdpPerCapita.toDouble(),
                            ),
                            correctCallback: _onCorrect,
                            wrongCallback: _onWrong,
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  _onWrong();
                }
              } : null,
              label: Text(_hasSelectedCountry ? 'Answer' : 'Find "$_targetCountry"'),
              icon: Icon(_hasSelectedCountry ? Icons.check : Icons.search),
            ),
          ),
        ],
      ),
    );
  }
}

class EuropeMapData {
  static const List<String> countries = <String>[
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
    'Georgia',
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
    'Andorra',
    'Luxembourg',
    'Monaco',
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
    'San Marino',
    'Serbia',
    'Vatican City',
    'Russia',
  ];
}