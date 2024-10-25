import 'package:flutter_stats/models/project/project.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'regression_factors.freezed.dart';
part 'regression_factors.g.dart';

@freezed
class RegressionFactors with _$RegressionFactors {
  const factory RegressionFactors({
    required double y,
    required List<double> x,
  }) = _RegressionFactors;

  factory RegressionFactors.fromJson(Map<String, Object?> json) =>
      _$RegressionFactorsFromJson(json);

  factory RegressionFactors.fromProject(Project project) {
    return RegressionFactors(
      y: project.metrics.y,
      x: [
        project.metrics.x1,
        if (project.metrics.x2 != null) project.metrics.x2!,
        if (project.metrics.x3 != null) project.metrics.x3!,
      ],
    );
  }
}

extension RegressionFactorsList on List<RegressionFactors> {
  List<List<double>> toArray() {
    return [
      map((f) => f.y).toList(),
      ...List.generate(first.x.length, (i) => map((f) => f.x[i]).toList()),
    ];
  }
}
