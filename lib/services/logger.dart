import 'package:logger/logger.dart';

class AppLogger {
  AppLogger()
      : logger = Logger(
          printer: PrettyPrinter(
            printTime: true,
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