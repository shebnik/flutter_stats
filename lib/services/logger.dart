// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AppLogger {
  factory AppLogger() {
    _instance ??= AppLogger._internal();
    return _instance!;
  }
  AppLogger._internal()
      : logger = Logger(
          printer: CustomPrinter(),
          output: MultiOutput([
            ConsoleOutput(),
            SyncFileOutput(),
          ]),
          filter: ProductionFilter(),
        );
  static AppLogger? _instance;

  final Logger logger;
}

class CustomPrinter extends LogPrinter {
  static final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
  final _startTime = DateTime.now();

  @override
  List<String> log(LogEvent event) {
    final now = DateTime.now();
    final timeSinceStart = now.difference(_startTime);
    final emoji = _getEmoji(event.level);
    final message = _formatMessage(event.message);
    final error = event.error;
    final stackTrace = event.stackTrace;

    final output = <String>[
      '${dateFormatter.format(now)} (+${_formatDuration(timeSinceStart)}) $emoji $message',
    ];

    if (error != null) {
      output.add('ERROR: $error');
    }

    if (stackTrace != null) {
      final frames = stackTrace
          .toString()
          .split('\n')
          .take(5)
          .map((frame) => '  $frame')
          .join('\n');
      output.add('STACK TRACE:\n$frames');
    }

    return output;
  }

  String _formatMessage(dynamic message) {
    if (message is List || message is Map) {
      return '\n${_indentJson(message.toString())}';
    }
    return message.toString();
  }

  String _indentJson(String json) {
    return json.split('\n').map((line) => '  $line').join('\n');
  }

  String _formatDuration(Duration duration) {
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}.${(duration.inMilliseconds % 1000).toString().padLeft(3, '0')}';
  }

  String _getEmoji(Level level) {
    switch (level) {
      case Level.trace:
        return '🔍';
      case Level.debug:
        return '🐛';
      case Level.info:
        return '💡';
      case Level.warning:
        return '⚠️';
      case Level.error:
        return '❌';
      case Level.fatal:
        return '💀';
      // ignore: no_default_cases
      default:
        return '📝';
    }
  }
}

class SyncFileOutput extends LogOutput {
  SyncFileOutput() {
    _initFile();
  }
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  File? _file;
  bool _initialized = false;
  final _initCompleter = Completer<void>();

  Future<void> _initFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDirPath = path.join(directory.path, 'FlutterStats');
      final logFilePath = path.join(logDirPath, 'app.log');

      final logDir = Directory(logDirPath);
      if (!logDir.existsSync()) {
        await logDir.create(recursive: true);
      }

      _file = File(logFilePath);

      // Rotate logs if needed
      if (_file!.existsSync()) {
        final size = await _file!.length();
        if (size > _maxFileSize) {
          final backupPath = '$logFilePath.old';
          final backupFile = File(backupPath);
          if (backupFile.existsSync()) {
            await backupFile.delete();
          }
          await _file!.rename(backupPath);
          _file = File(logFilePath);
        }
      }

      _initialized = true;
      _initCompleter.complete();
    } catch (e) {
      debugPrint('Failed to initialize file logging: $e');
      _initCompleter.completeError(e);
    }
  }

  @override
  void output(OutputEvent event) {
    if (!_initialized) {
      // Wait for initialization if it's not done yet
      _initCompleter.future.then((_) => _writeLines(event.lines));
      return;
    }
    _writeLines(event.lines);
  }

  void _writeLines(List<String> lines) {
    try {
      if (_file != null) {
        final content = lines.map((line) => '$line\n').join();
        _file!.writeAsStringSync(content, mode: FileMode.append, flush: true);
      }
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }

  @override
  Future<void> destroy() async {
    // No need to close anything as we're using sync operations
    await super.destroy();
  }
}
