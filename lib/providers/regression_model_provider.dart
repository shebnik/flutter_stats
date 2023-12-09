import 'package:flutter/foundation.dart';
import 'package:flutter_stats/models/model_quality/model_quality.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/services/regression_model.dart';

class RegressionModelProvider with ChangeNotifier {
  List<Project> _projects = [];

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
    _regressionModel = RegressionModel(
      projects.map((e) => e.metrics!).toList(),
    );
    notifyListeners();
  }

  void removeProject(int index) {
    _projects.removeAt(index);
    _regressionModel = RegressionModel(
      _projects.map((e) => e.metrics!).toList(),
    );
    notifyListeners();
  }

  List<double> get xData => _regressionModel.Zx;
  List<double> get yData => _regressionModel.Zy;

  List<List<double>> get covarianceMatrix =>
      _regressionModel.calculateCovarianceMatrix();

  List<List<double>> get covarianceMatrixInverse =>
      _regressionModel.invertMatrix(covarianceMatrix);

  List<double> get mahalanobisDistances =>
      _regressionModel.calculateMahalanobisDistances(covarianceMatrixInverse);

  List<double> get testStatistics =>
      _regressionModel.calculateTestStatistics(mahalanobisDistances);

  double get fisherFDistribution =>
      _regressionModel.calculateFisherFDistribution();

  List<int> get outliers => _regressionModel.determineOutliers(testStatistics);

  List<double> get coefficients =>
      _regressionModel.calculateRegressionCoefficients();

  List<double> get predictedValues =>
      _regressionModel.calculatePredictedValues(coefficients);

  ModelQuality get modelQuality =>
      _regressionModel.calculateModelQuality(predictedValues);
}
