import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/models/dataset/dataset.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/outliers.dart';
import 'package:flutter_stats/services/regression_model.dart';

class ProjectsProvider with ChangeNotifier {
  ProjectsProvider(
    this._regressionModelProvider, {
    this.dataset,
  });

  final RegressionModelProvider _regressionModelProvider;
  Dataset? dataset;

  List<Project> _fileProjects = [];
  List<Project> _projects = [];

  int _outliersRemoved = 0;
  int get outliersRemoved => _outliersRemoved;

  void setOutliersRemoved(int value) {
    _outliersRemoved = value;
    notifyListeners();
  }

  List<Project> get projects => _projects;
  Outliers _outliers = Outliers([]);

  Future<void> setProjects(
    List<Project>? projects, {
    required bool useRelativeNOC,
    required bool includeIntervalsMethod,
  }) async {
    if (projects == null) return;
    _fileProjects = List.from(projects);
    _projects = List.from(projects);
    _outliersRemoved = 0;

    divideByNOC(useRelativeNOC: useRelativeNOC);
    refitModel();
    await refitOutliers(
      projects,
      includeIntervalsMethod: includeIntervalsMethod,
    );
    notifyListeners();
  }

  Future<void> removeProjects(
    List<int> indexes, {
    required bool includeIntervalsMethod,
  }) async {
    indexes.sort();
    for (var i = indexes.length - 1; i >= 0; i--) {
      _projects.removeAt(indexes[i]);
      _fileProjects.removeAt(indexes[i]);
    }
    _outliersRemoved += indexes.length;
    refitModel();
    await refitOutliers(
      projects,
      includeIntervalsMethod: includeIntervalsMethod,
    );
    notifyListeners();
  }

  Future<void> removeProject(
    int index, {
    required bool includeIntervalsMethod,
  }) async {
    _projects.removeAt(index);
    _fileProjects.removeAt(index);
    _outliersRemoved++;
    refitModel();
    await refitOutliers(
      projects,
      includeIntervalsMethod: includeIntervalsMethod,
    );
    notifyListeners();
  }

  void refitModel() {
    _regressionModelProvider.model = RegressionModel(_projects);
  }

  Future<void> refitOutliers(
    List<Project> projects, {
    required bool includeIntervalsMethod,
  }) async {
    _outliers = Outliers(projects);
    await _outliers.determineOutliers(
      includeIntervalsMethod: includeIntervalsMethod,
      regressionModel: _regressionModelProvider.model,
    );
  }

  List<int> get outliers => _outliers.outliers;

  void useRelativeNOC({
    required bool useRelativeNOC,
  }) {
    if (_fileProjects.isEmpty) return;
    divideByNOC(useRelativeNOC: useRelativeNOC);
    notifyListeners();
    refitModel();
  }

  void divideByNOC({required bool useRelativeNOC}) {
    if (useRelativeNOC) {
      _projects = _fileProjects.map((e) {
        final metrics = e.metrics;
        final denominator =
            metrics.noc != null && metrics.noc! > 0 ? metrics.noc! : 1.0;
        return e.copyWith(
          metrics: metrics.copyWith(
            y: metrics.y / denominator,
            x1: metrics.x1 / denominator,
            x2: metrics.x2 != null ? metrics.x2! / denominator : null,
            x3: metrics.x3 != null ? metrics.x3! / denominator : null,
          ),
        );
      }).toList();
    } else {
      _projects = List.from(_fileProjects);
    }
  }

  void refitModelWithSigma({required bool useSigma}) {
    if (_regressionModelProvider.model == null) return;
    final model = _regressionModelProvider.model;
    _regressionModelProvider.model = RegressionModel(
      model!.projects,
      useSigma: useSigma,
      trainProjects: model.trainProjects,
      testProjects: model.testProjects,
    );
  }
}
