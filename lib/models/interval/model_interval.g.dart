// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_interval.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModelIntervalImpl _$$ModelIntervalImplFromJson(Map<String, dynamic> json) =>
    _$ModelIntervalImpl(
      index: (json['index'] as num).toInt(),
      calculatedValues: (json['calculatedValues'] as num).toDouble(),
      lowerConfidenceLimit: (json['lowerConfidenceLimit'] as num).toDouble(),
      upperConfidenceLimit: (json['upperConfidenceLimit'] as num).toDouble(),
      lowerPredictionLimit: (json['lowerPredictionLimit'] as num).toDouble(),
      upperPredictionLimit: (json['upperPredictionLimit'] as num).toDouble(),
    );

Map<String, dynamic> _$$ModelIntervalImplToJson(_$ModelIntervalImpl instance) =>
    <String, dynamic>{
      'index': instance.index,
      'calculatedValues': instance.calculatedValues,
      'lowerConfidenceLimit': instance.lowerConfidenceLimit,
      'upperConfidenceLimit': instance.upperConfidenceLimit,
      'lowerPredictionLimit': instance.lowerPredictionLimit,
      'upperPredictionLimit': instance.upperPredictionLimit,
    };
