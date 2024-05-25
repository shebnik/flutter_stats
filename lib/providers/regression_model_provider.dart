import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/models/interval/model_interval.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/services/regression_model.dart';

class RegressionModelProvider with ChangeNotifier {
  List<Project> _projects = [];

  int _outliersRemoved = 0;
  int get outliersRemoved => _outliersRemoved;

  void setOutliersRemoved(int value) {
    _outliersRemoved = value;
    notifyListeners();
  }

  List<Project> get projects => _projects;
  late RegressionModel _regressionModel;

  bool _linesOfCodeInThousands = true;

  bool get linesOfCodeInThousands => _linesOfCodeInThousands;

  // ignore: avoid_positional_boolean_parameters
  void setLinesOfCodeInThousands(bool value) {
    _linesOfCodeInThousands = value;
    if (value) {
      _projects = _projects
          .map(
            (e) => e.copyWith(
              metrics: e.metrics!.copyWith(
                linesOfCode: e.metrics!.linesOfCode! / 1000,
              ),
            ),
          )
          .toList();
    } else {
      _projects = _projects
          .map(
            (e) => e.copyWith(
              metrics: e.metrics!.copyWith(
                linesOfCode: e.metrics!.linesOfCode! * 1000,
              ),
            ),
          )
          .toList();
    }
    notifyListeners();
  }

  void setProjects(List<Project>? projects) {
    if (projects == null) return;
    _projects = projects;
    _outliersRemoved = 0;
    _regressionModel = RegressionModel(
      projects.map((e) => e.metrics!).toList(),
    );
    notifyListeners();
  }

  void removeProject(int index) {
    _projects.removeAt(index);
    _outliersRemoved++;
    _regressionModel = RegressionModel(
      _projects.map((e) => e.metrics!).toList(),
    );
    notifyListeners();
  }

  List<double> get xData =>
      _regressionModel.metrics.map((e) => e.numberOfClasses!).toList();
  List<double> get yData =>
      _regressionModel.metrics.map((e) => e.linesOfCode!).toList();

  List<double> get zxData => _regressionModel.Zx1;
  List<double> get zyData => _regressionModel.Zy;

  List<List<double>> get covarianceMatrix =>
      _regressionModel.calculateCovarianceMatrix();

  List<List<double>> get covarianceMatrixInverse =>
      _regressionModel.invertMatrix(covarianceMatrix);

  List<double> get mahalanobisDistances =>
      _regressionModel.calculateMahalanobisDistances(covarianceMatrixInverse);

  List<double> get testStatistics =>
      _regressionModel.calculateTestStatistics(mahalanobisDistances);

  Future<double> get fisherFDistribution =>
      _regressionModel.calculateFisherFDistribution();

  Future<List<int>> get outliers =>
      _regressionModel.determineOutliers(testStatistics);

  List<double> get coefficients =>
      _regressionModel.calculateRegressionCoefficients();

  List<double> get predictedValues =>
      _regressionModel.calculatePredictedValues(coefficients);

  List<num> get yHat => _regressionModel.calculateYHat(predictedValues);

  ModelQuality get modelQuality =>
      _regressionModel.calculateModelQuality(predictedValues);

  Future<List<ModelInterval>> get linearIntervals =>
      _regressionModel.calculateLinearIntervals();
  Future<List<ModelInterval>> get nonLinearIntervals =>
      _regressionModel.calculatenonLinearIntervals();
}
