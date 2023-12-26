import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:provider/provider.dart';

class ScatterPlotView extends StatelessWidget {
  const ScatterPlotView({super.key});

  @override
  Widget build(BuildContext context) {
    final zxData = context.watch<RegressionModelProvider>().zxData;
    final zyData = context.watch<RegressionModelProvider>().zyData;
    final zyHat = context.watch<RegressionModelProvider>().predictedValues;

    final xData = context.watch<RegressionModelProvider>().xData;
    final yData = context.watch<RegressionModelProvider>().yData;
    final yHat = context.watch<RegressionModelProvider>().yHat;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Row(
        children: [
          Expanded(
            child: ScatterPlot(
              xData: zxData,
              yData: zyData,
              predictedValues: zyHat,
              title: 'Zx and Zy',
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: ScatterPlot(
              xData: xData,
              yData: yData,
              predictedValues: yHat,
              title: 'X and Y',
            ),
          ),
        ],
      ),
    );
  }
}

class ScatterPlot extends StatelessWidget {
  const ScatterPlot({
    required this.xData,
    required this.yData,
    required this.predictedValues,
    required this.title,
    super.key,
  });

  final List<num> xData;
  final List<num> yData;
  final List<num> predictedValues;
  final String title;

  @override
  Widget build(BuildContext context) {
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
      child: ScatterPlotChart(series, title: title),
    );
  }
}

class ScatterPlotChart extends StatelessWidget {
  const ScatterPlotChart(
    this.seriesList, {
    required this.title,
    super.key,
  });

  final List<charts.Series<DataPoint, num>> seriesList;
  final String title;

  @override
  Widget build(BuildContext context) {
    return charts.ScatterPlotChart(
      seriesList,
      animate: true,
      behaviors: [
        charts.ChartTitle(
          title,
          subTitle: 'Red - Predicted Values',
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
