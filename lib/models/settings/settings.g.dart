// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsImpl _$$SettingsImplFromJson(Map<String, dynamic> json) =>
    _$SettingsImpl(
      useRelativeNOC: json['useRelativeNOC'] as bool? ?? false,
      useSigma: json['useSigma'] as bool? ?? false,
      useX2: json['useX2'] as bool? ?? true,
      useX3: json['useX3'] as bool? ?? true,
      csvAlias: json['csvAlias'] == null
          ? CSVAlias.defaultAlias
          : CSVAlias.fromJson(json['csvAlias'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SettingsImplToJson(_$SettingsImpl instance) =>
    <String, dynamic>{
      'useRelativeNOC': instance.useRelativeNOC,
      'useSigma': instance.useSigma,
      'useX2': instance.useX2,
      'useX3': instance.useX3,
      'csvAlias': instance.csvAlias.toJson(),
    };
