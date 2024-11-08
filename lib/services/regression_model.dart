import 'dart:async';
import 'dart:math';

import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/regression_factors/regression_factors.dart';
import 'package:flutter_stats/services/algebra.dart';
import 'package:flutter_stats/services/logging/logger_service.dart';
import 'package:flutter_stats/services/normalization.dart';
import 'package:flutter_stats/services/student.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

class RegressionModel {
  RegressionModel(
    this._projects, {
    List<Project>? trainProjects,
    List<Project>? testProjects,
  }) {
    if (trainProjects != null && testProjects != null) {
      _trainProjects = trainProjects;
      _testProjects = testProjects;
    } else {
      _splitData();
    }
    _evaluateModel();
    _testModel();
  }

  final _log = LoggerService.instance;
  final Algebra _algebra = Algebra();
  final Normalization _normalization = Normalization();

  late final List<Project> _projects;
  late final List<Project> _trainProjects;
  late final List<Project> _testProjects;

  List<Project> get projects => _projects;
  List<Project> get trainProjects => _trainProjects;
  List<Project> get testProjects => _testProjects;

  List<RegressionFactors> _factors = [];
  List<RegressionFactors> get factors => _factors;

  Coefficients _coefficients = Coefficients.empty();
  Coefficients get coefficients => _coefficients;

  List<double> _predictedValues = [];

  ModelQuality _modelQuality = ModelQuality.empty();
  ModelQuality get modelQuality => _modelQuality;

  ModelQuality _testModelQuality = ModelQuality.empty();
  ModelQuality get testModelQuality => _testModelQuality;

  int get p => (_factors.firstOrNull?.x.length ?? 0) + 1;

  MinMaxFactors get minMaxFactors {
    final values = _trainProjects.map((p) => p.metrics).toList();
    return MinMaxFactors(
      y: MinMax(
        values.map((f) => f.y).reduce(min),
        values.map((f) => f.y).reduce(max),
      ),
      x1: MinMax(
        values.map((f) => f.x1).reduce(min),
        values.map((f) => f.x1).reduce(max),
      ),
      x2: values.first.x2 != null
          ? MinMax(
              values.map((f) => f.x2!).reduce(min),
              values.map((f) => f.x2!).reduce(max),
            )
          : null,
      x3: values.first.x3 != null
          ? MinMax(
              values.map((f) => f.x3!).reduce(min),
              values.map((f) => f.x3!).reduce(max),
            )
          : null,
    );
  }

  void _splitData([double trainRatio = 0.6]) {
    final projects = List<Project>.from(_projects);

    // Sort projects by each metric
    // ignore: cascade_invocations
    projects.sort((a, b) => a.metrics.y.compareTo(b.metrics.y));
    final sortedByY = List<Project>.from(projects);

    projects.sort((a, b) => a.metrics.x1.compareTo(b.metrics.x1));
    final sortedByX1 = List<Project>.from(projects);

    var sortedByX2 = <Project>[];
    if (projects.first.metrics.x2 != null) {
      projects.sort((a, b) => a.metrics.x2!.compareTo(b.metrics.x2!));
      sortedByX2 = List<Project>.from(projects);
    }

    var sortedByX3 = <Project>[];
    if (projects.first.metrics.x3 != null) {
      projects.sort((a, b) => a.metrics.x3!.compareTo(b.metrics.x3!));
      sortedByX3 = List<Project>.from(projects);
    }

    // Get min and max projects for each metric
    final minMaxProjects = {
      sortedByY.first,
      sortedByY.last,
      sortedByX1.first,
      sortedByX1.last,
      if (sortedByX2.isNotEmpty) sortedByX2.first,
      if (sortedByX2.isNotEmpty) sortedByX2.last,
      if (sortedByX3.isNotEmpty) sortedByX3.first,
      if (sortedByX3.isNotEmpty) sortedByX3.last,
    };

    // Remove min and max projects from the main list and shuffle the rest
    final remainingProjects = projects
        .where((p) => !minMaxProjects.contains(p))
        .toList()
      ..shuffle(Random());

    // Calculate the number of additional projects needed for the training set
    final nTrain =
        (projects.length * trainRatio).toInt() - minMaxProjects.length;

    // Split the remaining projects
    _trainProjects = [...minMaxProjects, ...remainingProjects.take(nTrain)];
    _testProjects = remainingProjects.skip(nTrain).toList();
  }

  Coefficients _calculateRegressionCoefficients({
    List<RegressionFactors>? factors,
  }) {
    factors ??= _factors;
    final n = factors.length;
    final p = this.p;

    if (n == 0 || p == 0) {
      _log.e('Insufficient data to calculate regression coefficients.');
      return Coefficients.empty();
    }

    // Construct the design matrix X and the target vector y
    final xData = factors.map((f) => f.x).toList();
    final yData = factors.map((f) => f.y).toList();

    // Add a column of 1s for the intercept term
    final designMatrixData =
        xData.map((x) => Vector.fromList([1.0, ...x])).toList();
    final X = Matrix.fromRows(designMatrixData);
    final y = Vector.fromList(yData);

    // Calculate X^T * X
    final xtX = X.transpose() * X;

    // Calculate (X^T * X)^-1
    Matrix xtXInverse;
    try {
      xtXInverse = xtX.inverse();
    } catch (e) {
      _log.e('Matrix inversion failed: $e');
      return Coefficients.empty();
    }

    // Calculate X^T * y
    final xty = X.transpose() * y;

    // Calculate the coefficients: (X^T * X)^-1 * (X^T * y)
    final coefficients = xtXInverse * xty;

    final yPred = X * coefficients;
    final residuals = y - yPred;
    final mse = residuals.dot(residuals) / (n - p - 1);
    final sigma = sqrt(mse);

    return Coefficients(
      b: List<double>.from(coefficients.map((value) => value.first)),
      sigma: sigma,
    );
  }

  List<double> _calculatePredictedValues({
    List<RegressionFactors>? factors,
    Coefficients? coefficients,
  }) {
    factors ??= _factors;
    coefficients ??= _coefficients;
    return List.generate(factors.length, (i) {
      final factor = factors![i];
      var prediction = coefficients!.b[0];
      for (var j = 1; j < coefficients.b.length; j++) {
        prediction += coefficients.b[j] * factor.x[j - 1];
      }
      final epsilon = factor.y - prediction;
      return prediction + epsilon;
    });
  }

  List<double> _calculateNonlinearPredictedValues({
    List<RegressionFactors>? factors,
    Coefficients? coefficients,
  }) {
    factors ??= _factors;
    coefficients ??= _coefficients;
    return List.generate(factors.length, (i) {
      final factor = factors![i];
      var prediction = pow(10, coefficients!.b[0]);
      for (var j = 1; j < coefficients.b.length; j++) {
        prediction *= pow(factor.x[j - 1], coefficients.b[j]);
      }
      return prediction.toDouble();
    });
  }

  ModelQuality _calculateModelQuality({
    required List<double> y,
    required List<double> yHat,
    bool normalized = false,
  }) {
    if (normalized) {
      y = _normalization.revertNormalization(y);
      yHat = _normalization.revertNormalization(yHat);
    }

    final n = y.length;

    final yDiffSquared = List.generate(n, (i) => pow(y[i] - yHat[i], 2));
    final yAvgDiffSquared =
        y.map((value) => pow(value - _algebra.average(y), 2)).toList();

    final yDividedDiff = List.generate(n, (i) => (y[i] - yHat[i]) / y[i]);

    final sy = yDiffSquared.reduce((a, b) => a + b);
    final rSquared = 1 - (sy / yAvgDiffSquared.reduce((a, b) => a + b));

    final mmre =
        yDividedDiff.map((diff) => diff.abs()).reduce((a, b) => a + b) / n;

    final pred = yDividedDiff.where((diff) => diff.abs() < 0.25).length / n;

    return ModelQuality(
      rSquared: rSquared,
      mmre: mmre,
      pred: pred,
    );
  }

  void _evaluateModel() {
    final normalizedProjects = _normalization.normalizeProjects(_trainProjects);
    _factors = normalizedProjects.map(RegressionFactors.fromProject).toList();
    _log.i('Factors: ${_factors.length}');

    _coefficients = _calculateRegressionCoefficients();
    _log.i('Coefficients: ${_coefficients.b}');

    _predictedValues = _calculateNonlinearPredictedValues(
      factors: _trainProjects.map(RegressionFactors.fromProject).toList(),
    );
    _log.i('Predicted values: $_predictedValues');

    _modelQuality = _calculateModelQuality(
      y: _trainProjects.map((p) => p.metrics.y).toList(),
      yHat: _predictedValues,
    );
    _log.i('Model quality: $_modelQuality');
  }

  Future<void> _testModel() async {
    final normalizedTestProjects =
        _normalization.normalizeProjects(_testProjects);

    await _testProjectsQuality(normalizedTestProjects);

    _testModelQuality = _calculateModelQuality(
      y: _testProjects.map((p) => p.metrics.y).toList(),
      yHat: _calculateNonlinearPredictedValues(
        factors: _testProjects.map(RegressionFactors.fromProject).toList(),
      ),
    );
    _log.i('Test model quality: $_testModelQuality');
  }

  Future<void> _testProjectsQuality(List<Project> projects) async {
    var highQualityCount = 0;
    var mediumQualityCount = 0;
    var lowQualityCount = 0;

    for (var i = 0; i < projects.length; i++) {
      final project = projects[i];
      final (predLower, predUpper) = await calculatePredictionInterval(
        includeProjectsForTesting: false,
      );
      final (confLower, confUpper) = await calculateConfidenceInterval();

      final avgPredLower = _algebra.average(predLower);
      final avgPredUpper = _algebra.average(predUpper);
      final avgConfLower = _algebra.average(confLower);
      final avgConfUpper = _algebra.average(confUpper);

      final y = project.metrics.y;

      if (y >= avgConfLower && y <= avgConfUpper) {
        mediumQualityCount++;
      } else if (y > avgConfUpper && y <= avgPredUpper) {
        lowQualityCount++;
      } else if (y >= avgPredLower && y < avgConfLower) {
        highQualityCount++;
      } else if (y > avgPredUpper) {
        lowQualityCount++;
      }
    }

    final totalProjects = projects.length;
    final highQualityPercentage =
        (highQualityCount / totalProjects * 100).toStringAsFixed(1);
    final mediumQualityPercentage =
        (mediumQualityCount / totalProjects * 100).toStringAsFixed(1);
    final lowQualityPercentage =
        (lowQualityCount / totalProjects * 100).toStringAsFixed(1);

    _log
      ..i('Quality distribution of $totalProjects projects:')
      ..i('High quality: $highQualityPercentage% projects')
      ..i('Medium quality: $mediumQualityPercentage% projects')
      ..i('Low quality: $lowQualityPercentage% projects');
  }

  double predictY(List<double> x) {
    var prediction = pow(10, _coefficients.b[0] + _coefficients.sigma);
    for (var i = 1; i < _coefficients.b.length; i++) {
      prediction *= pow(x[i - 1], _coefficients.b[i]);
    }
    return prediction.toDouble();
  }

  Future<(List<double>, List<double>)> calculatePredictionInterval({
    required bool includeProjectsForTesting,
  }) async {
    var factors = _factors;
    var predictedValues = _predictedValues;

    if (includeProjectsForTesting) {
      final normalizedProjects = _normalization.normalizeProjects(_projects);
      factors = normalizedProjects.map(RegressionFactors.fromProject).toList();
      final coefficients = _calculateRegressionCoefficients(
        factors: factors,
      );
      _log.i('Coefficients: ${coefficients.b}');

      predictedValues = _calculatePredictedValues(
        factors: factors,
        coefficients: coefficients,
      );
      _log.i('Predicted values: $predictedValues');
    }

    final n = factors.length;

    final X = Matrix.fromColumns([
      Vector.fromList(List.filled(n, 1.0)),
      ...List.generate(
        p - 1,
        (i) => Vector.fromList(factors.map((f) => f.x[i]).toList()),
      ),
    ]);
    final y = Vector.fromList(factors.map((f) => f.y).toList());

    final residuals = Vector.fromList(
      List.generate(n, (i) => y[i] - predictedValues[i]),
    );
    final mse = residuals.dot(residuals) / (n - p - 1);

    final leverage = X * (X.transpose() * X).inverse() * X.transpose();
    final leverageDiagonal = List.generate(n, (i) => leverage[i][i]);
    final se = List.generate(n, (i) => sqrt(mse * (1 + leverageDiagonal[i])));

    final tValue = await Student.inv2T(alpha: 1 - alpha / 2, df: n - p - 1);
    final margin = List.generate(n, (i) => tValue! * se[i]);

    final lowerBound = List.generate(n, (i) => predictedValues[i] - margin[i]);
    final upperBound = List.generate(n, (i) => predictedValues[i] + margin[i]);

    return (lowerBound, upperBound);
  }

  Future<(List<double>, List<double>)> calculateConfidenceInterval() async {
    final n = _predictedValues.length;
    final X = Matrix.fromColumns([
      Vector.fromList(List.filled(n, 1.0)),
      ...List.generate(
        p - 1,
        (i) => Vector.fromList(_factors.map((f) => f.x[i]).toList()),
      ),
    ]);

    final xt = X.transpose();
    final xtX = xt * X;
    final xtXInverse = xtX.inverse();

    // Calculate standard error for confidence interval
    final residuals = Vector.fromList(
      List.generate(n, (i) => _factors[i].y - _predictedValues[i]),
    );
    final mse = residuals.dot(residuals) / (n - p - 1);

    final hatMatrix = X * xtXInverse * xt;
    final leverageDiagonal = List.generate(n, (i) => hatMatrix[i][i]);

    final seConf = List.generate(
      n,
      (i) => sqrt(mse * leverageDiagonal[i]),
    );

    final tValue = await Student.inv2T(alpha: 1 - alpha / 2, df: n - p - 1);
    final confMargin = List.generate(n, (i) => tValue! * seConf[i]);

    final confLower =
        List.generate(n, (i) => _predictedValues[i] - confMargin[i]);
    final confUpper =
        List.generate(n, (i) => _predictedValues[i] + confMargin[i]);

    return (confLower, confUpper);
  }

  Future<double> calculateProjectQuality(double y) async {
    final (predLower, predUpper) = await calculatePredictionInterval(
      includeProjectsForTesting: false,
    );
    final (confLower, confUpper) = await calculateConfidenceInterval();
    _log
      ..i('Confidence interval: $confLower - $confUpper')
      ..i('Prediction interval: $predLower - $predUpper');

    final avgConfLower = _algebra.average(confLower);
    final avgConfUpper = _algebra.average(confUpper);
    final avgPredLower = _algebra.average(predLower);
    final avgPredUpper = _algebra.average(predUpper);

    // Calculate distances between intervals for scaling
    final confInterval = avgConfUpper - avgConfLower;
    final lowerPredInterval = avgConfLower - avgPredLower;
    final upperPredInterval = avgPredUpper - avgConfUpper;

    // Calculate quality percentage based on where y falls
    if (y >= avgConfLower && y <= avgConfUpper) {
      // Within confidence interval - scale from 40% to 60%
      final center = (avgConfUpper + avgConfLower) / 2;
      final distanceFromCenter = (y - center).abs();
      final maxDistance = confInterval / 2;
      final positionInInterval = 1 - (distanceFromCenter / maxDistance);
      return 0.4 + (positionInInterval * 0.2);
    } else if (y < avgPredLower) {
      // Below prediction interval - scale from 80% to 100%
      final distanceBelowPred = avgPredLower - y;
      final scaleFactor = min(distanceBelowPred / lowerPredInterval, 1);
      return 0.8 + (scaleFactor * 0.2);
    } else if (y > avgPredUpper) {
      // Above prediction interval - scale from 0% to 20%
      final distanceAbovePred = y - avgPredUpper;
      final scaleFactor = min(distanceAbovePred / upperPredInterval, 1);
      return 0.2 * (1 - scaleFactor);
    } else if (y > avgConfUpper) {
      // Between confidence and upper prediction interval scale from 20% to 40%
      final distanceAboveConf = y - avgConfUpper;
      final scaleFactor = distanceAboveConf / upperPredInterval;
      return 0.4 * (1 - scaleFactor);
    } else {
      // Between lower prediction and confidence interval scale from 60% to 80%
      final distanceBelowConf = avgConfLower - y;
      final scaleFactor = distanceBelowConf / lowerPredInterval;
      return 0.6 + (scaleFactor * 0.2);
    }
  }
}

class MinMax {
  MinMax(this.min, this.max);

  final double min;
  final double max;
}

class MinMaxFactors {
  MinMaxFactors({
    required this.y,
    required this.x1,
    this.x2,
    this.x3,
  });

  final MinMax y;
  final MinMax x1;
  final MinMax? x2;
  final MinMax? x3;
}
