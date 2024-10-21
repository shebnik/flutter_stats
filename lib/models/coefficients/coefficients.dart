import 'package:freezed_annotation/freezed_annotation.dart';

part 'coefficients.freezed.dart';

part 'coefficients.g.dart';

@freezed
class Coefficients with _$Coefficients {
  const factory Coefficients({
    required List<double> b,
    required double sigma,
  }) = _Coefficients;

  factory Coefficients.fromJson(Map<String, dynamic> json) =>
      _$CoefficientsFromJson(json);

  factory Coefficients.empty() => const Coefficients(
        b: [],
        sigma: 0,
      );
}
