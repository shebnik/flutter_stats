import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:provider/provider.dart';

class ScatterPlotView extends StatelessWidget {
  const ScatterPlotView({super.key});

  @override
  Widget build(BuildContext context) {
    final xData = context.watch<RegressionModelProvider>().xData;
    final yData = context.watch<RegressionModelProvider>().yData;
    final regressionLine =
        context.watch<RegressionModelProvider>().predictedValues;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: CustomPaint(
        painter: ScatterPlotPainter(
          xData: xData,
          yData: yData,
          regressionLine: regressionLine,
        ),
      ),
    );
  }
}

class ScatterPlotPainter extends CustomPainter {
  ScatterPlotPainter({
    required this.xData,
    required this.yData,
    required this.regressionLine,
  });

  final List<double> xData;
  final List<double> yData;
  final List<double> regressionLine;

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale factors to fit data to canvas size
    final maxX = xData.reduce(math.max);
    final minX = xData.reduce(math.min);
    final maxY = yData.reduce(math.max);
    final minY = yData.reduce(math.min);
    final scaleX = size.width / (maxX - minX);
    final scaleY = size.height / (maxY - minY);

    // Draw data points
    for (int i = 0; i < xData.length; i++) {
      final x = (xData[i] - minX) * scaleX;
      final y = size.height - (yData[i] - minY) * scaleY;
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.blue);
    }

    // Draw regression line
    canvas.drawPoints(
        PointMode.lines,
        _generateRegressionLinePoints(scaleX, scaleY, minX, maxY, minY, size),
        Paint()..color = Colors.red);
  }

  List<Offset> _generateRegressionLinePoints(
      double scaleX, double scaleY, num minX, num maxX, num minY, Size size) {
    return List.generate(100, (i) {
      final x = i / 100 * size.width;
      final y = regressionLine[0] + regressionLine[1] * (x / scaleX + minX);
      return Offset(x, size.height - (y - minY) * scaleY);
    });
  }

  @override
  bool shouldRepaint(ScatterPlotPainter oldDelegate) => true;
}
