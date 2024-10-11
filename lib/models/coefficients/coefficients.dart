import 'package:freezed_annotation/freezed_annotation.dart';

part 'coefficients.freezed.dart';

part 'coefficients.g.dart';

@freezed
class Coefficients with _$Coefficients {
  const factory Coefficients({
    required double b0,
    required double b1,
    required double b2,
    required double b3,
    required double sigma,
  }) = _Coefficients;

  factory Coefficients.fromJson(Map<String, dynamic> json) =>
      _$CoefficientsFromJson(json);
}
