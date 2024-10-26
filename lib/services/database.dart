import 'dart:convert';

import 'package:flutter_stats/models/dataset/dataset.dart';
import 'package:flutter_stats/models/settings/settings.dart';
import 'package:flutter_stats/services/logging/logger_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Database {
  Database(this._db);
  final SharedPreferencesWithCache _db;
  final _logger = LoggerService.instance;

  Map<String, dynamic>? getMap(String key) {
    try {
      final json = _db.getString(key);
      if (json == null) {
        return null;
      }
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Error getting map from database: $e');
      return null;
    }
  }

  Future<void> setMap(String key, Map<String, dynamic> value) async {
    try {
      final json = jsonEncode(value);
      await _db.setString(key, json);
    } catch (e) {
      _logger.e('Error setting map in database: $e');
    }
  }

  Settings getSettings() {
    try {
      final map = getMap('settings');
      if (map == null) {
        return const Settings();
      }
      return Settings.fromJson(map);
    } catch (e) {
      _logger.e('Error getting settings from database: $e');
      return const Settings();
    }
  }

  Future<void> setSettings(Settings settings) async {
    try {
      await setMap('settings', settings.toJson());
    } catch (e) {
      _logger.e('Error setting settings in database: $e');
    }
  }

  Dataset? getDataset() {
    try {
      final map = getMap('dataset');
      if (map == null) {
        return null;
      }
      return Dataset.fromJson(map);
    } catch (e) {
      _logger.e('Error getting dataset from database: $e');
      return null;
    }
  }

  Future<void> setDataset(Dataset dataset) async {
    try {
      await setMap('dataset', dataset.toJson());
    } catch (e) {
      _logger.e('Error setting dataset in database: $e');
    }
  }
}
