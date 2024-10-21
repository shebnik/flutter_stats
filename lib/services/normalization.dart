import 'dart:math';

import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/services/algebra.dart';

class Normalization {
  Normalization() : algebra = Algebra();

  final Algebra algebra;

  List<Project> normalizeProjects(List<Project> projects) {
    return projects
        .map(
          (e) => e.copyWith(
            metrics: Metrics(
              dit: algebra.logBase10(e.metrics!.dit!),
              rfc: algebra.logBase10(e.metrics!.rfc!),
              cbo: algebra.logBase10(e.metrics!.cbo!),
              wmc: algebra.logBase10(e.metrics!.wmc!),
              noc: algebra.logBase10(e.metrics!.noc!),
            ),
          ),
        )
        .toList();
  }

  List<double> revertNormalization(List<double> values) {
    return values.map((e) => pow(10, e)).toList().cast<double>();
  }
}
