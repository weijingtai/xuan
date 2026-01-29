import 'package:flutter_test/flutter_test.dart';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';

import 'package:tiebanshenshu/service/strategy/tai_xuan_four_zhu_strategy.dart';

/// 太玄取数法调试测试 - 打印实际计算结果
void main() {
  test('打印实际计算结果 - 癸巳 甲子 丁酉 癸卯', () {
    final strategy = TaiXuanFourZhuStrategy();

    // 构造测试八字：癸巳 甲子 丁酉 癸卯
    final testEightChars = EightChars(
      year: JiaZi.GUI_SI,   // 癸巳
      month: JiaZi.JIA_ZI,  // 甲子
      day: JiaZi.DING_YOU,  // 丁酉
      time: JiaZi.GUI_MAO,  // 癸卯
    );

    final params = TaiXuanFourZhuStrategyParams(eightChars: testEightChars);
    final result = strategy.calculate(params);

    print('\n========== 太玄取数法计算结果 ==========');
    print('八字: 癸巳 甲子 丁酉 癸卯');
    print('年干: ${testEightChars.year.gan.name} (${testEightChars.year.gan.isYang ? "阳" : "阴"}年)');
    print('');

    final pillarNames = ['年柱', '月柱', '日柱', '时柱'];
    final ganzhiNames = [
      testEightChars.year.name,
      testEightChars.month.name,
      testEightChars.day.name,
      testEightChars.time.name,
    ];

    for (int i = 0; i < result.baseNumbers.length; i++) {
      final baseModel = result.baseNumbers[i];
      print('${pillarNames[i]}:');
      print('  干支: ${ganzhiNames[i]}');
      print('  太玄数: ${baseModel.baseNumber}');
      print('');
    }

    print('预期值: 4245, 4826, 2648, 4248');
    print('实际值: ${result.baseNumbers.map((m) => m.baseNumber).join(", ")}');
    print('========================================\n');
  });
}
