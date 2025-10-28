import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/country.dart';
import '../themes/app_theme.dart';

class ComparePage extends StatefulWidget {
  final CountryField compareField;
  final Country topCountry;
  final Country bottomCountry;
  final void Function() correctCallback;
  final void Function() wrongCallback;
  final int roundNumber;

  const ComparePage({
    Key? key,
    required this.compareField,
    required this.topCountry,
    required this.bottomCountry,
    required this.correctCallback,
    required this.wrongCallback,
    required this.roundNumber,
  }) : super(key: key);

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  @override
  void initState() {
    super.initState();
  }

  String _getStatText(CountryField field) {
    switch (field) {
      case CountryField.population:
        return 'population is';
      case CountryField.forestedArea:
        return 'forested area is';
      case CountryField.surfaceArea:
        return 'surface area is';
      case CountryField.co2Emissions:
        return 'CO2 emissions are';
      case CountryField.gdpPerCapita:
        return 'GDP per capita is';
    }
  }

  static String _getStatValueText(Country country, CountryField field) {
    switch (field) {
      case CountryField.population:
        return NumberFormat(
          '#,###',
        ).format((country.population * 1000).toInt());
      case CountryField.forestedArea:
        return '${country.forestedArea} %';
      case CountryField.surfaceArea:
        return '${country.surfaceArea} km²';
      case CountryField.co2Emissions:
        return '${country.co2Emissions} tons';
      case CountryField.gdpPerCapita:
        return '\$${country.gdpPerCapita}';
    }
  }

  num _getCompareValue(Country country, CountryField field) {
    switch (field) {
      case CountryField.population:
        return country.population;
      case CountryField.forestedArea:
        return country.forestedArea;
      case CountryField.surfaceArea:
        return country.surfaceArea;
      case CountryField.co2Emissions:
        return country.co2Emissions;
      case CountryField.gdpPerCapita:
        return country.gdpPerCapita;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.black),
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                Expanded(
                  flex: 70,
                  child: Container(
                    alignment: AlignmentGeometry.bottomCenter,
                    padding: EdgeInsets.only(bottom: 24, top: 108),
                    width: double.infinity,
                    color: AppTheme.window90,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${widget.topCountry.name}'s",
                              style: AppTheme.countryNameTextStyle,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              _getStatText(widget.compareField),
                              style: AppTheme.statisticTypeTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Text(
                          _getStatValueText(
                            widget.topCountry,
                            widget.compareField,
                          ),
                          style: AppTheme.statisticTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const Expanded(flex: 1, child: SizedBox.shrink()),

                Expanded(
                  flex: 70,
                  child: Container(
                    alignment: AlignmentGeometry.topCenter,
                    padding: EdgeInsets.all(24),
                    width: double.infinity,
                    color: AppTheme.window90,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${widget.bottomCountry.name}'s",
                              style: AppTheme.countryNameTextStyle,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              _getStatText(widget.compareField),
                              style: AppTheme.statisticTypeTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            TextButton(
                              style: AppTheme.upperCompareButton,
                              onPressed: () {
                                var value1 = _getCompareValue(
                                  widget.topCountry,
                                  widget.compareField,
                                );
                                var value2 = _getCompareValue(
                                  widget.bottomCountry,
                                  widget.compareField,
                                );
                                (value1 < value2)
                                    ? widget.correctCallback()
                                    : widget.wrongCallback();
                              },
                              child: const Text('Higher'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              style: AppTheme.lowerCompareButton,
                              onPressed: () {
                                var value1 = _getCompareValue(
                                  widget.topCountry,
                                  widget.compareField,
                                );
                                var value2 = _getCompareValue(
                                  widget.bottomCountry,
                                  widget.compareField,
                                );
                                (value1 > value2)
                                    ? widget.correctCallback()
                                    : widget.wrongCallback();
                              },
                              child: const Text('Lower'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Round counter in top left
            Positioned(
              left: (0.75 * MediaQuery.of(context).size.width) / 2,
              width: 0.25 * MediaQuery.of(context).size.width,
              top: 22,
              child: Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.window90,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Builder(
                  builder: (context) {
                    return Text(
                      'Round ${widget.roundNumber}',
                      style: TextStyle(fontSize: 16, color: AppTheme.textColor),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
