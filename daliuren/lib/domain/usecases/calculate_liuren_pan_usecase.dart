// lib/domain/usecases/calculate_liuren_pan_usecase.dart

import 'package:fpdart/fpdart.dart' hide Failure;
import 'package:daliuren/core/errors/failures.dart';
import 'package:daliuren/core/usecase/usecase.dart'; // Base UseCase interface
import 'package:daliuren/domain/entities/liuren_pan.dart'; // Return type
import 'package:daliuren/domain/entities/pan_input.dart'; // Parameter type
import 'package:daliuren/domain/repositories/liuren_repository.dart';

/// Use case for calculating or retrieving a Liu Ren Pan.
/// It orchestrates the interaction with the [LiuRenRepository] to get the divination盘.
class CalculateLiuRenPanUseCase implements UseCase<LiuRenPan, PanInput> {
  final LiuRenRepository _repository;

  CalculateLiuRenPanUseCase(this._repository);

  /// Executes the use case to get a Liu Ren Pan.
  ///
  /// [params]: An instance of [PanInput] containing the necessary parameters
  ///           (either date/time or GanZhi information) for the divination.
  ///
  /// Returns [Either<Failure, LiuRenPan>]:
  /// - Right([LiuRenPan]) containing the successfully calculated or retrieved pan.
  /// - Left([Failure]) if an error occurs during the process.
  ///
  /// Note: Input validation for [PanInput] integrity is expected to be handled by
  /// the [PanInput] class itself (e.g., via assertions in its constructors).
  /// This use case can add further business rule validations if necessary before calling the repository.
  @override
  Future<Either<Failure, LiuRenPan>> call(PanInput params) async {
    // Example of additional business rule validation (currently commented out):
    // if (params.inputType == PanInputType.GANZHI_INPUT && params.dayJiaZi == null) {
    //   return Left(InvalidInputFailure("Day GanZhi cannot be null for GanZhi input."));
    // }
    return await _repository.getLiuRenPan(params);
  }
}
