import 'package:flutter_stats/services/logging/log_entry.dart';

abstract class BaseLogOutput {
  Future<void> initialize();
  void write(LogEntry entry);
  Future<void> dispose();
}
