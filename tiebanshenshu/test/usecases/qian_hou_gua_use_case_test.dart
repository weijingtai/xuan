import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/repository/repository_factory.dart';
import 'package:tiebanshenshu/service/strategy/qian_hou_gua_strategy.dart';
import 'package:tiebanshenshu/usecases/qian_hou_gua_tiao_wen_list_use_case.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('QianHouGuaTiaoWenListUseCase', () {
    test('应该成功计算前后卦取数法并返回条文列表', () async {
      // 创建依赖
      final strategy = QianHouGuaStrategy();
      final repository = RepositoryFactory.defaultTiaoWenRepository;
      final useCase = QianHouGuaTiaoWenListUseCase(strategy, repository);

      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      // 创建参数
      final params = QianHouGuaUseCaseParams(
        eightChars: eightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

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

        // 打印前卦条文
        if (result.baseNumberTiaoWenList.isNotEmpty) {
          final qianGua = result.baseNumberTiaoWenList[0];
          print('\n前卦:');
          print('  Name: ${qianGua.name}');
          print('  Description: ${qianGua.description}');
          print('  TiaoWenNumbers: ${qianGua.tiaoWenNumbers}');
          print('  TiaoWenDataList count: ${qianGua.tiaoWenDataList.length}');
        }

        // 打印后卦条文
        if (result.baseNumberTiaoWenList.length > 1) {
          final houGua = result.baseNumberTiaoWenList[1];
          print('\n后卦:');
          print('  Name: ${houGua.name}');
          print('  Description: ${houGua.description}');
          print('  TiaoWenNumbers: ${houGua.tiaoWenNumbers}');
          print('  TiaoWenDataList count: ${houGua.tiaoWenDataList.length}');
        }
      }
      print('========== END DEBUG ==========\n');

      expect(result.hasError, false, reason: 'Should not have error');
      expect(
        result.baseNumberTiaoWenList.length,
        2,
        reason: 'Should have 2 base number models (前卦 + 后卦)',
      );
      expect(
        result.tiaoWenEntities?.isNotEmpty ?? false,
        true,
        reason: 'Should have tiao wen entities',
      );

      // 验证前卦条文
      final qianGuaModel = result.baseNumberTiaoWenList[0];
      expect(
        qianGuaModel.tiaoWenDataList.isNotEmpty,
        true,
        reason: 'QianGua should have tiao wen data',
      );

      // 验证后卦条文
      final houGuaModel = result.baseNumberTiaoWenList[1];
      expect(
        houGuaModel.tiaoWenDataList.isNotEmpty,
        true,
        reason: 'HouGua should have tiao wen data',
      );
    });
  });
}
