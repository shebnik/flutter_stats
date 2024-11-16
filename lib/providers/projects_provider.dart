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
    required this.outliersProvider,
    this.dataset,
  });

  final RegressionModelProvider _regressionModelProvider;
  final OutliersProvider outliersProvider;
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

  Future<void> setProjects(
    List<Project>? projects, {
    required bool useRelativeNOC,
    required bool divideYByNOC,
    bool refit = true,
  }) async {
    if (projects == null) return;
    _fileProjects = List.from(projects);
    _projects = List.from(projects);

    divideByNOC(
      useRelativeNOC: useRelativeNOC,
      divideYByNOC: divideYByNOC,
    );

    if (refit) {
      _projects = await outliersProvider.removeAllOutliers(_projects);
      setOutliersRemoved(_fileProjects.length - _projects.length);
      refitModel();
    } else {
      setOutliersRemoved(0);
    }
    notifyListeners();
  }

  void refitModel() {
    _regressionModelProvider.model = RegressionModel(_projects);
  }

  void useRelativeNOC({
    required bool useRelativeNOC,
    required bool divideYByNOC,
  }) {
    if (_fileProjects.isEmpty) return;
    divideByNOC(
      useRelativeNOC: useRelativeNOC,
      divideYByNOC: divideYByNOC,
    );
    notifyListeners();
    refitModel();
  }

  void divideByNOC({
    required bool useRelativeNOC,
    required bool divideYByNOC,
  }) {
    if (useRelativeNOC) {
      _projects = _fileProjects.map((e) {
        final metrics = e.metrics;
        final denominator =
            metrics.noc != null && metrics.noc! > 0 ? metrics.noc! : 1.0;
        return e.copyWith(
          metrics: metrics.copyWith(
            y: divideYByNOC ? metrics.y / denominator : metrics.y,
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
}
