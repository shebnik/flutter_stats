import 'package:flutter/foundation.dart';

@immutable
class LoggerConfig {
  const LoggerConfig({
    this.maxFileSize = 10 * 1024 * 1024,
    this.logDirectory = 'FlutterStats',
    this.logFileName = 'app.log',
    this.maxStackTraceLines = 5,
    this.enableConsoleOutput = true,
    this.enableFileOutput = true,
    this.minLogLevel = LogLevel.info,
  });

  final int maxFileSize;
  final String logDirectory;
  final String logFileName;
  final int maxStackTraceLines;
  final bool enableConsoleOutput;
  final bool enableFileOutput;
  final LogLevel minLogLevel;
}

enum LogLevel {
  trace(0, '🔍'),
  debug(1, '🐛'),
  info(2, '💡'),
  warning(3, '⚠️'),
  error(4, '❌'),
  fatal(5, '💀');

  const LogLevel(this.priority, this.emoji);
  final int priority;
  final String emoji;

  bool canLog(LogLevel minimumLevel) => priority >= minimumLevel.priority;
}
