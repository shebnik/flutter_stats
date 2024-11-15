import 'package:freezed_annotation/freezed_annotation.dart';

part 'intervals.freezed.dart';

part 'intervals.g.dart';

@freezed
class Intervals with _$Intervals {
  const factory Intervals({
    required List<double> predictionLower,
    required List<double> predictionUpper,
    required List<double> confidenceLower,
    required List<double> confidenceUpper,
  }) = _Intervals;

  factory Intervals.fromJson(Map<String, dynamic> json) =>
      _$IntervalsFromJson(json);

  factory Intervals.empty() => const Intervals(
        predictionLower: [],
        predictionUpper: [],
        confidenceLower: [],
        confidenceUpper: [],
      );
}
