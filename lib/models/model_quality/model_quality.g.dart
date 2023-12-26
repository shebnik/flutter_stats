// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_quality.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModelQualityImpl _$$ModelQualityImplFromJson(Map<String, dynamic> json) =>
    _$ModelQualityImpl(
      rSquared: (json['rSquared'] as num).toDouble(),
      sy: (json['sy'] as num).toDouble(),
      mmre: (json['mmre'] as num).toDouble(),
      pred: (json['pred'] as num).toDouble(),
    );

Map<String, dynamic> _$$ModelQualityImplToJson(_$ModelQualityImpl instance) =>
    <String, dynamic>{
      'rSquared': instance.rSquared,
      'sy': instance.sy,
      'mmre': instance.mmre,
      'pred': instance.pred,
    };
