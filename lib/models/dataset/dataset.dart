import 'dart:typed_data';

import 'package:flutter_stats/models/uint8list_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dataset.freezed.dart';
part 'dataset.g.dart';

@freezed
class Dataset with _$Dataset {
  const factory Dataset({
    @Uint8ListConverter() required Uint8List data,
    String? name,
  }) = _Dataset;

  factory Dataset.fromJson(Map<String, dynamic> json) =>
      _$DatasetFromJson(json);
}
