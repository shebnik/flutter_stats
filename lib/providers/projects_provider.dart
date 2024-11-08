import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/models/dataset/dataset.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/services/logging/logger_service.dart';
import 'package:flutter_stats/services/normalization.dart';
import 'package:flutter_stats/services/outliers.dart';
import 'package:flutter_stats/services/regression_model.dart';
import 'package:flutter_stats/services/utils.dart';

class ProjectsProvider with ChangeNotifier {
  ProjectsProvider(
    this._regressionModelProvider, {
    this.dataset,
  });

  final RegressionModelProvider _regressionModelProvider;
  Dataset? dataset;
  final _log = LoggerService.instance;

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

  List<double> get mahalanobisDistances =>
      _outliers.calculateMahalanobisDistances();

  List<double> get testStatistics => _outliers.calculateTestStatistics();

  Future<void> setProjects(
    List<Project>? projects, {
    required bool useRelativeNOC,
  }) async {
    if (projects == null) return;
    _fileProjects = List.from(projects);
    _projects = List.from(projects);
    _outliersRemoved = 0;

    divideByNOC(useRelativeNOC: useRelativeNOC);
    refitModel();
    await refitOutliers(
      _projects,
    );
    notifyListeners();
  }

  Future<void> removeProjects(List<int> indexes) async {
    indexes.sort();
    final outliers = <Project>[];
    final normalized = Normalization().normalizeProjects(projects);
    var i = 1;
    for (final index in indexes) {
      outliers.add(_projects[index]);
      _log.i('Removing $i project: ${_projects[index].name}'
          ' Zy: ${Utils.formatNumber(normalized[index].metrics.y)}'
          ' Zx1: ${Utils.formatNumber(normalized[index].metrics.x1)}'
          ' Zx2: ${Utils.formatNumber(normalized[index].metrics.x2 ?? 0.0)}'
          ' with ts: ${Utils.formatNumber(testStatistics[index])}');
      i++;
    }
    _projects.removeWhere(outliers.contains);
    _fileProjects.removeWhere(outliers.contains);

    _outliersRemoved += indexes.length;
    refitModel();
    await refitOutliers(
      _projects,
    );
    notifyListeners();
  }

  Future<void> removeProject(int index) async {
    _projects.removeAt(index);
    _fileProjects.removeAt(index);
    _outliersRemoved++;
    refitModel();
    await refitOutliers(
      _projects,
    );
    notifyListeners();
  }

  void refitModel() {
    _regressionModelProvider.model = RegressionModel(_projects);
  }

  Future<void> refitOutliers(List<Project> projects) async {
    _outliers = Outliers(projects);
    await _outliers.determineOutliers(
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
}
