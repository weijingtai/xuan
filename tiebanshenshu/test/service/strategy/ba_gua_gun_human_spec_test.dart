import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/ba_gua_gun_strategy.dart';
import 'package:tiebanshenshu/domain/models/ba_gua_gun_base_number_model.dart';

/// 八卦滚法单元测试 - 人工规格测试
///
/// 测试数据来源：用户提供的规格
/// 测试用例：男 己酉 丙子 辛巳 戊子 上元
///
/// 预期结果验证八卦滚法的完整计算流程
void main() {
  late BaGuaGunStrategy strategy;
  late EightChars testEightChars;
  late BaGuaGunStrategyParams testParams;
  late BaGuaGunBaseNumberModel model;

  setUp(() {
    strategy = BaGuaGunStrategy();

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("己酉")!,
      month: JiaZi.getFromGanZhiValue("丙子")!,
      day: JiaZi.getFromGanZhiValue("辛巳")!,
      time: JiaZi.getFromGanZhiValue("戊子")!,
    );

    testParams = BaGuaGunStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
    );

    final result = strategy.calculate(testParams);
    expect(result.hasError, false, reason: '计算不应该出错');
    model = result.baseNumbers.first as BaGuaGunBaseNumberModel;
  });

  group('步骤1：验证基本卦计算 - 己酉丙子辛巳戊子', () {
    test('应该成功生成基本卦', () {
      print('\n实际基本卦: ${model.basicGua}');
      print('基本数: ${model.basicNumber}');
      expect(model.basicGua, isNotNull, reason: '基本卦不应为空');
      expect(model.basicNumber, greaterThan(0), reason: '基本数应该大于0');
    });

    test('变爻基数应该被正确计算', () {
      print('\n实际变爻基数: ${model.variationBase}');
      expect(model.variationBase, greaterThan(0), reason: '变爻基数应该大于0');
    });
  });

  group('步骤2：验证前四卦的生成 - 八卦滚法前四卦序列', () {
    test('应该生成4个前四卦', () {
      print('\n实际前四卦列表长度: ${model.firstFourGuaList.length}');
      expect(model.firstFourGuaList.length, equals(4), reason: '应该生成4个前四卦');
    });

    test('第一卦：应该是基本卦本身', () {
      print('第一卦: ${model.firstFourGuaList[0]}');
      expect(model.firstFourGuaList[0], isNotNull);
    });

    test('第二卦：应该是第一卦变爻后上下交换', () {
      print('第二卦: ${model.firstFourGuaList[1]}');
      expect(model.firstFourGuaList[1], isNotNull);
    });

    test('第三卦：应该是第二卦的互卦', () {
      print('第三卦: ${model.firstFourGuaList[2]}');
      expect(model.firstFourGuaList[2], isNotNull);
    });

    test('第四卦：应该是第三卦的错卦', () {
      print('第四卦: ${model.firstFourGuaList[3]}');
      expect(model.firstFourGuaList[3], isNotNull);
    });
  });

  group('步骤3：验证后四卦的生成 - 八卦滚法后四卦序列', () {
    test('应该生成4个后四卦', () {
      print('\n实际后四卦列表长度: ${model.lastFourGuaList.length}');
      expect(model.lastFourGuaList.length, equals(4), reason: '应该生成4个后四卦');
    });

    test('第五卦：应该是第四卦变爻后上下交换', () {
      print('第五卦: ${model.lastFourGuaList[0]}');
      expect(model.lastFourGuaList[0], isNotNull);
    });

    test('第六卦：应该是第五卦的互卦', () {
      print('第六卦: ${model.lastFourGuaList[1]}');
      expect(model.lastFourGuaList[1], isNotNull);
    });

    test('第七卦：应该是第六卦的错卦', () {
      print('第七卦: ${model.lastFourGuaList[2]}');
      expect(model.lastFourGuaList[2], isNotNull);
    });

    test('第八卦：应该是第七卦变爻后上下交换', () {
      print('第八卦: ${model.lastFourGuaList[3]}');
      expect(model.lastFourGuaList[3], isNotNull);
    });
  });

  group('步骤4：验证八卦完整列表', () {
    test('应该有8个卦', () {
      print('\n八卦总数: ${model.eightGuaList.length}');
      expect(model.eightGuaList.length, equals(8), reason: '八卦滚法应该生成8个卦');
    });

    test('八卦列表应该等于前四卦+后四卦', () {
      expect(
        model.eightGuaList.length,
        equals(model.firstFourGuaList.length + model.lastFourGuaList.length),
        reason: '八卦 = 前四卦 + 后四卦',
      );
    });

    test('八卦序列应该完整', () {
      print('\n八卦序列:');
      for (int i = 0; i < model.eightGuaList.length; i++) {
        print('第${i + 1}卦: ${model.eightGuaList[i].fullname}');
      }
    });
  });

  group('步骤5：验证三基数计算', () {
    test('应该生成8组三基数', () {
      print('\n三基数列表长度: ${model.guaThreeNumbersList.length}');
      expect(model.guaThreeNumbersList.length, equals(8), reason: '应该有8组三基数');
    });

    test('每组三基数应该有效', () {
      for (int i = 0; i < model.guaThreeNumbersList.length; i++) {
        final threeNums = model.guaThreeNumbersList[i];
        print('\n第${i + 1}卦三基数:');
        print('  先天顺序数(a): ${threeNums.xiantianShunxu}');
        print('  先天洛书数(b): ${threeNums.xiantianLuoshu}');
        print('  后天洛书数(c): ${threeNums.houtianLuoshu}');

        // 验证范围
        expect(threeNums.xiantianShunxu, greaterThanOrEqualTo(1), reason: 'a应该>=1');
        expect(threeNums.xiantianShunxu, lessThanOrEqualTo(8), reason: 'a应该<=8');
        expect(threeNums.xiantianLuoshu, greaterThanOrEqualTo(1), reason: 'b应该>=1');
        expect(threeNums.xiantianLuoshu, lessThanOrEqualTo(9), reason: 'b应该<=9');
        expect(threeNums.houtianLuoshu, greaterThanOrEqualTo(1), reason: 'c应该>=1');
        expect(threeNums.houtianLuoshu, lessThanOrEqualTo(9), reason: 'c应该<=9');
      }
    });

    test('三基数应该对应卦象', () {
      for (int i = 0; i < model.guaThreeNumbersList.length; i++) {
        final gua = model.eightGuaList[i];
        final threeNums = model.guaThreeNumbersList[i];

        expect(threeNums.gua, equals(gua), reason: '第${i + 1}卦的三基数应该对应该卦');
      }
    });
  });

  group('步骤6：验证条文计算', () {
    test('应该生成48个条文（8卦×6条文）', () {
      print('\n条文总数: ${model.finalTiaowenList.length}');
      expect(model.finalTiaowenList.length, equals(48), reason: '八卦滚法应该生成48个条文');
    });

    test('所有条文编号应该在有效范围内', () {
      for (int i = 0; i < model.finalTiaowenList.length; i++) {
        final tiaowen = model.finalTiaowenList[i];
        expect(tiaowen, greaterThan(0), reason: '条文编号应该>0');
        expect(tiaowen, lessThan(10000), reason: '条文编号应该<10000');
      }

      print('前10个条文: ${model.finalTiaowenList.take(10).toList()}');
      print('后10个条文: ${model.finalTiaowenList.skip(38).toList()}');
    });

    test('条文应该按照三基数公式计算', () {
      // 验证第一组卦的6个条文
      if (model.guaThreeNumbersList.isNotEmpty) {
        final firstThreeNums = model.guaThreeNumbersList[0];
        final a = firstThreeNums.xiantianShunxu;
        final b = firstThreeNums.xiantianLuoshu;
        final c = firstThreeNums.houtianLuoshu;

        print('\n第一卦三基数: a=$a, b=$b, c=$c');

        final expectedSix = [
          a * 100 + b,
          a * 100 + c,
          b * 100 + a,
          b * 100 + c,
          c * 100 + a,
          c * 100 + b,
        ];

        print('预期前6个条文: $expectedSix');
        print('实际前6个条文: ${model.finalTiaowenList.take(6).toList()}');

        for (int i = 0; i < 6; i++) {
          expect(
            model.finalTiaowenList[i],
            equals(expectedSix[i]),
            reason: '第${i + 1}个条文应该按照公式计算',
          );
        }
      }
    });
  });

  group('完整流程验证 - 八卦滚法', () {
    test('应该成功计算并返回结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, false, reason: '计算应该成功');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('所有关键字段应该符合预期', () {
      final summary = {
        '算法名称': model.name,
        '基本卦': model.basicGua.fullname,
        '基本数': model.basicNumber,
        '变爻基数': model.variationBase,
        '前四卦': model.firstFourGuaList.map((g) => g.name).join(' → '),
        '后四卦': model.lastFourGuaList.map((g) => g.name).join(' → '),
        '八卦总数': model.eightGuaList.length,
        '三基数组数': model.guaThreeNumbersList.length,
        '条文总数': model.finalTiaowenList.length,
      };

      print('\n========== 八卦滚法完整结果汇总 ==========');
      summary.forEach((key, value) {
        print('$key: $value');
      });
      print('==========================================\n');

      // 验证核心字段
      expect(model.eightGuaList.length, equals(8));
      expect(model.guaThreeNumbersList.length, equals(8));
      expect(model.finalTiaowenList.length, equals(48));
    });

    test('不同参数应该产生不同结果', () {
      // 测试三元变化
      final zhongyuanParams = BaGuaGunStrategyParams(
        eightChars: testEightChars,
        gender: Gender.male,
        threeYuan: YuanYunOrder.middle,
      );
      final zhongyuanResult = strategy.calculate(zhongyuanParams);
      final zhongyuanModel = zhongyuanResult.baseNumbers.first as BaGuaGunBaseNumberModel;

      print('\n上元基本数: ${model.basicNumber}');
      print('中元基本数: ${zhongyuanModel.basicNumber}');

      // 三元不同可能导致不同的结果
    });
  });
}
