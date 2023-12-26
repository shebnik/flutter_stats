import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_interval.freezed.dart';

part 'model_interval.g.dart';

@freezed
class ModelInterval with _$ModelInterval {
  const factory ModelInterval({
    required int index,
    required double calculatedValues,
    required double lowerConfidenceLimit,
    required double upperConfidenceLimit,
    required double lowerPredictionLimit,
    required double upperPredictionLimit,
  }) = _ModelInterval;

  factory ModelInterval.fromJson(Map<String, dynamic> json) =>
      _$ModelIntervalFromJson(json);
}
