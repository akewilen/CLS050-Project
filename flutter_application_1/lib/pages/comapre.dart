import 'package:flutter/material.dart';
import 'package:flutter_application_1/GameLogic.dart';
import 'package:intl/intl.dart';
import '../components/country.dart';
import '../components/timer_indicator.dart';
import '../themes/app_theme.dart';

class ComparePage extends StatefulWidget {
  final bool timeRestriction;
  final CountryField compareField;
  final Country topCountry;
  final Country bottomCountry;
  final void Function() correctCallback;
  final void Function() wrongCallback;

  const ComparePage({
    Key? key,
    required this.timeRestriction,
    required this.compareField,
    required this.topCountry,
    required this.bottomCountry,
    required this.correctCallback,
    required this.wrongCallback,
  }) : super(key: key);

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  int _currentScore = 50;
  bool _isActive = true;  // Track timer state locally

  @override
  void initState() {
    super.initState();
    _currentScore = 50;  // Start with full score in compare view
  }

  void _handleScoreUpdate(int score) {
    if (!mounted) return;
    setState(() {
      _currentScore = score;
    });
  }

  void _handleCorrect() {
    // Stop the timer by setting active to false
    setState(() {
      _isActive = false;
    });
    
    // Add score from this view
    if (widget.timeRestriction) {
      final game = GameLogic.getCurrentGame();
      if (game != null) {
        game.addToScore(_currentScore);
      }
    }
    
    // Call callback to proceed
    widget.correctCallback();
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

  String _getStatValueText(Country country, CountryField field) {
    switch (field) {
      case CountryField.population:
        return '${NumberFormat('#,###').format(country.population)} million';
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
      body: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.black),
        child: Stack(
          children: [
            // Round counter in top left
            Positioned(
              left: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.window90,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Builder(
                  builder: (context) {
                    final game = GameLogic.getCurrentGame();
                    final roundNumber = game?.currentRoundIndex != null ? 
                      game!.currentRoundIndex + 1 : 0;
                    return Text(
                      'Round $roundNumber',
                      style: AppTheme.countryNameTextStyle,
                    );
                  },
                ),
              ),
            ),
            if (widget.timeRestriction) Positioned(
              top: 20,
              right: 20,
              child: TimerIndicator(
                isActive: _isActive,
                onScore: _handleScoreUpdate,
                onTimeUp: () {
                  // Make sure we handle the timeout cleanly
                  if (mounted) {
                    setState(() {
                      _isActive = false;
                    });
                    widget.wrongCallback();
                  }
                },
              ),
            ),
            // Main content
            Column(
              children: [
                Expanded(
                  flex: 48,
                  child: Container(
                    width: double.infinity,
                    color: AppTheme.window90,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${widget.topCountry.name}'s", style: AppTheme.countryNameTextStyle, textAlign: TextAlign.center),
                          Text(_getStatText(widget.compareField), style: AppTheme.statisticTypeTextStyle, textAlign: TextAlign.center),
                          Text(_getStatValueText(widget.topCountry, widget.compareField), style: AppTheme.statisticTextStyle, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),

                const Expanded(flex: 2, child: SizedBox.shrink()),

                Expanded(
                  flex: 48,
                  child: Container(
                    width: double.infinity,
                    color: AppTheme.window90,
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: DefaultTextStyle.merge(
                        style: AppTheme.statisticTypeTextStyle,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("${widget.bottomCountry.name}'s", style: AppTheme.countryNameTextStyle, textAlign: TextAlign.center),
                            Text(_getStatText(widget.compareField), style: AppTheme.statisticTypeTextStyle, textAlign: TextAlign.center),
                            TextButton(
                              style: AppTheme.upperCompareButton,
                              onPressed: () {
                                var value1 = _getCompareValue(widget.topCountry, widget.compareField);
                                var value2 = _getCompareValue(widget.bottomCountry, widget.compareField);
                                (value1 < value2) ? _handleCorrect() : widget.wrongCallback();
                              },
                              child: const Text('Higher'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              style: AppTheme.lowerCompareButton,
                              onPressed: () {
                                var value1 = _getCompareValue(widget.topCountry, widget.compareField);
                                var value2 = _getCompareValue(widget.bottomCountry, widget.compareField);
                                (value1 > value2) ? _handleCorrect() : widget.wrongCallback();
                              },
                              child: const Text('Lower'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}