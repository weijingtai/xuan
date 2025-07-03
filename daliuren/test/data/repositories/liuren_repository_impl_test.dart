import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:daliuren/core/errors/failures.dart';
import 'package:daliuren/data/datasources/local/local_data_source.dart';
import 'package:daliuren/data/datasources/local/drift_database.dart'; // For DBOs
import 'package:daliuren/data/repositories/liuren_repository_impl.dart';
import 'package:daliuren/domain/entities/pan_input.dart';
import 'package:daliuren/domain/entities/liuren_pan.dart';
import 'package:daliuren/domain/entities/yuding_entry.dart';
import 'package:daliuren/data/models/ju_mapping_data_model.dart';
import 'package:daliuren/data/models/yu_ding_da_liu_ren_data_model.dart';
import 'package:daliuren/data/models/da_liu_ren_pan_data_model.dart';

// Mocks
@GenerateMocks([LiuRenLocalDataSource])
import 'liuren_repository_impl_test.mocks.dart';

void main() {
  late MockLiuRenLocalDataSource mockLocalDataSource;
  late LiuRenRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockLiuRenLocalDataSource();
    repository = LiuRenRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final tRawInitialData = {
    'ju_mapper': [{'dayJiaZi': '甲子', 'timeDiZhi': '子', 'yinYang': 'yang', 'juNumber': 1}],
    'yuding_daliuren': [{'dayJiaZi': '甲子', 'juNumber':1, 'juName':'子', 'details':{}, 'books':{}, 'body':['test'], 'meaning':'m', 'explain':'e', 'predication':'p'}],
    '甲午庚牛羊_阳': [{'dayJiaZi': '甲子', 'shiChen': '子', 'juNumberName': '一局', 'heavenPlate':{}, 'earthPlate':{}, 'fourClass': {'first':{'order':1, 'sky':'子','ground':'亥','guiRen':'贵人','isFirstClass':true}, 'firstClassDayGan':'甲', 'second':{'order':2, 'sky':'丑','ground':'子','guiRen':'螣蛇'},'third':{'order':3, 'sky':'寅','ground':'丑','guiRen':'朱雀'},'fourth':{'order':4, 'sky':'卯','ground':'寅','guiRen':'六合'}}, 'threeChuan': {'first':{'diZhi':'辰','guiRen':'勾陈','liuQin':'兄弟'},'second':{'diZhi':'巳','guiRen':'青龙','liuQin':'父母'},'third':{'diZhi':'午','guiRen':'天空','liuQin':'子孙'}}, 'nineZongMenName':'伏吟'}],
    '甲午庚牛羊_阴': [],
  };

  group('initializeDatabase', () {
    test('should call localDataSource.bulkInsertInitialData when DB not initialized', () async {
      // Arrange
      when(mockLocalDataSource.isDatabaseInitialized()).thenAnswer((_) async => false);
      when(mockLocalDataSource.bulkInsertInitialData(
        juMappings: anyNamed('juMappings'),
        yuDingEntries: anyNamed('yuDingEntries'),
        presetPans: anyNamed('presetPans')))
      .thenAnswer((_) async => Future.value());
      when(mockLocalDataSource.markDatabaseAsInitialized()).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.initializeDatabase(tRawInitialData);

      // Assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.isDatabaseInitialized());
      verify(mockLocalDataSource.bulkInsertInitialData(
          juMappings: anyNamed('juMappings'),
          yuDingEntries: anyNamed('yuDingEntries'),
          presetPans: anyNamed('presetPans')));
      verify(mockLocalDataSource.markDatabaseAsInitialized());
    });

    test('should NOT call bulkInsertInitialData when DB already initialized', () async {
      // Arrange
      when(mockLocalDataSource.isDatabaseInitialized()).thenAnswer((_) async => true);

      // Act
      final result = await repository.initializeDatabase(tRawInitialData);

      // Assert
      expect(result, const Right(null));
      verify(mockLocalDataSource.isDatabaseInitialized());
      verifyNever(mockLocalDataSource.bulkInsertInitialData(
        juMappings: anyNamed('juMappings'),
        yuDingEntries: anyNamed('yuDingEntries'),
        presetPans: anyNamed('presetPans')));
      verifyNever(mockLocalDataSource.markDatabaseAsInitialized());
    });
  });

  group('getYuDingEntry', () {
    final tDayJiaZiName = "甲子";
    final tGanShangDiZhiName = "子";
    final tYuDingEntryDb = YuDingEntryDb(
        dayJiaZiName: tDayJiaZiName, juName: tGanShangDiZhiName, juNumber: 1,
        detailsJson: {}, booksJson: {}, bodyJson: {'test'},
        meaning: "m", explain: "e", predication: "p"
    );

    test('should return YuDingEntry when localDataSource returns DBO', () async {
      // Arrange
      when(mockLocalDataSource.getYuDingEntry(tDayJiaZiName, tGanShangDiZhiName))
          .thenAnswer((_) async => tYuDingEntryDb);
      // Act
      final result = await repository.getYuDingEntry(tDayJiaZiName, tGanShangDiZhiName);
      // Assert
      expect(result.isRight(), isTrue);
      result.fold((l) => fail("should be right"), (r) {
        expect(r.課義, "m");
      });
      verify(mockLocalDataSource.getYuDingEntry(tDayJiaZiName, tGanShangDiZhiName));
    });

    test('should return NotFoundFailure when localDataSource returns null', () async {
      // Arrange
      when(mockLocalDataSource.getYuDingEntry(tDayJiaZiName, tGanShangDiZhiName))
          .thenAnswer((_) async => null);
      // Act
      final result = await repository.getYuDingEntry(tDayJiaZiName, tGanShangDiZhiName);
      // Assert
      expect(result.isLeft(), isTrue);
      result.fold((l) {
        expect(l, isA<NotFoundFailure>());
      } , (r) => fail("should be left"));
    });
  });

  // Tests for getLiuRenPan would be more complex:
  // - Mocking localDataSource.getPresetPan
  // - Verifying the mapping _mapPresetPanDboToEntity
  // - Testing the calculation path (currently placeholder)
  //   - This would involve mocking LiuRenCalculationService if it were a dependency,
  //     or mocking localDataSource.getJuMapping if repo does calculation.
});
