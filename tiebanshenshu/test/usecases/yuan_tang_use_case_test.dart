import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/four_zhu.dart';
import 'package:tiebanshenshu/domain/models/base_number_model.dart';
import 'package:tiebanshenshu/domain/models/base_number_model_result.dart';
import 'package:tiebanshenshu/domain/models/yuan_tang_base_number_model.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';
import 'package:tiebanshenshu/repository/tiao_wen_repository.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';
import 'package:tiebanshenshu/usecases/yuan_tang_tiao_wen_list_use_case.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

/// Mock Strategy for testing
class MockYuanTangStrategy extends YuanTangStrategy {
  BaseNumberModelResult? mockResult;
  int callCount = 0;
  YuanTangStrategyParams? lastParams;

  @override
  BaseNumberModelResult calculate(YuanTangStrategyParams params) {
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

/// 元堂卦UseCase测试
///
/// 测试UseCase的业务逻辑处理
void main() {
  late YuanTangTiaoWenListUseCase useCase;
  late MockYuanTangStrategy mockStrategy;
  late MockTiaoWenRepository mockRepository;
  late FourZhu testFourZhu;
  late EightChars testEightChars;
  late YuanTangUseCaseParams testParams;

  setUp(() {
    mockStrategy = MockYuanTangStrategy();
    mockRepository = MockTiaoWenRepository();
    useCase = YuanTangTiaoWenListUseCase(mockStrategy, mockRepository);

    testFourZhu = FourZhu(
      yearGanzhi: "甲戌",
      monthGanzhi: "己巳",
      dayGanzhi: "辛丑",
      timeGanzhi: "丁酉",
    );

    testEightChars = EightChars(
      year: JiaZi.JIA_XU,
      month: JiaZi.JI_SI,
      day: JiaZi.XIN_CHOU,
      time: JiaZi.DING_YOU,
    );

    testParams = YuanTangUseCaseParams(
      eightChars: testEightChars,
      gender: "男",
      threeYuan: "上",
      birthAfterZhi: "夏至",
    );
  });

  group('YuanTangTiaoWenListUseCase - 参数验证', () {
    test('应该接受有效的男性参数', () {
      expect(() => useCase.validateParams(testParams), returnsNormally);
    });

    test('应该接受有效的女性参数', () {
      final femaleParams = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "女",
        threeYuan: "中",
        birthAfterZhi: "冬至",
      );

      expect(() => useCase.validateParams(femaleParams), returnsNormally);
    });

    test('应该拒绝无效的性别参数', () {
      final invalidParams = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "其他",
        threeYuan: "上",
        birthAfterZhi: "夏至",
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });

    test('应该拒绝无效的三元参数', () {
      final invalidParams = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "男",
        threeYuan: "无效",
        birthAfterZhi: "夏至",
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });

    test('应该拒绝无效的节气参数', () {
      final invalidParams = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "男",
        threeYuan: "上",
        birthAfterZhi: "春分",
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });
  });

  group('YuanTangTiaoWenListUseCase - Strategy调用', () {
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
      expect(capturedParams.eightChars.year.ganZhiStr, equals("甲戌"));
      expect(capturedParams.gender, equals("男"));
      expect(capturedParams.threeYuan, equals("上"));
      expect(capturedParams.birthAfterZhi, equals("夏至"));
    });
  });

  group('YuanTangTiaoWenListUseCase - 条文查询', () {
    test('应该收集所有8种方法生成的条文编号', () async {
      // 使用真实Strategy
      await useCase.execute(testParams);

      // 验证Repository被调用
      expect(mockRepository.getByIdListCallCount, equals(1));
      expect(mockRepository.lastQueryList, isNotNull);

      // 验证收集了多个条文编号（先天卦和后天卦各4种方法 + 互取数列表）
      final queryList = mockRepository.lastQueryList!;
      expect(queryList.length, greaterThan(6)); // 至少6个（6个基础方法 + 互取数列表）
    });

    test('应该对条文编号去重', () async {
      // 准备一个包含重复编号的Mock结果
      final mockBaseNumber = YuanTangBaseNumberModel.create(
        baseNumber: 1234,
        name: "测试",
        description: "测试描述",
        source: BaseNumberSource.yearZhu,
        eightChars: testEightChars,
        gender: "男",
        threeYuan: "上",
        birthAfterZhi: "夏至",
        ganNumList: [6, 9, 4, 7],
        zhiNumList: [
          [3, 7],
          [8, 6],
          [10, 5],
          [2, 9],
        ],
        oddNumTotal: 47,
        evenNumTotal: 50,
        tianGuaNum: 22,
        diGuaNum: 20,
        tianGua: "兑",
        diGua: "坤",
        usedThreeYuanWuGong: false,
        yearYinYang: "阳",
        upperGua: "兑",
        lowerGua: "坤",
        xiantianGua: "兑坤",
        xiantianUpperGuaNumber: 7,
        xiantianLowerGuaNumber: 2,
        timeGanzhi: "丁酉",
        timeYinYang: "阴",
        totalYangYao: 1,
        totalYinYao: 5,
        zhiList: [
          [],
          ["丑"],
          ["未"],
          ["酉"],
          ["亥"],
          [],
        ],
        yuantangYaoIndex: 4,
        yuantangYaoLabel: "五",
        houtianGua: "坤兑",
        houtianUpperGuaNumber: 2,
        houtianLowerGuaNumber: 7,
        xiantianGuaHu: "震巽",
        houtianGuaHu: "巽震",
        // 故意设置一些重复的条文编号
        tiaowenNumberJiazeXiantiangua: 1234,
        tiaowenNumberJiazeHoutiangua: 1234, // 重复
        tiaowenNumberNajiaTaixuanXiantiangua: 2345,
        tiaowenNumberNajiaTaixuanHoutiangua: 2345, // 重复
        tiaowenNumberXiantianBenhu: 3456,
        tiaowenNumberHoutianBenhu: 3456, // 重复
        tiaowenNumberListXiantianGuahu: [3454, 3452, 3448, 3440],
        tiaowenNumberListHoutianGuahu: [3454, 3452, 3448, 3440], // 重复
      );

      mockStrategy.mockResult = BaseNumberModelResult.success(
        algorithmName: "元堂卦取数法",
        algorithmDescription: "测试",
        calculationParams: "测试参数",
        baseNumbers: [mockBaseNumber],
        sourceData: {},
      );

      await useCase.execute(testParams);

      // 验证去重：每个编号只出现一次
      final queryList = mockRepository.lastQueryList!;
      final uniqueNumbers = queryList.toSet();
      expect(queryList.length, equals(uniqueNumbers.length));
    });

    test('应该正确批量查询条文数据', () async {
      // 不准备Mock数据，验证Repository被正确调用
      final result = await useCase.execute(testParams);

      // 验证Repository被调用一次（批量查询）
      expect(mockRepository.getByIdListCallCount, equals(1));

      // 验证Repository收到了条文编号列表
      expect(mockRepository.lastQueryList, isNotNull);
      expect(mockRepository.lastQueryList!.length, greaterThan(0));
    });
  });

  group('YuanTangTiaoWenListUseCase - 结果构建', () {
    test('应该返回包含完整信息的成功结果', () async {
      final result = await useCase.execute(testParams);

      expect(result.hasError, isFalse);
      expect(result.algorithmName, equals("元堂卦取数法"));
      expect(result.baseNumberTiaoWenList.length, equals(1));
      expect(result.sourceData['tiaoWenMethodsCount'], equals(8));
      expect(result.sourceData['yuanTangBaseNumberModel'], isNotNull);
    });

    test('应该在sourceData中保存YuanTangBaseNumberModel', () async {
      final result = await useCase.execute(testParams);

      // 验证sourceData中保存了完整的YuanTangBaseNumberModel
      expect(
        result.sourceData['yuanTangBaseNumberModel'],
        isA<YuanTangBaseNumberModel>(),
      );

      final savedModel =
          result.sourceData['yuanTangBaseNumberModel']
              as YuanTangBaseNumberModel;
      expect(savedModel.baseNumber, greaterThan(0));
      expect(savedModel.xiantianGua, isNotEmpty);
      expect(savedModel.houtianGua, isNotEmpty);
    });

    test('应该包含所有条文编号信息', () async {
      final result = await useCase.execute(testParams);

      expect(result.hasError, isFalse);

      final tiaoWenNumbers = result.baseNumberTiaoWenList.first.tiaoWenNumbers;

      // 验证包含多个条文编号（8种方法生成的）
      expect(tiaoWenNumbers.length, greaterThan(6));
    });
  });

  group('YuanTangTiaoWenListUseCase - 错误处理', () {
    test('应该处理Strategy计算失败', () async {
      // Mock Strategy返回错误
      mockStrategy.mockResult = BaseNumberModelResult.error(
        algorithmName: "元堂卦取数法",
        algorithmDescription: "测试",
        calculationParams: "测试",
        errorMessage: "计算失败",
        sourceData: {},
      );

      final result = await useCase.execute(testParams);

      expect(result.hasError, isTrue);
      expect(result.errorMessage, contains("元堂卦计算失败"));
    });

    test('应该处理参数验证异常', () async {
      final invalidParams = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "无效",
        threeYuan: "上",
        birthAfterZhi: "夏至",
      );

      // execute() 会rethrow InputValidationException, 所以应该抛出异常
      expect(() async => await useCase.execute(invalidParams), throwsException);
    });
  });

  group('YuanTangUseCaseParams - 参数类测试', () {
    test('toString应该返回完整信息', () {
      final str = testParams.toString();

      expect(str, contains("YuanTangUseCaseParams"));
      expect(str, contains("男"));
      expect(str, contains("上"));
      expect(str, contains("夏至"));
    });

    test('相同参数应该相等', () {
      final params1 = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "男",
        threeYuan: "上",
        birthAfterZhi: "夏至",
      );

      final params2 = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "男",
        threeYuan: "上",
        birthAfterZhi: "夏至",
      );

      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });

    test('不同参数应该不相等', () {
      final params1 = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "男",
        threeYuan: "上",
        birthAfterZhi: "夏至",
      );

      final params2 = YuanTangUseCaseParams(
        eightChars: testEightChars,
        gender: "女",
        threeYuan: "上",
        birthAfterZhi: "夏至",
      );

      expect(params1, isNot(equals(params2)));
    });
  });

  group('YuanTangTiaoWenListUseCase - 完整集成测试', () {
    test('应该完整执行元堂卦计算流程', () async {
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
      expect(result.algorithmName, equals("元堂卦取数法"));
      expect(mockStrategy.callCount, equals(1));
      expect(mockRepository.getByIdListCallCount, equals(1));

      // 验证包含完整的计算结果
      final yuanTangModel =
          result.sourceData['yuanTangBaseNumberModel']
              as YuanTangBaseNumberModel;

      // 验证5个步骤的结果都存在
      expect(yuanTangModel.tianGua, isNotEmpty); // 步骤1
      expect(yuanTangModel.xiantianGua, isNotEmpty); // 步骤2
      expect(yuanTangModel.yuantangYaoIndex, greaterThanOrEqualTo(0)); // 步骤3
      expect(yuanTangModel.houtianGua, isNotEmpty); // 步骤4
      expect(yuanTangModel.xiantianGuaHu, isNotEmpty); // 步骤5
      expect(yuanTangModel.houtianGuaHu, isNotEmpty); // 步骤5

      // 验证8种条文编号都生成了
      expect(yuanTangModel.tiaowenNumberJiazeXiantiangua, greaterThan(0));
      expect(yuanTangModel.tiaowenNumberJiazeHoutiangua, greaterThan(0));
      expect(
        yuanTangModel.tiaowenNumberNajiaTaixuanXiantiangua,
        greaterThan(0),
      );
      expect(yuanTangModel.tiaowenNumberNajiaTaixuanHoutiangua, greaterThan(0));
      expect(yuanTangModel.tiaowenNumberXiantianBenhu, greaterThan(0));
      expect(yuanTangModel.tiaowenNumberHoutianBenhu, greaterThan(0));
      expect(
        yuanTangModel.tiaowenNumberListXiantianGuahu.length,
        greaterThan(0),
      );
      expect(
        yuanTangModel.tiaowenNumberListHoutianGuahu.length,
        greaterThan(0),
      );
    });
  });
}
