import 'dart:math';

import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/regression_factors/regression_factors.dart';
import 'package:flutter_stats/services/algebra.dart';
import 'package:flutter_stats/services/logger.dart';
import 'package:flutter_stats/services/normalization.dart';
import 'package:flutter_stats/services/student.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

class RegressionModel {
  RegressionModel(
    this._projects, {
    List<Project>? trainProjects,
    List<Project>? testProjects,
    this.useSigma = false,
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

  final _logger = AppLogger().logger;
  final Algebra _algebra = Algebra();
  final Normalization _normalization = Normalization();

  late final List<Project> _projects;
  late final List<Project> _trainProjects;
  late final List<Project> _testProjects;

  bool useSigma;

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

  int get p => _factors.firstOrNull?.x.length ?? 0;

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
    // Sort projects by each metric
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

  Coefficients _calculateRegressionCoefficients() {
    final n = _factors.length;
    final X = Matrix.fromColumns([
      Vector.fromList(List.filled(n, 1.0)),
      ...List.generate(
        p,
        (i) => Vector.fromList(_factors.map((f) => f.x[i]).toList()),
      ),
    ]);

    final y = Vector.fromList(_factors.map((f) => f.y).toList());

    final xt = X.transpose();
    final xtX = xt * X;
    final xtXInverse = xtX.inverse();
    final xtY = xt * y;
    final coefficientsVector = xtXInverse * xtY;
    final coefficients =
        List<double>.from(coefficientsVector.map((value) => value.first));

    final residuals = y - X * coefficientsVector;
    final sigma = sqrt(residuals.dot(residuals) / (n - p - 1));

    return Coefficients(
      b: coefficients,
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
      if (useSigma) {
        prediction += coefficients.sigma;
      }
      for (var j = 1; j < _coefficients.b.length; j++) {
        prediction += _coefficients.b[j] * factor.x[j - 1];
      }
      return prediction;
    });
  }

  ModelQuality _calculateModelQuality({
    required List<double> y,
    required List<double> yHat,
    bool normalized = true,
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
    _logger.i('Factors: ${_factors.length}');

    _coefficients = _calculateRegressionCoefficients();
    _logger.i('Coefficients: ${_coefficients.b}');

    _predictedValues = _calculatePredictedValues();
    _logger.i('Predicted values: $_predictedValues');

    _modelQuality = _calculateModelQuality(
      y: _factors.map((f) => f.y).toList(),
      yHat: _predictedValues,
    );
    _logger.i('Model quality: $_modelQuality');
  }

  void _testModel() {
    final normalizedTestProjects =
        _normalization.normalizeProjects(_testProjects);

    final testFactors =
        normalizedTestProjects.map(RegressionFactors.fromProject).toList();

    _testModelQuality = _calculateModelQuality(
      y: testFactors.map((f) => f.y).toList(),
      yHat: _calculatePredictedValues(factors: testFactors),
    );
    _logger.i('Test model quality: $_testModelQuality');
  }

  double predictY(List<double> x) {
    var prediction =
        pow(10, _coefficients.b[0] + (useSigma ? _coefficients.sigma : 0));
    for (var i = 1; i < _coefficients.b.length; i++) {
      prediction *= pow(x[i - 1], _coefficients.b[i]);
    }
    return prediction.toDouble();
  }

  Future<(List<double>, List<double>)> calculatePredictionInterval({
    bool useAllProjects = false,
  }) async {
    final factors = useAllProjects
        ? _normalization
            .normalizeProjects(_projects)
            .map(RegressionFactors.fromProject)
            .toList()
        : _factors;
    final predictedValues = useAllProjects
        ? _calculatePredictedValues(factors: factors)
        : _predictedValues;

    final n = factors.length;

    final X = Matrix.fromColumns([
      Vector.fromList(List.filled(n, 1.0)),
      ...List.generate(
        p,
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
        p,
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
    final (predLower, predUpper) = await calculatePredictionInterval();
    final (confLower, confUpper) = await calculateConfidenceInterval();

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
