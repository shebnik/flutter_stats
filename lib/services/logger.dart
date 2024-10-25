import 'package:logger/logger.dart';

class AppLogger {
  AppLogger()
      : logger = Logger(
          printer: PrettyPrinter(
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
          filter: PermissiveFilter(),
        );

  final Logger logger;
}

class PermissiveFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
    // const localHostAddresses = [
    //   'localhost',
    //   '127.0.0.1',
    //   '::1',
    //   '[::1]',
    // ];

    // final currentHost = Uri.base.host.toLowerCase();

    // return kDebugMode || localHostAddresses.contains(currentHost);
  }
}
