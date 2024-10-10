import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/interval/model_interval.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/services/fisher.dart';
import 'package:flutter_stats/services/student.dart';
import 'package:ml_linalg/linalg.dart';

class RegressionModel {
  RegressionModel(this.metrics) {
    _x1 = metrics.map((e) => e.dit!).toList();
    _x2 = metrics.map((e) => e.cbo!).toList();
    _x3 = metrics.map((e) => e.wmc!).toList();
    _y = metrics.map((e) => e.rfc!).toList();

    normalizeData();
  }

  void normalizeData() {
    _zx1 = _x1.map(_logBase10).toList();
    _zx2 = _x2.map(_logBase10).toList();
    _zx3 = _x3.map(_logBase10).toList();
    _zy = _y.map(_logBase10).toList();
  }

  late final List<Metrics> metrics;
  late final List<double> _x1;
  late final List<double> _x2;
  late final List<double> _x3;
  late final List<double> _y;

  late final List<double> _zx1;
  late final List<double> _zx2;
  late final List<double> _zx3;
  late final List<double> _zy;

  int get n => metrics.length;
  double get x1Avg => _average(_x1);
  double get x2Avg => _average(_x2);
  double get x3Avg => _average(_x3);
  double get yAvg => _average(_y);
  double get zx1Avg => _average(_zx1);
  double get zx2Avg => _average(_zx2);
  double get zx3Avg => _average(_zx3);
  double get zyAvg => _average(_zy);

  List<double> get zx1 => _zx1;
  List<double> get zx2 => _zx2;
  List<double> get zx3 => _zx3;
  List<double> get zy => _zy;

  static double _logBase10(double value) {
    if (value <= 0) return 0;
    return log(value) / log(10);
  }

  static double _average(List<double> values) =>
      values.reduce((a, b) => a + b) / values.length;

  List<List<double>> calculateCovarianceMatrix() {
    final values = <List<double>>[_zy, _zx1, _zx2, _zx3];
    return List.generate(
      4,
      (i) => List.generate(4, (j) {
        final sum = List.generate(
          n,
          (k) =>
              (values[i][k] - _average(values[i])) *
              (values[j][k] - _average(values[j])),
        ).reduce((a, b) => a + b);
        return sum / n;
      }),
    );
  }

  List<List<double>> invertMatrix(List<List<double>> matrix) {
    final size = matrix.length;
    final identityMatrix = List<List<double>>.generate(
      size,
      (i) => List.generate(size, (j) => i == j ? 1.0 : 0.0),
    );
    final workingMatrix = matrix.map((row) => row.toList()).toList();

    for (var i = 0; i < size; i++) {
      final diagElement = workingMatrix[i][i];
      for (var j = 0; j < size; j++) {
        workingMatrix[i][j] /= diagElement;
        identityMatrix[i][j] /= diagElement;
      }

      for (var k = 0; k < size; k++) {
        if (k == i) continue;
        final factor = workingMatrix[k][i];
        for (var j = 0; j < size; j++) {
          workingMatrix[k][j] -= factor * workingMatrix[i][j];
          identityMatrix[k][j] -= factor * identityMatrix[i][j];
        }
      }
    }

    return identityMatrix;
  }

  List<double> calculateMahalanobisDistances(List<List<double>> covInv) {
    final values = <List<double>>[_zy, _zx1, _zx2, _zx3];
    final means = values.map(_average).toList();

    return List.generate(n, (i) {
      final diff = List<double>.generate(4, (j) => values[j][i] - means[j]);
      final product = List<double>.generate(
        4,
        (j) => List.generate(4, (k) => covInv[j][k] * diff[k])
            .reduce((a, b) => a + b),
      );
      return List.generate(4, (j) => product[j] * diff[j])
          .reduce((a, b) => a + b);
    });
  }

  List<double> calculateTestStatistics(List<double> distances) {
    final factor = (n - 4) * n / ((pow(n, 2) - 1) * 4);
    return distances.map((d) => factor * d).toList();
  }

  Future<double?> calculateFisherFDistribution() =>
      Fisher.inv(alpha: alpha, df1: 4, df2: n - 4);

  Future<List<int>> determineOutliers(List<double> testStatistics) async {
    final f = await calculateFisherFDistribution();
    if (f == null) {
      debugPrint('Failed to calculate Fisher F distribution');
      return [];
    }
    final mahalanobisOutliers =
        List.generate(n, (i) => i).where((i) => testStatistics[i] > f).toList();

    final intervals = await calculateLinearIntervals();
    final lowerBound =
        intervals.map((interval) => interval.lowerPredictionLimit).toList();
    final upperBound =
        intervals.map((interval) => interval.upperPredictionLimit).toList();
    final predictionIntervalOutliers = List.generate(n, (i) => i)
        .where((i) => _zy[i] < lowerBound[i] || _zy[i] > upperBound[i])
        .toList();

    // Combine both outlier detection methods
    final combinedOutliers = {
      ...mahalanobisOutliers,
      ...predictionIntervalOutliers,
    }.toList()
      ..sort();

    return combinedOutliers;
  }

  List<double> calculateRegressionCoefficients() {
    final x = Matrix.fromList(
      List.generate(n, (i) => [1.0, _zx1[i], _zx2[i], _zx3[i]]),
    );
    final y = Vector.fromList(_zy);

    final xTranspose = x.transpose();
    final xTx = xTranspose * x;
    final xTxInv = xTx.inverse();
    final xTy = xTranspose * y;
    final coffs = xTxInv * xTy;

    return List.from(coffs.map((value) => value.first));
  }

  List<double> calculatePredictedValues(List<double> b) => List.generate(
        n,
        (i) => b[0] + b[1] * _zx1[i] + b[2] * _zx2[i] + b[3] * _zx3[i],
      );

  List<double> calculateYHat(List<double> predictedValues) =>
      predictedValues.map((value) => pow(10, value)).toList().cast<double>();

  ModelQuality calculateModelQuality(List<double> predictedValues) {
    final yHat = calculateYHat(predictedValues);

    final yDiffSquared = List.generate(n, (i) => pow(_y[i] - yHat[i], 2));
    final yAvgDiffSquared = _y.map((value) => pow(value - yAvg, 2)).toList();

    final yDividedDiff = List.generate(n, (i) => (_y[i] - yHat[i]) / _y[i]);

    final sy = yDiffSquared.reduce((a, b) => a + b);
    final rSquared = 1 - (sy / yAvgDiffSquared.reduce((a, b) => a + b));

    final mmre =
        yDividedDiff.map((diff) => diff.abs()).reduce((a, b) => a + b) / n;

    final pred = yDividedDiff.where((diff) => diff.abs() < 0.25).length / n;

    return ModelQuality(rSquared: rSquared, mmre: mmre, pred: pred);
  }

  Future<List<ModelInterval>> calculateLinearIntervals() async {
    final q = await Student.inv2T(alpha: alpha / 2, df: n - 4);
    if (q == null) {
      debugPrint('Failed to calculate Student T distribution');
      return [];
    }

    final zyHat = calculatePredictedValues(calculateRegressionCoefficients());
    final sy = sqrt(
      (1 / (n - 4)) *
          List.generate(n, (i) => pow(_zy[i] - zyHat[i], 2))
              .reduce((a, b) => a + b),
    );

    return _calculateIntervals(
      zyHat,
      sy,
      q,
      _zx1,
      _zx2,
      _zx3,
      zx1Avg,
      zx2Avg,
      zx3Avg,
    );
  }

  Future<List<ModelInterval>> calculateNonLinearIntervals() async {
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
          List.generate(n, (i) => pow(_y[i] - yHat[i], 2))
              .reduce((a, b) => a + b),
    );

    return _calculateIntervals(yHat, sy, q, _x1, _x2, _x3, x1Avg, x2Avg, x3Avg);
  }

  List<ModelInterval> _calculateIntervals(
    List<double> yHat,
    double sy,
    double q,
    List<double> x1,
    List<double> x2,
    List<double> x3,
    double x1Avg,
    double x2Avg,
    double x3Avg,
  ) {
    final sumSquaredDiffs = List.generate(
      3,
      (j) => List.generate(n, (i) => pow(x1[i] - x1Avg, 2))
          .reduce((a, b) => a + b),
    );

    return List.generate(n, (i) {
      final value = 1 / n +
          List.generate(3, (j) => pow(x1[i] - x1Avg, 2) / sumSquaredDiffs[j])
              .reduce((a, b) => a + b);

      return ModelInterval(
        index: i + 1,
        calculatedValues: yHat[i],
        lowerConfidenceLimit: yHat[i] - q * sy * sqrt(value),
        upperConfidenceLimit: yHat[i] + q * sy * sqrt(value),
        lowerPredictionLimit: yHat[i] - q * sy * sqrt(1 + value),
        upperPredictionLimit: yHat[i] + q * sy * sqrt(1 + value),
      );
    });
  }
}
