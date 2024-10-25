// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MetricsImpl _$$MetricsImplFromJson(Map<String, dynamic> json) =>
    _$MetricsImpl(
      y: (json['y'] as num).toDouble(),
      x1: (json['x1'] as num).toDouble(),
      x2: (json['x2'] as num?)?.toDouble(),
      x3: (json['x3'] as num?)?.toDouble(),
      noc: (json['noc'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$MetricsImplToJson(_$MetricsImpl instance) =>
    <String, dynamic>{
      'y': instance.y,
      'x1': instance.x1,
      'x2': instance.x2,
      'x3': instance.x3,
      'noc': instance.noc,
    };
