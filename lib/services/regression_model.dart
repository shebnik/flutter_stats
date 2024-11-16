import 'dart:async';
import 'dart:math';

import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/models/intervals/intervals.dart';
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

  Intervals _intervals = Intervals.empty();
  Intervals get intervals => _intervals;

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

  Coefficients calculateRegressionCoefficients({
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

    return Coefficients(
      b: List<double>.from(coefficients.map((value) => value.first)),
      epsilon: 0,
    );
  }

  double _calculateEpsilon(List<double> y, List<double> predictedY) {
    final residuals = List.generate(y.length, (i) => y[i] - predictedY[i]);
    final n = residuals.length;
    return sqrt(
      residuals.map((r) => pow(r, 2)).reduce((a, b) => a + b) / (n - 3),
    );
  }

  List<double> calculatePredictedValues({
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

  Future<void> _evaluateModel() async {
    final normalizedProjects = _normalization.normalizeProjects(_trainProjects);
    _factors = normalizedProjects.map(RegressionFactors.fromProject).toList();
    _log.i('Factors: ${_factors.length}');

    _coefficients = calculateRegressionCoefficients();
    _log.i('Coefficients: ${_coefficients.b}');

    _predictedValues = calculatePredictedValues();
    _log.i('Predicted values ${_predictedValues.length}: $_predictedValues');

    _coefficients = _coefficients.copyWith(
      epsilon: _calculateEpsilon(
        _factors.map((e) => e.y).toList(),
        calculatePredictedValues(),
      ),
    );

    _modelQuality = _calculateModelQuality(
      y: _factors.map((f) => f.y).toList(),
      yHat: _predictedValues,
    );
    _log.i('Model quality: $_modelQuality');
    _intervals = await calculateIntervals(
      zyHat: _predictedValues,
      z: _factors.map((f) => f.x).toList(),
      zy: factors.map((f) => f.y).toList(),
    );
    await _testModel();
  }

  Future<void> _testModel() async {
    final normalizedProjects = _normalization.normalizeProjects(_trainProjects);
    final normalizedTestProjects =
        _normalization.normalizeProjects(_testProjects);
    final factors =
        normalizedTestProjects.map(RegressionFactors.fromProject).toList();

    _testModelQuality = _calculateModelQuality(
      y: factors.map((f) => f.y).toList(),
      yHat: calculatePredictedValues(
        factors: factors,
        coefficients: _coefficients,
      ),
    );
    _log.i('Test model quality: $_testModelQuality');

    await _testProjectsQuality(
      [...normalizedProjects, ...normalizedTestProjects],
    );
  }

  Future<void> _testProjectsQuality(List<Project> projects) async {
    var highQualityCount = 0;
    var mediumQualityCount = 0;
    var lowQualityCount = 0;

    final factors = _normalization
        .normalizeProjects(projects)
        .map(RegressionFactors.fromProject)
        .toList();
    final coefficients = calculateRegressionCoefficients(factors: factors);
    final zyHat = calculatePredictedValues(
      factors: factors,
      coefficients: coefficients,
    );
    final intervals = await calculateIntervals(
      z: factors.map((f) => f.x).toList(),
      zy: factors.map((f) => f.y).toList(),
      zyHat: zyHat,
    );

    for (var i = 0; i < projects.length; i++) {
      final project = projects[i];
      final y = pow(10, project.metrics.y);

      final predLower = pow(10, intervals.predictionLower[i]);
      final predUpper = pow(10, intervals.predictionUpper[i]);
      final confLower = pow(10, intervals.confidenceLower[i]);
      final confUpper = pow(10, intervals.confidenceUpper[i]);

      if (y > predUpper) {
        // RFC exceeds prediction interval upper bound
        lowQualityCount++;
      } else if (y >= confLower && y <= confUpper) {
        // RFC falls within confidence interval
        mediumQualityCount++;
      } else if ((y > confUpper && y <= predUpper) ||
          (y >= predLower && y < confLower)) {
        // RFC falls between confidence and prediction intervals
        highQualityCount++;
      } else {
        _log.w('Project ${project.url} has unusual Y value: $y');
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
    var prediction = pow(10, _coefficients.b[0] + _coefficients.epsilon);
    for (var i = 1; i < _coefficients.b.length; i++) {
      prediction *= pow(x[i - 1], _coefficients.b[i]);
    }
    return prediction.toDouble();
  }

  Future<Intervals> calculateIntervals({
    required List<List<double>> z,
    required List<double> zy,
    required List<double> zyHat,
  }) async {
    final n = z.length;
    final p = z.first.length;
    final nu = n - (p + 1); // Degrees of freedom

    // Calculate t-statistic
    final tStat = await Student.inv2T(alpha: 0.05 / 2, df: nu) ?? 0;

    try {
      // Calculate residual standard deviation
      final residuals = List.generate(n, (i) => zy[i] - zyHat[i]);
      final szy =
          sqrt(residuals.map((r) => r * r).reduce((a, b) => a + b) / nu);

      // Calculate means for each predictor
      final zMeans = List.generate(
        p,
        (j) => z.map((row) => row[j]).reduce((a, b) => a + b) / n,
      );

      // Calculate centered Z matrix
      final zCentered =
          List.generate(n, (i) => List.generate(p, (j) => z[i][j] - zMeans[j]));

      // Calculate covariance matrix
      final sZ = _algebra.matrixMultiply(
        _algebra.transposeMatrix(zCentered),
        zCentered,
      );

      // Invert covariance matrix
      final sZInv = _algebra.invertMatrix(sZ);

      // Calculate quadratic form for each observation
      final quadraticForm = List.generate(n, (i) {
        final temp = _algebra.matrixVectorMultiply(sZInv, zCentered[i]);
        return List.generate(p, (j) => temp[j] * zCentered[i][j])
            .reduce((a, b) => a + b);
      });

      // Calculate intervals in log scale
      final predLower = List.generate(
        n,
        (i) => zyHat[i] - tStat * szy * sqrt(1 + 1 / n + quadraticForm[i]),
      );
      final predUpper = List.generate(
        n,
        (i) => zyHat[i] + tStat * szy * sqrt(1 + 1 / n + quadraticForm[i]),
      );
      final confLower = List.generate(
        n,
        (i) => zyHat[i] - tStat * szy * sqrt(1 / n + quadraticForm[i]),
      );
      final confUpper = List.generate(
        n,
        (i) => zyHat[i] + tStat * szy * sqrt(1 / n + quadraticForm[i]),
      );

      // Transform back to original scale
      return Intervals(
        y: zy.map((x) => pow(10, x).toDouble()).toList(),
        yHat: zyHat.map((x) => pow(10, x).toDouble()).toList(),
        predictionLower: predLower.map((x) => pow(10, x).toDouble()).toList(),
        predictionUpper: predUpper.map((x) => pow(10, x).toDouble()).toList(),
        confidenceLower: confLower.map((x) => pow(10, x).toDouble()).toList(),
        confidenceUpper: confUpper.map((x) => pow(10, x).toDouble()).toList(),
      );
    } catch (e) {
      LoggerService.instance.e('Failed to calculate intervals: $e');
      return Intervals.empty();
    }
  }

  Future<QualityTypes> calculateProjectQuality(double y) async {
    final avgPredLower = _algebra.average(intervals.predictionLower);
    final avgPredUpper = _algebra.average(intervals.predictionUpper);
    final avgConfLower = _algebra.average(intervals.confidenceLower);
    final avgConfUpper = _algebra.average(intervals.confidenceUpper);

    _log.i('Calculating quality for project with y = $y, '
        'prediction interval: $avgPredLower - $avgPredUpper, '
        'confidence interval: $avgConfLower - $avgConfUpper');

    if (y >= avgConfLower && y <= avgConfUpper) {
      return QualityTypes.medium;
    } else if (y > avgConfUpper && y <= avgPredUpper) {
      return QualityTypes.low;
    } else if (y >= avgPredLower && y < avgConfLower) {
      return QualityTypes.high;
    } else if (y > avgPredUpper) {
      return QualityTypes.low;
    }

    return QualityTypes.unknown;
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
