import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

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
  late MapShapeSource _sublayerSource;
  late MapZoomPanBehavior _zoomPan;
  int? _selectedIndex;
  int _wrongSelection = -1;
  int wrongCounter = 0;

  void handleCorrect(int index) {
    setState(() {
      _selectedIndex = index;
      _wrongSelection = -1;
    });
    widget.onTargetFound();
  }

  void handleWrong(int index) {
    wrongCounter++;
    if (wrongCounter > 2) {
      setState(() => _wrongSelection = 0);
      widget.onWrong();
    }
    setState(() => _wrongSelection = index);
  }

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

    _sublayerSource = MapShapeSource.asset(
      'assets/europe.geojson',
      shapeDataField: 'NAME',
      dataCount: EuropeMapData.countries.length,
      primaryValueMapper: (int index) => EuropeMapData.countries[index],
      shapeColorValueMapper: (int index) => Colors.transparent,
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
      backgroundColor: const Color.fromARGB(255, 146, 198, 241),
      body: Stack(
        //alignment: Alignment.center,
        children: [
          SfMaps(
            layers: [
              MapShapeLayer(
                source: _shapeSource,
                zoomPanBehavior: _zoomPan,
                selectedIndex: _selectedIndex ?? -1,
                selectionSettings: const MapSelectionSettings(
                  color: Color.fromARGB(255, 121, 183, 123),
                  strokeColor: Colors.white,
                  strokeWidth: 1.2,
                ),
                sublayers: [
                  MapShapeSublayer(
                    source: _sublayerSource,
                    selectedIndex: _wrongSelection,
                    selectionSettings: const MapSelectionSettings(
                      color: Color.fromARGB(255, 241, 128, 84),
                      strokeColor: Colors.white,
                      strokeWidth: 1.2,
                    ),
                    onSelectionChanged: (int index) {
                      final hiddenIndex = EuropeMapData.countries.indexWhere(
                        (c) => c == widget.hiddenCountry,
                      );
                      if (index != hiddenIndex) {
                        handleWrong(index);
                      } else {
                        handleCorrect(index);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text('Find: ${widget.hiddenCountry}'),
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
