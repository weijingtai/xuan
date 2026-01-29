import 'package:common/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/service/strategy/qian_hou_gua_strategy.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('QianHouGuaStrategy Debug Test', () {
    test('检查前后卦取数法的条文编号是否在合理范围内', () {
      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      // 创建策略
      final strategy = QianHouGuaStrategy();

      // 创建参数
      final params = QianHouGuaStrategyParams(
        eightChars: eightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.upper,
        birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      );

      // 执行计算
      final result = strategy.calculate(params);

      // 打印调试信息
      print('\n========== STRATEGY DEBUG INFO ==========');
      print('Result hasError: ${result.hasError}');
      if (result.hasError) {
        print('Error Message: ${result.errorMessage}');
      } else {
        final model = result.baseNumbers.first;
        print('BaseNumber: ${model.baseNumber}');
        print('Name: ${model.name}');

        // 获取QianHouGuaBaseNumberModel
        final qianHouModel = model as dynamic;
        print('\n前卦信息:');
        print('  前卦名称: ${qianHouModel.qianGuaName}');
        print('  前卦基础数: ${qianHouModel.qianGuaBaseNumber}');
        print('  前卦条文编号: ${qianHouModel.qianGuaTiaoWenNumbers}');

        print('\n后卦信息:');
        print('  后卦名称: ${qianHouModel.houGuaName}');
        print('  后卦基础数: ${qianHouModel.houGuaBaseNumber}');
        print('  后卦条文编号: ${qianHouModel.houGuaTiaoWenNumbers}');

        print('\n条文编号范围检查:');
        final allNumbers = [
          ...qianHouModel.qianGuaTiaoWenNumbers as List<int>,
          ...qianHouModel.houGuaTiaoWenNumbers as List<int>,
        ];

        // 检查是否有负数
        final negativeNumbers = allNumbers.where((n) => n < 0).toList();
        if (negativeNumbers.isNotEmpty) {
          print('  ⚠️ 发现负数条文编号: $negativeNumbers');
        } else {
          print('  ✓ 所有条文编号都是正数');
        }

        // 检查条文编号是否过大
        final tooLargeNumbers = allNumbers.where((n) => n > 960).toList();
        if (tooLargeNumbers.isNotEmpty) {
          print('  ⚠️ 发现过大的条文编号(>960): $tooLargeNumbers');
        } else {
          print('  ✓ 所有条文编号都在合理范围内');
        }

        print('\n条文编号最小值: ${allNumbers.reduce((a, b) => a < b ? a : b)}');
        print('条文编号最大值: ${allNumbers.reduce((a, b) => a > b ? a : b)}');
      }
      print('========== END DEBUG ==========\n');

      expect(result.hasError, false);
    });
  });
}
