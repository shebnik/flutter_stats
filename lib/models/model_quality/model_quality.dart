import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_quality.freezed.dart';

part 'model_quality.g.dart';

@freezed
class ModelQuality with _$ModelQuality {
  const factory ModelQuality({
    required double rSquared,
    required double sy,
    required double mmre,
    required double pred,
  }) = _ModelQuality;

  factory ModelQuality.fromJson(Map<String, dynamic> json) =>
      _$ModelQualityFromJson(json);
}
