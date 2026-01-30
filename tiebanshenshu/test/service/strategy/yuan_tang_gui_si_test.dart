import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';
import 'package:tiebanshenshu/domain/models/yuan_tang_base_number_model.dart';

/// 元堂卦取数法单元测试 - 癸巳甲子丁酉癸卯
///
/// 基于修正后算法的完整验证测试
/// 测试数据：阴男 癸巳 甲子 丁酉 癸卯
///
/// 验证内容：
/// - 干支配数: 2[2,7] 6[1,6] 7[4,9] 2[3,8]
/// - 天地数: 天:27%25=2 地:30%30=3
/// - 先天卦: 震坤 (雷地豫，上震下坤)
/// - 元堂爻: 二爻(索引1) 配置：1:寅/2:卯[元堂]/3:辰/4:子丑/5:巳/6:空
/// - 后天卦: 坎震 (水雷屯，上坎下震)
void main() {
  late YuanTangStrategy strategy;
  late EightChars testEightChars;
  late YuanTangStrategyParams testParams;
  late YuanTangBaseNumberModel model;

  setUp(() {
    strategy = YuanTangStrategy();

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("癸巳")!,
      month: JiaZi.getFromGanZhiValue("甲子")!,
      day: JiaZi.getFromGanZhiValue("丁酉")!,
      time: JiaZi.getFromGanZhiValue("癸卯")!,
    );

    testParams = YuanTangStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      birthMonth: 5,
    );

    final result = strategy.calculate(testParams);
    model = result.baseNumbers.first as YuanTangBaseNumberModel;
  });

  group('步骤1：生成天地卦 - 癸巳甲子丁酉癸卯', () {
    test('应该正确提取天干配数: 癸=2, 甲=6, 丁=7, 癸=2', () {
      expect(
        model.ganNumList,
        equals([2, 6, 7, 2]),
        reason: '天干配数应该按照 癸=2, 甲=6, 丁=7, 癸=2',
      );
    });

    test('应该正确提取地支配数: 巳=[2,7], 子=[1,6], 酉=[4,9], 卯=[3,8]', () {
      // 验证地支配数，忽略每个地支内部的数字顺序
      expect(model.zhiNumList.length, equals(4), reason: '应该有4个地支');

      // 巳: [2,7] 或 [7,2]
      expect(model.zhiNumList[0], containsAll([2, 7]), reason: '巳应该包含2和7');
      expect(model.zhiNumList[0].length, equals(2), reason: '巳应该有2个数');

      // 子: [1,6] 或 [6,1]
      expect(model.zhiNumList[1], containsAll([1, 6]), reason: '子应该包含1和6');
      expect(model.zhiNumList[1].length, equals(2), reason: '子应该有2个数');

      // 酉: [4,9] 或 [9,4]
      expect(model.zhiNumList[2], containsAll([4, 9]), reason: '酉应该包含4和9');
      expect(model.zhiNumList[2].length, equals(2), reason: '酉应该有2个数');

      // 卯: [3,8] 或 [8,3]
      expect(model.zhiNumList[3], containsAll([3, 8]), reason: '卯应该包含3和8');
      expect(model.zhiNumList[3].length, equals(2), reason: '卯应该有2个数');
    });

    test('应该计算奇数总和=27', () {
      // 根据修正后的数据计算奇数和
      // 天干奇数：7(丁)
      // 地支奇数：7(巳2) + 1(子1) + 9(酉2) + 3(卯1) = 20
      // 奇数总和 = 7 + 20 = 27
      expect(model.oddNumTotal, equals(27), reason: '所有奇数之和应该是27');
    });

    test('应该计算偶数总和=30', () {
      // 根据修正后的数据计算偶数和
      // 天干偶数：2(癸) + 6(甲) + 2(癸) = 10
      // 地支偶数：2(巳1) + 6(子2) + 4(酉1) + 8(卯2) = 20
      // 偶数总和 = 10 + 20 = 30
      expect(model.evenNumTotal, equals(30), reason: '所有偶数之和应该是30');
    });

    test('天数应该=2，天卦=坤', () {
      // 天数：27 % 25 = 2
      expect(model.tianGuaNum, equals(2), reason: '奇数和27对25取模应该得2');
      expect(model.tianGua, equals('坤'), reason: '天数2对应坤卦');
    });

    test('地数应该=3，地卦=震', () {
      // 地数：30 % 30 = 3（特殊处理）
      expect(model.diGuaNum, equals(3), reason: '偶数和30对30取模特殊处理为3');
      expect(model.diGua, equals('震'), reason: '地数3对应震卦');
    });

    test('应该未使用三元五宫', () {
      expect(model.usedThreeYuanWuGong, isFalse, reason: '天数和地数都不是5，不需要使用三元五宫');
    });
  });

  group('步骤2：生成上下卦（先天卦） - 癸巳甲子丁酉癸卯', () {
    test('应该判断癸年为阴年', () {
      // 癸为阴干
      expect(model.yearYinYang, equals('阴'), reason: '癸为阴干，应该判断为阴年');
    });

    test('阴年男性应该地卦在上、天卦在下', () {
      // 阴年男性：地卦在上，天卦在下
      expect(model.upperGua, equals(model.diGua), reason: '阴年男性，地卦应该在上');
      expect(model.lowerGua, equals(model.tianGua), reason: '阴年男性，天卦应该在下');
    });

    test('先天卦应该是震坤（雷地豫）', () {
      // 天数2对应坤卦，地数3对应震卦
      // 阴年男性：地卦在上，天卦在下 -> 震坤
      expect(model.xiantianGua, equals('震坤'), reason: '先天卦应该是震坤（雷地豫）');
      expect(model.upperGua, equals('震'), reason: '上卦应该是震');
      expect(model.lowerGua, equals('坤'), reason: '下卦应该是坤');
    });

    test('上下卦后天数应该正确', () {
      // 震卦后天数为3, 坤卦后天数为2
      expect(model.xiantianUpperGuaNumber, equals(3), reason: '震卦的后天数是3');
      expect(model.xiantianLowerGuaNumber, equals(2), reason: '坤卦的后天数是2');
    });
  });

  group('步骤3：元堂装卦 - 癸巳甲子丁酉癸卯', () {
    test('应该判断卯时为阳时', () {
      expect(model.timeGanzhi, equals('癸卯'), reason: '时柱应该是癸卯');
      expect(model.timeYinYang, equals('阳'), reason: '卯时属于阳时（子丑寅卯辰巳）');
    });

    test('震坤卦应该有1个阳爻，5个阴爻', () {
      // 震坤 = 001000（从上到下：震=001, 坤=000）
      expect(model.totalYangYao, equals(1), reason: '震坤卦有1个阳爻');
      expect(model.totalYinYao, equals(5), reason: '震坤卦有5个阴爻');
    });

    test('元堂爻应该在二爻（索引1）', () {
      expect(model.yuantangYaoIndex, equals(1), reason: '阳时取阳爻，元堂爻应该在二爻');
      expect(model.yuantangYaoLabel, equals('二'), reason: '索引1对应二爻');
    });

    test('二爻应该配置卯，且标记为元堂爻', () {
      expect(model.zhiList[1], contains('卯'), reason: '二爻应该装配卯地支');

      final erYao = model.yaoDetails[1];
      expect(erYao.isYuanTangYao, isTrue, reason: '二爻应该是元堂爻');
      expect(erYao.positionLabel, equals('二'), reason: '位置标签应该是"二"');
      expect(erYao.diZhiList, contains('卯'), reason: '二爻yaoDetails中应该包含卯');
    });

    test('六爻地支配置应该完整正确', () {
      // 预期配置：1:寅/2:卯[元堂]/3:辰/4:子丑/5:巳/6:空
      expect(model.zhiList[0], contains('寅'), reason: '初爻：寅');
      expect(model.zhiList[1], contains('卯'), reason: '二爻：卯[元堂]');
      expect(model.zhiList[2], contains('辰'), reason: '三爻：辰');
      expect(model.zhiList[3], containsAll(['子', '丑']), reason: '四爻：子丑');
      expect(model.zhiList[4], contains('巳'), reason: '五爻：巳');
      expect(model.zhiList[5], isEmpty, reason: '上爻：空');
    });

    test('只有一个元堂爻，且位置正确', () {
      final yuanTangYaoCount = model.yaoDetails
          .where((yao) => yao.isYuanTangYao)
          .length;

      expect(yuanTangYaoCount, equals(1), reason: '只应该有一个元堂爻');

      final yuanTangYao = model.yaoDetails.firstWhere(
        (yao) => yao.isYuanTangYao,
      );
      expect(yuanTangYao.position, equals(1), reason: '元堂爻应该在二爻位置');
      expect(yuanTangYao.positionLabel, equals('二'), reason: '元堂爻标签应该是"二"');
    });
  });

  group('步骤4：生成后天卦 - 癸巳甲子丁酉癸卯', () {
    test('后天卦应该是坎震（水雷屯）', () {
      // 二爻（索引1）阳爻爻变：震坤 -> 变后卦，上下卦互换
      expect(model.houtianGua, equals('坎震'), reason: '二爻爻变且上下卦互换后应该得到坎震（水雷屯）');
    });

    test('后天卦上卦应该是坎', () {
      expect(model.houtianGua.top, equals('坎'), reason: '后天卦上卦应该是坎');
      expect(model.houtianUpperGuaNumber, equals(1), reason: '坎卦的后天数是1');
    });

    test('后天卦下卦应该是震', () {
      expect(model.houtianGua.bottom, equals('震'), reason: '后天卦下卦应该是震');
      expect(model.houtianLowerGuaNumber, equals(3), reason: '震卦的后天数是3');
    });

    test('后天卦应该与先天卦不同', () {
      expect(
        model.houtianGua,
        isNot(equals(model.xiantianGua)),
        reason: '元堂爻爻变且上下卦互换后，后天卦应该与先天卦不同',
      );
    });
  });

  group('步骤5：互卦计算 - 癸巳甲子丁酉癸卯', () {
    test('先天卦互卦应该已计算', () {
      expect(model.xiantianGuaHu, isNotEmpty, reason: '先天卦互卦应该已计算');
      // expect(model.xiantianGuaHu.length, equals(2), reason: '互卦应该是两个卦的组合');
    });

    test('后天卦互卦应该已计算', () {
      expect(model.houtianGuaHu, isNotEmpty, reason: '后天卦互卦应该已计算');
      // expect(model.houtianGuaHu.length, equals(2), reason: '互卦应该是两个卦的组合');
    });
  });

  group('完整计算流程验证 - 癸巳甲子丁酉癸卯', () {
    test('应该返回成功结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, isFalse, reason: '计算应该成功，无错误');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('所有关键字段应该已填充', () {
      expect(model.tianGua, equals('坤'), reason: '天卦应该是坤');
      expect(model.diGua, equals('震'), reason: '地卦应该是震');
      expect(model.xiantianGua, equals('震坤'), reason: '先天卦应该是震坤');
      expect(model.houtianGua, equals('坎震'), reason: '后天卦应该是坎震');
      expect(model.xiantianGuaHu, isNotEmpty, reason: '先天卦互卦应该已计算');
      expect(model.houtianGuaHu, isNotEmpty, reason: '后天卦互卦应该已计算');
    });

    test('与预期算法输出完全匹配', () {
      // 这是一个综合验证测试，确保所有关键点都符合预期的算法输出

      // 验证地支配数（忽略顺序）
      bool checkZhiNumList() {
        if (model.zhiNumList.length != 4) return false;
        if (!model.zhiNumList[0].toSet().containsAll([2, 7]) ||
            model.zhiNumList[0].length != 2)
          return false;
        if (!model.zhiNumList[1].toSet().containsAll([1, 6]) ||
            model.zhiNumList[1].length != 2)
          return false;
        if (!model.zhiNumList[2].toSet().containsAll([4, 9]) ||
            model.zhiNumList[2].length != 2)
          return false;
        if (!model.zhiNumList[3].toSet().containsAll([3, 8]) ||
            model.zhiNumList[3].length != 2)
          return false;
        return true;
      }

      final expectations = {
        '天干配数': model.ganNumList.toString() == '[2, 6, 7, 2]',
        '地支配数': checkZhiNumList(),
        '奇数总和': model.oddNumTotal == 27,
        '偶数总和': model.evenNumTotal == 30,
        '天数': model.tianGuaNum == 2,
        '地数': model.diGuaNum == 3,
        '先天卦': model.xiantianGua == '震坤',
        '时辰阴阳': model.timeYinYang == '阳',
        '元堂爻位置': model.yuantangYaoIndex == 1,
        '元堂爻标签': model.yuantangYaoLabel == '二',
        '二爻配置': model.zhiList[1].contains('卯'),
        '后天卦': model.houtianGua == '坎震',
      };

      final failed = <String>[];
      expectations.forEach((key, value) {
        if (!value) {
          failed.add(key);
        }
      });

      expect(failed, isEmpty, reason: '所有验证点都应该通过，失败项: ${failed.join(", ")}');
    });
  });
}
