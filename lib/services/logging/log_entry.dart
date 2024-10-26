import 'package:flutter/widgets.dart';
import 'package:flutter_stats/services/logging/logger_config.dart';

@immutable
class LogEntry {
  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.metadata,
  });

  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  @override
  String toString() {
    final buffer = StringBuffer()..write('[$level] $message');
    if (error != null) buffer.write('\nError: $error');
    if (stackTrace != null) buffer.write('\nStack: $stackTrace');
    if (metadata != null) buffer.write('\nMetadata: $metadata');
    return buffer.toString();
  }
}
