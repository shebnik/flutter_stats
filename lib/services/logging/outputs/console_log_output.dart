import 'package:flutter/material.dart';
import 'package:flutter_stats/services/logging/log_entry.dart';
import 'package:flutter_stats/services/logging/outputs/base_log_output.dart';

class ConsoleLogOutput extends BaseLogOutput {
  @override
  Future<void> initialize() async {}

  @override
  void write(LogEntry entry) {
    debugPrint(entry.toString());
  }

  @override
  Future<void> dispose() async {}
}
