// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsImpl _$$SettingsImplFromJson(Map<String, dynamic> json) =>
    _$SettingsImpl(
      useRelativeNOC: json['useRelativeNOC'] as bool? ?? false,
      hasX2: json['hasX2'] as bool? ?? true,
      hasX3: json['hasX3'] as bool? ?? true,
      hasNOC: json['hasNOC'] as bool? ?? true,
      useYInThousands: json['useYInThousands'] as bool? ?? false,
      csvAlias: json['csvAlias'] == null
          ? CSVAlias.defaultAlias
          : CSVAlias.fromJson(json['csvAlias'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SettingsImplToJson(_$SettingsImpl instance) =>
    <String, dynamic>{
      'useRelativeNOC': instance.useRelativeNOC,
      'hasX2': instance.hasX2,
      'hasX3': instance.hasX3,
      'hasNOC': instance.hasNOC,
      'useYInThousands': instance.useYInThousands,
      'csvAlias': instance.csvAlias.toJson(),
    };
