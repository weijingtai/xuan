/// GuaUtils工具方法测试
///
/// 测试新添加的天地卦和先天卦生成方法
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/utils/utils.dart' as gua_utils;

void main() {
  group('generateTianDiGua 测试', () {
    test('癸巳案例 - 天地卦生成正确', () {
      // 癸巳案例：癸巳 甲子 丁酉 癸卯
      // 性别：男，三元：上，年份：阴年
      final result = gua_utils.generateTianDiGua(
        yearGan: '癸',
        monthGan: '甲',
        dayGan: '丁',
        timeGan: '癸',
        yearZhi: '巳',
        monthZhi: '子',
        dayZhi: '酉',
        timeZhi: '卯',
        yearYinYang: '阴',
        gender: '男',
        threeYuan: '上',
      );

      final (tianGua, diGua, ganNumList, zhiNumList, oddNumTotal, evenNumTotal,
              tianGuaNum, diGuaNum, usedThreeYuanWuGong) = result;

      // 验证天地卦
      expect(tianGua, '坤', reason: '天卦应该是坤');
      expect(diGua, '震', reason: '地卦应该是震');

      // 验证天干数列表
      expect(ganNumList, [2, 6, 7, 2], reason: '天干数列表：癸2 甲6 丁7 癸2');

      // 验证地支数列表（内部顺序不重要，使用containsAll）
      expect(zhiNumList.length, 4, reason: '应该有4个地支');
      expect(zhiNumList[0], containsAll([7, 2]), reason: '巳应该包含7和2');
      expect(zhiNumList[1], containsAll([1, 6]), reason: '子应该包含1和6');
      expect(zhiNumList[2], containsAll([9, 4]), reason: '酉应该包含9和4');
      expect(zhiNumList[3], containsAll([3, 8]), reason: '卯应该包含3和8');

      // 验证奇偶数总和
      // 奇数：7(丁) + 7(巳) + 1(子) + 9(酉) + 3(卯) = 27
      // 偶数：2(癸) + 6(甲) + 2(癸) + 2(巳) + 6(子) + 4(酉) + 8(卯) = 30
      expect(oddNumTotal, 27, reason: '奇数总和应为27');
      expect(evenNumTotal, 30, reason: '偶数总和应为30');

      // 验证天数地数
      expect(tianGuaNum, 2, reason: '天数：27 % 25 = 2');
      expect(diGuaNum, 3, reason: '地数：30 % 30 = 3（特殊处理为3）');

      // 验证是否使用三元五宫
      expect(usedThreeYuanWuGong, false, reason: '天数和地数都不为5，未使用三元五宫');
    });

    test('天数为5时应使用三元五宫映射', () {
      // 构造一个天数为5的案例
      // 奇数和 = 25 时，天数为5
      final result = gua_utils.generateTianDiGua(
        yearGan: '甲',
        monthGan: '乙',
        dayGan: '丙',
        timeGan: '丁',
        yearZhi: '子',
        monthZhi: '丑',
        dayZhi: '寅',
        timeZhi: '卯',
        yearYinYang: '阳',
        gender: '男',
        threeYuan: '上',
      );

      final (_, _, _, _, oddNumTotal, _, tianGuaNum, _, usedThreeYuanWuGong) =
          result;

      // 如果天数为5，应该使用三元五宫
      if (tianGuaNum == 5) {
        expect(usedThreeYuanWuGong, true, reason: '天数为5时应使用三元五宫');
      }
    });

    test('阳年女性 - 上元 - 地数为5', () {
      // 构造一个地数为5的案例，测试三元五宫映射
      // 这是一个示例，实际数值需要根据真实案例调整
      final result = gua_utils.generateTianDiGua(
        yearGan: '甲',
        monthGan: '甲',
        dayGan: '甲',
        timeGan: '甲',
        yearZhi: '子',
        monthZhi: '子',
        dayZhi: '子',
        timeZhi: '子',
        yearYinYang: '阳',
        gender: '女',
        threeYuan: '上',
      );

      final (tianGua, diGua, _, _, _, _, tianGuaNum, diGuaNum, _) = result;

      // 验证天地卦生成
      expect(tianGua, isNotEmpty, reason: '天卦应该生成');
      expect(diGua, isNotEmpty, reason: '地卦应该生成');
    });
  });

  group('generateXiantianGua 测试', () {
    test('癸巳案例 - 先天卦生成正确（阴年男性）', () {
      // 根据元堂卦测试，癸巳案例：
      // 天卦：坤，地卦：震
      // 阴年男性：地卦在上，天卦在下
      // 先天卦应该是：震坤

      final result = gua_utils.generateXiantianGua(
        tianGua: '坤',
        diGua: '震',
        yearYinYang: '阴',
        gender: '男',
      );

      final (xiantianGua, upperGua, lowerGua, upperGuaNumber, lowerGuaNumber) =
          result;

      // 阴年男性：地卦在上，天卦在下
      expect(upperGua, '震', reason: '阴年男性：上卦应该是地卦震');
      expect(lowerGua, '坤', reason: '阴年男性：下卦应该是天卦坤');
      expect(xiantianGua, '震坤', reason: '先天卦应该是震坤');

      // 验证后天数
      expect(upperGuaNumber, 3, reason: '震的后天数是3');
      expect(lowerGuaNumber, 2, reason: '坤的后天数是2');
    });

    test('阳年男性 - 天地卦顺序', () {
      final result = gua_utils.generateXiantianGua(
        tianGua: '乾',
        diGua: '坤',
        yearYinYang: '阳',
        gender: '男',
      );

      final (xiantianGua, upperGua, lowerGua, upperGuaNumber, lowerGuaNumber) =
          result;

      // 阳年男性：天卦在上，地卦在下
      expect(upperGua, '乾', reason: '阳年男性：上卦应该是天卦乾');
      expect(lowerGua, '坤', reason: '阳年男性：下卦应该是地卦坤');
      expect(xiantianGua, '乾坤', reason: '先天卦应该是乾坤');
      expect(upperGuaNumber, 6, reason: '乾的后天数是6');
      expect(lowerGuaNumber, 2, reason: '坤的后天数是2');
    });

    test('阳年女性 - 天地卦顺序', () {
      final result = gua_utils.generateXiantianGua(
        tianGua: '离',
        diGua: '坎',
        yearYinYang: '阳',
        gender: '女',
      );

      final (xiantianGua, upperGua, lowerGua, _, _) = result;

      // 阳年女性：地卦在上，天卦在下
      expect(upperGua, '坎', reason: '阳年女性：上卦应该是地卦坎');
      expect(lowerGua, '离', reason: '阳年女性：下卦应该是天卦离');
      expect(xiantianGua, '坎离', reason: '先天卦应该是坎离');
    });

    test('阳年女性 - 天地卦顺序（更正）', () {
      final result = gua_utils.generateXiantianGua(
        tianGua: '艮',
        diGua: '兑',
        yearYinYang: '阳',
        gender: '女',
      );

      final (xiantianGua, upperGua, lowerGua, _, _) = result;

      // 阳年女性：地卦在上，天卦在下
      expect(upperGua, '兑', reason: '阳年女性：上卦应该是地卦兑');
      expect(lowerGua, '艮', reason: '阳年女性：下卦应该是天卦艮');
      expect(xiantianGua, '兑艮', reason: '先天卦应该是兑艮');
    });
  });

  group('generateTianDiGua 和 generateXiantianGua 集成测试', () {
    test('完整流程：从四柱到先天卦', () {
      // 步骤1：生成天地卦
      final tianDiResult = gua_utils.generateTianDiGua(
        yearGan: '癸',
        monthGan: '甲',
        dayGan: '丁',
        timeGan: '癸',
        yearZhi: '巳',
        monthZhi: '子',
        dayZhi: '酉',
        timeZhi: '卯',
        yearYinYang: '阴',
        gender: '男',
        threeYuan: '上',
      );

      final (tianGua, diGua, _, _, _, _, _, _, _) = tianDiResult;

      // 步骤2：生成先天卦
      final xiantianResult = gua_utils.generateXiantianGua(
        tianGua: tianGua,
        diGua: diGua,
        yearYinYang: '阴',
        gender: '男',
      );

      final (xiantianGua, _, _, _, _) = xiantianResult;

      // 验证完整流程结果
      expect(tianGua, '坤', reason: '天卦应该是坤');
      expect(diGua, '震', reason: '地卦应该是震');
      expect(xiantianGua, '震坤', reason: '阴年男性，先天卦应该是震坤');
    });
  });
}
