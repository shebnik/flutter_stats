import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/models/coefficients/coefficients.dart';
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

  void setProjects(List<Project>? projects) {
    if (projects == null) return;
    _projects = projects;
    _outliersRemoved = 0;
    _regressionModel = RegressionModel(
      projects.map((e) => e.metrics!).toList(),
    );
    notifyListeners();
  }

  void removeProjects(List<int> indexes) {
    indexes.sort();
    for (var i = indexes.length - 1; i >= 0; i--) {
      _projects.removeAt(indexes[i]);
    }
    _outliersRemoved += indexes.length;
    _regressionModel = RegressionModel(
      _projects.map((e) => e.metrics!).toList(),
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

  List<double> get x1Data =>
      _regressionModel.metrics.map((e) => e.dit!).toList();
  List<double> get x2Data =>
      _regressionModel.metrics.map((e) => e.rfc!).toList();
  List<double> get x3Data =>
      _regressionModel.metrics.map((e) => e.cbo!).toList();
  List<double> get yData =>
      _regressionModel.metrics.map((e) => e.wmc!).toList();

  List<double> get zx1Data => _regressionModel.zx1;
  List<double> get zx2Data => _regressionModel.zx2;
  List<double> get zx3Data => _regressionModel.zx3;
  List<double> get zyData => _regressionModel.zy;

  List<List<double>> get covarianceMatrix =>
      _regressionModel.calculateCovarianceMatrix();

  List<List<double>> get covarianceMatrixInverse =>
      _regressionModel.invertMatrix(covarianceMatrix);

  List<double> get mahalanobisDistances =>
      _regressionModel.calculateMahalanobisDistances();

  List<double> get testStatistics =>
      _regressionModel.calculateTestStatistics();

  Future<double?> get fisherFDistribution =>
      _regressionModel.calculateFisherFDistribution();

  Future<List<int>> get outliers =>
      _regressionModel.determineOutliers();

  Coefficients get coefficients =>
      _regressionModel.calculateRegressionCoefficients();

  List<double> get predictedValues =>
      _regressionModel.calculatePredictedValues();

  List<num> get yHat => _regressionModel.calculateYHat();

  ModelQuality get modelQuality =>
      _regressionModel.calculateModelQuality(predictedValues);

  Future<List<ModelInterval>> get linearIntervals =>
      _regressionModel.calculateLinearIntervals();
  Future<List<ModelInterval>> get nonLinearIntervals =>
      _regressionModel.calculateNonLinearIntervals();

  num? predictY(double x1, double x2, double x3) =>
      _regressionModel.predictY(x1, x2, x3);
}
