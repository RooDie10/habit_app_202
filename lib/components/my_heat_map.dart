import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMap extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final DateTime startDate;

  const MyHeatMap({
    super.key,
    required this.startDate,
    required this.datasets
  });

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      startDate: startDate,
      endDate: DateTime.now(),
      datasets: datasets,
      colorMode: ColorMode.color,
      defaultColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).textTheme.bodyText1?.color, // Use the text color defined in the theme
      showColorTip: false,
      showText: true,
      scrollable: true,
      size: 30,
      colorsets: {
    1: Colors.blue.shade300,
    3: Colors.blue.shade900,
    },
    );
  }
}