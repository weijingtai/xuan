// lib/core/errors/failures.dart

// Base Failure class
abstract class Failure {
  final String message;
  final StackTrace? stackTrace;

  Failure(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

// General failures
class ServerFailure extends Failure {
  ServerFailure(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}

class CacheFailure extends Failure {
  CacheFailure(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}

class UnknownFailure extends Failure {
  UnknownFailure(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}

class InvalidInputFailure extends Failure {
  InvalidInputFailure(String message, [StackTrace? stackTrace]) : super(message, stackTrace);
}
