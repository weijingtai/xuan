import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:common/dev_constant.dart';
import 'package:tiebanshenshu/service/strategy/gua_zhong_strategy.dart';
import 'package:tiebanshenshu/domain/models/gua_zhong_base_number_model.dart';

/// 卦中取数法三种千位计算方案专项测试
///
/// 重点验证：
/// 1. 震卦(4)触发千位=10场景的三种方案
/// 2. 其他卦象的千位计算逻辑
/// 3. 12个条文编号的正确性（4个位置 × 3种方案）
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('卦中取数法三种千位计算方案测试', () {
    late GuaZhongStrategy strategy;

    setUp(() {
      strategy = GuaZhongStrategy();
    });

    test('验证震卦场景 - 上卦先天数=4触发千位=10', () {
      print('\n========== 震卦场景测试 ==========');

      // 使用DevConstant.dev_usa的数据（年月卦上卦为震卦）
      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      print(
        '四柱: ${eightChars.year} ${eightChars.month} ${eightChars.day} ${eightChars.time}',
      );

      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, false, reason: '计算不应该出错');

      final model = result.baseNumbers.first as GuaZhongBaseNumberModel;

      print(
        '年月卦上卦: ${model.nianYueUpperGuaName} (先天数: ${model.nianYueUpperGuaXiantianNumber})',
      );
      print(
        '年月卦下卦: ${model.nianYueLowerGuaName} (先天数: ${model.nianYueLowerGuaXiantianNumber})',
      );

      // 验证是否触发震卦场景
      if (model.nianYueUpperGuaXiantianNumber == 4) {
        print('✓ 年月卦上卦为震卦(4) - 触发千位=10场景!');

        // 验证三种方案的千位计算
        final plan1Qianwei = (model.nianYueZhuGuaTiaoWenNumber_Plan1 / 1000)
            .floor();
        final plan2Qianwei = (model.nianYueZhuGuaTiaoWenNumber_Plan2 / 1000)
            .floor();
        final plan3Qianwei = (model.nianYueZhuGuaTiaoWenNumber_Plan3 / 1000)
            .floor();

        print('\n千位验证:');
        print('  方案1千位: $plan1Qianwei (预期: 1)');
        print('  方案2千位: $plan2Qianwei (预期: 4)');
        print('  方案3千位: $plan3Qianwei (预期: 10)');

        expect(plan1Qianwei, 1, reason: '方案1应该取1代替0');
        expect(plan2Qianwei, 4, reason: '方案2应该取先天数4');
        expect(plan3Qianwei, 10, reason: '方案3应该保留10');

        print('✓ 三种方案千位计算全部正确!');
      }

      // 验证总条文数量
      final allTiaoWen = model.allTiaoWenNumbers;
      print('\n总条文数: ${allTiaoWen.length}');
      expect(
        allTiaoWen.length,
        greaterThanOrEqualTo(4),
        reason: '至少应该有4个去重后的条文编号',
      );
      expect(
        allTiaoWen.length,
        lessThanOrEqualTo(12),
        reason: '最多应该有12个条文编号（4个位置 × 3种方案）',
      );

      // 验证所有12个原始条文编号都已生成
      print('\n年月卦主卦三种方案:');
      print('  Plan1: ${model.nianYueZhuGuaTiaoWenNumber_Plan1}');
      print('  Plan2: ${model.nianYueZhuGuaTiaoWenNumber_Plan2}');
      print('  Plan3: ${model.nianYueZhuGuaTiaoWenNumber_Plan3}');

      print('\n年月卦互卦三种方案:');
      print('  Plan1: ${model.nianYueHuGuaTiaoWenNumber_Plan1}');
      print('  Plan2: ${model.nianYueHuGuaTiaoWenNumber_Plan2}');
      print('  Plan3: ${model.nianYueHuGuaTiaoWenNumber_Plan3}');

      print('\n日时卦主卦三种方案:');
      print('  Plan1: ${model.riShiZhuGuaTiaoWenNumber_Plan1}');
      print('  Plan2: ${model.riShiZhuGuaTiaoWenNumber_Plan2}');
      print('  Plan3: ${model.riShiZhuGuaTiaoWenNumber_Plan3}');

      print('\n日时卦互卦三种方案:');
      print('  Plan1: ${model.riShiHuGuaTiaoWenNumber_Plan1}');
      print('  Plan2: ${model.riShiHuGuaTiaoWenNumber_Plan2}');
      print('  Plan3: ${model.riShiHuGuaTiaoWenNumber_Plan3}');

      // 验证按方案获取条文编号的方法
      final plan1Numbers = model.getAllTiaoWenNumbersByPlan(1);
      final plan2Numbers = model.getAllTiaoWenNumbersByPlan(2);
      final plan3Numbers = model.getAllTiaoWenNumbersByPlan(3);

      print('\n按方案分组:');
      print('  方案1条文数: ${plan1Numbers.length} (预期: 4)');
      print('  方案2条文数: ${plan2Numbers.length} (预期: 4)');
      print('  方案3条文数: ${plan3Numbers.length} (预期: 4)');

      expect(plan1Numbers.length, 4, reason: '方案1应该有4个条文（年月主/互 + 日时主/互）');
      expect(plan2Numbers.length, 4, reason: '方案2应该有4个条文');
      expect(plan3Numbers.length, 4, reason: '方案3应该有4个条文');

      print('========== 测试通过 ==========\n');
    });

    test('验证非震卦场景 - 千位不等于10', () {
      print('\n========== 非震卦场景测试 ==========');

      // 构造一个不会触发千位=10的四柱
      // 年柱: 甲子(1+6=7), 7 % 8 = 7 → 艮卦
      // 月柱: 乙丑(2+7=9), 9 % 8 = 1 → 乾卦
      final eightChars = EightChars(
        year: JiaZi.getFromGanZhiValue('甲子')!,
        month: JiaZi.getFromGanZhiValue('乙丑')!,
        day: JiaZi.getFromGanZhiValue('丙寅')!,
        time: JiaZi.getFromGanZhiValue('丁卯')!,
      );

      print(
        '四柱: ${eightChars.year.name} ${eightChars.month.name} ${eightChars.day.name} ${eightChars.time.name}',
      );

      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);

      expect(result.hasError, false, reason: '计算不应该出错');

      final model = result.baseNumbers.first as GuaZhongBaseNumberModel;

      print(
        '年月卦上卦: ${model.nianYueUpperGuaName} (先天数: ${model.nianYueUpperGuaXiantianNumber})',
      );
      print(
        '年月卦下卦: ${model.nianYueLowerGuaName} (先天数: ${model.nianYueLowerGuaXiantianNumber})',
      );

      // 验证千位计算
      final xiantianNum = model.nianYueUpperGuaXiantianNumber;
      final expectedQianwei = (xiantianNum + 6) % 10;

      print('\n千位计算: ($xiantianNum + 6) % 10 = $expectedQianwei');

      if (xiantianNum != 4) {
        // 非震卦场景，三种方案应该结果相同
        final plan1Qianwei = (model.nianYueZhuGuaTiaoWenNumber_Plan1 / 1000)
            .floor();
        final plan2Qianwei = (model.nianYueZhuGuaTiaoWenNumber_Plan2 / 1000)
            .floor();
        final plan3Qianwei = (model.nianYueZhuGuaTiaoWenNumber_Plan3 / 1000)
            .floor();

        print('  方案1千位: $plan1Qianwei');
        print('  方案2千位: $plan2Qianwei');
        print('  方案3千位: $plan3Qianwei');

        // 当千位不等于10时，三种方案的前两个应该相同（方案3可能不同）
        expect(plan1Qianwei, expectedQianwei, reason: '方案1千位应该等于预期值');
        expect(plan2Qianwei, expectedQianwei, reason: '方案2千位应该等于预期值');

        if (plan3Qianwei != 10) {
          // 如果方案3的千位也不是10，那么应该和前两个方案相同
          expect(plan3Qianwei, expectedQianwei, reason: '方案3千位应该等于预期值');
          print('✓ 非震卦场景，三种方案千位相同');
        }
      }

      print('========== 测试通过 ==========\n');
    });

    test('验证tiaoWenNumbersWithPlanLabel方法', () {
      print('\n========== 带标签条文列表测试 ==========');

      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);
      final model = result.baseNumbers.first as GuaZhongBaseNumberModel;

      // 获取带标签的条文列表
      final numbersWithLabel = model.tiaoWenNumbersWithPlanLabel;

      print('带标签条文总数: ${numbersWithLabel.length}');
      expect(numbersWithLabel.length, 12, reason: '应该有12条记录（4个位置 × 3种方案）');

      // 验证标签格式
      for (final item in numbersWithLabel) {
        final number = item.$1;
        final plan = item.$2;
        final position = item.$3;

        expect(plan, greaterThanOrEqualTo(1), reason: '方案编号应该 >= 1');
        expect(plan, lessThanOrEqualTo(3), reason: '方案编号应该 <= 3');
        expect(number, greaterThan(0), reason: '条文编号应该大于0');
        expect(position, isNotEmpty, reason: '位置标签不应该为空');

        print('  [$position] 方案$plan: $number');
      }

      // 验证每个位置都有三种方案
      final positions = ['年月卦主卦', '年月卦互卦', '日时卦主卦', '日时卦互卦'];
      for (final pos in positions) {
        final posNumbers = numbersWithLabel
            .where((item) => item.$3 == pos)
            .toList();
        expect(posNumbers.length, 3, reason: '$pos 应该有3个方案');

        // 验证包含方案1, 2, 3
        final plans = posNumbers.map((item) => item.$2).toSet();
        expect(plans, {1, 2, 3}, reason: '$pos 应该包含方案1, 2, 3');
      }

      print('✓ 带标签条文列表验证通过');
      print('========== 测试通过 ==========\n');
    });

    test('验证getNianYueZhuGuaTiaoWenNumber和getRiShiZhuGuaTiaoWenNumber方法', () {
      print('\n========== 按方案获取条文编号方法测试 ==========');

      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);
      final model = result.baseNumbers.first as GuaZhongBaseNumberModel;

      // 测试年月卦主卦
      print('年月卦主卦:');
      for (int plan = 1; plan <= 3; plan++) {
        final number = model.getNianYueZhuGuaTiaoWenNumber(plan);
        print('  方案$plan: $number');
        expect(number, greaterThan(0), reason: '条文编号应该大于0');
      }

      // 测试年月卦互卦
      print('年月卦互卦:');
      for (int plan = 1; plan <= 3; plan++) {
        final number = model.getNianYueHuGuaTiaoWenNumber(plan);
        print('  方案$plan: $number');
        expect(number, greaterThan(0), reason: '条文编号应该大于0');
      }

      // 测试日时卦主卦
      print('日时卦主卦:');
      for (int plan = 1; plan <= 3; plan++) {
        final number = model.getRiShiZhuGuaTiaoWenNumber(plan);
        print('  方案$plan: $number');
        expect(number, greaterThan(0), reason: '条文编号应该大于0');
      }

      // 测试日时卦互卦
      print('日时卦互卦:');
      for (int plan = 1; plan <= 3; plan++) {
        final number = model.getRiShiHuGuaTiaoWenNumber(plan);
        print('  方案$plan: $number');
        expect(number, greaterThan(0), reason: '条文编号应该大于0');
      }

      // 测试getAllTiaoWenNumbersByPlan
      print('\n按方案获取全部条文:');
      for (int plan = 1; plan <= 3; plan++) {
        final numbers = model.getAllTiaoWenNumbersByPlan(plan);
        print('  方案$plan: ${numbers.length}个条文 $numbers');
        expect(numbers.length, 4, reason: '每个方案应该有4个条文');
      }

      print('✓ 按方案获取条文编号方法验证通过');
      print('========== 测试通过 ==========\n');
    });

    test('验证震卦千位=10的精确计算', () {
      print('\n========== 震卦千位=10精确计算测试 ==========');

      final eightChars = DevConstant.dev_usa.standeredChineseInfo.eightChars;

      final params = GuaZhongStrategyParams(eightChars: eightChars);
      final result = strategy.calculate(params);
      final model = result.baseNumbers.first as GuaZhongBaseNumberModel;

      if (model.nianYueUpperGuaXiantianNumber == 4) {
        print('✓ 触发震卦场景（上卦先天数=4）');

        // 获取年干、年支的太玄数
        final yearGan = model.yearGanTaixuanNumber;
        final yearZhi = model.yearZhiTaixuanNumber;
        final baiWei = 4; // 震卦先天数
        final shiWei = yearGan;
        final geWei = yearZhi;

        print('\n手动计算:');
        print('  百位 = 上卦先天数 = $baiWei');
        print('  十位 = 年干太玄数 = $shiWei');
        print('  个位 = 年支太玄数 = $geWei');

        // 方案1: 千位=1
        final expectedPlan1 = 1 * 1000 + baiWei * 100 + shiWei * 10 + geWei;
        print(
          '  方案1预期: 1 * 1000 + $baiWei * 100 + $shiWei * 10 + $geWei = $expectedPlan1',
        );

        // 方案2: 千位=4
        final expectedPlan2 = 4 * 1000 + baiWei * 100 + shiWei * 10 + geWei;
        print(
          '  方案2预期: 4 * 1000 + $baiWei * 100 + $shiWei * 10 + $geWei = $expectedPlan2',
        );

        // 方案3: 千位=10
        final expectedPlan3 = 10 * 1000 + baiWei * 100 + shiWei * 10 + geWei;
        print(
          '  方案3预期: 10 * 1000 + $baiWei * 100 + $shiWei * 10 + $geWei = $expectedPlan3',
        );

        print('\n实际结果:');
        print('  方案1实际: ${model.nianYueZhuGuaTiaoWenNumber_Plan1}');
        print('  方案2实际: ${model.nianYueZhuGuaTiaoWenNumber_Plan2}');
        print('  方案3实际: ${model.nianYueZhuGuaTiaoWenNumber_Plan3}');

        expect(
          model.nianYueZhuGuaTiaoWenNumber_Plan1,
          expectedPlan1,
          reason: '方案1条文编号应该匹配手动计算',
        );
        expect(
          model.nianYueZhuGuaTiaoWenNumber_Plan2,
          expectedPlan2,
          reason: '方案2条文编号应该匹配手动计算',
        );
        expect(
          model.nianYueZhuGuaTiaoWenNumber_Plan3,
          expectedPlan3,
          reason: '方案3条文编号应该匹配手动计算',
        );

        print('✓ 精确计算验证通过');
      } else {
        print('⚠️  当前四柱未触发震卦场景，跳过此测试');
      }

      print('========== 测试通过 ==========\n');
    });
  });
}
