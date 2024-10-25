import 'package:freezed_annotation/freezed_annotation.dart';

part 'csv_alias.freezed.dart';
part 'csv_alias.g.dart';

@freezed
class CSVAlias with _$CSVAlias {
  const factory CSVAlias({
    @Default('RFC') String y,
    @Default('DIT') String x1,
    @Default('CBO') String x2,
    @Default('WMC') String x3,
    @Default('NOC') String noc,
    @Default('URL') String url,
  }) = _CSVAlias;

  factory CSVAlias.fromJson(Map<String, dynamic> json) =>
      _$CSVAliasFromJson(json);

  const CSVAlias._();

  static const defaultAlias = CSVAlias();
}
