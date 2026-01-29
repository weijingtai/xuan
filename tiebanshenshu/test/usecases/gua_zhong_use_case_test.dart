import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/repository/repository_factory.dart';
import 'package:tiebanshenshu/service/strategy/gua_zhong_strategy.dart';
import 'package:tiebanshenshu/usecases/gua_zhong_tiao_wen_list_use_case.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('GuaZhongTiaoWenListUseCase（三种方案）', () {
    test('应该成功计算卦中取数法并返回条文列表（三种方案）', () async {
      // 创建依赖
      final strategy = GuaZhongStrategy();
      final repository = RepositoryFactory.defaultTiaoWenRepository;
      final useCase = GuaZhongTiaoWenListUseCase(strategy, repository);

      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      // 创建参数
      final params = GuaZhongUseCaseParams(eightChars: eightChars);

      // 执行UseCase
      final result = await useCase.execute(params);

      // 验证结果
      print('\n========== DEBUG INFO ==========');
      print('Result hasError: ${result.hasError}');
      if (result.hasError) {
        print('Error Message: ${result.errorMessage}');
        print('Source Data: ${result.sourceData}');
      } else {
        print('Success!');
        print('Algorithm Name: ${result.algorithmName}');
        print(
          'BaseNumberTiaoWenList count: ${result.baseNumberTiaoWenList.length}',
        );
        print('TiaoWenEntities count: ${result.tiaoWenEntities?.length ?? 0}');

        // 打印年月卦条文
        if (result.baseNumberTiaoWenList.isNotEmpty) {
          final nianYue = result.baseNumberTiaoWenList[0];
          print('\n年月卦:');
          print('  Name: ${nianYue.name}');
          print('  Description: ${nianYue.description}');
          print('  TiaoWenNumbers: ${nianYue.tiaoWenNumbers}');
          print('  TiaoWenDataList count: ${nianYue.tiaoWenDataList.length}');
        }

        // 打印日时卦条文
        if (result.baseNumberTiaoWenList.length > 1) {
          final riShi = result.baseNumberTiaoWenList[1];
          print('\n日时卦:');
          print('  Name: ${riShi.name}');
          print('  Description: ${riShi.description}');
          print('  TiaoWenNumbers: ${riShi.tiaoWenNumbers}');
          print('  TiaoWenDataList count: ${riShi.tiaoWenDataList.length}');
        }
      }
      print('========== END DEBUG ==========\n');

      expect(result.hasError, false, reason: 'Should not have error');
      expect(
        result.baseNumberTiaoWenList.length,
        2,
        reason: 'Should have 2 base number models (年月卦 + 日时卦)',
      );
      expect(
        result.tiaoWenEntities?.isNotEmpty ?? false,
        true,
        reason: 'Should have tiao wen entities',
      );

      // 验证年月卦条文（三种方案可能产生2-6个条文编号）
      final nianYueModel = result.baseNumberTiaoWenList[0];
      expect(
        nianYueModel.tiaoWenDataList.isNotEmpty,
        true,
        reason: 'NianYue should have tiao wen data',
      );
      expect(
        nianYueModel.tiaoWenNumbers.length,
        greaterThanOrEqualTo(2),
        reason: 'NianYue should have at least 2 tiao wen numbers (主卦+互卦)',
      );
      expect(
        nianYueModel.tiaoWenNumbers.length,
        lessThanOrEqualTo(6),
        reason: 'NianYue should have at most 6 tiao wen numbers (主卦+互卦 × 3种方案)',
      );

      // 验证日时卦条文（三种方案可能产生2-6个条文编号）
      final riShiModel = result.baseNumberTiaoWenList[1];
      expect(
        riShiModel.tiaoWenDataList.isNotEmpty,
        true,
        reason: 'RiShi should have tiao wen data',
      );
      expect(
        riShiModel.tiaoWenNumbers.length,
        greaterThanOrEqualTo(2),
        reason: 'RiShi should have at least 2 tiao wen numbers (主卦+互卦)',
      );
      expect(
        riShiModel.tiaoWenNumbers.length,
        lessThanOrEqualTo(6),
        reason: 'RiShi should have at most 6 tiao wen numbers (主卦+互卦 × 3种方案)',
      );

      // 验证sourceData包含三种方案信息
      expect(result.sourceData['supportedPlans'], [
        1,
        2,
        3,
      ], reason: 'Should support 3 plans');
      expect(
        result.sourceData['guaZhongBaseNumberModel'],
        isNotNull,
        reason: 'Should save GuaZhongBaseNumberModel in sourceData',
      );
    });
  });
}
