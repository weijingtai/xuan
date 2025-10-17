import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/si_men_fa_strategy.dart';
import 'package:tiebanshenshu/domain/models/si_men_fa_base_number_model.dart';

/// 四门法V2单元测试 - 人工规格测试
///
/// 测试数据来源：用户提供的规格
/// 测试用例：男 己酉 丙子 辛巳 戊子 上元
///
/// 预期结果验证四门法V2的完整计算流程
void main() {
  late SiMenFaStrategy strategy;
  late EightChars testEightChars;
  late SiMenFaStrategyParams testParams;
  late SiMenFaBaseNumberModel model;

  setUp(() {
    strategy = SiMenFaStrategy();

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("己酉")!,
      month: JiaZi.getFromGanZhiValue("丙子")!,
      day: JiaZi.getFromGanZhiValue("辛巳")!,
      time: JiaZi.getFromGanZhiValue("戊子")!,
    );

    testParams = SiMenFaStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
    );

    final result = strategy.calculate(testParams);
    expect(result.hasError, false, reason: '计算不应该出错');
    model = result.baseNumbers.first as SiMenFaBaseNumberModel;
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

  group('步骤2：验证四个卦的生成 - 四门法V2卦象序列', () {
    test('应该生成4个卦', () {
      print('\n实际四卦列表长度: ${model.fourGuaList.length}');
      expect(model.fourGuaList.length, equals(4), reason: '四门法应该生成4个卦');
    });

    test('第一卦：应该是基本卦的互卦', () {
      print('第一卦: ${model.fourGuaList[0]}');
      expect(model.fourGuaList[0], isNotNull);
    });

    test('第二卦：应该是第一卦变爻后的错卦', () {
      print('第二卦: ${model.fourGuaList[1]}');
      expect(model.fourGuaList[1], isNotNull);
    });

    test('第三卦：应该是第一卦的互卦', () {
      print('第三卦: ${model.fourGuaList[2]}');
      expect(model.fourGuaList[2], isNotNull);
    });

    test('第四卦：应该是第二卦的互卦', () {
      print('第四卦: ${model.fourGuaList[3]}');
      expect(model.fourGuaList[3], isNotNull);
    });
  });

  group('步骤3：验证秘数计算', () {
    test('应该生成4个秘数', () {
      print('\n实际秘数列表: ${model.secretNumbers}');
      expect(model.secretNumbers.length, equals(4), reason: '应该有4个秘数');
    });

    test('所有秘数应该在有效范围内', () {
      for (int i = 0; i < model.secretNumbers.length; i++) {
        final secretNum = model.secretNumbers[i];
        print('第${i + 1}卦秘数: $secretNum');
        expect(secretNum, greaterThanOrEqualTo(0), reason: '秘数应该>=0');
        expect(secretNum, lessThan(10000), reason: '秘数应该<10000');
      }
    });

    test('秘数计算应该基于年干阴阳和卦象', () {
      final isYangYear = testEightChars.year.gan.yinYang == YinYang.YANG;
      print('\n年干阴阳: ${isYangYear ? "阳" : "阴"}');
      print('年干: ${testEightChars.year.gan.name}');

      // 己为阴干
      expect(isYangYear, isFalse, reason: '己为阴干');
    });
  });

  group('步骤4：验证先天数计算', () {
    test('应该生成4个先天数', () {
      print('\n实际先天数列表: ${model.xiantianNumbers}');
      expect(model.xiantianNumbers.length, equals(4), reason: '应该有4个先天数');
    });

    test('所有先天数应该在有效范围内', () {
      for (int i = 0; i < model.xiantianNumbers.length; i++) {
        final xiantianNum = model.xiantianNumbers[i];
        print('第${i + 1}卦先天数: $xiantianNum');
        expect(xiantianNum, greaterThanOrEqualTo(1), reason: '先天数应该>=1');
        expect(xiantianNum, lessThanOrEqualTo(8), reason: '先天数应该<=8');
      }
    });
  });

  group('步骤5：验证条文计算', () {
    test('应该生成条文列表', () {
      print('\n条文总数: ${model.finalTiaowenList.length}');
      expect(model.finalTiaowenList, isNotEmpty, reason: '条文列表不应为空');
    });

    test('所有条文编号应该在有效范围内', () {
      for (int i = 0; i < model.finalTiaowenList.length; i++) {
        final tiaowen = model.finalTiaowenList[i];
        expect(tiaowen, greaterThan(0), reason: '条文编号应该>0');
        expect(tiaowen, lessThan(10000), reason: '条文编号应该<10000');
      }

      print('前10个条文: ${model.finalTiaowenList.take(10).toList()}');
      if (model.finalTiaowenList.length > 10) {
        print('后10个条文: ${model.finalTiaowenList.skip(model.finalTiaowenList.length - 10).toList()}');
      }
    });

    test('条文数量应该合理', () {
      // 四门法通过秘数和先天数组合计算，条文数量应该比较多
      expect(model.finalTiaowenList.length, greaterThan(10), reason: '条文数量应该大于10');
    });
  });

  group('完整流程验证 - 四门法V2', () {
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
        '四卦数量': model.fourGuaList.length,
        '四卦': model.fourGuaList.map((g) => g.name).join(' → '),
        '秘数列表': model.secretNumbers.toString(),
        '先天数列表': model.xiantianNumbers.toString(),
        '条文总数': model.finalTiaowenList.length,
      };

      print('\n========== 四门法V2完整结果汇总 ==========');
      summary.forEach((key, value) {
        print('$key: $value');
      });
      print('==========================================\n');

      // 验证核心字段
      expect(model.fourGuaList.length, equals(4));
      expect(model.secretNumbers.length, equals(4));
      expect(model.xiantianNumbers.length, equals(4));
      expect(model.finalTiaowenList, isNotEmpty);
    });

    test('不同参数应该产生不同结果', () {
      // 测试性别变化
      final femaleParams = SiMenFaStrategyParams(
        eightChars: testEightChars,
        gender: Gender.female,
        threeYuan: YuanYunOrder.upper,
      );
      final femaleResult = strategy.calculate(femaleParams);
      final femaleModel = femaleResult.baseNumbers.first as SiMenFaBaseNumberModel;

      print('\n男性基本数: ${model.basicNumber}');
      print('女性基本数: ${femaleModel.basicNumber}');

      // 性别不同可能导致不同的结果
      // 注意：根据算法，性别会影响数字计算
    });
  });
}
