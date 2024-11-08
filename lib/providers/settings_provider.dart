import 'package:flutter/material.dart';
import 'package:flutter_stats/models/settings/settings.dart';
import 'package:flutter_stats/services/database.dart';
import 'package:flutter_stats/services/logging/logger_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required this.db}) : _settings = db.getSettings() {
    _log.i('SettingsProvider initialized with settings: $_settings');
  }

  final _log = LoggerService.instance;
  Database db;
  Settings _settings;
  Settings get settings => _settings;

  bool get useRelativeNOC => _settings.useRelativeNOC;
  bool get useYInThousands => _settings.useYInThousands;
  String get nocAlias => _settings.csvAlias.noc;
  bool get hasX2 => _settings.hasX2;
  bool get hasX3 => _settings.hasX3;
  bool get hasNOC => _settings.hasNOC;
  String get yAlias => _settings.csvAlias.y;
  String get x1Alias => _settings.csvAlias.x1;
  String get x2Alias => _settings.csvAlias.x2;
  String get x3Alias => _settings.csvAlias.x3;
  String get urlAlias => _settings.csvAlias.url;

  set useYInThousands(bool value) {
    _log.i(
      'Setting useYInThousands: $value',
    );
    _settings = _settings.copyWith(useYInThousands: value);
    notifyListeners();
  }

  set useRelativeNOC(bool value) {
    _log.i('Setting useRelativeNOC: $value');
    _settings = _settings.copyWith(useRelativeNOC: value);
    notifyListeners();
  }

  set nocAlias(String value) {
    _log.i('Setting nocAlias: $value');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(noc: value),
    );
    notifyListeners();
  }

  set hasX2(bool value) {
    _log.i('Setting hasX2: $value');
    _settings = _settings.copyWith(hasX2: value);
    notifyListeners();
  }

  set hasX3(bool value) {
    _log.i('Setting hasX3: $value');
    _settings = _settings.copyWith(hasX3: value);
    notifyListeners();
  }

  set hasNOC(bool value) {
    _log.i('Setting hasNOC: $value');
    _settings = _settings.copyWith(hasNOC: value);
    notifyListeners();
  }

  set yAlias(String value) {
    _log.i('Setting yAlias: $value');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(y: value),
    );
    notifyListeners();
  }

  set x1Alias(String value) {
    _log.i('Setting x1Alias: $value');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x1: value),
    );
    notifyListeners();
  }

  set x2Alias(String value) {
    _log.i('Setting x2Alias: $value');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x2: value),
    );
    notifyListeners();
  }

  set x3Alias(String value) {
    _log.i('Setting x3Alias: $value');
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x3: value),
    );
    notifyListeners();
  }

  set urlAlias(String value) {
    _log.i('Setting urlAlias: $value');
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
