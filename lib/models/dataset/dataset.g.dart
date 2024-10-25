// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DatasetImpl _$$DatasetImplFromJson(Map<String, dynamic> json) =>
    _$DatasetImpl(
      data: const Uint8ListConverter().fromJson(json['data'] as String),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$DatasetImplToJson(_$DatasetImpl instance) =>
    <String, dynamic>{
      'data': const Uint8ListConverter().toJson(instance.data),
      'name': instance.name,
    };
