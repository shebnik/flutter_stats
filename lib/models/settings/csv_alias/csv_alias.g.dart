// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'csv_alias.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CSVAliasImpl _$$CSVAliasImplFromJson(Map<String, dynamic> json) =>
    _$CSVAliasImpl(
      y: json['y'] as String? ?? 'RFC',
      x1: json['x1'] as String? ?? 'DIT',
      x2: json['x2'] as String? ?? 'CBO',
      x3: json['x3'] as String? ?? 'WMC',
      noc: json['noc'] as String? ?? 'NOC',
      url: json['url'] as String? ?? 'URL',
    );

Map<String, dynamic> _$$CSVAliasImplToJson(_$CSVAliasImpl instance) =>
    <String, dynamic>{
      'y': instance.y,
      'x1': instance.x1,
      'x2': instance.x2,
      'x3': instance.x3,
      'noc': instance.noc,
      'url': instance.url,
    };
