// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coefficients.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoefficientsImpl _$$CoefficientsImplFromJson(Map<String, dynamic> json) =>
    _$CoefficientsImpl(
      b: (json['b'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      epsilon: (json['epsilon'] as num).toDouble(),
    );

Map<String, dynamic> _$$CoefficientsImplToJson(_$CoefficientsImpl instance) =>
    <String, dynamic>{
      'b': instance.b,
      'epsilon': instance.epsilon,
    };
