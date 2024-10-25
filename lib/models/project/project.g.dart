// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      metrics: Metrics.fromJson(json['metrics'] as Map<String, dynamic>),
      url: json['url'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'metrics': instance.metrics,
      'url': instance.url,
      'name': instance.name,
    };
