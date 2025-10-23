import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import '../GameLogic.dart';
import '../components/country.dart';
import '../components/timer_indicator.dart';
import 'compare.dart';
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
  bool _hasSelectedCountry = false;
  bool _countryFound = false;

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
    if (_selectedIndex == null) {
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
                  setState(() => _selectedIndex = index);

                  final hiddenIndex = EuropeMapData.countries.indexWhere(
                    (c) => c == widget.hiddenCountry,
                  );

                  // Only promote the selection if it matches the target.
                  if (index == hiddenIndex) {
                    //setState(() => _selectedIndex = index);
                    //widget.onTargetFound();
                    _countryFound = true;
                  }

                  _hasSelectedCountry = true;
                },
              ),
            ],
          ),
          Positioned(bottom: 50, child: Text('Find: ${widget.hiddenCountry}')),

          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: _hasSelectedCountry
                  ? () {
                      // Check if selected country matches target

                      if (_countryFound) {
                        // Stop this view's timer and add the map score
                        widget.onTargetFound();
                      } else {
                        widget.onWrong();
                      }
                    }
                  : null,
              label: Text(
                _hasSelectedCountry
                    ? 'Answer'
                    : 'Find "${widget.hiddenCountry}}"',
              ),
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
