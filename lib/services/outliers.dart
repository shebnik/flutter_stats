import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/services/algebra.dart';
import 'package:flutter_stats/services/fisher.dart';

class Outliers {
  Outliers(this.metrics) {
    _x1 = metrics.map((e) => e.dit!).toList();
    _x2 = metrics.map((e) => e.cbo!).toList();
    _x3 = metrics.map((e) => e.wmc!).toList();
    _y = metrics.map((e) => e.rfc!).toList();

    normalizeData();
  }

  final Algebra _algebra = Algebra();

  void normalizeData() {
    _zx1 = _x1.map(_algebra.logBase10).toList();
    _zx2 = _x2.map(_algebra.logBase10).toList();
    _zx3 = _x3.map(_algebra.logBase10).toList();
    _zy = _y.map(_algebra.logBase10).toList();
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

  List<List<double>> calculateCovarianceMatrix() {
    final values = <List<double>>[_zy, _zx1, _zx2, _zx3];
    return List.generate(
      4,
      (i) => List.generate(4, (j) {
        final sum = List.generate(
          n,
          (k) =>
              (values[i][k] - _algebra.average(values[i])) *
              (values[j][k] - _algebra.average(values[j])),
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

  List<double> calculateMahalanobisDistances() {
    final covInv = invertMatrix(calculateCovarianceMatrix());
    final values = <List<double>>[_zy, _zx1, _zx2, _zx3];
    final means = values.map(_algebra.average).toList();

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

  List<double> calculateTestStatistics() {
    final distances = calculateMahalanobisDistances();
    final factor = (n - 4) * n / ((pow(n, 2) - 1) * 4);
    return distances.map((d) => factor * d).toList();
  }

  Future<double?> calculateFisherFDistribution() =>
      Fisher.inv(alpha: alpha, df1: 4, df2: n - 4);

  // Future<(List<double>, List<double>)> calculatePredictionInterval() async {
  //   final yHat = calculatePredictedValues();

  //   final zx = Matrix.fromColumns([
  //     Vector.fromList(List.filled(n, 1.0)),
  //     Vector.fromList(_zx1),
  //     Vector.fromList(_zx2),
  //     Vector.fromList(_zx3),
  //   ]);

  //   final residuals = Vector.fromList(
  //     List.generate(n, (i) => _zy[i] - yHat[i]),
  //   );
  //   final mse = residuals.dot(residuals) / (n - 4);

  //   final leverage = zx * (zx.transpose() * zx).inverse() * zx.transpose();
  //   final leverageDiagonal = List.generate(n, (i) => leverage[i][i]);
  //   final se =
  //    List.generate(n, (i) => sqrt(mse * (1 + leverageDiagonal[i])));

  //   final tValue = await Student.inv2T(alpha: 1 - alpha / 2, df: n - 4);
  //   final margin = List.generate(n, (i) => tValue! * se[i]);

  //   final lowerBound = List.generate(n, (i) => yHat[i] - margin[i]);
  //   final upperBound = List.generate(n, (i) => yHat[i] + margin[i]);

  //   return (lowerBound, upperBound);
  // }

  Future<List<int>> determineOutliers() async {
    final testStatistics = calculateTestStatistics();
    final f = await calculateFisherFDistribution();
    if (f == null) {
      debugPrint('Failed to calculate Fisher F distribution');
      return [];
    }

    final mahalanobisOutliers =
        List.generate(n, (i) => i).where((i) => testStatistics[i] > f).toList();

    // final (lower, upper) = await calculatePredictionInterval();

    // final intervalOutliers = List.generate(n, (i) => i)
    //     .where((i) => _zy[i] < lower[i] || _zy[i] > upper[i])
    //     .toList();

    return mahalanobisOutliers;
  }

  // Future<List<ModelInterval>> calculateLinearIntervals() async {
  //   final q = await Student.inv2T(alpha: 1 - alpha / 2, df: n - 4);
  //   if (q == null) {
  //     debugPrint('Failed to calculate Student T distribution');
  //     return [];
  //   }

  //   final zyHat = calculatePredictedValues();
  //   final sy = sqrt(
  //     (1 / (n - 4)) *
  //         List.generate(n, (i) => pow(_zy[i] - zyHat[i], 2))
  //             .reduce((a, b) => a + b),
  //   );

  //   return _calculateIntervals(
  //     zyHat,
  //     sy,
  //     q,
  //     _zx1,
  //     _zx2,
  //     _zx3,
  //     zx1Avg,
  //     zx2Avg,
  //     zx3Avg,
  //   );
  // }

  // Future<List<ModelInterval>> calculateNonLinearIntervals() async {
  //   final q = await Student.inv2T(alpha: 1 - alpha / 2, df: n - 4);
  //   if (q == null) {
  //     debugPrint('Failed to calculate Student T distribution');
  //     return [];
  //   }

  //   final yHat = calculateYHat();
  //   final sy = sqrt(
  //     (1 / (n - 4)) *
  //         List.generate(n, (i) => pow(_y[i] - yHat[i], 2))
  //             .reduce((a, b) => a + b),
  //   );

  //   return _calculateIntervals(
  //  yHat, sy, q, _x1, _x2, _x3, x1Avg, x2Avg, x3Avg,);
  // }

  // List<ModelInterval> _calculateIntervals(
  //   List<double> yHat,
  //   double sy,
  //   double q,
  //   List<double> x1,
  //   List<double> x2,
  //   List<double> x3,
  //   double x1Avg,
  //   double x2Avg,
  //   double x3Avg,
  // ) {
  //   final sumSquaredDiffs = List.generate(
  //     3,
  //     (j) => List.generate(n, (i) => pow(x1[i] - x1Avg, 2))
  //         .reduce((a, b) => a + b),
  //   );

  //   return List.generate(n, (i) {
  //     final value = 1 / n +
  //         List.generate(3, (j) => pow(x1[i] - x1Avg, 2) / sumSquaredDiffs[j])
  //             .reduce((a, b) => a + b);

  //     return ModelInterval(
  //       index: i + 1,
  //       calculatedValues: yHat[i],
  //       lowerConfidenceLimit: yHat[i] - q * sy * sqrt(value),
  //       upperConfidenceLimit: yHat[i] + q * sy * sqrt(value),
  //       lowerPredictionLimit: yHat[i] - q * sy * sqrt(1 + value),
  //       upperPredictionLimit: yHat[i] + q * sy * sqrt(1 + value),
  //     );
  //   });
  // }
}
