// lib/core/usecase/usecase.dart

import 'package:daliuren/model/pan_config.dart';
import 'package:fpdart/fpdart.dart' hide Failure;
import '../errors/failures.dart';

// Parameters have to be Equatable for value comparison
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(PanConfig config, Params params);
}

// This will be used by the code generator if `iązGenerateFailure` is true.
class NoParams {}
