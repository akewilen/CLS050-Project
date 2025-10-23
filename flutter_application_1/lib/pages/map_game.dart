import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../GameLogic.dart';
import '../components/country.dart';
import '../components/timer_indicator.dart';
import './comapre.dart';
import './high_score.dart';
import './home_screen.dart';

class MapGame extends StatefulWidget {
  final String selectedCountry;
  final String hiddenCountry;
  final VoidCallback onTargetFound;
  final VoidCallback onWrong;

  const MapGame({
    super.key,
    required this.selectedCountry, //Upper country
    required this.hiddenCountry, //Lower country
    required this.onTargetFound, //Function to navigate to the higher/lower game
    required this.onWrong,
  });

  @override
  State<MapGame> createState() => _MapGameState();
}

class _MapGameState extends State<MapGame> {
  late MapShapeSource _shapeSource;
  late MapZoomPanBehavior _zoomPan;
  int? _selectedIndex;
  //bool _hasSelectedCountry = false; //?

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    _selectedIndex = EuropeMapData.countries.indexWhere(
      (c) => c == widget.selectedCountry,
    );

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
    final game = GameLogic.getCurrentGame();

    if (_selectedIndex == null || game == null) {
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
                  //final tappedName = EuropeMapData.countries[index];
                  //widget.onAnyTap?.call(index, tappedName);

                  final hiddenIndex = EuropeMapData.countries.indexWhere(
                    (c) => c == widget.hiddenCountry,
                  );

                  // Only promote the selection if it matches the target.
                  if (index == hiddenIndex) {
                    //game.addToScore(_currentScore);
                    setState(() => _selectedIndex = index);
                    widget.onTargetFound();
                  }
                },
              ),
            ],
          ),
          Positioned(bottom: 50, child: Text('Find: ${widget.hiddenCountry}')),
          /*
          if (widget.timeRestriction) Positioned(
            top: 20,
            left: 20,
            child: TimerIndicator(
              isActive: _isTimerActive,
              onScore: _updateScore,
              onTimeUp: _handleTimeUp,
            ),
          ),
          */
          /*
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _hasSelectedCountry ? () {
                // Check if selected country matches target
                final selectedCountry = _selectedIndex != null ? 
                  EuropeMapData.countries[_selectedIndex!] : null;
                
                if (selectedCountry == widget.selectedCountry) {
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
          */
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
