// lib/domain/usecases/initialize_database_usecase.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import 'package:fpdart/fpdart.dart' hide Failure;
import 'package:daliuren/core/errors/failures.dart';
import 'package:daliuren/core/usecase/usecase.dart'; // Base UseCase interface
import 'package:daliuren/domain/repositories/liuren_repository.dart';

/// Use case responsible for initializing the application's database with data from JSON assets.
/// This is typically a one-time operation performed when the app starts or when data needs to be reset.
class InitializeDatabaseUseCase {
  final LiuRenRepository _repository;

  InitializeDatabaseUseCase(this._repository);

  /// Executes the database initialization process.
  /// Loads data from predefined JSON asset files, transforms it as needed,
  /// and then calls the repository to persist this data.
  ///
  /// Takes [NoParams] as input, indicating no specific parameters are needed to trigger initialization.
  /// Returns [Either<Failure, void>]:
  /// - Right(null) on successful initialization.
  /// - Left(Failure) if any error occurs during asset loading or database operations.
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      // Define paths to the JSON asset files.
      const String juMapperPath = "assets/da_liu_ren/ju_mapper.json";
      const String yuDingPath = "assets/da_liu_ren/御定大六壬.json";
      const String yangPanPath = "assets/da_liu_ren/甲午庚牛羊_阳.json";
      const String yinPanPath = "assets/da_liu_ren/甲午庚牛羊_阴.json";

      // Asynchronously load the content of each JSON file.
      // Using Future.wait for concurrent loading.
      final results = await Future.wait([
        rootBundle.loadString(juMapperPath),
        rootBundle.loadString(yuDingPath),
        rootBundle.loadString(yangPanPath),
        rootBundle.loadString(yinPanPath),
      ]);

      final juMapperJsonString = results[0];
      final yuDingJsonString = results[1];
      final yangPanJsonString = results[2];
      final yinPanJsonString = results[3];

      // Decode JSON strings into Dart objects.
      // The `ju_mapper.json` has a nested structure that needs transformation.
      final List<Map<String, dynamic>> juMapperData = _transformJuMapper(
          json.decode(juMapperJsonString) as Map<String, dynamic>);
      // Other JSONs are expected to be lists of maps.
      final List<Map<String, dynamic>> yuDingData =
          (json.decode(yuDingJsonString) as List).cast<Map<String, dynamic>>();
      final List<Map<String, dynamic>> yangPanData =
          (json.decode(yangPanJsonString) as List).cast<Map<String, dynamic>>();
      final List<Map<String, dynamic>> yinPanData =
          (json.decode(yinPanJsonString) as List).cast<Map<String, dynamic>>();

      // Prepare the data map to be passed to the repository.
      final initialData = {
        'ju_mapper': juMapperData,
        'yuding_daliuren': yuDingData,
        '甲午庚牛羊_阳': yangPanData,
        '甲午庚牛羊_阴': yinPanData,
      };

      // Call the repository to initialize the database with the loaded data.
      return await _repository.initializeDatabase(initialData);
    } catch (e, s) {
      // Catch any exception during asset loading or JSON parsing.
      print("Error initializing database (UseCase): $e\nStack: $s");
      return Left(AssetFailure(
          "Failed to load or parse initial data from assets: ${e.toString()}",
          s));
    }
  }

  /// Transforms the nested map structure of `ju_mapper.json` into a flat list of maps.
  /// Each map in the list represents a single Ju mapping entry suitable for database insertion.
  /// Example output entry: `{'dayJiaZi': '甲子', 'timeDiZhi': '子', 'yinYang': 'yang', 'juNumber': 1}`
  List<Map<String, dynamic>> _transformJuMapper(
      Map<String, dynamic> rawJuMapper) {
    final List<Map<String, dynamic>> transformedList = [];
    rawJuMapper.forEach((dayJiaZi, timeMap) {
      (timeMap as Map<String, dynamic>).forEach((timeDiZhi, yinYangMap) {
        (yinYangMap as Map<String, dynamic>).forEach((yinYang, juNumber) {
          transformedList.add({
            'dayJiaZi': dayJiaZi,
            'timeDiZhi': timeDiZhi,
            'yinYang': yinYang, // Expected "yang" or "yin"
            'juNumber': juNumber as int,
          });
        });
      });
    });
    return transformedList;
  }
}

/// Custom [Failure] type for errors occurring during asset loading or processing.
class AssetFailure extends Failure {
  AssetFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
