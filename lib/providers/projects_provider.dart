import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/outliers.dart';
import 'package:flutter_stats/services/regression_model.dart';

class ProjectsProvider with ChangeNotifier {
  ProjectsProvider(this._regressionModelProvider);

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
  void setUseRelativeNOC(bool value) {
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

  Future<void> setProjects(List<Project>? projects) async {
    if (projects == null) return;
    _projects = projects;
    _fileProjects = List.from(projects);
    _outliersRemoved = 0;
    await refitOutliers(projects);
    notifyListeners();
    refitModel();
  }

  Future<void> removeProjects(List<int> indexes) async {
    indexes.sort();
    for (var i = indexes.length - 1; i >= 0; i--) {
      _projects.removeAt(indexes[i]);
      _fileProjects.removeAt(indexes[i]);
    }
    _outliersRemoved += indexes.length;
    await refitOutliers(_projects);
    notifyListeners();
    refitModel();
  }

  Future<void> removeProject(int index) async {
    _projects.removeAt(index);
    _fileProjects.removeAt(index);
    _outliersRemoved++;
    await refitOutliers(_projects);
    notifyListeners();
    refitModel();
  }

  void refitModel() {
    _regressionModelProvider
        .setModel(RegressionModel(_projects, useSigma: _useSigma));
  }

  Future<void> refitOutliers(List<Project> projects) async {
    _outliers = Outliers(projects);
    await _outliers.determineOutliers();
  }

  List<int> get outliers => _outliers.outliers;

  bool _useSigma = false;

  bool get useSigma => _useSigma;

  set useSigma(bool value) {
    _useSigma = value;
    notifyListeners();
    refitModel();
  }
}
