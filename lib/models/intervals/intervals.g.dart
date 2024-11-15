// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IntervalsImpl _$$IntervalsImplFromJson(Map<String, dynamic> json) =>
    _$IntervalsImpl(
      predictionLower: (json['predictionLower'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      predictionUpper: (json['predictionUpper'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      confidenceLower: (json['confidenceLower'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      confidenceUpper: (json['confidenceUpper'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$$IntervalsImplToJson(_$IntervalsImpl instance) =>
    <String, dynamic>{
      'predictionLower': instance.predictionLower,
      'predictionUpper': instance.predictionUpper,
      'confidenceLower': instance.confidenceLower,
      'confidenceUpper': instance.confidenceUpper,
    };
