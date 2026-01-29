import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/models/base_number_model_result.dart';
import 'package:tiebanshenshu/domain/models/liu_yao_gan_zhi_he_base_number_model.dart';
import 'package:tiebanshenshu/repository/datamodels/tiao_wen_datamodel.dart';
import 'package:tiebanshenshu/repository/tiao_wen_repository.dart';
import 'package:tiebanshenshu/service/strategy/liu_yao_gan_zhi_he_strategy.dart';
import 'package:tiebanshenshu/usecases/liu_yao_gan_zhi_he_tiao_wen_list_use_case.dart';
import 'package:common/enums.dart';

/// Mock Strategy for testing
class MockLiuYaoGanZhiHeStrategy extends LiuYaoGanZhiHeStrategy {
  BaseNumberModelResult? mockResult;
  int callCount = 0;
  LiuYaoGanZhiHeStrategyParams? lastParams;

  @override
  BaseNumberModelResult calculate(LiuYaoGanZhiHeStrategyParams params) {
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

/// 先后天卦六爻干支和数法UseCase测试
///
/// 测试UseCase的业务逻辑处理
void main() {
  late LiuYaoGanZhiHeTiaoWenListUseCase useCase;
  late MockLiuYaoGanZhiHeStrategy mockStrategy;
  late MockTiaoWenRepository mockRepository;
  late EightChars testEightChars;
  late LiuYaoGanZhiHeUseCaseParams testParams;

  setUp(() {
    mockStrategy = MockLiuYaoGanZhiHeStrategy();
    mockRepository = MockTiaoWenRepository();
    useCase = LiuYaoGanZhiHeTiaoWenListUseCase(mockStrategy, mockRepository);

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("癸巳")!,
      month: JiaZi.getFromGanZhiValue("甲子")!,
      day: JiaZi.getFromGanZhiValue("丁酉")!,
      time: JiaZi.getFromGanZhiValue("癸卯")!,
    );

    testParams = LiuYaoGanZhiHeUseCaseParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
    );
  });

  group('LiuYaoGanZhiHeTiaoWenListUseCase - 参数验证', () {
    test('应该接受有效的男性参数', () {
      expect(() => useCase.validateParams(testParams), returnsNormally);
    });

    test('应该接受有效的女性参数', () {
      final femaleParams = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.female,
        threeYuan: YuanYunOrder.middle,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
      );

      expect(() => useCase.validateParams(femaleParams), returnsNormally);
    });

    test('应该拒绝无效的性别参数', () {
      final invalidParams = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.unknown,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });

    test('应该拒绝无效的三元参数', () {
      final invalidParams = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });

    test('应该拒绝无效的节气参数', () {
      final invalidParams = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.DONG_ZHI,
      );

      expect(() => useCase.validateParams(invalidParams), throwsException);
    });
  });

  group('LiuYaoGanZhiHeTiaoWenListUseCase - Strategy调用', () {
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
      expect(capturedParams.eightChars.year.ganZhiStr, equals("癸巳"));
      expect(capturedParams.gender, equals(Gender.male));
      expect(capturedParams.threeYuan, equals(YuanYunOrder.upper));
      expect(capturedParams.birthAfterZhi, equals("夏至"));
    });
  });

  group('LiuYaoGanZhiHeTiaoWenListUseCase - 条文查询', () {
    test('应该收集先天卦和后天卦的条文编号', () async {
      // 使用真实Strategy
      await useCase.execute(testParams);

      // 验证Repository被调用
      expect(mockRepository.getByIdListCallCount, equals(1));
      expect(mockRepository.lastQueryList, isNotNull);

      // 验证收集了多个条文编号
      // 先天卦8个 + 后天卦8个，如果基础数相同会完全重复，去重后是8个
      // 如果基础数不同，去重后最多16个，最少8个（完全重复）
      final queryList = mockRepository.lastQueryList!;
      expect(
        queryList.length,
        greaterThanOrEqualTo(8),
        reason: '应该有至少8个唯一条文编号（先天卦8个 + 后天卦8个，可能会重复去重）',
      );
      expect(queryList.length, lessThanOrEqualTo(16), reason: '最多有16个唯一条文编号');
    });

    test('应该对条文编号去重', () async {
      // 先天卦和后天卦基础数相同时，会有重复的条文编号
      final result = await useCase.execute(testParams);

      // 验证结果成功
      expect(result.hasError, isFalse);

      // 条文编号应该已去重
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

  group('LiuYaoGanZhiHeTiaoWenListUseCase - 结果构建', () {
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
      expect(result.algorithmName, equals("先后天卦六爻干支和数法"));
      expect(result.sourceData['xiantianTiaoWenCount'], equals(8));
      expect(result.sourceData['houtianTiaoWenCount'], equals(8));
      expect(result.sourceData['liuYaoGanZhiHeBaseNumberModel'], isNotNull);
    });

    test('应该在sourceData中保存LiuYaoGanZhiHeBaseNumberModel', () async {
      final result = await useCase.execute(testParams);

      // 验证sourceData中保存了完整的LiuYaoGanZhiHeBaseNumberModel
      expect(
        result.sourceData['liuYaoGanZhiHeBaseNumberModel'],
        isA<LiuYaoGanZhiHeBaseNumberModel>(),
      );

      final savedModel =
          result.sourceData['liuYaoGanZhiHeBaseNumberModel']
              as LiuYaoGanZhiHeBaseNumberModel;
      expect(savedModel.xiantianBaseNumber, greaterThan(0));
      expect(savedModel.houtianBaseNumber, greaterThan(0));
      expect(savedModel.xiantianGua, isNotEmpty);
      expect(savedModel.houtianGua, isNotEmpty);

      // 验证六爻纳甲字段
      expect(savedModel.xiantianYaoTianGanList.length, equals(6));
      expect(savedModel.xiantianYaoDiZhiList.length, equals(6));
      expect(savedModel.houtianYaoTianGanList.length, equals(6));
      expect(savedModel.houtianYaoDiZhiList.length, equals(6));
    });

    test('先天卦BaseNumberTiaoWenListModel应该包含8个条文编号', () async {
      final result = await useCase.execute(testParams);

      expect(result.hasError, isFalse);

      // 第一个是先天卦
      final xiantianModel = result.baseNumberTiaoWenList[0];
      expect(xiantianModel.name, contains("先天卦"));
      expect(
        xiantianModel.tiaoWenNumbers.length,
        equals(8),
        reason: '先天卦应该有8个条文编号（递增减96四次）',
      );
    });

    test('后天卦BaseNumberTiaoWenListModel应该包含8个条文编号', () async {
      final result = await useCase.execute(testParams);

      expect(result.hasError, isFalse);

      // 第二个是后天卦
      final houtianModel = result.baseNumberTiaoWenList[1];
      expect(houtianModel.name, contains("后天卦"));
      expect(
        houtianModel.tiaoWenNumbers.length,
        equals(8),
        reason: '后天卦应该有8个条文编号（递增减96四次）',
      );
    });

    test('先天卦和后天卦条文编号应该包含基础数', () async {
      final result = await useCase.execute(testParams);

      final savedModel =
          result.sourceData['liuYaoGanZhiHeBaseNumberModel']
              as LiuYaoGanZhiHeBaseNumberModel;

      final xiantianNumbers = result.baseNumberTiaoWenList[0].tiaoWenNumbers;
      final houtianNumbers = result.baseNumberTiaoWenList[1].tiaoWenNumbers;

      // 基础数应该在条文编号列表中（即+0的那个）
      expect(
        xiantianNumbers,
        contains(savedModel.xiantianBaseNumber),
        reason: '先天卦条文编号应该包含基础数',
      );
      expect(
        houtianNumbers,
        contains(savedModel.houtianBaseNumber),
        reason: '后天卦条文编号应该包含基础数',
      );
    });
  });

  group('LiuYaoGanZhiHeTiaoWenListUseCase - 错误处理', () {
    test('应该处理Strategy计算失败', () async {
      // Mock Strategy返回错误
      mockStrategy.mockResult = BaseNumberModelResult.error(
        algorithmName: "先后天卦六爻干支和数法",
        algorithmDescription: "测试",
        calculationParams: "测试",
        errorMessage: "计算失败",
        sourceData: {},
      );

      final result = await useCase.execute(testParams);

      expect(result.hasError, isTrue);
      expect(result.errorMessage, contains("先后天卦六爻干支和数法计算失败"));
    });

    test('应该处理参数验证异常', () async {
      final invalidParams = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      // execute() 会rethrow InputValidationException, 所以应该抛出异常
      expect(() async => await useCase.execute(invalidParams), throwsException);
    });
  });

  group('LiuYaoGanZhiHeUseCaseParams - 参数类测试', () {
    test('toString应该返回完整信息', () {
      final str = testParams.toString();

      expect(str, contains("LiuYaoGanZhiHeUseCaseParams"));
      expect(str, contains(Gender.male));
      expect(str, contains(YuanYunOrder.upper));
      expect(str, contains("夏至"));
    });

    test('相同参数应该相等', () {
      final params1 = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      final params2 = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      expect(params1, equals(params2));
      expect(params1.hashCode, equals(params2.hashCode));
    });

    test('不同参数应该不相等', () {
      final params1 = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      final params2 = LiuYaoGanZhiHeUseCaseParams(
        eightChars: testEightChars,
        gender: Gender.female,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      expect(params1, isNot(equals(params2)));
    });
  });

  group('LiuYaoGanZhiHeTiaoWenListUseCase - 完整集成测试', () {
    test('应该完整执行先后天卦六爻干支和数法计算流程', () async {
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
      expect(result.algorithmName, equals("先后天卦六爻干支和数法"));
      expect(mockStrategy.callCount, equals(1));
      expect(mockRepository.getByIdListCallCount, equals(1));

      // 验证包含完整的计算结果
      final liuYaoModel =
          result.sourceData['liuYaoGanZhiHeBaseNumberModel']
              as LiuYaoGanZhiHeBaseNumberModel;

      // 验证关键步骤的结果都存在
      expect(liuYaoModel.tianGua, isNotEmpty); // 步骤1: 天地卦
      expect(liuYaoModel.xiantianGua, isNotEmpty); // 步骤2: 先天卦
      expect(liuYaoModel.houtianGua, isNotEmpty); // 步骤2: 后天卦

      // 验证六爻纳甲配置
      expect(
        liuYaoModel.xiantianYaoTianGanList.length,
        equals(6),
      ); // 步骤3: 先天卦六爻天干
      expect(
        liuYaoModel.xiantianYaoDiZhiList.length,
        equals(6),
      ); // 步骤3: 先天卦六爻地支
      expect(
        liuYaoModel.houtianYaoTianGanList.length,
        equals(6),
      ); // 步骤5: 后天卦六爻天干
      expect(liuYaoModel.houtianYaoDiZhiList.length, equals(6)); // 步骤5: 后天卦六爻地支

      // 验证基础数和条文扩展
      expect(liuYaoModel.xiantianBaseNumber, greaterThan(0));
      expect(liuYaoModel.houtianBaseNumber, greaterThan(0));

      // 验证条文编号数量（8个）
      expect(result.baseNumberTiaoWenList[0].tiaoWenNumbers.length, equals(8));
      expect(result.baseNumberTiaoWenList[1].tiaoWenNumbers.length, equals(8));
    });
  });
}
