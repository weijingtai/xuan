abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DivinationFailure extends Failure {
  const DivinationFailure(super.message);
}

class NoParams {}

class DateTimeParams {
  final DateTime dateTime;
  final String? question;

  const DateTimeParams(this.dateTime, {this.question});
}
