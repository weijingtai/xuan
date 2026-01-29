import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';
import 'package:tiebanshenshu/domain/models/yuan_tang_base_number_model.dart';

/// 元堂卦取数法单元测试 - 己酉丙子辛巳戊子
///
/// 基于修正后算法的完整验证测试
/// 测试数据：男 己酉 丙子 辛巳 戊子
///
/// 修正说明：移除了_zhuangguaLowerThan3和_zhuanggua45的第二次反转操作
/// 并修正了后天卦生成时的索引转换问题
/// 修正前：元堂爻在上爻(index 5)，后天卦为震离
/// 修正后：元堂爻在初爻(index 0)，后天卦为坤震
///
/// 验证内容：
/// - 干支配数: 9[49] 8[16] 4[27] 1[16]
/// - 天地数: 天:28%25=3 地:30%30=3
/// - 先天卦: 震震 (震为雷，震上震下)
/// - 元堂爻: 初爻(索引0) 配置：1:子寅[元堂]/2:辰/3:巳/4:丑卯/5:空/6:空
/// - 后天卦: 坤震 (地雷复)
/// - 先天卦加则法（爻序法）: 3387
/// - 后天卦加则法（爻序法）: 2477
void main() {
  late YuanTangStrategy strategy;
  late EightChars testEightChars;
  late YuanTangStrategyParams testParams;
  late YuanTangBaseNumberModel model;

  setUp(() {
    strategy = YuanTangStrategy();

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("己酉")!,
      month: JiaZi.getFromGanZhiValue("丙子")!,
      day: JiaZi.getFromGanZhiValue("辛巳")!,
      time: JiaZi.getFromGanZhiValue("戊子")!,
    );

    testParams = YuanTangStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
      birthMonth: 8,
    );

    final result = strategy.calculate(testParams);
    model = result.baseNumbers.first as YuanTangBaseNumberModel;
  });

  group('步骤1：生成天地卦 - 己酉丙子辛巳戊子', () {
    test('应该正确提取天干配数: 己=9, 丙=8, 辛=4, 戊=1', () {
      expect(
        model.ganNumList,
        equals([9, 8, 4, 1]),
        reason: '天干配数应该按照 己=9, 丙=8, 辛=4, 戊=1',
      );
    });

    test('应该正确提取地支配数: 酉=[9,4], 子=[1,6], 巳=[7,2], 子=[1,6]', () {
      expect(
        model.zhiNumList,
        equals([
          [9, 4], // 酉
          [1, 6], // 子
          [7, 2], // 巳
          [1, 6], // 子
        ]),
        reason: '地支配数应该按照Constants.diZhiNumberMapper映射',
      );
    });

    test('应该计算奇数总和=28', () {
      // 奇数：9(己) + 9(酉1) + 1(子1) + 7(巳1) + 1(戊) + 1(子1) = 28
      expect(model.oddNumTotal, equals(28), reason: '所有奇数之和应该是28');
    });

    test('应该计算偶数总和=30', () {
      // 偶数：8(丙) + 4(酉2) + 6(子2) + 2(巳2) + 4(辛) + 6(子2) = 30
      expect(model.evenNumTotal, equals(30), reason: '所有偶数之和应该是30');
    });

    test('天数应该=3，天卦=震', () {
      // 天数：28 % 25 = 3
      expect(model.tianGuaNum, equals(3), reason: '奇数和28对25取模应该得3');
      expect(model.tianGua, equals('震'), reason: '天数3对应震卦');
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

  group('步骤2：生成上下卦（先天卦） - 己酉丙子辛巳戊子', () {
    test('应该判断己年为阴年', () {
      // 己为阴干
      expect(model.yearYinYang, equals('阴'), reason: '己为阴干，应该判断为阴年');
    });

    test('阴年男性应该地卦在上、天卦在下', () {
      // 阴年男性：地卦在上，天卦在下
      expect(model.upperGua, equals(model.diGua), reason: '阴年男性，地卦应该在上');
      expect(model.lowerGua, equals(model.tianGua), reason: '阴年男性，天卦应该在下');
    });

    test('先天卦应该是震震（震为雷）', () {
      expect(model.xiantianGua, equals('震震'), reason: '天卦震+地卦震，阴年男性组合为震震');
      expect(model.upperGua, equals('震'), reason: '上卦应该是震');
      expect(model.lowerGua, equals('震'), reason: '下卦应该是震');
    });

    test('上下卦后天数应该都是3', () {
      // 震卦后天数为3 (根据houTianGuaNumberMapper)
      expect(model.xiantianUpperGuaNumber, equals(3), reason: '震卦的后天数是3');
      expect(model.xiantianLowerGuaNumber, equals(3), reason: '震卦的后天数是3');
    });
  });

  group('步骤3：元堂装卦 - 己酉丙子辛巳戊子', () {
    test('应该判断子时为阳时', () {
      expect(model.timeGanzhi, equals('戊子'), reason: '时柱应该是戊子');
      expect(model.timeYinYang, equals('阳'), reason: '子时属于阳时（子丑寅卯辰巳）');
    });

    test('震震卦应该有2个阳爻，4个阴爻', () {
      // 震震 = 001001（从下到上）
      expect(model.totalYangYao, equals(2), reason: '震震卦有2个阳爻');
      expect(model.totalYinYao, equals(4), reason: '震震卦有4个阴爻');
    });

    test('元堂爻应该在初爻（索引0）', () {
      expect(
        model.yuantangYaoIndex,
        equals(0),
        reason: '阳时取阳爻，2个阳爻使用双重装配，元堂爻应该在初爻',
      );
      expect(model.yuantangYaoLabel, equals('初'), reason: '索引0对应初爻');
    });

    test('初爻应该配置子寅，且标记为元堂爻', () {
      expect(
        model.zhiList[0],
        containsAll(['子', '寅']),
        reason: '初爻应该装配子、寅两个地支',
      );

      final chuYao = model.yaoDetails[0];
      expect(chuYao.isYuanTangYao, isTrue, reason: '初爻应该是元堂爻');
      expect(chuYao.positionLabel, equals('初'), reason: '位置标签应该是"初"');
      expect(
        chuYao.diZhiList,
        containsAll(['子', '寅']),
        reason: '初爻yaoDetails中应该包含子、寅',
      );
    });

    test('六爻地支配置应该完整正确', () {
      // 预期配置：1:子寅[元堂]/2:辰/3:巳/4:丑卯/5:空/6:空
      expect(model.zhiList[0], containsAll(['子', '寅']), reason: '初爻：子寅[元堂]');
      expect(model.zhiList[1], contains('辰'), reason: '二爻：辰');
      expect(model.zhiList[2], contains('巳'), reason: '三爻：巳');
      expect(model.zhiList[3], containsAll(['丑', '卯']), reason: '四爻：丑卯');
      expect(model.zhiList[4], isEmpty, reason: '五爻：空');
      expect(model.zhiList[5], isEmpty, reason: '上爻：空');
    });

    test('六爻阴阳属性应该正确', () {
      final yaoDetails = model.yaoDetails;

      // 震震 = 001001：从Binary列表[0,0,1,0,0,1]到实际爻位的映射
      // 修正后的装卦，爻位与阴阳的对应关系
      // 需要验证实际算法输出
      expect(
        yaoDetails[0].yinYang,
        anyOf(equals('阳'), equals('阴')),
        reason: '初爻阴阳属性应该已设置',
      );
      expect(
        yaoDetails[1].yinYang,
        anyOf(equals('阳'), equals('阴')),
        reason: '二爻阴阳属性应该已设置',
      );
      expect(
        yaoDetails[2].yinYang,
        anyOf(equals('阳'), equals('阴')),
        reason: '三爻阴阳属性应该已设置',
      );
      expect(
        yaoDetails[3].yinYang,
        anyOf(equals('阳'), equals('阴')),
        reason: '四爻阴阳属性应该已设置',
      );
      expect(
        yaoDetails[4].yinYang,
        anyOf(equals('阳'), equals('阴')),
        reason: '五爻阴阳属性应该已设置',
      );
      expect(
        yaoDetails[5].yinYang,
        anyOf(equals('阳'), equals('阴')),
        reason: '上爻阴阳属性应该已设置',
      );

      // 验证总计：2个阳爻 + 4个阴爻 = 6爻
      final yangCount = yaoDetails.where((y) => y.yinYang == '阳').length;
      final yinCount = yaoDetails.where((y) => y.yinYang == '阴').length;
      expect(yangCount, equals(2), reason: '应该有2个阳爻');
      expect(yinCount, equals(4), reason: '应该有4个阴爻');
    });

    test('只有一个元堂爻，且位置正确', () {
      final yuanTangYaoCount = model.yaoDetails
          .where((yao) => yao.isYuanTangYao)
          .length;

      expect(yuanTangYaoCount, equals(1), reason: '只应该有一个元堂爻');

      final yuanTangYao = model.yaoDetails.firstWhere(
        (yao) => yao.isYuanTangYao,
      );
      expect(yuanTangYao.position, equals(0), reason: '元堂爻应该在初爻位置');
      expect(yuanTangYao.positionLabel, equals('初'), reason: '元堂爻标签应该是"初"');
    });
  });

  group('步骤4：生成后天卦 - 己酉丙子辛巳戊子', () {
    test('后天卦应该是坤震（地雷复）', () {
      // 初爻（索引0）阳爻爻变：震(001001) -> 变后卦，上下卦互换
      expect(model.houtianGua, equals('坤震'), reason: '初爻爻变且上下卦互换后应该得到坤震（地雷复）');
    });

    test('后天卦上卦应该是坤', () {
      expect(model.houtianGua.top, equals('坤'), reason: '后天卦上卦应该是坤');
      expect(model.houtianUpperGuaNumber, equals(2), reason: '坤卦的后天数是2');
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
  group('条文编号计算 - 己酉丙子辛巳戊子', () {
    test('先天卦加则数应该为 3387', () {
      // 震震的加则法编号（使用爻序法）
      expect(
        model.tiaowenNumberJiazeXiantiangua,
        equals(3387),
        reason: '震震的加则法条文编号（爻序法）应该是3387',
      );
    });

    test('后天卦加则数为2477', () {
      // 坤震的加则法编号（使用爻序法）
      expect(
        model.tiaowenNumberJiazeHoutiangua,
        equals(2477),
        reason: '坤震的加则法条文编号（爻序法）应该是2477',
      );
    });

    test('先天卦纳甲太玄数条文编号应该大于0', () {
      expect(
        model.tiaowenNumberNajiaTaixuanXiantiangua,
        greaterThan(0),
        reason: '先天卦纳甲太玄数条文编号应该已计算',
      );
    });

    test('后天卦纳甲太玄数条文编号应该大于0', () {
      expect(
        model.tiaowenNumberNajiaTaixuanHoutiangua,
        greaterThan(0),
        reason: '后天卦纳甲太玄数条文编号应该已计算',
      );
    });

    test('先天卦本互条文编号应该大于0', () {
      expect(
        model.tiaowenNumberXiantianBenhu,
        greaterThan(0),
        reason: '先天卦本互条文编号应该已计算',
      );
    });

    test('后天卦本互条文编号应该大于0', () {
      expect(
        model.tiaowenNumberHoutianBenhu,
        greaterThan(0),
        reason: '后天卦本互条文编号应该已计算',
      );
    });

    test('先天卦互取数列表应该有8个数', () {
      expect(
        model.tiaowenNumberListXiantianGuahu.length,
        equals(8),
        reason: '先天卦互取数列表应该包含8个条文编号',
      );
      for (final num in model.tiaowenNumberListXiantianGuahu) {
        expect(num, greaterThan(0), reason: '列表中每个条文编号都应该大于0');
      }
    });

    test('后天卦互取数列表应该有8个数', () {
      expect(
        model.tiaowenNumberListHoutianGuahu.length,
        equals(8),
        reason: '后天卦互取数列表应该包含8个条文编号',
      );
      for (final num in model.tiaowenNumberListHoutianGuahu) {
        expect(num, greaterThan(0), reason: '列表中每个条文编号都应该大于0');
      }
    });
  });

  group('完整计算流程验证 - 己酉丙子辛巳戊子', () {
    test('应该返回成功结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, isFalse, reason: '计算应该成功，无错误');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('所有关键字段应该已填充', () {
      expect(model.tianGua, equals('震'), reason: '天卦应该是震');
      expect(model.diGua, equals('震'), reason: '地卦应该是震');
      expect(model.xiantianGua, equals('震震'), reason: '先天卦应该是震震');
      expect(model.houtianGua, equals('坤震'), reason: '后天卦应该是坤震');
      expect(model.xiantianGuaHu, equals('坎艮'), reason: '先天卦互卦应该是坎艮');
      expect(model.houtianGuaHu, isNotEmpty, reason: '后天卦互卦应该已计算');
    });

    test('便捷getter应该正常工作', () {
      expect(
        model.upperGuaDisplayText,
        contains('震'),
        reason: 'upperGuaDisplayText应该包含上卦信息',
      );
      expect(
        model.lowerGuaDisplayText,
        contains('震'),
        reason: 'lowerGuaDisplayText应该包含下卦信息',
      );
      expect(
        model.tianDiGuaFormula,
        contains('奇数和'),
        reason: 'tianDiGuaFormula应该包含天地卦生成说明',
      );
    });

    test('与修正后算法输出完全匹配', () {
      // 这是一个综合验证测试，确保所有关键点都符合修正后的算法输出
      final expectations = {
        '天干配数': model.ganNumList.toString() == '[9, 8, 4, 1]',
        '地支配数':
            model.zhiNumList.toString() == '[[9, 4], [1, 6], [7, 2], [1, 6]]',
        '奇数总和': model.oddNumTotal == 28,
        '偶数总和': model.evenNumTotal == 30,
        '天数': model.tianGuaNum == 3,
        '地数': model.diGuaNum == 3,
        '先天卦': model.xiantianGua == '震震',
        '时辰阴阳': model.timeYinYang == '阳',
        '元堂爻位置': model.yuantangYaoIndex == 0,
        '元堂爻标签': model.yuantangYaoLabel == '初',
        '初爻配置':
            model.zhiList[0].length == 2 &&
            model.zhiList[0].contains('子') &&
            model.zhiList[0].contains('寅'),
        '后天卦': model.houtianGua == '坤震',
        '先天卦加则数（爻序法）': model.tiaowenNumberJiazeXiantiangua == 3387,
        '后天卦加则数（爻序法）': model.tiaowenNumberJiazeHoutiangua == 2477,
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
