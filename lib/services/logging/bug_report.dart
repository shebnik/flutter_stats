// ignore_for_file: cascade_invocations

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/constants.dart';
import 'package:flutter_stats/services/logging/logger_service.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Result of the bug report operation
enum BugReportResult {
  success,
  logFileNotFound,
  emailClientError,
  folderOpenError,
  unknownError
}

class BugReportService {
  static const String _bugReportSubject = 'FlutterStats Bug Report';

  /// Reports a bug by gathering logs and launching email client
  /// Returns a [BugReportResult] indicating the outcome
  static Future<BugReportResult> reportBug({
    BuildContext? context,
    String? additionalInfo,
  }) async {
    final logger = LoggerService.instance;

    try {
      final logFilePath = await _getLogFilePath();

      logger.i(
        'Bug report requested',
        metadata: {
          'logFilePath': logFilePath,
          'additionalInfo': additionalInfo,
          'platform': Platform.operatingSystem,
        },
      );

      // Verify log file exists
      final logFile = File(logFilePath);
      if (!logFile.existsSync()) {
        logger.e(
          'Log file not found',
          metadata: {'path': logFilePath},
        );
        return BugReportResult.logFileNotFound;
      }

      // Get system info
      final systemInfo = await _getSystemInfo();

      // Construct email body
      final emailBody = _constructEmailBody(
        logFilePath: logFilePath,
        systemInfo: systemInfo,
        additionalInfo: additionalInfo,
      );

      final emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': _bugReportSubject,
          'body': emailBody,
        },
      );

      // Open folder containing logs on desktop platforms
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        await _openLogFolder(logFilePath);
      }

      // Copy log path to clipboard
      await Clipboard.setData(ClipboardData(text: logFilePath));

      // Launch email client
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return BugReportResult.success;
      } else {
        logger.e('Cannot launch email client');
        return BugReportResult.emailClientError;
      }
    } catch (e, stackTrace) {
      logger.e(
        'Error sending bug report',
        error: e,
        stackTrace: stackTrace,
      );
      return BugReportResult.unknownError;
    }
  }

  /// Gets the full path to the log file
  static Future<String> _getLogFilePath() async {
    final config = LoggerService.instance.config;
    final docsDir = await getApplicationDocumentsDirectory();
    return path.join(
      docsDir.path,
      config.logDirectory,
      config.logFileName,
    );
  }

  /// Opens the folder containing the log file based on platform
  static Future<void> _openLogFolder(String logFilePath) async {
    try {
      final directory = path.dirname(logFilePath);

      if (Platform.isWindows) {
        await Process.run('explorer.exe', [directory]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [directory]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [directory]);
      }
    } catch (e) {
      LoggerService.instance.e(
        'Failed to open log file location',
        error: e,
      );
      throw Exception('Failed to open log folder: $e');
    }
  }

  /// Gathers system information for the bug report
  static Future<Map<String, String>> _getSystemInfo() async {
    return {
      'Platform': Platform.operatingSystem,
      'Version': Platform.operatingSystemVersion,
      'Locale': Platform.localeName,
      'Dart Version': Platform.version,
    };
  }

  /// Constructs the email body with all necessary information
  static String _constructEmailBody({
    required String logFilePath,
    required Map<String, String> systemInfo,
    String? additionalInfo,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Bug Report Details:');
    buffer.writeln('-------------------');

    // System information
    buffer.writeln('\nSystem Information:');
    systemInfo.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    // Log file location
    buffer.writeln('\nLog File Location:');
    buffer.writeln(logFilePath);
    buffer.writeln('(Path has been copied to clipboard)');

    // Additional information
    if (additionalInfo != null && additionalInfo.isNotEmpty) {
      buffer.writeln('\nAdditional Information:');
      buffer.writeln(additionalInfo);
    }

    buffer.writeln('\nPlease attach the log file when sending this report.');

    return buffer.toString();
  }
}
