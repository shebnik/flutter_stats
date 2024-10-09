// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MetricsImpl _$$MetricsImplFromJson(Map<String, dynamic> json) =>
    _$MetricsImpl(
      dit: (json['dit'] as num?)?.toDouble(),
      rfc: (json['rfc'] as num?)?.toDouble(),
      cbo: (json['cbo'] as num?)?.toDouble(),
      wmc: (json['wmc'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$MetricsImplToJson(_$MetricsImpl instance) =>
    <String, dynamic>{
      'dit': instance.dit,
      'rfc': instance.rfc,
      'cbo': instance.cbo,
      'wmc': instance.wmc,
    };
