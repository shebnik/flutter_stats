// ignore_for_file: prefer_final_locals, omit_local_variable_types, non_constant_identifier_names, lines_longer_than_80_chars

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/interval/model_interval.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/services/fisher.dart';
import 'package:flutter_stats/services/student.dart';
import 'package:ml_linalg/linalg.dart';

const epsilon = 1e-10;

class RegressionModel {
  RegressionModel(this.metrics)
      : x1 = metrics.map((e) => e.dit!).toList(),
        x2 = metrics.map((e) => e.rfc!).toList(),
        x3 = metrics.map((e) => e.cbo!).toList(),
        y = metrics.map((e) => e.wmc!).toList(),
        Zx1 = metrics.map((e) => log(e.dit! + epsilon) / log(10)).toList(),
        Zx2 = metrics.map((e) => log(e.rfc! + epsilon) / log(10)).toList(),
        Zx3 = metrics.map((e) => log(e.cbo! + epsilon) / log(10)).toList(),
        Zy = metrics.map((e) => log(e.wmc! + epsilon) / log(10)).toList();

  List<Metrics> metrics;
  List<double> x1;
  List<double> x2;
  List<double> x3;
  List<double> y;
  List<double> Zx1;
  List<double> Zx2;
  List<double> Zx3;
  List<double> Zy;

  int get n => metrics.length;
  double get x1Avg => x1.reduce((a, b) => a + b) / n;
  double get x2Avg => x2.reduce((a, b) => a + b) / n;
  double get x3Avg => x3.reduce((a, b) => a + b) / n;
  double get yAvg => y.reduce((a, b) => a + b) / n;
  double get Zx1Avg => Zx1.reduce((a, b) => a + b) / n;
  double get Zx2Avg => Zx2.reduce((a, b) => a + b) / n;
  double get Zx3Avg => Zx3.reduce((a, b) => a + b) / n;
  double get ZyAvg => Zy.reduce((a, b) => a + b) / n;

  List<List<double>> calculateCovarianceMatrix() {
    List<List<double>> cov = List.generate(4, (_) => List.filled(4, 0));

    List<List<double>> values = [
      Zy,
      Zx1,
      Zx2,
      Zx3,
    ];

    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        double sum = 0;
        for (int k = 0; k < n; k++) {
          sum += (values[i][k] - values[i].reduce((a, b) => a + b) / n) *
              (values[j][k] - values[j].reduce((a, b) => a + b) / n);
        }
        cov[i][j] = sum / n;
      }
    }

    return cov;
  }

  List<List<double>> invertMatrix(List<List<double>> matrix) {
    int n = matrix.length;

    List<List<double>> identityMatrix =
        List.generate(n, (i) => List.generate(n, (j) => i == j ? 1.0 : 0.0));

    List<List<double>> a = matrix.map((row) => row.toList()).toList();

    for (int i = 0; i < n; i++) {
      double diagElement = a[i][i];
      if (diagElement == 0) {
        throw Exception('Matrix is not invertible');
      }
      for (int j = 0; j < n; j++) {
        a[i][j] /= diagElement;
        identityMatrix[i][j] /= diagElement;
      }

      for (int k = 0; k < n; k++) {
        if (k == i) continue;
        double factor = a[k][i];
        for (int j = 0; j < n; j++) {
          a[k][j] -= factor * a[i][j];
          identityMatrix[k][j] -= factor * identityMatrix[i][j];
        }
      }
    }

    return identityMatrix;
  }

  List<double> calculateMahalanobisDistances(List<List<double>> covInv) {
    List<double> distances = List.filled(n, 0);

    List<List<double>> values = [
      Zy,
      Zx1,
      Zx2,
      Zx3,
    ];

    for (int i = 0; i < n; i++) {
      List<double> row = List.filled(4, 0);
      for (int j = 0; j < 4; j++) {
        for (int k = 0; k < 4; k++) {
          row[j] += covInv[j][k] *
              (values[k][i] - values[k].reduce((a, b) => a + b) / n);
        }
      }

      for (int j = 0; j < 4; j++) {
        distances[i] +=
            row[j] * (values[j][i] - values[j].reduce((a, b) => a + b) / n);
      }
    }

    return distances;
  }

  List<double> calculateTestStatistics(List<double> distances) {
    List<double> testStatistics = List.filled(n, 0);

    for (int i = 0; i < n; i++) {
      testStatistics[i] = (n - 4) * n / ((pow(n, 2) - 1) * 4) * distances[i];
    }

    return testStatistics;
  }

  Future<double?> calculateFisherFDistribution() {
    return Fisher.inv(
      alpha: alpha,
      df1: 4,
      df2: n - 4,
    );
  }

  Future<List<int>> determineOutliers(List<double> testStatistics) async {
    double? f = await calculateFisherFDistribution();
    if (f == null) {
      debugPrint('Failed to calculate Fisher F distribution');
      return [];
    }
    List<int> outliers = [];
    for (int i = 0; i < n; i++) {
      if (testStatistics[i] > f) {
        outliers.add(i);
      }
    }
    return outliers;
  }

  List<double> calculateRegressionCoefficients() {
    final z = List.generate(n, (i) {
      return [Zx1[i], Zx2[i], Zx3[i], Zy[i]];
    });

    var x = z.map((row) => row.sublist(0, row.length - 1)).toList();
    var y = z.map((row) => row.last).toList();

    // Add a column of ones to X for the intercept term
    x = x.map((row) => [1.0, ...row]).toList();

    // Convert to matrices
    var xMatrix = Matrix.fromList(x);
    var yMatrix = Vector.fromList(y);

    // Calculate (X^T * X)^-1 * X^T * Y
    var xTranspose = xMatrix.transpose();
    var xTx = xTranspose * xMatrix;
    var xTxInv = xTx.inverse();
    var xTy = xTranspose * yMatrix;
    var coeffs = xTxInv * xTy;

    return List.from(coeffs.map((value) => value.first));
  }

  List<double> calculatePredictedValues(List<double> b) {
    double b0 = b[0];
    double b1 = b[1];
    double b2 = b[2];
    double b3 = b[3];

    List<double> Zy_hat = List.filled(n, 0);
    for (int i = 0; i < n; i++) {
      Zy_hat[i] = b0 + b1 * Zx1[i] + b2 * Zx2[i] + b3 * Zx3[i];
    }

    return Zy_hat;
  }

  List<double> calculateYHat(List<double> predictedValues) {
    return predictedValues
        .map((value) => pow(10, value))
        .toList()
        .cast<double>();
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

  Future<List<ModelInterval>> calculateLinearIntervals() async {
    List<ModelInterval> intervals = [];

    final q = await Student.inv2T(alpha: alpha / 2, df: n - 4);
    if (q == null) {
      debugPrint('Failed to calculate Student T distribution');
      return [];
    }

    final ZyHat = calculatePredictedValues(calculateRegressionCoefficients());
    final sy = sqrt(
      (1 / (n - 4)) *
          Zy.map((value) => pow(value - ZyHat[Zy.indexOf(value)], 2))
              .reduce((value, element) => value + element),
    );

    for (int i = 0; i < n; i++) {
      final value = 1 / n +
          (pow(Zx1[i] - Zx1Avg, 2) +
                  pow(Zx2[i] - Zx2Avg, 2) +
                  pow(Zx3[i] - Zx3Avg, 2)) /
              (Zx1.map((value) => pow(value - Zx1Avg, 2))
                      .reduce((value, element) => value + element) +
                  Zx2.map((value) => pow(value - Zx2Avg, 2))
                      .reduce((value, element) => value + element) +
                  Zx3.map((value) => pow(value - Zx3Avg, 2))
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

  Future<List<ModelInterval>> calculatenonLinearIntervals() async {
    List<ModelInterval> intervals = [];

    final q = await Student.inv2T(alpha: alpha / 2, df: n - 4);
    if (q == null) {
      debugPrint('Failed to calculate Student T distribution');
      return [];
    }

    final yHat = calculateYHat(
      calculatePredictedValues(calculateRegressionCoefficients()),
    );
    final sy = sqrt(
      (1 / (n - 4)) *
          y
              .map((value) => pow(value - yHat[y.indexOf(value)], 2))
              .reduce((value, element) => value + element),
    );

    for (int i = 0; i < n; i++) {
      final value = 1 / n +
          (pow(x1[i] - x1Avg, 2) +
                  pow(x2[i] - x2Avg, 2) +
                  pow(x3[i] - x3Avg, 2)) /
              (x1
                      .map((value) => pow(value - x1Avg, 2))
                      .reduce((value, element) => value + element) +
                  x2
                      .map((value) => pow(value - x2Avg, 2))
                      .reduce((value, element) => value + element) +
                  x3
                      .map((value) => pow(value - x3Avg, 2))
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
