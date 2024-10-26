import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/app/app.dart';
import 'package:flutter_stats/services/logging/logger_config.dart';
import 'package:flutter_stats/services/logging/logger_service.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    final logger = await LoggerService.initialize(
      config: LoggerConfig(
        maxFileSize: 5 * 1024 * 1024, // 5MB
        logDirectory: path.join('FlutterStats', 'logs'),
        minLogLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
        enableFileOutput: !kIsWeb,
      ),
    );
    logger.i(
      'Application started',
      metadata: {
        'version': '1.0.0',
        'buildNumber': '42',
        'isWeb': kIsWeb,
        'platform': Platform.operatingSystem,
        'operatingSystemVersion': Platform.operatingSystemVersion,
        'localHostname': Platform.localHostname,
        'numberOfProcessors': Platform.numberOfProcessors,
      },
    );

    usePathUrlStrategy();
    registerErrorHandlers(logger);

    final sp = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    runApp(App(sp: sp));
  }, (error, stackTrace) {
    LoggerService.instance.e(
      'Error',
      error: error,
      stackTrace: stackTrace,
    );
  });
}

void registerErrorHandlers(LoggerService logger) {
  FlutterError.onError = (details) {
    logger.e(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logger.e(
      'PlatformDispatcher Error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };
}
