import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/models/tiao_wen_list_result.dart';
import 'package:tiebanshenshu/domain/models/tiao_wen_list_state.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';
import 'package:common/enums.dart';

void main() {
  group('TiaoWenListResult', () {
    test('should create success result using factory constructor', () {
      // Arrange
      final tiaoWenNumbers = [1, 2, 3];
      final tiaoWenEntities = [
        TiaoWenDataModel(
          id: 1,
          setName: DiZhi.ZI,
          content1: '测试条文1',
          ageSet1: [1, 2],
        ),
        TiaoWenDataModel(
          id: 2,
          setName: DiZhi.CHOU,
          content1: '测试条文2',
          ageSet1: [3, 4],
        ),
        TiaoWenDataModel(
          id: 3,
          setName: DiZhi.YIN,
          content1: '测试条文3',
          ageSet1: [5, 6],
        ),
      ];
      final calculationMethod = '日干支卦';
      final sourceData = {'test': 'data'};

      // Act
      final result = TiaoWenListResult.success(
        tiaoWenNumbers: tiaoWenNumbers,
        tiaoWenEntities: tiaoWenEntities,
        calculationMethod: calculationMethod,
        sourceData: sourceData,
      );

      // Assert
      expect(result.tiaoWenNumbers, equals(tiaoWenNumbers));
      expect(result.tiaoWenEntities, equals(tiaoWenEntities));
      expect(result.state, equals(TiaoWenListState.success));
      expect(result.calculationMethod, equals(calculationMethod));
      expect(result.sourceData, equals(sourceData));
      expect(result.errorMessage, isNull);
      expect(result.isSuccess, isTrue);
      expect(result.hasError, isFalse);
      expect(result.tiaoWenCount, equals(3));
    });

    test('should create error result using factory constructor', () {
      // Arrange
      final calculationMethod = '四柱天干';
      final errorMessage = 'Test error';
      final sourceData = {'error': 'test'};

      // Act
      final result = TiaoWenListResult.error(
        calculationMethod: calculationMethod,
        errorMessage: errorMessage,
        sourceData: sourceData,
      );

      // Assert
      expect(result.tiaoWenNumbers, isEmpty);
      expect(result.state, equals(TiaoWenListState.error));
      expect(result.calculationMethod, equals(calculationMethod));
      expect(result.sourceData, equals(sourceData));
      expect(result.errorMessage, equals(errorMessage));
      expect(result.isSuccess, isFalse);
      expect(result.hasError, isTrue);
      expect(result.tiaoWenCount, equals(0));
    });

    test('should create loading result using factory constructor', () {
      // Arrange
      final calculationMethod = '太玄四柱';
      final sourceData = {'loading': 'test'};

      // Act
      final result = TiaoWenListResult.loading(
        calculationMethod: calculationMethod,
        sourceData: sourceData,
      );

      // Assert
      expect(result.tiaoWenNumbers, isEmpty);
      expect(result.state, equals(TiaoWenListState.loading));
      expect(result.calculationMethod, equals(calculationMethod));
      expect(result.sourceData, equals(sourceData));
      expect(result.errorMessage, isNull);
      expect(result.isSuccess, isFalse);
      expect(result.hasError, isFalse);
      expect(result.isLoading, isTrue);
      expect(result.tiaoWenCount, equals(0));
    });

    test('should implement equality correctly', () {
      // Arrange
      final entities = [
        TiaoWenDataModel(
          id: 1,
          content1: '测试条文1',
          setName: DiZhi.ZI,
          ageSet1: [],
        ),
        TiaoWenDataModel(
          id: 2,
          content1: '测试条文2',
          setName: DiZhi.ZI,
          ageSet1: [],
        ),
        TiaoWenDataModel(
          id: 3,
          content1: '测试条文3',
          setName: DiZhi.ZI,
          ageSet1: [],
        ),
      ];

      final result1 = TiaoWenListResult.success(
        tiaoWenNumbers: [1, 2, 3],
        tiaoWenEntities: entities,
        calculationMethod: '日干支卦',
        sourceData: {'test': 'data'},
      );

      final result2 = TiaoWenListResult.success(
        tiaoWenNumbers: [1, 2, 3],
        tiaoWenEntities: entities,
        calculationMethod: '日干支卦',
        sourceData: {'test': 'data'},
      );

      final result3 = TiaoWenListResult.success(
        tiaoWenNumbers: [1, 2, 4],
        tiaoWenEntities: [
          TiaoWenDataModel(
            id: 4,
            setName: DiZhi.MAO,
            content1: '不同条文',
            ageSet1: [7, 8],
          ),
        ],
        calculationMethod: '日干支卦',
        sourceData: {'test': 'data'},
      );

      // Act & Assert
      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
      expect(result1, isNot(equals(result3)));
    });

    test('should have proper toString implementation', () {
      // Arrange
      final entities = [
        TiaoWenDataModel(
          id: 1,
          setName: DiZhi.ZI,
          content1: '测试条文1',
          ageSet1: [1, 2],
        ),
        TiaoWenDataModel(
          id: 2,
          setName: DiZhi.CHOU,
          content1: '测试条文2',
          ageSet1: [3, 4],
        ),
        TiaoWenDataModel(
          id: 3,
          setName: DiZhi.YIN,
          content1: '测试条文3',
          ageSet1: [5, 6],
        ),
      ];

      final result = TiaoWenListResult.success(
        tiaoWenNumbers: [1, 2, 3],
        tiaoWenEntities: entities,
        calculationMethod: '日干支卦',
        sourceData: {'test': 'data'},
      );

      // Act
      final stringRepresentation = result.toString();

      // Assert
      expect(stringRepresentation, contains('TiaoWenListResult'));
      expect(stringRepresentation, contains('[1, 2, 3]'));
      expect(stringRepresentation, contains('日干支卦'));
      expect(stringRepresentation, contains('TiaoWenListState.success'));
    });

    test('should handle state properties correctly', () {
      // Arrange & Act
      final successResult = TiaoWenListResult.success(
        tiaoWenNumbers: [1],
        tiaoWenEntities: [
          TiaoWenDataModel(
            id: 1,
            setName: DiZhi.ZI,
            content1: '测试条文',
            ageSet1: [1, 2],
          ),
        ],
        calculationMethod: 'test',
        sourceData: {},
      );

      final errorResult = TiaoWenListResult.error(
        calculationMethod: 'test',
        errorMessage: 'error',
        sourceData: {},
      );

      final loadingResult = TiaoWenListResult.loading(
        calculationMethod: 'test',
      );

      // Assert
      expect(successResult.isSuccess, isTrue);
      expect(successResult.hasError, isFalse);
      expect(successResult.isLoading, isFalse);
      expect(successResult.isInitial, isFalse);

      expect(errorResult.isSuccess, isFalse);
      expect(errorResult.hasError, isTrue);
      expect(errorResult.isLoading, isFalse);
      expect(errorResult.isInitial, isFalse);

      expect(loadingResult.isSuccess, isFalse);
      expect(loadingResult.hasError, isFalse);
      expect(loadingResult.isLoading, isTrue);
      expect(loadingResult.isInitial, isFalse);
    });
  });
}
