import 'package:flutter_stats/services/logging/log_entry.dart';
import 'package:flutter_stats/services/logging/logger_config.dart';
import 'package:flutter_stats/services/logging/outputs/base_log_output.dart';
import 'package:flutter_stats/services/logging/outputs/console_log_output.dart';
import 'package:flutter_stats/services/logging/outputs/file_log_output.dart';

class LoggerService {
  LoggerService._();
  static LoggerService? _instance;

  static Future<LoggerService> initialize({
    LoggerConfig config = const LoggerConfig(),
  }) async {
    if (_instance != null) return _instance!;

    final service = LoggerService._();
    await service._initialize(config);
    _instance = service;
    return service;
  }

  static LoggerService get instance {
    if (_instance == null) {
      throw StateError('LoggerService is not initialized');
    }

    return _instance!;
  }

  late final LoggerConfig _config;
  LoggerConfig get config => _config;
  final List<BaseLogOutput> _outputs = [];

  Future<void> _initialize(LoggerConfig config) async {
    _config = config;

    if (config.enableConsoleOutput) {
      _outputs.add(ConsoleLogOutput());
    }

    if (config.enableFileOutput) {
      _outputs.add(FileLogOutput(config));
    }

    await Future.wait(_outputs.map((output) => output.initialize()));
  }

  void log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    if (!level.canLog(_config.minLogLevel)) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );

    for (final output in _outputs) {
      output.write(entry);
    }
  }

  // Convenience methods
  void t(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      log(
        LogLevel.trace,
        message,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );

  void d(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      log(
        LogLevel.debug,
        message,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );

  void i(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      log(
        LogLevel.info,
        message,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );

  void w(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      log(
        LogLevel.warning,
        message,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );

  void e(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      log(
        LogLevel.error,
        message,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );

  void f(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) =>
      log(
        LogLevel.fatal,
        message,
        error: error,
        stackTrace: stackTrace,
        metadata: metadata,
      );

  Future<void> dispose() async {
    await Future.wait(_outputs.map((output) => output.dispose()));
    _instance = null;
  }
}
