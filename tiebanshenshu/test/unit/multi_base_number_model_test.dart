import 'package:flutter_test/flutter_test.dart';
import '../../lib/domain/models/base_number_model.dart';
import '../../lib/domain/models/multi_base_number_result.dart';
import '../../lib/domain/models/tiao_wen_list_state.dart';
import '../../lib/service/strategy/tiao_wen_list_calculation.dart';
import '../../lib/repository/datamodels/tiao_wen_datamodel.dart';

void main() {
  group('MultiBaseNumberModel Tests', () {
    late TiaoWenListCalculationConfig testConfig;

    setUp(() {
      testConfig = TiaoWenListCalculationConfig.listAdd(
        customList: [96, 192, 384, 768],
        withSub: true,
      );
    });

    group('BaseNumberModel', () {
      test('创建基础数模型', () {
        // Arrange & Act
        final baseNumber = BaseNumberModel.create(
          baseNumber: 1234,
          name: '测试基础数',
          description: '测试描述',
          source: BaseNumberSource.yearZhu,
          calculationConfig: testConfig,
        );

        // Assert
        expect(baseNumber.baseNumber, equals(1234));
        expect(baseNumber.name, equals('测试基础数'));
        expect(baseNumber.description, equals('测试描述'));
        expect(baseNumber.source, equals(BaseNumberSource.yearZhu));
        expect(baseNumber.sourceDescription, equals('年柱计算'));
        expect(baseNumber.tiaoWenNumbers, isNotEmpty);
        expect(baseNumber.tiaoWenCount, greaterThan(0));
        expect(baseNumber.hasTiaoWenData, isFalse);
        expect(baseNumber.hasBaseTiaoWen, isFalse);
      });

      test('使用条文数据创建基础数模型', () {
        // Arrange
        final mockTiaoWenData = [
          TiaoWenDataModel(id: 1330, content1: '测试条文内容', page: 1, line: 1),
        ];

        // Act
        final baseNumber = BaseNumberModel.withData(
          baseNumber: 1234,
          name: '测试基础数',
          description: '测试描述',
          source: BaseNumberSource.monthZhu,
          calculationConfig: testConfig,
          tiaoWenDataList: mockTiaoWenData,
        );

        // Assert
        expect(baseNumber.baseNumber, equals(1234));
        expect(baseNumber.hasTiaoWenData, isTrue);
        expect(baseNumber.tiaoWenDataList.length, equals(1));
        expect(baseNumber.tiaoWenDataList.first.content1, equals('测试条文内容'));
      });

      test('复制并更新条文数据', () {
        // Arrange
        final originalModel = BaseNumberModel.create(
          baseNumber: 1234,
          name: '原始模型',
          description: '原始描述',
          source: BaseNumberSource.dayZhu,
          calculationConfig: testConfig,
        );

        final newTiaoWenData = [
          TiaoWenDataModel(id: 1330, content1: '新条文内容', page: 1, line: 1),
        ];

        // Act
        final updatedModel = originalModel.copyWithTiaoWenData(newTiaoWenData);

        // Assert
        expect(updatedModel.baseNumber, equals(originalModel.baseNumber));
        expect(updatedModel.name, equals(originalModel.name));
        expect(updatedModel.hasTiaoWenData, isTrue);
        expect(updatedModel.tiaoWenDataList.length, equals(1));
        expect(originalModel.hasTiaoWenData, isFalse); // 原模型不变
      });

      test('基础数来源描述', () {
        final sources = [
          (BaseNumberSource.yearZhu, '年柱计算'),
          (BaseNumberSource.monthZhu, '月柱计算'),
          (BaseNumberSource.dayZhu, '日柱计算'),
          (BaseNumberSource.timeZhu, '时柱计算'),
          (BaseNumberSource.combined, '综合计算'),
          (BaseNumberSource.initial, '初始数'),
          (BaseNumberSource.secondary, '次数'),
          (BaseNumberSource.custom, '自定义'),
        ];

        for (final (source, expectedDescription) in sources) {
          final model = BaseNumberModel.create(
            baseNumber: 1234,
            name: '测试',
            description: '测试',
            source: source,
            calculationConfig: testConfig,
          );

          expect(model.sourceDescription, equals(expectedDescription));
        }
      });
    });

    group('MultiBaseNumberResult', () {
      test('创建成功结果', () {
        // Arrange
        final baseNumbers = [
          BaseNumberModel.create(
            baseNumber: 1234,
            name: '基础数1',
            description: '描述1',
            source: BaseNumberSource.yearZhu,
            calculationConfig: testConfig,
          ),
          BaseNumberModel.create(
            baseNumber: 5678,
            name: '基础数2',
            description: '描述2',
            source: BaseNumberSource.monthZhu,
            calculationConfig: testConfig,
          ),
        ];

        // Act
        final result = MultiBaseNumberResult.success(
          algorithmName: '测试算法',
          algorithmDescription: '测试算法描述',
          calculationParams: '测试参数',
          baseNumbers: baseNumbers,
          sourceData: {'test': 'data'},
        );

        // Assert
        expect(result.algorithmName, equals('测试算法'));
        expect(result.algorithmDescription, equals('测试算法描述'));
        expect(result.isSuccess, isTrue);
        expect(result.hasError, isFalse);
        expect(result.isLoading, isFalse);
        expect(result.baseNumberCount, equals(2));
        expect(result.totalTiaoWenCount, greaterThan(0));
        expect(result.allTiaoWenNumbers, isNotEmpty);
      });

      test('创建错误结果', () {
        // Act
        final result = MultiBaseNumberResult.error(
          algorithmName: '测试算法',
          algorithmDescription: '测试算法描述',
          calculationParams: '测试参数',
          errorMessage: '测试错误',
        );

        // Assert
        expect(result.algorithmName, equals('测试算法'));
        expect(result.isSuccess, isFalse);
        expect(result.hasError, isTrue);
        expect(result.errorMessage, equals('测试错误'));
        expect(result.baseNumberCount, equals(0));
        expect(result.totalTiaoWenCount, equals(0));
      });

      test('创建加载中结果', () {
        // Act
        final result = MultiBaseNumberResult.loading(
          algorithmName: '测试算法',
          algorithmDescription: '测试算法描述',
          calculationParams: '测试参数',
        );

        // Assert
        expect(result.algorithmName, equals('测试算法'));
        expect(result.isLoading, isTrue);
        expect(result.isSuccess, isFalse);
        expect(result.hasError, isFalse);
        expect(result.baseNumberCount, equals(0));
      });

      test('按来源获取基础数', () {
        // Arrange
        final baseNumbers = [
          BaseNumberModel.create(
            baseNumber: 1234,
            name: '年柱基础数',
            description: '年柱描述',
            source: BaseNumberSource.yearZhu,
            calculationConfig: testConfig,
          ),
          BaseNumberModel.create(
            baseNumber: 5678,
            name: '月柱基础数',
            description: '月柱描述',
            source: BaseNumberSource.monthZhu,
            calculationConfig: testConfig,
          ),
          BaseNumberModel.create(
            baseNumber: 9012,
            name: '另一个年柱基础数',
            description: '另一个年柱描述',
            source: BaseNumberSource.yearZhu,
            calculationConfig: testConfig,
          ),
        ];

        final result = MultiBaseNumberResult.success(
          algorithmName: '测试算法',
          algorithmDescription: '测试算法描述',
          calculationParams: '测试参数',
          baseNumbers: baseNumbers,
          sourceData: {},
        );

        // Act
        final yearZhuNumbers = result.getBaseNumbersBySource(
          BaseNumberSource.yearZhu,
        );
        final monthZhuNumbers = result.getBaseNumbersBySource(
          BaseNumberSource.monthZhu,
        );
        final dayZhuNumbers = result.getBaseNumbersBySource(
          BaseNumberSource.dayZhu,
        );

        // Assert
        expect(yearZhuNumbers.length, equals(2));
        expect(monthZhuNumbers.length, equals(1));
        expect(dayZhuNumbers.length, equals(0));
        expect(yearZhuNumbers.first.baseNumber, equals(1234));
        expect(yearZhuNumbers.last.baseNumber, equals(9012));
        expect(monthZhuNumbers.first.baseNumber, equals(5678));
      });

      test('按数值获取基础数', () {
        // Arrange
        final baseNumbers = [
          BaseNumberModel.create(
            baseNumber: 1234,
            name: '基础数1',
            description: '描述1',
            source: BaseNumberSource.yearZhu,
            calculationConfig: testConfig,
          ),
          BaseNumberModel.create(
            baseNumber: 5678,
            name: '基础数2',
            description: '描述2',
            source: BaseNumberSource.monthZhu,
            calculationConfig: testConfig,
          ),
        ];

        final result = MultiBaseNumberResult.success(
          algorithmName: '测试算法',
          algorithmDescription: '测试算法描述',
          calculationParams: '测试参数',
          baseNumbers: baseNumbers,
          sourceData: {},
        );

        // Act
        final foundModel = result.getBaseNumberByValue(1234);
        final notFoundModel = result.getBaseNumberByValue(9999);

        // Assert
        expect(foundModel, isNotNull);
        expect(foundModel!.name, equals('基础数1'));
        expect(notFoundModel, isNull);
      });

      test('继承自BaseCalculationResult', () {
        // Arrange & Act
        final result = MultiBaseNumberResult.success(
          algorithmName: '测试算法',
          algorithmDescription: '测试算法描述',
          calculationParams: '测试参数',
          baseNumbers: [],
          sourceData: {},
        );

        // Assert
        expect(result, isA<BaseCalculationResult>());
      });
    });
  });
}
