// ignore_for_file: non_constant_identifier_names, omit_local_variable_types, prefer_final_locals

import 'dart:math';

import 'package:flutter_stats/models/metrics/metrics.dart';

class RegressionModel {
  RegressionModel(this.metrics)
      : Zx = metrics.map((e) => log(e.numberOfClasses!) / log(10)).toList(),
        Zy = metrics.map((e) => log(e.linesOfCode!) / log(10)).toList();

  List<Metrics> metrics;
  List<double> Zx;
  List<double> Zy;

  int get n => metrics.length;

  List<List<double>> calculateCovarianceMatrix() {
    double ZxAvg = Zx.reduce((a, b) => a + b) / n;
    double ZyAvg = Zy.reduce((a, b) => a + b) / n;

    List<double> ZxZxAvgDiff = Zx.map((x) => x - ZxAvg).toList();
    List<double> ZyZyAvgDiff = Zy.map((y) => y - ZyAvg).toList();

    List<double> ZxZxAvgDiffSq = ZxZxAvgDiff.map((x) => x * x).toList();
    List<double> ZyZyAvgDiffSq = ZyZyAvgDiff.map((y) => y * y).toList();

    double covXY = 0;
    for (int i = 0; i < n; i++) {
      covXY += ZxZxAvgDiff[i] * ZyZyAvgDiff[i];
    }
    covXY /= n;

    double covXX = ZxZxAvgDiffSq.reduce((a, b) => a + b) / n;
    double covYY = ZyZyAvgDiffSq.reduce((a, b) => a + b) / n;

    return [
      [covXX, covXY],
      [covXY, covYY],
    ];
  }

  List<List<double>> invertMatrix(List<List<double>> matrix) {
    double det = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    return [
      [matrix[1][1] / det, -matrix[0][1] / det],
      [-matrix[1][0] / det, matrix[0][0] / det],
    ];
  }
}
