// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MetricsImpl _$$MetricsImplFromJson(Map<String, dynamic> json) =>
    _$MetricsImpl(
      linesOfCode: (json['linesOfCode'] as num?)?.toDouble(),
      cyclomaticComplexity: (json['cyclomaticComplexity'] as num?)?.toDouble(),
      numberOfMethods: (json['numberOfMethods'] as num?)?.toDouble(),
      numberOfClasses: (json['numberOfClasses'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$MetricsImplToJson(_$MetricsImpl instance) =>
    <String, dynamic>{
      'linesOfCode': instance.linesOfCode,
      'cyclomaticComplexity': instance.cyclomaticComplexity,
      'numberOfMethods': instance.numberOfMethods,
      'numberOfClasses': instance.numberOfClasses,
    };
