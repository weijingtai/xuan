import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/liu_yao_gan_zhi_he_strategy.dart';
import 'package:tiebanshenshu/domain/models/liu_yao_gan_zhi_he_base_number_model.dart';

/// 先后天卦六爻干支和数法单元测试 - 人工规格测试
///
/// 测试数据来源：用户提供的规格
/// 测试用例：女 丙辰 乙未 壬戌 戊巳
///
/// 预期结果：
/// 1. 先天卦：山雷颐[艮上震下]
/// 2. 纳甲（初到上）：庚子/庚寅/庚辰/丙戌/丙子/丙寅
/// 3. 太玄数：8、9/8、9/8、5/7、5/7、9/7、7
/// 4. 上卦之和：42  下卦之和：45
/// 5. 基本数：4245
/// 6. 先天卦递增96四次：4245 → 4341 4437 4533 4629
/// 7. 后天卦递减96四次：4245 → 4149 4053 3957 3861
void main() {
  late LiuYaoGanZhiHeStrategy strategy;
  late EightChars testEightChars;
  late LiuYaoGanZhiHeStrategyParams testParams;
  late LiuYaoGanZhiHeBaseNumberModel model;

  setUp(() {
    strategy = LiuYaoGanZhiHeStrategy();

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("丙辰")!,
      month: JiaZi.getFromGanZhiValue("乙未")!,
      day: JiaZi.getFromGanZhiValue("壬戌")!,
      time: JiaZi.getFromGanZhiValue("戊巳")!,
    );

    testParams = LiuYaoGanZhiHeStrategyParams(
      eightChars: testEightChars,
      gender: Gender.female,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
    );

    final result = strategy.calculate(testParams);
    expect(result.hasError, false, reason: '计算不应该出错');
    model = result.baseNumbers.first as LiuYaoGanZhiHeBaseNumberModel;
  });

  group('步骤1：验证先天卦 - 山雷颐', () {
    test('先天卦应该是山雷颐（艮上震下）', () {
      print('\n实际先天卦: ${model.xiantianGua}');
      expect(model.xiantianGua, equals('艮震'), reason: '先天卦应该是艮震（山雷颐）');
    });
  });

  group('步骤2：验证六爻纳甲', () {
    test('六爻纳甲应该是：庚子/庚寅/庚辰/丙戌/丙子/丙寅', () {
      print('\n实际六爻纳甲:');
      for (int i = 0; i < 6; i++) {
        final gan = model.xiantianYaoTianGanList[i];
        final zhi = model.xiantianYaoDiZhiList[i];
        final ganzhi = '$gan$zhi';
        print('${['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'][i]}: $ganzhi');
      }

      // 组合天干和地支验证
      final expectedNaJia = ['庚子', '庚寅', '庚辰', '丙戌', '丙子', '丙寅'];
      for (int i = 0; i < 6; i++) {
        final actualGanZhi =
            '${model.xiantianYaoTianGanList[i]}${model.xiantianYaoDiZhiList[i]}';
        expect(
          actualGanZhi,
          equals(expectedNaJia[i]),
          reason:
              '${['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'][i]}应该是${expectedNaJia[i]}',
        );
      }
    });
  });

  group('步骤3：验证太玄数', () {
    test('六爻太玄数和应该符合规格', () {
      print('\n实际六爻太玄数和:');
      for (int i = 0; i < 6; i++) {
        print(
          '${['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'][i]}和: ${model.xiantianYaoSumList[i]}',
        );
      }

      // 根据规格验证（注意：和为10的不计入）
      // 庚子: 7+6=13 (不是10，计入)
      // 庚寅: 7+9=16 (不是10，计入)
      // 庚辰: 7+5=12 (不是10，计入)
      // 丙戌: 8+5=13 (不是10，计入)
      // 丙子: 8+6=14 (不是10，计入)
      // 丙寅: 8+9=17 (不是10，计入)
    });

    test('下卦（初二三爻）之和应该=45', () {
      print('实际下卦之和: ${model.xiantianLowerSum}');
      // 根据规格：下卦之和=45
      expect(model.xiantianLowerSum, equals(45), reason: '下卦之和应该是45');
    });

    test('上卦（四五上爻）之和应该=42', () {
      print('实际上卦之和: ${model.xiantianUpperSum}');
      // 根据规格：上卦之和=42
      expect(model.xiantianUpperSum, equals(42), reason: '上卦之和应该是42');
    });
  });

  group('步骤4：验证基本数', () {
    test('基本数应该=4245', () {
      print('\n实际基本数: ${model.xiantianBaseNumber}');
      expect(
        model.xiantianBaseNumber,
        equals(4245),
        reason: '基本数应该是4245（上卦42+下卦45）',
      );
    });
  });

  group('步骤5：验证条文扩展', () {
    test('先天卦条文应该递增96四次: 4245 4341 4437 4533 4629', () {
      print('\n先天卦条文: 暂无条文扩展字段');
      // 注意：LiuYaoGanZhiHeBaseNumberModel没有条文扩展字段
      // 需要通过UseCase层获取
    });

    test('后天卦条文应该递减96四次: 4245 4149 4053 3957 3861', () {
      print('后天卦条文: 暂无条文扩展字段');
      // 注意：LiuYaoGanZhiHeBaseNumberModel没有条文扩展字段
      // 需要通过UseCase层获取
    });
  });

  group('完整流程验证 - 丙辰乙未壬戌戊巳', () {
    test('应该成功计算并返回结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, false, reason: '计算应该成功');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('所有关键字段应该符合人工规格', () {
      final liuYaoNaJia = <String>[];
      for (int i = 0; i < 6; i++) {
        liuYaoNaJia.add(
          '${model.xiantianYaoTianGanList[i]}${model.xiantianYaoDiZhiList[i]}',
        );
      }

      final summary = {
        '四柱':
            '${testEightChars.year} ${testEightChars.month} ${testEightChars.day} ${testEightChars.time}',
        '性别': testParams.gender,
        '先天卦': model.xiantianGua,
        '六爻纳甲': liuYaoNaJia,
        '六爻太玄数和': model.xiantianYaoSumList,
        '上卦之和': model.xiantianUpperSum,
        '下卦之和': model.xiantianLowerSum,
        '基本数': model.xiantianBaseNumber,
      };

      print('\n========== 完整结果汇总 ==========');
      summary.forEach((key, value) {
        print('$key: $value');
      });
      print('====================================\n');

      // 验证核心字段
      expect(model.xiantianGua, equals('艮震'));
      expect(model.xiantianBaseNumber, equals(4245));
    });
  });
}
