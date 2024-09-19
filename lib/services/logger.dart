import 'package:logger/logger.dart';

class AppLogger {
  AppLogger()
      : logger = Logger(
          printer: PrettyPrinter(
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
          // filter: PermissiveFilter(),
        );

  final Logger logger;
}

class PermissiveFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}
