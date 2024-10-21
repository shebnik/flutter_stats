import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/outliers.dart';
import 'package:flutter_stats/services/regression_model.dart';

class OutliersProvider with ChangeNotifier {

  OutliersProvider(this._regressionModelProvider);

  final RegressionModelProvider _regressionModelProvider;

  late List<Project> _fileProjects;
  List<Project> _projects = [];

  int _outliersRemoved = 0;
  int get outliersRemoved => _outliersRemoved;

  void setOutliersRemoved(int value) {
    _outliersRemoved = value;
    notifyListeners();
  }

  List<Project> get projects => _projects;
  late Outliers _outliers;

  bool _useRelativeNOC = false;
  bool get useRelativeNOC => _useRelativeNOC;

  // ignore: avoid_positional_boolean_parameters
  void setUseRelativeNOC(bool? value) {
    if (value == null) return;
    _useRelativeNOC = value;
    if (_useRelativeNOC) {
      _projects = _fileProjects.map((e) {
        final metrics = e.metrics!;
        final relativeNOC =
            metrics.noc != null && metrics.noc! > 0 ? metrics.noc : 1;
        return e.copyWith(
          metrics: metrics.copyWith(
            dit: metrics.dit! / relativeNOC!,
            rfc: metrics.rfc! / relativeNOC,
            cbo: metrics.cbo! / relativeNOC,
            wmc: metrics.wmc! / relativeNOC,
          ),
        );
      }).toList();
    } else {
      _projects = List.from(_fileProjects);
    }
    notifyListeners();
    refitModel();
  }

  void setProjects(List<Project>? projects) {
    if (projects == null) return;
    _projects = projects;
    _fileProjects = List.from(projects);
    _outliersRemoved = 0;
    _outliers = Outliers(
      projects.map((e) => e.metrics!).toList(),
    );
    notifyListeners();
    refitModel();
  }

  void removeProjects(List<int> indexes) {
    indexes.sort();
    for (var i = indexes.length - 1; i >= 0; i--) {
      _projects.removeAt(indexes[i]);
      _fileProjects.removeAt(indexes[i]);
    }
    _outliersRemoved += indexes.length;
    _outliers = Outliers(
      _projects.map((e) => e.metrics!).toList(),
    );
    notifyListeners();
    refitModel();
  }

  void removeProject(int index) {
    _projects.removeAt(index);
    _fileProjects.removeAt(index);
    _outliersRemoved++;
    _outliers = Outliers(
      _projects.map((e) => e.metrics!).toList(),
    );
    notifyListeners();
    refitModel();
  }

  void refitModel() {
    _regressionModelProvider.setModel(RegressionModel(_projects));
  }

  List<List<double>> get covarianceMatrix =>
      _outliers.calculateCovarianceMatrix();

  List<List<double>> get covarianceMatrixInverse =>
      _outliers.invertMatrix(covarianceMatrix);

  List<double> get mahalanobisDistances =>
      _outliers.calculateMahalanobisDistances();

  List<double> get testStatistics => _outliers.calculateTestStatistics();

  Future<double?> get fisherFDistribution =>
      _outliers.calculateFisherFDistribution();

  Future<List<int>> get outliers => _outliers.determineOutliers();
}
