import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import 'package:tiebanshenshu/service/strategy/ba_gua_jia_ze_strategy.dart';
import 'package:tiebanshenshu/domain/models/ba_gua_jia_ze_base_number_model.dart';

/// 八卦加则调试测试 - 打印实际计算结果
void main() {
  test('打印实际计算结果 - 癸未 庚申 丁未 丙午', () {
    final strategy = BaGuaJiaZeStrategy();

    // 构造测试八字：癸未 庚申 丁未 丙午
    final testEightChars = EightChars(
      year: JiaZi.GUI_WEI,    // 癸未
      month: JiaZi.GENG_SHEN, // 庚申
      day: JiaZi.DING_WEI,    // 丁未
      time: JiaZi.BING_WU,    // 丙午
    );

    final params = BaGuaJiaZeStrategyParams(eightChars: testEightChars);
    final result = strategy.calculate(params);

    print('\n========== 八卦加则计算结果 ==========');
    print('八字: 癸未 庚申 丁未 丙午\n');

    for (final baseModel in result.baseNumbers.cast<BaGuaJiaZeBaseNumberModel>()) {
      print('${baseModel.name}:');
      print('  干支: ${baseModel.ganZhi.name}');
      print('  上卦: ${baseModel.upperGua.name}(${baseModel.upperGuaNumber})');
      print('  下卦: ${baseModel.lowerGua.name}(${baseModel.lowerGuaNumber})');
      print('  六爻总和: ${baseModel.yaoSum}');
      print('  公式: ${baseModel.formula}');
      print('  条文编号: ${baseModel.baseNumber}');
      print('');
    }

    print('========================================\n');
  });
}
