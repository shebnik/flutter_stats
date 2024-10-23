import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/regression_factors/regression_factors.dart';
import 'package:flutter_stats/services/algebra.dart';
import 'package:flutter_stats/services/fisher.dart';
import 'package:flutter_stats/services/normalization.dart';

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

  Future<List<int>> determineOutliers() async {
    final testStatistics = calculateTestStatistics();
    final f = await calculateFisherFDistribution();
    if (f == null) {
      debugPrint('Failed to calculate Fisher F distribution');
      return [];
    }

    final mahalanobisOutliers =
        List.generate(n, (i) => i).where((i) => testStatistics[i] > f).toList();

    return mahalanobisOutliers;
  }
}
