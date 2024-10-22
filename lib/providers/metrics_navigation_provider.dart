import 'package:flutter/material.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/services/regression_model.dart';

enum MetricsNavigationType {
  projects(label: 'All Projects', icon: Icons.list),
  train(label: 'Projects for Training', icon: Icons.model_training),
  test(label: 'Projects for Testing', icon: Icons.text_snippet);

  const MetricsNavigationType({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

final metricsNavigationRoutes = [
  MetricsNavigationType.projects,
  MetricsNavigationType.train,
  MetricsNavigationType.test,
];

class MetricsNavigationProvider with ChangeNotifier {
  MetricsNavigationType _type = MetricsNavigationType.projects;
  MetricsNavigationType get type => _type;

  set type(MetricsNavigationType type) {
    _type = type;
    notifyListeners();
  }

  List<Project> getProjects({
    required RegressionModel model,
    MetricsNavigationType? type,
  }) {
    switch (type ?? _type) {
      case MetricsNavigationType.train:
        return model.trainProjects;
      case MetricsNavigationType.test:
        return model.testProjects;
      case MetricsNavigationType.projects:
        return model.projects;
    }
  }
}
