import 'package:flutter/material.dart';

// Project dependencies
import 'package:flutter_application_1/components/country.dart';
import '../themes/app_theme.dart';

class ComparePage extends StatelessWidget {
  final CountryField compareField;
  final Country topCountry;
  final Country bottomCountry;

  final void Function() correctCallback;
  final void Function() wrongCallback;

  const ComparePage({
    Key? key,
    required this.compareField,
    required this.topCountry,
    required this.bottomCountry,
    required this.correctCallback,
    required this.wrongCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.black),
        child: Column(
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
                      Text("${topCountry.name}'s", style: AppTheme.countryNameTextStyle, textAlign: TextAlign.center),
                      Text((compareField == CountryField.population) ? "population is" : "forested area", style: AppTheme.statisticTypeTextStyle, textAlign: TextAlign.center),
                      Text((compareField == CountryField.population) ? "${topCountry.population} million" : "${topCountry.forestedArea} square km", style: AppTheme.statisticTextStyle, textAlign: TextAlign.center),
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
                        Text("${bottomCountry.name}'s", style: AppTheme.countryNameTextStyle, textAlign: TextAlign.center),
                        Text("population is", style: AppTheme.statisticTypeTextStyle, textAlign: TextAlign.center),
                        TextButton(
                          style: AppTheme.upperCompareButton,
                          onPressed: () {
                            var stats = (compareField == CountryField.population) ? (topCountry.population, bottomCountry.population) : (topCountry.forestedArea, bottomCountry.forestedArea);
                            (stats.$1 < stats.$2) ? correctCallback() : wrongCallback();
                          },
                          child: const Text('Higher'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          style: AppTheme.lowerCompareButton,
                          onPressed: () {
                            var stats = (compareField == CountryField.population) ? (topCountry.population, bottomCountry.population) : (topCountry.forestedArea, bottomCountry.forestedArea);
                            (stats.$1 > stats.$2) ? correctCallback() : wrongCallback();
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
      ),
    );
  }
}
