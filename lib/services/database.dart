import 'dart:convert';

import 'package:flutter_stats/models/dataset/dataset.dart';
import 'package:flutter_stats/models/settings/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Database {
  Database(this._db);
  final SharedPreferencesWithCache _db;

  Map<String, dynamic>? getMap(String key) {
    final json = _db.getString(key);
    if (json == null) {
      return null;
    }
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> setMap(String key, Map<String, dynamic> value) async {
    final json = jsonEncode(value);
    await _db.setString(key, json);
  }

  Settings getSettings() {
    final map = getMap('settings');
    if (map == null) {
      return const Settings();
    }
    return Settings.fromJson(map);
  }

  Future<void> setSettings(Settings settings) async {
    await setMap('settings', settings.toJson());
  }

  Dataset? getDataset() {
    final map = getMap('dataset');
    if (map == null) {
      return null;
    }
    return Dataset.fromJson(map);
  }

  Future<void> setDataset(Dataset dataset) async {
    await setMap('dataset', dataset.toJson());
  }
}
