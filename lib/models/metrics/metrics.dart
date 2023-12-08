import 'package:freezed_annotation/freezed_annotation.dart';

part 'metrics.freezed.dart';
part 'metrics.g.dart';

@freezed
class Metrics with _$Metrics {
  const factory Metrics({
    double? linesOfCode,
    double? cyclomaticComplexity,
    double? numberOfMethods,
    double? numberOfClasses,
  }) = _Metrics;

  factory Metrics.fromJson(Map<String, Object?> json)
      => _$MetricsFromJson(json);
}
