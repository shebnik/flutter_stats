// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsImpl _$$SettingsImplFromJson(Map<String, dynamic> json) =>
    _$SettingsImpl(
      useRelativeNOC: json['useRelativeNOC'] as bool? ?? false,
      useSigma: json['useSigma'] as bool? ?? false,
      hasX2: json['hasX2'] as bool? ?? true,
      hasX3: json['hasX3'] as bool? ?? true,
      hasNOC: json['hasNOC'] as bool? ?? true,
      csvAlias: json['csvAlias'] == null
          ? CSVAlias.defaultAlias
          : CSVAlias.fromJson(json['csvAlias'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SettingsImplToJson(_$SettingsImpl instance) =>
    <String, dynamic>{
      'useRelativeNOC': instance.useRelativeNOC,
      'useSigma': instance.useSigma,
      'hasX2': instance.hasX2,
      'hasX3': instance.hasX3,
      'hasNOC': instance.hasNOC,
      'csvAlias': instance.csvAlias.toJson(),
    };
