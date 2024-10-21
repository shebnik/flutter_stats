import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_quality.freezed.dart';
part 'model_quality.g.dart';

enum ModelQualityTypes { rSquared, mmre, pred }

@freezed
class ModelQuality with _$ModelQuality {
  const factory ModelQuality({
    required double rSquared,
    required double mmre,
    required double pred,
  }) = _ModelQuality;

  factory ModelQuality.fromJson(Map<String, dynamic> json) =>
      _$ModelQualityFromJson(json);

  factory ModelQuality.empty() => const ModelQuality(
        rSquared: 0,
        mmre: 0,
        pred: 0,
      );
}
