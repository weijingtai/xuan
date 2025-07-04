// lib/domain/repositories/liuren_repository.dart

import 'package:fpdart/fpdart.dart' hide Failure; // For Either type
import 'package:daliuren/core/errors/failures.dart'; // For Failure type
import '../entities/liuren_pan.dart'; // Domain entity for Liu Ren Pan
import '../entities/yuding_entry.dart'; // Domain entity for Yu Ding interpretations
import '../entities/pan_input.dart'; // Input object for pan calculation

/// Abstract interface for the Liu Ren data repository.
/// Defines the contract for data operations related to Liu Ren divination,
/// separating the domain layer from specific data source implementations.
abstract class LiuRenRepository {
  /// Retrieves or calculates a Liu Ren Pan based on the provided [input].
  ///
  /// Returns a [LiuRenPan] domain entity on success (Right),
  /// or a [Failure] on error (Left).
  Future<Either<Failure, LiuRenPan>> getLiuRenPan(PanInput input);

  /// Fetches a "御定大六壬" (Yu Ding Da Liu Ren) interpretation entry.
  ///
  /// [dayJiaZiName] is the JiaZi name of the day (e.g., "甲子").
  /// [ganShangDiZhiName] is the DiZhi name of the deity/branch on the Day Gan (日干上神).
  /// Returns a [YuDingEntry] on success (Right), or a [Failure] on error (Left).
  // Future<Either<Failure, YuDingEntry>> getYuDingEntry(
  //     String dayJiaZiName, String ganShangDiZhiName);

  /// Initializes the backend database with data from assets if it hasn't been done yet.
  /// This is typically a one-time setup operation.
  ///
  /// [initialData] is a map where keys are identifiers for data sets (e.g., 'ju_mapper',
  /// 'yuding_daliuren', '甲午庚牛羊_阳', '甲午庚牛羊_阴') and values are lists of
  /// raw JSON objects (Map<String, dynamic>) parsed from asset files.
  /// Returns [void] on success (Right), or a [Failure] on error (Left).
  Future<Either<Failure, void>> initializeDatabase(
      Map<String, List<Map<String, dynamic>>> initialData);
}
