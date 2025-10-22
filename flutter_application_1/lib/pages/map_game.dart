import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class MapGame extends StatefulWidget {
  const MapGame({
    super.key,
    required this.selectedCountry, //Upper country
    required this.hiddenCountry, //Lower country
    //this.onTargetFound, //Function to navigate to the higher/lower game
    //this.onAnyTap, //If tapped elsewhere, not sure if this can be used yet
  });

  final String selectedCountry;
  final String hiddenCountry;

  /// Callback when the user taps the target country.
  //final ValueChanged<int>? onTargetFound;

  /// Optional callback for any tap (index, name)
  //final void Function(int index, String name)? onAnyTap;

  @override
  State<MapGame> createState() => _MapGameState();
}

class _MapGameState extends State<MapGame> {
  late MapShapeSource _shapeSource;
  late MapZoomPanBehavior _zoomPan;

  /// Local “selected” state mirrors the preselected, and updates when target found.
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();

    _selectedIndex = EuropeMapData.countries.indexWhere(
      (c) => c == widget.selectedCountry,
    );

    _shapeSource = MapShapeSource.asset(
      'assets/europe.geojson',
      shapeDataField: 'NAME',
      dataCount: EuropeMapData.countries.length,
      primaryValueMapper: (int index) => EuropeMapData.countries[index],
      // Base color — selected color is controlled via `selectionSettings`.
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

  /*
  @override
  void didUpdateWidget() {
    //super.didUpdateWidget(oldWidget);
    // If parent starts a new round, sync our selected index with the new preselected.
    if (_selectedIndex == widget.hidden) {
      setState(() => _hiddenCountry = widget.hiddenCountry);
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    return SfMaps(
      layers: [
        MapShapeLayer(
          source: _shapeSource,
          zoomPanBehavior: _zoomPan,

          selectedIndex: _selectedIndex,
          selectionSettings: const MapSelectionSettings(
            color: Colors.green,
            strokeColor: Colors.white,
            strokeWidth: 1.2,
          ),

          onSelectionChanged: (int index) {
            //final tappedName = EuropeMapData.countries[index];
            //widget.onAnyTap?.call(index, tappedName);

            // Only promote the selection if it matches the target.
            if (index ==
                EuropeMapData.countries.indexWhere(
                  (c) => c == widget.hiddenCountry,
                )) {
              setState(() => _selectedIndex = index);
              //widget.onTargetFound?.call(index);
            }
          },
        ),
      ],
    );
  }
}

/// Central place for the country list so both parent and map widget can access it.
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
    'Lichtenstein',
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
