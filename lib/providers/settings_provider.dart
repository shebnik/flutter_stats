import 'package:flutter/material.dart';
import 'package:flutter_stats/models/settings/settings.dart';
import 'package:flutter_stats/services/database.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required this.db}) : _settings = db.getSettings();

  Database db;
  Settings _settings;
  Settings get settings => _settings;

  bool get useRelativeNOC => _settings.useRelativeNOC;
  String get nocAlias => _settings.csvAlias.noc;
  bool get useSigma => _settings.useSigma;
  bool get useX2 => _settings.useX2;
  bool get useX3 => _settings.useX3;
  String get yAlias => _settings.csvAlias.y;
  String get x1Alias => _settings.csvAlias.x1;
  String get x2Alias => _settings.csvAlias.x2;
  String get x3Alias => _settings.csvAlias.x3;
  String get urlAlias => _settings.csvAlias.url;

  set useRelativeNOC(bool value) {
    _settings = _settings.copyWith(useRelativeNOC: value);
    notifyListeners();
  }

  set nocAlias(String value) {
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(noc: value),
    );
    notifyListeners();
  }

  set useSigma(bool value) {
    _settings = _settings.copyWith(useSigma: value);
    notifyListeners();
  }

  set useX2(bool value) {
    _settings = _settings.copyWith(useX2: value);
    notifyListeners();
  }

  set useX3(bool value) {
    _settings = _settings.copyWith(useX3: value);
    notifyListeners();
  }

  set yAlias(String value) {
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(y: value),
    );
    notifyListeners();
  }

  set x1Alias(String value) {
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x1: value),
    );
    notifyListeners();
  }

  set x2Alias(String value) {
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x2: value),
    );
    notifyListeners();
  }

  set x3Alias(String value) {
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(x3: value),
    );
    notifyListeners();
  }

  set urlAlias(String value) {
    _settings = _settings.copyWith(
      csvAlias: _settings.csvAlias.copyWith(url: value),
    );
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    db.setSettings(settings);
  }
}
