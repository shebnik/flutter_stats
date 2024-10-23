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
      y: project.metrics!.rfc!,
      x: [
        project.metrics!.dit!,
        project.metrics!.cbo!,
        project.metrics!.wmc!,
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
