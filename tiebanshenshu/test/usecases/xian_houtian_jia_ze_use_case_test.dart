import 'package:flutter_test/flutter_test.dart';
import 'package:common/models/eight_chars.dart';
import 'package:tiebanshenshu/domain/models/base_number_model_result.dart';
import 'package:tiebanshenshu/domain/models/xian_houtian_gua_base_number_model.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';
import 'package:tiebanshenshu/repository/tiao_wen_repository.dart';
import 'package:tiebanshenshu/service/strategy/xian_houtian_jia_ze_strategy.dart';
import 'package:tiebanshenshu/usecases/xian_houtian_jia_ze_tiao_wen_list_use_case.dart';
import 'package:common/enums.dart';

/// Mock Strategy for testing
class MockXianHoutianJiaZeStrategy extends XianHoutianJiaZeStrategy {
  BaseNumberModelResult? mockResult;
  int callCount = 0;
  XianHoutianJiaZeStrategyParams? lastParams;

  @override
  BaseNumberModelResult calculate(XianHoutianJiaZeStrategyParams params) {
    callCount++;
    lastParams = params;
    return mockResult ?? super.calculate(params);
  }
}

/// Mock Repository for testing
class MockTiaoWenRepository implements TiaoWenRepository {
  Map<int, TiaoWenDataModel> mockData = {};
  int getByIdListCallCount = 0;
  List<int>? lastQueryList;

  @override
  Future<List<TiaoWenDataModel>> getByIdList({
    required List<int> queryList,
    bool preserveOrder = false,
    bool skipNotFound = true,
  }) async {
    getByIdListCallCount++;
    lastQueryList = queryList;

    final result = <TiaoWenDataModel>[];
    for (var id in queryList) {
      if (mockData.containsKey(id)) {
        result.add(mockData[id]!);
      }
    }
    return result;
  }

  // 其他方法抛出 UnimplementedError
  @override
  Future<TiaoWenDataModel?> getById(int id) => throw UnimplementedError();

  @override
  Future<List<TiaoWenDataModel>> getByIdsWithPageRange({
    required List<int> ids,
    required List<int> pageRange,
    int steps = 1,
  }) => throw UnimplementedError();

  @override
  Future<List<TiaoWenDataModel>> listAll() => throw UnimplementedError();

  @override
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  }) => throw UnimplementedError();

  @override
  Future<int> getCount() => throw UnimplementedError();

  @override
  Future<List<TiaoWenDataModel>> getAroundById({
    required int centerId,
    required int beforeCount,
    required int afterCount,
    bool includeCenterItem = true,
  }) => throw UnimplementedError();

  @override
  Future<List<TiaoWenDataModel>> getByIntervalAroundId({
    required int centerId,
    required int interval,
    required int minCount,
    int? maxRange,
    bool includeCenterItem = true,
  }) => throw UnimplementedError();

  @override
  Future<List<TiaoWenDataModel>> getByIdRange({
    required int startId,
    required int endId,
  }) => throw UnimplementedError();

  @override
  Future<String?> getTiaoWenContentByNumber(int number) =>
      throw UnimplementedError();

  @override
  Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> numbers) =>
      throw UnimplementedError();
}

/// 先后天八卦加则法UseCase测试
///
/// 测试UseCase的业务逻辑处理
void main() {
  late XianHoutianJiaZeTiaoWenListUseCase useCase;
  late MockXianHoutianJiaZeStrategy mockStrategy;
  late MockTiaoWenRepository mockRepository;
  late EightChars testEightChars;
  late XianHoutianJiaZeUseCaseParams testParams;

  setUp(() {
    mockStrategy = MockXianHoutianJiaZeStrategy();
    mockRepository = MockTiaoWenRepository();
    useCase = XianHoutianJiaZeTiaoWenListUseCase(mockStrategy, mockRepository);

    testEightChars = EightChars(
      year: JiaZi.GUI_SI,
      month: JiaZi.JIA_ZI,
      day: JiaZi.DING_YOU,
      time: JiaZi.GUI_MAO,
    );

    testParams = XianHoutianJiaZeUseCaseParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
    );
  });

  group('XianHoutianJiaZeTiaoWenListUseCase - 参数验证', () {
    test('应该接受有效的男性参数', () {
      expect(() => useCase.validateParams(testParams), returnsNormally);
    });

    test('应该接受有效的女性参数', () {
      final femaleParams = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.female,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
      );

      expect(() => useCase.validateParams(femaleParams), returnsNormally);
    });

    test('应该拒绝无效的性别参数', () {
      final invalidParams = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.unknown,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });

    test('应该拒绝无效的三元参数', () {
      final invalidParams = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });

    test('应该拒绝无效的节气参数', () {
      final invalidParams = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });
  });

  group('XianHoutianJiaZeTiaoWenListUseCase - Strategy调用', () {
    test('应该调用真实Strategy进行计算', () async {
      // 不设置 mockResult,让它使用真实的 calculate 方法
      final result = await useCase.execute(testParams);

      // 验证Strategy被调用
      expect(mockStrategy.callCount, equals(1));
      expect(mockStrategy.lastParams, isNotNull);

      // 验证结果成功
      expect(result.hasError, isFalse);
    });

    test('应该正确传递参数给Strategy', () async {
      // 不设置 mockResult,使用真实计算
      await useCase.execute(testParams);

      // 验证传递给Strategy的参数
      final capturedParams = mockStrategy.lastParams!;
      expect(capturedParams.eightChars.year.name, equals("癸巳"));
      expect(capturedParams.gender, equals(Gender.male));
      expect(capturedParams.threeYuan, equals("上"));
      expect(capturedParams.birthAfterZhi, equals(TwentyFourJieQi.XIA_ZHI));
    });
  });

  group('XianHoutianJiaZeTiaoWenListUseCase - 条文查询', () {
    test('应该收集先天卦和后天卦的条文编号', () async {
      // 使用真实Strategy
      await useCase.execute(testParams);

      // 验证Repository被调用
      expect(mockRepository.getByIdListCallCount, equals(1));
      expect(mockRepository.lastQueryList, isNotNull);

      // 验证收集了多个条文编号
      // 先天卦5个 + 后天卦5个 = 10个，但基础数相同会被去重，所以是9个
      final queryList = mockRepository.lastQueryList!;
      expect(
        queryList.length,
        equals(9),
        reason: '应该有9个唯一条文编号（先天卦5个 + 后天卦5个，基础数重复去重）',
      );
    });

    test('应该对条文编号去重', () async {
      // 先天卦和后天卦基础数相同时，会有重复的条文编号
      final result = await useCase.execute(testParams);

      // 验证结果成功
      expect(result.hasError, isFalse);

      // 由于先天卦递增，后天卦递减，基础数相同时会有重复（基础数本身）
      final queryList = mockRepository.lastQueryList!;
      final uniqueNumbers = queryList.toSet();
      expect(
        queryList.length,
        equals(uniqueNumbers.length),
        reason: '条文编号应该已去重',
      );
    });

    test('应该正确批量查询条文数据', () async {
      await useCase.execute(testParams);

      // 验证Repository被调用一次（批量查询）
      expect(mockRepository.getByIdListCallCount, equals(1));

      // 验证Repository收到了条文编号列表
      expect(mockRepository.lastQueryList, isNotNull);
      expect(mockRepository.lastQueryList!.length, greaterThan(0));
    });
  });

  group('XianHoutianJiaZeTiaoWenListUseCase - 结果构建', () {
    test('应该返回包含2个BaseNumberTiaoWenListModel', () async {
      final result = await useCase.execute(testParams);

      expect(result.hasError, isFalse);
      expect(
        result.baseNumberTiaoWenList.length,
        equals(2),
        reason: '应该返回2个BaseNumberTiaoWenListModel（先天卦和后天卦）',
      );
    });

    test('应该返回包含完整信息的成功结果', () async {
      final result = await useCase.execute(testParams);

      expect(result.hasError, isFalse);
      expect(result.algorithmName, equals("先后天八卦加则法"));
      expect(result.sourceData['xiantianTiaoWenCount'], equals(5));
      expect(result.sourceData['houtianTiaoWenCount'], equals(5));
      expect(result.sourceData['xianHoutianGuaBaseNumberModel'], isNotNull);
    });

    test('应该在sourceData中保存XianHoutianGuaBaseNumberModel', () async {
      final result = await useCase.execute(testParams);

      // 验证sourceData中保存了完整的XianHoutianGuaBaseNumberModel
      expect(
        result.sourceData['xianHoutianGuaBaseNumberModel'],
        isA<XianHoutianGuaBaseNumberModel>(),
      );

      final savedModel =
          result.sourceData['xianHoutianGuaBaseNumberModel']
              as XianHoutianGuaBaseNumberModel;
      expect(savedModel.xiantianBaseNumber, greaterThan(0));
      expect(savedModel.houtianBaseNumber, greaterThan(0));
      expect(savedModel.xiantianGua, isNotEmpty);
      expect(savedModel.houtianGua, isNotEmpty);
    });

    test('先天卦BaseNumberTiaoWenListModel应该包含5个条文编号', () async {
      final result = await useCase.execute(testParams);

      expect(result.hasError, isFalse);

      // 第一个是先天卦
      final xiantianModel = result.baseNumberTiaoWenList[0];
      expect(xiantianModel.name, contains("先天卦"));
      expect(
        xiantianModel.tiaoWenNumbers.length,
        equals(5),
        reason: '先天卦应该有5个条文编号（递增96四次）',
      );
    });

    test('后天卦BaseNumberTiaoWenListModel应该包含5个条文编号', () async {
      final result = await useCase.execute(testParams);

      expect(result.hasError, isFalse);

      // 第二个是后天卦
      final houtianModel = result.baseNumberTiaoWenList[1];
      expect(houtianModel.name, contains("后天卦"));
      expect(
        houtianModel.tiaoWenNumbers.length,
        equals(5),
        reason: '后天卦应该有5个条文编号（递减96四次）',
      );
    });

    test('先天卦条文编号应该递增96', () async {
      final result = await useCase.execute(testParams);
      final xiantianModel = result.baseNumberTiaoWenList[0];
      final tiaoWenNumbers = xiantianModel.tiaoWenNumbers;

      // 验证递增96
      for (int i = 1; i < tiaoWenNumbers.length; i++) {
        expect(
          tiaoWenNumbers[i] - tiaoWenNumbers[i - 1],
          equals(96),
          reason: '先天卦条文编号应该递增96',
        );
      }
    });

    test('后天卦条文编号应该递减96', () async {
      final result = await useCase.execute(testParams);
      final houtianModel = result.baseNumberTiaoWenList[1];
      final tiaoWenNumbers = houtianModel.tiaoWenNumbers;

      // 验证递减96
      for (int i = 1; i < tiaoWenNumbers.length; i++) {
        expect(
          tiaoWenNumbers[i - 1] - tiaoWenNumbers[i],
          equals(96),
          reason: '后天卦条文编号应该递减96',
        );
      }
    });
  });

  group('XianHoutianJiaZeTiaoWenListUseCase - 错误处理', () {
    test('应该处理Strategy计算失败', () async {
      // Mock Strategy返回错误
      mockStrategy.mockResult = BaseNumberModelResult.error(
        algorithmName: "先后天八卦加则法",
        algorithmDescription: "测试",
        calculationParams: "测试",
        errorMessage: "计算失败",
        sourceData: {},
      );

      final result = await useCase.execute(testParams);

      expect(result.hasError, isTrue);
      expect(result.errorMessage, contains("先后天八卦加则法计算失败"));
    });

    test('应该处理参数验证异常', () async {
      final invalidParams = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.unknown,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      // execute() 会rethrow InputValidationException, 所以应该抛出异常
      expect(() async => await useCase.execute(invalidParams), throwsException);
    });
  });

  group('XianHoutianJiaZeUseCaseParams - 参数类测试', () {
    test('toString应该返回完整信息', () {
      final str = testParams.toString();

      expect(str, contains("XianHoutianJiaZeUseCaseParams"));
      expect(str, contains(Gender.male));
      expect(str, contains("上"));
      expect(str, contains(TwentyFourJieQi.XIA_ZHI));
    });

    test('相同参数应该相等', () {
      final params1 = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      final params2 = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });

    test('不同参数应该不相等', () {
      final params1 = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      final params2 = XianHoutianJiaZeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.female,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      expect(params1, isNot(equals(params2)));
    });
  });

  group('XianHoutianJiaZeTiaoWenListUseCase - 完整集成测试', () {
    test('应该完整执行先后天八卦加则法计算流程', () async {
      // 准备Mock条文数据
      mockRepository.mockData = {
        1: TiaoWenDataModel(
          id: 1,
          setName: DiZhi.ZI,
          content1: "条文1",
          ageSet1: [1],
        ),
        2: TiaoWenDataModel(
          id: 2,
          setName: DiZhi.ZI,
          content1: "条文2",
          ageSet1: [2],
        ),
      };

      // 执行完整流程
      final result = await useCase.execute(testParams);

      // 验证结果
      expect(result.hasError, isFalse);
      expect(result.algorithmName, equals("先后天八卦加则法"));
      expect(mockStrategy.callCount, equals(1));
      expect(mockRepository.getByIdListCallCount, equals(1));

      // 验证包含完整的计算结果
      final xianHoutianModel =
          result.sourceData['xianHoutianGuaBaseNumberModel']
              as XianHoutianGuaBaseNumberModel;

      // 验证关键步骤的结果都存在
      expect(xianHoutianModel.tianGua, isNotEmpty); // 步骤1: 天地卦
      expect(xianHoutianModel.xiantianGua, isNotEmpty); // 步骤2: 先天卦
      expect(xianHoutianModel.houtianGua, isNotEmpty); // 步骤2: 后天卦
      expect(xianHoutianModel.xiantianGuaHu, isNotEmpty); // 步骤3: 先天卦互卦
      expect(xianHoutianModel.houtianGuaHu, isNotEmpty); // 步骤4: 后天卦互卦

      // 验证基础数和条文扩展
      expect(xianHoutianModel.xiantianBaseNumber, greaterThan(0));
      expect(xianHoutianModel.houtianBaseNumber, greaterThan(0));
      expect(xianHoutianModel.xiantianTiaoWenNumbers.length, equals(5));
      expect(xianHoutianModel.houtianTiaoWenNumbers.length, equals(5));
    });
  });
}
