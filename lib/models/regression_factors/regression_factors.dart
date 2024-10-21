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
        project.metrics!.cbo!,
        project.metrics!.wmc!,
        project.metrics!.dit!,
      ],
    );
  }
}
