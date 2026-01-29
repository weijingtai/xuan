import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';
import 'package:tiebanshenshu/domain/models/yuan_tang_base_number_model.dart';

/// 元堂卦取数法 - 大运计算调试测试
void main() {
  test('大运计算调试 - 癸巳甲子丁酉癸卯', () {
    final strategy = YuanTangStrategy();

    final testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("癸巳")!,
      month: JiaZi.getFromGanZhiValue("甲子")!,
      day: JiaZi.getFromGanZhiValue("丁酉")!,
      time: JiaZi.getFromGanZhiValue("癸卯")!,
    );

    final testParams = YuanTangStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      birthMonth: 6,
    );

    final result = strategy.calculate(testParams);
    final model = result.baseNumbers.first as YuanTangBaseNumberModel;

    print('\n========== 大运计算调试信息 ==========');
    print('先天卦: ${model.xiantianGua}');
    print('元堂爻: ${model.yuantangYaoLabel}（索引${model.yuantangYaoIndex}）');
    print('');

    print('先天卦大运列表:');
    for (final period in model.xiantianDayunList) {
      print(
        '  ${period.yaoLabel}爻(${period.yinYang}): ${period.years}年, ${period.ageRange}岁, 地支=${period.diZhiList.join("、")}',
      );
    }

    print('');
    print('后天卦: ${model.houtianGua}');
    print(
      '后天卦元堂爻: ${model.houtianYuantangYaoLabel}（索引${model.houtianYuantangYaoIndex}）',
    );
    print('');

    print('后天卦大运列表:');
    for (final period in model.houtianDayunList) {
      print(
        '  ${period.yaoLabel}爻(${period.yinYang}): ${period.years}年, ${period.ageRange}岁, 地支=${period.diZhiList.join("、")}',
      );
    }

    print('');
    print('先天卦六爻地支:');
    for (var i = 0; i < model.zhiList.length; i++) {
      print('  索引$i: ${model.zhiList[i].join("、")}');
    }

    print('');
    print('后天卦六爻地支:');
    for (var i = 0; i < model.houtianZhiList.length; i++) {
      print('  索引$i: ${model.houtianZhiList[i].join("、")}');
    }

    print('========================================\n');
  });
}
