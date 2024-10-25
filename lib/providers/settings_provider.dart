import 'package:flutter/material.dart';
import 'package:flutter_stats/models/settings/settings.dart';
import 'package:flutter_stats/services/database.dart';
import 'package:flutter_stats/services/logger.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required this.db}) : _settings = db.getSettings() {
    _log.i('SettingsProvider initialized with settings: $_settings');
  }

  final _log = AppLogger().logger;
  Database db;
  Settings _settings;
  Settings get settings => _settings;

  bool get useRelativeNOC {
    _log.d('Getting useRelativeNOC: ${_settings.useRelativeNOC}');
    return _settings.useRelativeNOC;
  }

  bool get useYInThousands {
    _log.d('Getting useYInThousands: ${_settings.useYInThousands}');
    return _settings.useYInThousands;
  }

  bool get includeIntervalsMethod {
    _log.d(
      'Getting includeIntervalsMethod: ${_settings.includeIntervalsMethod}',
    );
    return _settings.includeIntervalsMethod;
  }

  String get nocAlias {
    _log.d('Getting nocAlias: ${_settings.csvAlias.noc}');
    return _settings.csvAlias.noc;
  }

  bool get useSigma {
    _log.d('Getting useSigma: ${_settings.useSigma}');
    return _settings.useSigma;
  }

  bool get hasX2 {
    _log.d('Getting hasX2: ${_settings.hasX2}');
    return _settings.hasX2;
  }

  bool get hasX3 {
    _log.d('Getting hasX3: ${_settings.hasX3}');
    return _settings.hasX3;
  }

  bool get hasNOC {
    _log.d('Getting hasNOC: ${_settings.hasNOC}');
    return _settings.hasNOC;
  }

  String get yAlias {
    _log.d('Getting yAlias: ${_settings.csvAlias.y}');
    return _settings.csvAlias.y;
  }

  String get x1Alias {
    _log.d('Getting x1Alias: ${_settings.csvAlias.x1}');
    return _settings.csvAlias.x1;
  }

  String get x2Alias {
    _log.d('Getting x2Alias: ${_settings.csvAlias.x2}');
    return _settings.csvAlias.x2;
  }

  String get x3Alias {
    _log.d('Getting x3Alias: ${_settings.csvAlias.x3}');
    return _settings.csvAlias.x3;
  }

  String get urlAlias {
    _log.d('Getting urlAlias: ${_settings.csvAlias.url}');
    return _settings.csvAlias.url;
  }

  // Setters with enhanced logging
  set useYInThousands(bool value) {
    _log.i(
      'Setting useYInThousands: $value (was: ${_settings.useYInThousands})',
    );
    _settings = _settings.copyWith(useYInThousands: value);
    notifyListeners();
  }

  set includeIntervalsMethod(bool value) {
    _log.i(
      'Setting includeIntervalsMethod: $value'
      ' (was: ${_settings.includeIntervalsMethod})',
    );
    _settings = _settings.copyWith(includeIntervalsMethod: value);
    notifyListeners();
  }

  set useRelativeNOC(bool value) {
    _log.i('Setting useRelativeNOC: $value (was: ${_settings.useRelativeNOC})');
    _settings = _settings.copyWith(useRelativeNOC: value);
    notifyListeners();
  }

  set nocAlias(String value) {
    _log.i('Setting nocAlias: $value (was: ${_settings.csvAlias.noc})');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(noc: value),
    );
    notifyListeners();
  }

  set useSigma(bool value) {
    _log.i('Setting useSigma: $value (was: ${_settings.useSigma})');
    _settings = _settings.copyWith(useSigma: value);
    notifyListeners();
  }

  set hasX2(bool value) {
    _log.i('Setting hasX2: $value (was: ${_settings.hasX2})');
    _settings = _settings.copyWith(hasX2: value);
    notifyListeners();
  }

  set hasX3(bool value) {
    _log.i('Setting hasX3: $value (was: ${_settings.hasX3})');
    _settings = _settings.copyWith(hasX3: value);
    notifyListeners();
  }

  set hasNOC(bool value) {
    _log.i('Setting hasNOC: $value (was: ${_settings.hasNOC})');
    _settings = _settings.copyWith(hasNOC: value);
    notifyListeners();
  }

  set yAlias(String value) {
    _log.i('Setting yAlias: $value (was: ${_settings.csvAlias.y})');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(y: value),
    );
    notifyListeners();
  }

  set x1Alias(String value) {
    _log.i('Setting x1Alias: $value (was: ${_settings.csvAlias.x1})');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x1: value),
    );
    notifyListeners();
  }

  set x2Alias(String value) {
    _log.i('Setting x2Alias: $value (was: ${_settings.csvAlias.x2})');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x2: value),
    );
    notifyListeners();
  }

  set x3Alias(String value) {
    _log.i('Setting x3Alias: $value (was: ${_settings.csvAlias.x3})');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x3: value),
    );
    notifyListeners();
  }

  set urlAlias(String value) {
    _log.i('Setting urlAlias: $value (was: ${_settings.csvAlias.url})');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(url: value),
    );
    notifyListeners();
  }

  @override
  void notifyListeners() {
    try {
      super.notifyListeners();
      db.setSettings(settings);
      _log.d('Settings saved to database');
    } catch (e, stackTrace) {
      _log.e(
        'Failed to save settings to database',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    _log.i('SettingsProvider disposed');
    super.dispose();
  }
}
