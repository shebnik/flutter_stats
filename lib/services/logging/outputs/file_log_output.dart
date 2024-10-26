import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_stats/services/logging/log_entry.dart';
import 'package:flutter_stats/services/logging/logger_config.dart';
import 'package:flutter_stats/services/logging/outputs/base_log_output.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/extension.dart';

class FileLogOutput extends BaseLogOutput {
  FileLogOutput(this.config);

  final LoggerConfig config;
  File? _file;
  final _lock = Object();

  @override
  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final logDirPath = path.join(directory.path, config.logDirectory);
    final logFilePath = path.join(logDirPath, config.logFileName);

    await Directory(logDirPath).create(recursive: true);
    _file = File(logFilePath);

    await _rotateLogsIfNeeded();
  }

  Future<void> _rotateLogsIfNeeded() async {
    if (!_file!.existsSync()) return;

    final size = await _file!.length();
    if (size <= config.maxFileSize) return;

    final backupPath = '${_file!.path}.old';
    final backupFile = File(backupPath);

    if (backupFile.existsSync()) {
      await backupFile.delete();
    }

    await _file!.rename(backupPath);
    _file = File(_file!.path);
  }

  @override
  void write(LogEntry entry) {
    if (_file == null) return;

    _lock.synchronized(() {
      try {
        final formattedEntry = _formatEntry(entry);
        _file!.writeAsStringSync(
          '$formattedEntry\n',
          mode: FileMode.append,
          flush: true,
        );
      } catch (e) {
        debugPrint('Failed to write to log file: $e');
      }
    });
  }

  String _formatEntry(LogEntry entry) {
    final timestamp = _formatTimestamp(entry.timestamp);
    final level = entry.level.emoji;
    final message = entry.message;

    final buffer = StringBuffer('$timestamp $level $message');

    if (entry.error != null) {
      buffer.write('\nERROR: ${entry.error}');
    }

    if (entry.stackTrace != null) {
      final frames = entry.stackTrace
          .toString()
          .split('\n')
          .take(config.maxStackTraceLines)
          .map((frame) => '  $frame')
          .join('\n');
      buffer.write('\nSTACK TRACE:\n$frames');
    }

    if (entry.metadata != null) {
      buffer.write('\nMETADATA: ${_formatMetadata(entry.metadata!)}');
    }

    return buffer.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.toIso8601String()} '
        '(+${_formatDuration(timestamp.difference(_startTime))})';
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:'
        '${(duration.inSeconds % 60).toString().padLeft(2, '0')}.'
        '${(duration.inMilliseconds % 1000).toString().padLeft(3, '0')}';
  }

  String _formatMetadata(Map<String, dynamic> metadata) {
    return metadata.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  final _startTime = DateTime.now();

  @override
  Future<void> dispose() async {
    _file = null;
  }
}
