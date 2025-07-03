// lib/core/usecase/usecase.dart

import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';

// Parameters have to be Equatable for value comparison
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// This will be used by the code generator if `iązGenerateFailure` is true.
class NoParams {}
