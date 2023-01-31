import 'package:logger/logger.dart';

class DebugLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

Logger _logger = Logger(printer: PrettyPrinter(), filter: DebugLogFilter());

Logger get logger => _logger;
