import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    String? url,
    String? name,
    Metrics? metrics,
  }) = _Project;

  factory Project.fromJson(Map<String, Object?> json)
      => _$ProjectFromJson(json);
}
