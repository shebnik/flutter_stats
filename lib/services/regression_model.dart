// ignore_for_file: prefer_final_locals, omit_local_variable_types, non_constant_identifier_names, lines_longer_than_80_chars

import 'dart:math';

import 'package:flutter_stats/models/interval/model_interval.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/services/fisher.dart';
import 'package:flutter_stats/services/student.dart';

class RegressionModel {
  RegressionModel(this.metrics)
      : x = metrics.map((e) => e.numberOfClasses!).toList(),
        y = metrics.map((e) => e.linesOfCode!).toList(),
        Zx = metrics.map((e) => log(e.numberOfClasses!) / log(10)).toList(),
        Zy = metrics.map((e) => log(e.linesOfCode!) / log(10)).toList();

  List<Metrics> metrics;
  List<double> x;
  List<double> y;
  List<double> Zx;
  List<double> Zy;

  int get n => metrics.length;
  double get xAvg => x.reduce((a, b) => a + b) / n;
  double get yAvg => y.reduce((a, b) => a + b) / n;
  double get ZxAvg => Zx.reduce((a, b) => a + b) / n;
  double get ZyAvg => Zy.reduce((a, b) => a + b) / n;

  List<List<double>> calculateCovarianceMatrix() {
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

  List<double> calculateMahalanobisDistances(List<List<double>> covInv) {
    List<double> zxDiff = Zx.map((x) => x - ZxAvg).toList();
    List<double> zyDiff = Zy.map((y) => y - ZyAvg).toList();

    List<double> diffVector = List.filled(n * 2, 0);

    for (int i = 0; i < n; i++) {
      diffVector[i] = zxDiff[i];
      diffVector[i + n] = zyDiff[i];
    }

    List<double> distances = List.filled(n, 0);

    for (int i = 0; i < n; i++) {
      double x = diffVector[i];
      double y = diffVector[i + n];
      List<double> row = [x, y];

      double distance = 0;
      for (int j = 0; j < 2; j++) {
        for (int k = 0; k < 2; k++) {
          distance += row[j] * covInv[j][k] * row[k];
        }
      }

      distances[i] = distance;
    }

    return distances;
  }

  List<double> calculateTestStatistics(List<double> distances) {
    List<double> testStatistics = List.filled(n, 0);

    for (int i = 0; i < n; i++) {
      testStatistics[i] = (n - 2) * n / ((pow(n, 2) - 1) * 2) * distances[i];
    }

    return testStatistics;
  }

  double calculateFisherFDistribution() {
    return Fisher.inv(
      alpha: 0.05,
      df1: 2,
      df2: n - 2,
    );
  }

  List<int> determineOutliers(List<double> testStatistics) {
    double f = calculateFisherFDistribution();
    List<int> outliers = [];
    for (int i = 0; i < n; i++) {
      if (testStatistics[i] > f) {
        outliers.add(i);
      }
    }
    return outliers;
  }

  List<double> calculateRegressionCoefficients() {
    double b1Numerator = 0;
    double b1Denominator = 0;
    for (int i = 0; i < Zx.length; i++) {
      b1Numerator += (Zx[i] - ZxAvg) * (Zy[i] - ZyAvg);
      b1Denominator += (Zx[i] - ZxAvg) * (Zx[i] - ZxAvg);
    }

    double b1 = b1Numerator / b1Denominator;
    double b0 = ZyAvg - b1 * ZxAvg;

    return [b0, b1];
  }

  List<double> calculatePredictedValues(List<double> b) {
    double b0 = b[0];
    double b1 = b[1];

    List<double> Zy_hat = List.filled(n, 0);
    for (int i = 0; i < n; i++) {
      Zy_hat[i] = b0 + b1 * Zx[i];
    }

    return Zy_hat;
  }

  List<double> calculateYHat(List<double> predictedValues) {
    return predictedValues.map((value) => pow(10, value)).toList().cast();
  }

  ModelQuality calculateModelQuality(List<double> predictedValues) {
    final yHat = calculateYHat(predictedValues);

    final yDiffSquared =
        y.map((value) => pow(value - yHat[y.indexOf(value)], 2)).toList();
    final yAvgDiffSquared = y.map((value) => pow(value - yAvg, 2)).toList();

    final yDividedDiff = List.generate(y.length, (index) {
      return (y[index] - yHat[index]) / y[index];
    });

    final sy = yDiffSquared.reduce((value, element) => value + element);
    final rSquared =
        1 - (sy / yAvgDiffSquared.reduce((value, element) => value + element));

    final mmre = yDividedDiff
            .map((diff) => diff.abs())
            .reduce((value, element) => value + element) /
        y.length;

    final pred =
        yDividedDiff.where((diff) => diff.abs() < 0.25).length / y.length;

    return ModelQuality(
      rSquared: rSquared,
      sy: sy.toDouble(),
      mmre: mmre,
      pred: pred,
    );
  }

  List<ModelInterval> calculateLinearIntervals() {
    List<ModelInterval> intervals = [];

    final q = Student.inv2T(alpha: 0.05 / 2, df: n - 2);

    final ZyHat = calculatePredictedValues(calculateRegressionCoefficients());
    final sy = sqrt(
      (1 / (n - 2)) *
          Zy.map((value) => pow(value - ZyHat[Zy.indexOf(value)], 2))
              .reduce((value, element) => value + element),
    );

    for (int i = 0; i < n; i++) {
      final value = 1 / n +
          (pow(Zx[i] - ZxAvg, 2) /
              Zx.map((value) => pow(value - ZxAvg, 2))
                  .reduce((value, element) => value + element));

      intervals.add(
        ModelInterval(
          index: i + 1,
          calculatedValues: ZyHat[i],
          lowerConfidenceLimit: ZyHat[i] - q * sy * sqrt(value),
          upperConfidenceLimit: ZyHat[i] + q * sy * sqrt(value),
          lowerPredictionLimit: ZyHat[i] - q * sy * sqrt(1 + value),
          upperPredictionLimit: ZyHat[i] + q * sy * sqrt(1 + value),
        ),
      );
    }
    return intervals;
  }

  List<ModelInterval> calculatenonLinearIntervals() {
    List<ModelInterval> intervals = [];

    final q = Student.inv2T(alpha: 0.05 / 2, df: n - 2);

    final yHat = calculateYHat(
      calculatePredictedValues(calculateRegressionCoefficients()),
    );
    final sy = sqrt(
      (1 / (n - 2)) *
          y
              .map((value) => pow(value - yHat[y.indexOf(value)], 2))
              .reduce((value, element) => value + element),
    );

    for (int i = 0; i < n; i++) {
      final value = 1 / n +
          (pow(x[i] - xAvg, 2) /
              x
                  .map((value) => pow(value - xAvg, 2))
                  .reduce((value, element) => value + element));

      intervals.add(
        ModelInterval(
          index: i + 1,
          calculatedValues: yHat[i],
          lowerConfidenceLimit: yHat[i] - q * sy * sqrt(value),
          upperConfidenceLimit: yHat[i] + q * sy * sqrt(value),
          lowerPredictionLimit: yHat[i] - q * sy * sqrt(1 + value),
          upperPredictionLimit: yHat[i] + q * sy * sqrt(1 + value),
        ),
      );
    }
    return intervals;
  }
}
