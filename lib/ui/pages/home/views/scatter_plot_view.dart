import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:provider/provider.dart';

class ScatterPlotView extends StatelessWidget {
  const ScatterPlotView({super.key});

  @override
  Widget build(BuildContext context) {
    final xData = context.watch<RegressionModelProvider>().xData;
    final yData = context.watch<RegressionModelProvider>().yData;
    final predictedValues =
        context.watch<RegressionModelProvider>().predictedValues;

    final dataPoints = <DataPoint>[];

    for (var i = 0; i < xData.length; i++) {
      dataPoints.add(DataPoint(xData[i], yData[i]));
    }

    final predictedPoints = <DataPoint>[];

    for (var i = 0; i < xData.length; i++) {
      predictedPoints.add(DataPoint(xData[i], predictedValues[i]));
    }

    final dataSeries = charts.Series(
      data: dataPoints,
      domainFn: (point, _) => point.x,
      measureFn: (point, _) => point.y,
      id: 'data',
    );

    final predictedLineSeries = charts.Series<DataPoint, num>(
      id: 'predicted',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (DataPoint point, _) => point.x,
      measureFn: (DataPoint point, _) => point.y,
      data: predictedPoints,
    );

    final series = [
      dataSeries,
      predictedLineSeries,
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ScatterPlotChart(series),
    );
  }
}

class ScatterPlotChart extends StatelessWidget {
  const ScatterPlotChart(this.seriesList, {super.key});

  final List<charts.Series<DataPoint, num>> seriesList;

  @override
  Widget build(BuildContext context) {
    return charts.ScatterPlotChart(
      seriesList,
      animate: true,
      behaviors: [
        charts.ChartTitle(
          'Zx, Zy and Predicted Values',
        ),
      ],
    );
  }
}

class DataPoint {
  DataPoint(this.x, this.y);

  final num x;
  final num y;
}
