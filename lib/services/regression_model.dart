import 'dart:math';

import 'package:flutter_stats/models/coefficients/coefficients.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/regression_factors/regression_factors.dart';
import 'package:flutter_stats/services/algebra.dart';
import 'package:flutter_stats/services/logger.dart';
import 'package:flutter_stats/services/normalization.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

class RegressionModel {
  RegressionModel(
    this._projects, {
    this.useSigma = false,
  }) {
    _splitData(_projects);
    _evaluateModel();
    _testModel();
  }

  final _logger = AppLogger().logger;
  final Algebra _algebra = Algebra();
  final Normalization _normalization = Normalization();

  final List<Project> _projects;
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

  int get p => _factors.firstOrNull?.x.length ?? 0;

  bool useSigma;

  void _splitData(List<Project> projects, [double trainRatio = 0.6]) {
    // Sort projects by each metric
    projects.sort((a, b) => a.metrics!.cbo!.compareTo(b.metrics!.cbo!));
    final sortedByCbo = List<Project>.from(projects);

    projects.sort((a, b) => a.metrics!.wmc!.compareTo(b.metrics!.wmc!));
    final sortedByWmc = List<Project>.from(projects);

    projects.sort((a, b) => a.metrics!.rfc!.compareTo(b.metrics!.rfc!));
    final sortedByRfc = List<Project>.from(projects);

    projects.sort((a, b) => a.metrics!.dit!.compareTo(b.metrics!.dit!));
    final sortedByDit = List<Project>.from(projects);

    // Get min and max projects for each metric
    final minMaxProjects = {
      sortedByDit.first,
      sortedByDit.last,
      sortedByCbo.first,
      sortedByCbo.last,
      sortedByWmc.first,
      sortedByWmc.last,
      sortedByRfc.first,
      sortedByRfc.last,
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

  double predictY(List<double> x) {
    var prediction =
        pow(10, _coefficients.b[0] + (useSigma ? _coefficients.sigma : 0));
    for (var i = 1; i < _coefficients.b.length; i++) {
      prediction += pow(x[i - 1], _coefficients.b[i]);
    }
    return prediction.toDouble();
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
}
