
import 'package:flutter_stats/models/settings/csv_alias/csv_alias.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
class Settings with _$Settings {
  @JsonSerializable(explicitToJson: true)
  const factory Settings({
    @Default(false) bool useRelativeNOC,
    @Default(false) bool useSigma,
    @Default(true) bool hasX2,
    @Default(true) bool hasX3,
    @Default(true) bool hasNOC,
    @Default(false) bool useYInThousands,
    @Default(false) bool includeIntervalsMethod,
    @Default(CSVAlias.defaultAlias) CSVAlias csvAlias,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}
