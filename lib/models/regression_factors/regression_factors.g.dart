// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'regression_factors.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegressionFactorsImpl _$$RegressionFactorsImplFromJson(
        Map<String, dynamic> json) =>
    _$RegressionFactorsImpl(
      y: (json['y'] as num).toDouble(),
      x: (json['x'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$RegressionFactorsImplToJson(
        _$RegressionFactorsImpl instance) =>
    <String, dynamic>{
      'y': instance.y,
      'x': instance.x,
    };
