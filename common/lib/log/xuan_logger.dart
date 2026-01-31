import 'dart:developer' as developer;

abstract class XuanLogger {
  void d(String message, [dynamic error, StackTrace? stackTrace]);
  void i(String message, [dynamic error, StackTrace? stackTrace]);
  void w(String message, [dynamic error, StackTrace? stackTrace]);
  void e(String message, [dynamic error, StackTrace? stackTrace]);
}

class DevLogger implements XuanLogger {
  const DevLogger();

  @override
  void d(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log('DEBUG: $message',
        error: error, stackTrace: stackTrace, level: 0);
  }

  @override
  void i(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log('INFO: $message',
        error: error, stackTrace: stackTrace, level: 800);
  }

  @override
  void w(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log('WARN: $message',
        error: error, stackTrace: stackTrace, level: 900);
  }

  @override
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log('ERROR: $message',
        error: error, stackTrace: stackTrace, level: 1000);
  }
}

/// Global logger instance
final XuanLogger logger = const DevLogger();
