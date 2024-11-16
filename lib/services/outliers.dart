import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/regression_factors/regression_factors.dart';
import 'package:flutter_stats/services/algebra.dart';
import 'package:flutter_stats/services/fisher.dart';
import 'package:flutter_stats/services/logging/logger_service.dart';
import 'package:flutter_stats/services/normalization.dart';
import 'package:flutter_stats/services/regression_model.dart';
import 'package:flutter_stats/services/utils.dart';

enum OutliersType { epsilon, predictionInterval }

class OutliersIterations {
  OutliersIterations({
    required this.step,
    required this.projects,
    required this.type,
    required this.whyOutliers,
  });

  final int step;
  final List<Project> projects;
  final OutliersType type;
  final List<String> whyOutliers;
  int get count => projects.length;
}

class OutliersProvider extends ChangeNotifier {
  final Algebra _algebra = Algebra();
  final Normalization _normalization = Normalization();
  final _log = LoggerService.instance;

  List<OutliersIterations> _iterations = [];
  List<OutliersIterations> get iterations => _iterations;

  Future<List<Project>> removeAllOutliers(List<Project> projects) async {
    _log.i('Removing all outliers');
    _iterations = [];
    var outliers = <Project>[];
    var whyOutliers = <String>[];
    var iteration = 1;
    do {
      (whyOutliers, outliers) = await determineEpsilonOutliers(projects);
      if (outliers.isNotEmpty) {
        _iterations.add(
          OutliersIterations(
            step: iteration,
            projects: outliers,
            whyOutliers: whyOutliers,
            type: OutliersType.epsilon,
          ),
        );
        projects.removeWhere((p) => outliers.contains(p));
        iteration++;
      }
    } while (outliers.isNotEmpty);

    do {
      (whyOutliers, outliers) = await determinePredictionIntervalOutliers(
        projects,
      );
      if (outliers.isNotEmpty) {
        _iterations.add(
          OutliersIterations(
            step: iteration,
            projects: outliers,
            whyOutliers: whyOutliers,
            type: OutliersType.predictionInterval,
          ),
        );
        projects.removeWhere((p) => outliers.contains(p));
        iteration++;
      }
    } while (outliers.isNotEmpty);

    _iterations = List.from(_iterations);
    notifyListeners();

    return projects;
  }

  List<double> calculateMahalanobisDistances(List<RegressionFactors> factors) {
    final n = factors.length;
    final p = factors.first.x.length + 1;
    final values = factors.toArray();
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

  List<double> calculateTestStatistics(List<RegressionFactors> factors) {
    final distances = calculateMahalanobisDistances(factors);
    final n = factors.length;
    final p = factors.first.x.length + 1;
    final factor = (n - p) * n / ((pow(n, 2) - 1) * p);
    return distances.map((d) => factor * d).toList();
  }

  Future<double?> calculateFisherFDistribution({
    required int n,
    required int p,
  }) =>
      Fisher.inv(alpha: alpha, df1: p, df2: n - p);

  Future<(List<String>, List<Project>)> determineEpsilonOutliers(
    List<Project> projects,
  ) async {
    _log.d('Epsilon Outlier Detection Started');
    final factors = _normalization
        .normalizeProjects(projects)
        .map(RegressionFactors.fromProject)
        .toList();
    final n = factors.length;
    final p = factors.first.x.length + 1;
    final testStatistics = calculateTestStatistics(factors);
    final f = await calculateFisherFDistribution(n: n, p: p);
    if (f == null) {
      debugPrint('Failed to calculate Fisher F distribution');
      return (<String>[], <Project>[]);
    }
    _log.i('Fisher F distribution: $f');

    final outliers = <Project>[];
    final whyOutliers = <String>[];
    for (var i = 0; i < n; i++) {
      if (testStatistics[i] > f) {
        final outlier = projects[i];
        final why = 'Test Statistic: ${Utils.formatNumber(testStatistics[i])} '
            '> F: ${Utils.formatNumber(f)}';
        _log.d('Epsilon Outlier detected: ${outlier.url} $why');
        outliers.add(outlier);
        whyOutliers.add(why);
      }
    }
    return (whyOutliers, outliers);
  }

  Future<(List<String>, List<Project>)> determinePredictionIntervalOutliers(
    List<Project> projects,
  ) async {
    _log.i('Prediction Interval Outlier Detection Started');
    final regressionModel = RegressionModel(projects);
    final factors = _normalization
        .normalizeProjects(projects)
        .map(RegressionFactors.fromProject)
        .toList();
    final n = factors.length;
    final coefficients =
        regressionModel.calculateRegressionCoefficients(factors: factors);
    final zyHat = regressionModel.calculatePredictedValues(
      factors: factors,
      coefficients: coefficients,
    );
    final intervals = await regressionModel.calculateIntervals(
      z: factors.map((f) => f.x).toList(),
      zy: factors.map((f) => f.y).toList(),
      zyHat: zyHat,
    );

    final outliers = <Project>[];
    final whyOutliers = <String>[];
    for (var i = 0; i < n; i++) {
      final actualValue = pow(10, factors[i].y);
      if (actualValue < intervals.predictionLower[i]) {
        final outlier = projects[i];
        whyOutliers.add('Actual: ${Utils.formatNumber(actualValue.toDouble())} '
            '< Lower: ${Utils.formatNumber(intervals.predictionLower[i])}');
        _log.d(
          'Prediction Outlier detected: ${outlier.url} '
          '$actualValue < ${intervals.predictionLower[i]} '
          '(actual < lower)',
        );
        outliers.add(outlier);
      }
      if (actualValue > intervals.predictionUpper[i]) {
        final outlier = projects[i];
        whyOutliers.add('Actual: ${Utils.formatNumber(actualValue.toDouble())} '
            '> Upper: ${Utils.formatNumber(intervals.predictionUpper[i])}');
        _log.d(
          'Prediction Outlier detected: ${outlier.url} '
          '$actualValue > ${intervals.predictionUpper[i]} '
          '(actual > upper)',
        );
        outliers.add(outlier);
      }
    }
    return (whyOutliers, outliers);
  }
}
