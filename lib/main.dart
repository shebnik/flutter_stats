import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/app/app.dart';
import 'package:flutter_stats/services/logger.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = AppLogger().logger;

Future<void> main() async {
  _log.i('App started');
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    usePathUrlStrategy();
    registerErrorHandlers();

    final sp = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    runApp(App(sp: sp));
  }, (error, stackTrace) {
    _log.e(
      'Error',
      error: error,
      stackTrace: stackTrace,
    );
  });
}

void registerErrorHandlers() {
  FlutterError.onError = (details) {
    _log.e(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _log.e(
      'PlatformDispatcher Error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };
}
