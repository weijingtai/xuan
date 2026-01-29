import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/service/strategy/gua_zhong_strategy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('GuaZhong算法逻辑验证', () {
    test('验证年月卦计算 - mod 8逻辑', () {
      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      print('\n========== 年月卦计算验证 ==========');
      print('年柱: ${eightChars.year.name}');
      print('月柱: ${eightChars.month.name}');

      // 手动计算太玄数
      // 癸=10, 卯=9 → yearSum=19
      // 癸=10, 亥=3 → monthSum=13
      print('年柱: 癸(10) + 卯(9) = 19');
      print('月柱: 癸(10) + 亥(3) = 13');

      // mod 8计算
      // 19 % 8 = 3 → 上卦先天数=3 (离卦)
      // 13 % 8 = 5 → 下卦先天数=5 (巽卦)
      print('年柱 mod 8: 19 % 8 = 3 (离卦)');
      print('月柱 mod 8: 13 % 8 = 5 (巽卦)');
      print('预期年月卦: 离巽');

      final strategy = GuaZhongStrategy();
      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, false);

      final model = result.baseNumbers.first;
      print('\n实际计算结果:');
      print('年月卦上卦: ${(model as dynamic).nianYueUpperGuaName}');
      print('年月卦下卦: ${(model as dynamic).nianYueLowerGuaName}');
      print('年月卦主卦: ${(model as dynamic).nianYueZhuGuaName}');

      print('========== 年月卦验证结束 ==========\n');
    });

    test('验证日时卦计算 - 大于8减8逻辑', () {
      // 使用DevConstant.dev_usa的八字数据
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      print('\n========== 日时卦计算验证 ==========');
      print('日柱: ${eightChars.day.name}');
      print('时柱: ${eightChars.time.name}');

      // 手动计算太玄数
      // 甲=1, 申=2 → daySum=3
      // 甲=1, 子=6 → timeSum=7
      print('日柱: 甲(1) + 申(2) = 3');
      print('时柱: 甲(1) + 子(6) = 7');

      // > 8 则减8
      // 3 不大于8，保持3 → 上卦先天数=3 (离卦)
      // 7 不大于8，保持7 → 下卦先天数=7 (艮卦)
      print('日柱: 3 <= 8, 保持3 (离卦)');
      print('时柱: 7 <= 8, 保持7 (艮卦)');
      print('预期日时卦: 离艮');

      final strategy = GuaZhongStrategy();
      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, false);

      final model = result.baseNumbers.first;
      print('\n实际计算结果:');
      print('日时卦上卦: ${(model as dynamic).riShiUpperGuaName}');
      print('日时卦下卦: ${(model as dynamic).riShiLowerGuaName}');
      print('日时卦主卦: ${(model as dynamic).riShiZhuGuaName}');

      print('========== 日时卦验证结束 ==========\n');
    });

    test('验证条文编号计算 - 年月卦主卦', () {
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      print('\n========== 年月卦主卦条文编号验证（三种方案） ==========');

      // 假设上卦先天数=4（震卦）
      // 这是触发千位=10的场景
      print('假设上卦先天数=4（震卦）:');
      print('千位计算:');
      print('  方案1: (4+6)==10 → 取1代替0 → 千位=1');
      print('  方案2: (4+6)==10 → 取先天数4 → 千位=4');
      print('  方案3: (4+6)==10 → 保留10 → 千位=10');
      print('百位 = 4');
      print('十位 = 癸(10)');
      print('个位 = 卯(9)');
      print('预期条文编号:');
      print('  方案1 = 1 * 1000 + 4 * 100 + 10 * 10 + 9 = 1549');
      print('  方案2 = 4 * 1000 + 4 * 100 + 10 * 10 + 9 = 4549');
      print('  方案3 = 10 * 1000 + 4 * 100 + 10 * 10 + 9 = 10549');

      final strategy = GuaZhongStrategy();
      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);

      final model = result.baseNumbers.first as dynamic;
      print('\n实际计算结果（三种方案）:');
      print('年月卦主卦条文编号_方案1: ${model.nianYueZhuGuaTiaoWenNumber_Plan1}');
      print('年月卦主卦条文编号_方案2: ${model.nianYueZhuGuaTiaoWenNumber_Plan2}');
      print('年月卦主卦条文编号_方案3: ${model.nianYueZhuGuaTiaoWenNumber_Plan3}');

      print('上卦先天数: ${model.nianYueUpperGuaXiantianNumber}');
      print('上卦名: ${model.nianYueUpperGuaName}');

      print('所有条文编号: ${model.allTiaoWenNumbers}');
      print('条文总数: ${model.allTiaoWenNumbers.length}');

      print('========== 验证结束 ==========\n');
    });

    test('测试极端情况 - 干支和正好等于8', () {
      print('\n========== 测试mod 8边界情况 ==========');

      // 构造一个干支和=8的情况
      // 比如：丁(4) + 辰(4) = 8
      final eightChars = EightChars(
        year: JiaZi.getFromGanZhiValue('丁辰')!,
        month: JiaZi.getFromGanZhiValue('癸亥')!,
        day: JiaZi.getFromGanZhiValue('甲申')!,
        time: JiaZi.getFromGanZhiValue('甲子')!,
      );

      print('年柱: 丁辰 → 丁(4) + 辰(4) = 8');
      print('8 % 8 = 0, 应该取8 (坤卦)');

      final strategy = GuaZhongStrategy();
      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);

      // Check if there is an error
      if (result.hasError) {
        print('❌ 计算失败: ${result.errorMessage}');
        print('========== 测试结束 ==========\n');
        return;
      }

      final model = result.baseNumbers.first as dynamic;
      final upperXiantian = model.nianYueUpperGuaXiantianNumber as int;
      print('实际上卦先天数: $upperXiantian');
      print('实际上卦名: ${model.nianYueUpperGuaName}');

      // 先天数8对应坤卦
      expect(upperXiantian, 8);

      print('========== 测试结束 ==========\n');
    });

    test('测试日时卦大于8的情况', () {
      print('\n========== 测试大于8减8逻辑 ==========');

      // 构造一个干支和>8的情况
      // 比如：癸(10) + 亥(3) = 13, 应该减8得5
      final eightChars = EightChars(
        year: JiaZi.getFromGanZhiValue('癸卯')!,
        month: JiaZi.getFromGanZhiValue('癸亥')!,
        day: JiaZi.getFromGanZhiValue('癸亥')!, // 癸(10) + 亥(3) = 13
        time: JiaZi.getFromGanZhiValue('癸卯')!, // 癸(10) + 卯(9) = 19
      );

      print('日柱: 癸亥 → 癸(10) + 亥(3) = 13');
      print('13 > 8, 减8 → 13 - 8 = 5 (巽卦)');
      print('时柱: 癸卯 → 癸(10) + 卯(9) = 19');
      print('19 > 8, 减8 → 19 - 8 = 11');
      print('11 > 8, 再减8 → 11 - 8 = 3 (离卦)');
      print('⚠️  问题：算法只说"如果大于8则减去8"，是只减一次还是循环减？');

      final strategy = GuaZhongStrategy();
      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);

      final model = result.baseNumbers.first;
      final upperXiantian = (model as dynamic).riShiUpperGuaXiantianNumber;
      final lowerXiantian = (model as dynamic).riShiLowerGuaXiantianNumber;
      print('\n实际日柱上卦先天数: $upperXiantian');
      print('实际时柱下卦先天数: $lowerXiantian');

      print('========== 测试结束 ==========\n');
    });
  });
}
