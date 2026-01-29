import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import 'package:tiebanshenshu/service/strategy/tai_xuan_four_zhu_strategy.dart';
import 'package:tiebanshenshu/domain/models/tai_xuan_base_number_model.dart';

/// 太玄取数法调试测试 - 验证两种纳甲方案
void main() {
  test('打印传统内外卦纳甲法实际计算结果', () {
    final strategy = TaiXuanFourZhuStrategy();

    // 构造测试八字：癸未 癸亥 壬午 戊申
    final testEightChars = EightChars(
      year: JiaZi.GUI_WEI,   // 癸未
      month: JiaZi.GUI_HAI,  // 癸亥
      day: JiaZi.REN_WU,     // 壬午
      time: JiaZi.WU_SHEN,   // 戊申
    );

    // 测试传统内外卦纳甲法
    final paramsInnerOuter = TaiXuanFourZhuStrategyParams(
      eightChars: testEightChars,
      naJiaMethod: TaiXuanNaJiaMethod.innerOuterGua,
    );
    final resultInnerOuter = strategy.calculate(paramsInnerOuter);

    // 测试年干阴阳纳甲法
    final paramsYearGan = TaiXuanFourZhuStrategyParams(
      eightChars: testEightChars,
      naJiaMethod: TaiXuanNaJiaMethod.yearGanYinYang,
    );
    final resultYearGan = strategy.calculate(paramsYearGan);

    print('\n========== 太玄取数法双纳甲方案对比 ==========');
    print('八字: 癸未 癸亥 壬午 戊申');
    print('');

    final pillarNames = ['年柱', '月柱', '日柱', '时柱'];
    final ganzhiNames = [
      testEightChars.year.name,
      testEightChars.month.name,
      testEightChars.day.name,
      testEightChars.time.name,
    ];

    print('=== 传统内外卦纳甲法 ===');
    for (int i = 0; i < resultInnerOuter.baseNumbers.length; i++) {
      final baseModel = resultInnerOuter.baseNumbers[i] as TaiXuanBaseNumberModel;
      print('\n${pillarNames[i]}:');
      print('  干支: ${ganzhiNames[i]}');
      print('  上卦: ${baseModel.upperGua.name}(${baseModel.upperGuaNumber})');
      print('  下卦: ${baseModel.lowerGua.name}(${baseModel.lowerGuaNumber})');
      print('  纳甲方法: ${baseModel.naJiaMethod.displayName}');
      print('  六爻详情:');
      for (final yao in baseModel.yaoDetails) {
        print('    ${yao.positionLabel}爻(${yao.yinYang}): ${yao.tianGan.name}${yao.diZhi.name} = '
            '${yao.taiXuanGanNumber}+${yao.taiXuanZhiNumber} = ${yao.taiXuanNumber}'
            '${yao.isFiltered ? " (已过滤)" : ""}');
      }
      print('  上卦总和: ${baseModel.upperGuaSum}');
      print('  下卦总和: ${baseModel.lowerGuaSum}');
      print('  计算公式: ${baseModel.formula}');
      print('  太玄数: ${baseModel.baseNumber}');
    }

    print('\n=== 年干阴阳纳甲法 ===');
    for (int i = 0; i < resultYearGan.baseNumbers.length; i++) {
      final baseModel = resultYearGan.baseNumbers[i] as TaiXuanBaseNumberModel;
      print('\n${pillarNames[i]}:');
      print('  干支: ${ganzhiNames[i]}');
      print('  纳甲方法: ${baseModel.naJiaMethod.displayName}');
      print('  太玄数: ${baseModel.baseNumber}');
    }

    print('\n=== 结果对比 ===');
    print('传统内外卦纳甲预期值: 3342, 3326, 3945, 2648');
    print('传统内外卦纳甲实际值: ${resultInnerOuter.baseNumbers.map((m) => m.baseNumber).join(", ")}');
    print('');
    print('年干阴阳纳甲预期值: 4245, 4826, 2648, 4248 (癸巳 甲子 丁酉 癸卯的测试数据)');
    print('年干阴阳纳甲实际值: ${resultYearGan.baseNumbers.map((m) => m.baseNumber).join(", ")}');
    print('========================================\n');

    // 验证传统内外卦纳甲法结果
    final innerOuterNumbers = resultInnerOuter.baseNumbers.map((m) => m.baseNumber).toList();
    expect(innerOuterNumbers, equals([3342, 3326, 3945, 2648]),
        reason: '传统内外卦纳甲法计算结果应该匹配预期值');

    // 验证两种方法产生不同结果
    final yearGanNumbers = resultYearGan.baseNumbers.map((m) => m.baseNumber).toList();
    expect(innerOuterNumbers, isNot(equals(yearGanNumbers)),
        reason: '两种纳甲方法应该产生不同的结果');
  });

  test('年干阴阳纳甲法应与原测试数据匹配', () {
    final strategy = TaiXuanFourZhuStrategy();

    // 使用原测试数据：癸巳 甲子 丁酉 癸卯
    final testEightChars = EightChars(
      year: JiaZi.GUI_SI,    // 癸巳
      month: JiaZi.JIA_ZI,   // 甲子
      day: JiaZi.DING_YOU,   // 丁酉
      time: JiaZi.GUI_MAO,   // 癸卯
    );

    final params = TaiXuanFourZhuStrategyParams(
      eightChars: testEightChars,
      naJiaMethod: TaiXuanNaJiaMethod.yearGanYinYang,
    );
    final result = strategy.calculate(params);

    final baseNumbers = result.baseNumbers.map((m) => m.baseNumber).toList();

    print('\n年干阴阳纳甲法验证（癸巳 甲子 丁酉 癸卯）: ${baseNumbers.join(", ")}');

    expect(baseNumbers, equals([4245, 4826, 2648, 4248]),
        reason: '年干阴阳纳甲法应匹配原测试数据');
  });
}
