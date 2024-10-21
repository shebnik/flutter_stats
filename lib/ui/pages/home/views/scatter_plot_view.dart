// import 'package:community_charts_flutter/community_charts_flutter.dart'
//     as charts;
// import 'package:flutter/material.dart';
// import 'package:flutter_stats/providers/outliers_provider.dart';
// import 'package:provider/provider.dart';

// class ScatterPlotView extends StatelessWidget {
//   const ScatterPlotView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<OutliersProvider>();

//     final zx1Data = provider.zx1Data;
//     final zx2Data = provider.zx2Data;
//     final zx3Data = provider.zx3Data;
//     final zyData = provider.zyData;
//     final zyHat = provider.predictedValues;

//     final x1Data = provider.x1Data;
//     final x2Data = provider.x2Data;
//     final x3Data = provider.x3Data;
//     final yData = provider.yData;
//     final yHat = provider.yHat;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         Column(
//           children: [
//             ScatterPlot(
//               xData: zx1Data,
//               yData: zyData,
//               predictedValues: zyHat,
//               title: 'Zx1 and Zy',
//               xLabel: 'Zx1',
//               yLabel: 'Zy',
//             ),
//             const Divider(),
//             ScatterPlot(
//               xData: zx2Data,
//               yData: zyData,
//               predictedValues: zyHat,
//               title: 'Zx2 and Zy',
//               xLabel: 'Zx2',
//               yLabel: 'Zy',
//             ),
//             const Divider(),
//             ScatterPlot(
//               xData: zx3Data,
//               yData: zyData,
//               predictedValues: zyHat,
//               title: 'Zx3 and Zy',
//               xLabel: 'Zx3',
//               yLabel: 'Zy',
//             ),
//           ],
//         ),
//         const Divider(),
//         Column(
//           children: [
//             ScatterPlot(
//               xData: x1Data,
//               yData: yData,
//               predictedValues: yHat,
//               title: 'X1 and Y',
//               xLabel: 'X1',
//             ),
//             const Divider(),
//             ScatterPlot(
//               xData: x2Data,
//               yData: yData,
//               predictedValues: yHat,
//               title: 'X2 and Y',
//               xLabel: 'X2',
//             ),
//             const Divider(),
//             ScatterPlot(
//               xData: x3Data,
//               yData: yData,
//               predictedValues: yHat,
//               title: 'X3 and Y',
//               xLabel: 'X3',
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class ScatterPlot extends StatelessWidget {
//   const ScatterPlot({
//     required this.xData,
//     required this.yData,
//     required this.predictedValues,
//     required this.title,
//     this.xLabel = 'X',
//     this.yLabel = 'Y',
//     super.key,
//   });

//   final List<num> xData;
//   final List<num> yData;
//   final List<num> predictedValues;
//   final String title;
//   final String xLabel;
//   final String yLabel;

//   @override
//   Widget build(BuildContext context) {
//     final dataPoints = <DataPoint>[];

//     for (var i = 0; i < xData.length; i++) {
//       dataPoints.add(DataPoint(xData[i], yData[i]));
//     }

//     final predictedPoints = <DataPoint>[];

//     for (var i = 0; i < xData.length; i++) {
//       predictedPoints.add(DataPoint(xData[i], predictedValues[i]));
//     }

//     final dataSeries = charts.Series(
//       data: dataPoints,
//       domainFn: (point, _) => point.x,
//       measureFn: (point, _) => point.y,
//       id: 'data',
//     );

//     final predictedLineSeries = charts.Series<DataPoint, num>(
//       id: 'predicted',
//       colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
//       domainFn: (DataPoint point, _) => point.x,
//       measureFn: (DataPoint point, _) => point.y,
//       data: predictedPoints,
//     );

//     final series = [
//       dataSeries,
//       predictedLineSeries,
//     ];

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: ScatterPlotChart(
//         series,
//         title: title,
//         xLabel: xLabel,
//         yLabel: yLabel,
//       ),
//     );
//   }
// }

// class ScatterPlotChart extends StatelessWidget {
//   const ScatterPlotChart(
//     this.seriesList, {
//     required this.title,
//     this.xLabel = 'X',
//     this.yLabel = 'Y',
//     super.key,
//   });

//   final List<charts.Series<DataPoint, num>> seriesList;
//   final String title;
//   final String xLabel;
//   final String yLabel;

//   @override
//   Widget build(BuildContext context) {
//     final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
//     return ConstrainedBox(
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width / 3,
//         maxHeight: 400,
//       ),
//       child: charts.ScatterPlotChart(
//         seriesList,
//         animate: true,
//         behaviors: [
//           charts.ChartTitle(
//             title,
//             subTitle: 'Red - Predicted Values',
//             titleStyleSpec: charts.TextStyleSpec(
//               fontSize: 16,
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//             subTitleStyleSpec: charts.TextStyleSpec(
//               fontSize: 14,
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//           ),
//           charts.ChartTitle(
//             xLabel,
//             behaviorPosition: charts.BehaviorPosition.bottom,
//             titleStyleSpec: charts.TextStyleSpec(
//               fontSize: 14,
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//           ),
//           charts.ChartTitle(
//             yLabel,
//             behaviorPosition: charts.BehaviorPosition.start,
//             titleStyleSpec: charts.TextStyleSpec(
//               fontSize: 14,
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//           ),
//         ],
//         secondaryMeasureAxis: charts.NumericAxisSpec(
//           renderSpec: charts.GridlineRendererSpec(
//             labelStyle: charts.TextStyleSpec(
//               fontSize: 14,
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//             lineStyle: charts.LineStyleSpec(
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//           ),
//         ),
//         primaryMeasureAxis: charts.NumericAxisSpec(
//           renderSpec: charts.GridlineRendererSpec(
//             labelStyle: charts.TextStyleSpec(
//               fontSize: 14,
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//             lineStyle: charts.LineStyleSpec(
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//           ),
//         ),
//         domainAxis: charts.NumericAxisSpec(
//           renderSpec: charts.GridlineRendererSpec(
//             labelStyle: charts.TextStyleSpec(
//               fontSize: 14,
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//             lineStyle: charts.LineStyleSpec(
//               color: isDarkTheme
//                   ? charts.MaterialPalette.white
//                   : charts.MaterialPalette.black,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DataPoint {
//   DataPoint(this.x, this.y);

//   final num x;
//   final num y;
// }
