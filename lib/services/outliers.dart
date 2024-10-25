import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/regression_factors/regression_factors.dart';
import 'package:flutter_stats/services/algebra.dart';
import 'package:flutter_stats/services/fisher.dart';
import 'package:flutter_stats/services/normalization.dart';
import 'package:flutter_stats/services/regression_model.dart';

class Outliers {
  Outliers(this.projects) {
    _normalizeData();
  }
  late final List<Project> projects;

  final Algebra _algebra = Algebra();
  final Normalization _normalization = Normalization();

  late final List<RegressionFactors> _factors;

  int get n => projects.length;
  int get p => _factors.first.x.length + 1;

  List<int> _outliers = [];
  List<int> get outliers => _outliers;

  void _normalizeData() {
    final normalizedTestProjects = _normalization.normalizeProjects(projects);
    _factors =
        normalizedTestProjects.map(RegressionFactors.fromProject).toList();
  }

  List<double> calculateMahalanobisDistances() {
    final values = _factors.toArray();
    final covInv =
        _algebra.invertMatrix(_algebra.calculateCovarianceMatrix(values));
    final means = values.map(_algebra.average).toList();

    return List.generate(n, (i) {
      final diff = List<double>.generate(p, (j) => values[j][i] - means[j]);
      final product = List<double>.generate(
        p,
        (j) => List.generate(p, (k) => covInv[j][k] * diff[k])
            .reduce((a, b) => a + b),
      );
      return List.generate(p, (j) => product[j] * diff[j])
          .reduce((a, b) => a + b);
    });
  }

  List<double> calculateTestStatistics() {
    final distances = calculateMahalanobisDistances();
    final factor = (n - p) * n / ((pow(n, 2) - 1) * p);
    return distances.map((d) => factor * d).toList();
  }

  Future<double?> calculateFisherFDistribution() =>
      Fisher.inv(alpha: alpha, df1: p, df2: n - p);

  Future<void> determineOutliers({
    bool includeIntervalsMethod = false,
    RegressionModel? regressionModel,
  }) async {
    if (includeIntervalsMethod && regressionModel == null) {
      debugPrint('Regression model is required for prediction intervals');
    }

    final testStatistics = calculateTestStatistics();
    final f = await calculateFisherFDistribution();
    if (f == null) {
      debugPrint('Failed to calculate Fisher F distribution');
      return;
    }

    final mahalanobisOutliers =
        List.generate(n, (i) => i).where((i) => testStatistics[i] > f).toList();

    if (includeIntervalsMethod && regressionModel != null) {
      final predictionOutliers =
          await calculatePredictionIntervalOutliers(regressionModel);
      final predictionIndices = List.generate(n, (i) => i)
          .where((i) => predictionOutliers[i])
          .toList();

      _outliers = {...mahalanobisOutliers, ...predictionIndices}.toList()
        ..sort();
    } else {
      _outliers = mahalanobisOutliers;
    }
  }

  Future<List<bool>> calculatePredictionIntervalOutliers(
    RegressionModel regressionModel,
  ) async {
    // Calculate prediction intervals
    final (lowerBound, upperBound) =
        await regressionModel.calculatePredictionInterval(useAllProjects: true);

    // Check if each point falls outside the prediction intervals
    return List.generate(n, (i) {
      final actualValue = _factors[i].y;
      return actualValue < lowerBound[i] || actualValue > upperBound[i];
    });
  }
}
