import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:provider/provider.dart';

class ScatterPlotView extends StatelessWidget {
  const ScatterPlotView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegressionModelProvider>();

    final zx1Data = provider.zx1Data;
    final zx2Data = provider.zx2Data;
    final zx3Data = provider.zx3Data;
    final zyData = provider.zyData;
    final zyHat = provider.predictedValues;

    final x1Data = provider.x1Data;
    final x2Data = provider.x2Data;
    final x3Data = provider.x3Data;
    final yData = provider.yData;
    final yHat = provider.yHat;

    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              ScatterPlot(
                xData: zx1Data,
                yData: zyData,
                predictedValues: zyHat,
                title: 'Zx1 and Zy',
              ),
              const Divider(),
              ScatterPlot(
                xData: zx2Data,
                yData: zyData,
                predictedValues: zyHat,
                title: 'Zx2 and Zy',
              ),
              const Divider(),
              ScatterPlot(
                xData: zx3Data,
                yData: zyData,
                predictedValues: zyHat,
                title: 'Zx3 and Zy',
              ),
            ],
          ),
          const Divider(),
          Column(
            children: [
              ScatterPlot(
                xData: x1Data,
                yData: yData,
                predictedValues: yHat,
                title: 'X1 and Y',
              ),
              const Divider(),
              ScatterPlot(
                xData: x2Data,
                yData: yData,
                predictedValues: yHat,
                title: 'X2 and Y',
              ),
              const Divider(),
              ScatterPlot(
                xData: x3Data,
                yData: yData,
                predictedValues: yHat,
                title: 'X3 and Y',
              ),
            ],
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
    return ConstrainedBox( // or SizedBox
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width / 3,
        maxHeight: 300, // Provide a finite height constraint
      ),
      child: charts.ScatterPlotChart(
        seriesList,
        animate: true,
        behaviors: [
          charts.ChartTitle(
            title,
            subTitle: 'Red - Predicted Values',
          ),
        ],
      ),
    );
  }
}

class DataPoint {
  DataPoint(this.x, this.y);

  final num x;
  final num y;
}
