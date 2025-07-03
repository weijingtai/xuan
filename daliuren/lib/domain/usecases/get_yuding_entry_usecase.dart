// lib/domain/usecases/get_yuding_entry_usecase.dart

import 'package:fpdart/fpdart.dart';
import 'package:daliuren/core/errors/failures.dart';
import 'package:daliuren/core/usecase/usecase.dart'; // Base UseCase interface
import 'package:daliuren/domain/entities/yuding_entry.dart'; // Return type
import 'package:daliuren/domain/repositories/liuren_repository.dart';

/// Parameters required for the [GetYuDingEntryUseCase].
class GetYuDingEntryUseCaseParams {
  /// The JiaZi name of the day (e.g., "甲子").
  final String dayJiaZi;
  /// The DiZhi name of the deity/branch on the Day Gan (日干上神).
  final String ganShangDiZhi;

  GetYuDingEntryUseCaseParams({required this.dayJiaZi, required this.ganShangDiZhi});

  // Consider implementing Equatable if these params are used for state comparison (e.g., in BLoC).
  // @override
  // List<Object?> get props => [dayJiaZi, ganShangDiZhi];
}

/// Use case for fetching a "御定大六壬" (Yu Ding Da Liu Ren) interpretation entry.
/// It takes [GetYuDingEntryUseCaseParams] and calls the repository to get the data.
class GetYuDingEntryUseCase implements UseCase<YuDingEntry, GetYuDingEntryUseCaseParams> {
  final LiuRenRepository _repository;

  GetYuDingEntryUseCase(this._repository);

  /// Executes the use case to fetch the Yu Ding entry.
  ///
  /// [params]: An instance of [GetYuDingEntryUseCaseParams] containing the day JiaZi
  ///           and the GanShang DiZhi.
  ///
  /// Returns [Either<Failure, YuDingEntry>]:
  /// - Right([YuDingEntry]) containing the successfully fetched interpretation.
  /// - Left([Failure]) if an error occurs or the entry is not found.
  @override
  Future<Either<Failure, YuDingEntry>> call(GetYuDingEntryUseCaseParams params) async {
    // Basic validation for parameters.
    if (params.dayJiaZi.isEmpty || params.ganShangDiZhi.isEmpty) {
      return Left(InvalidInputFailure("DayJiaZi and GanShangDiZhi parameters cannot be empty."));
    }
    return await _repository.getYuDingEntry(params.dayJiaZi, params.ganShangDiZhi);
  }
}
