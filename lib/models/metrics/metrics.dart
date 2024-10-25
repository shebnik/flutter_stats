import 'package:freezed_annotation/freezed_annotation.dart';

part 'metrics.freezed.dart';
part 'metrics.g.dart';

@freezed
class Metrics with _$Metrics {
  const factory Metrics({
    required double y,
    required double x1,
    double? x2,
    double? x3,
    double? noc,
  }) = _Metrics;

  factory Metrics.fromJson(Map<String, Object?> json)
      => _$MetricsFromJson(json);
}
