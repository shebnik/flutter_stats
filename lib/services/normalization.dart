import 'dart:math';

import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/regression_factors/regression_factors.dart';
import 'package:flutter_stats/services/algebra.dart';

class Normalization {
  Normalization() : algebra = Algebra();

  final Algebra algebra;

  double normalize(double value) {
    return algebra.logBase10(value);
  }

  RegressionFactors normalizeFactors(RegressionFactors factors) {
    return factors.copyWith(
      y: algebra.logBase10(factors.y),
      x: factors.x.map(algebra.logBase10).toList(),
    );
  }

  List<Project> normalizeProjects(List<Project> projects) {
    return projects
        .map(
          (e) => e.copyWith(
            metrics: Metrics(
              y: algebra.logBase10(e.metrics.y),
              x1: algebra.logBase10(e.metrics.x1),
              x2: e.metrics.x2 != null
                  ? algebra.logBase10(e.metrics.x2!)
                  : null,
              x3: e.metrics.x3 != null
                  ? algebra.logBase10(e.metrics.x3!)
                  : null,
              noc: e.metrics.noc != null
                  ? algebra.logBase10(e.metrics.noc!)
                  : null,
            ),
          ),
        )
        .toList();
  }

  List<double> revertNormalization(List<double> values) {
    return values.map((e) => pow(10, e)).toList().cast<double>();
  }
}
