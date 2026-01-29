import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/liu_yao_gan_zhi_he_strategy.dart';
import 'package:tiebanshenshu/domain/models/liu_yao_gan_zhi_he_base_number_model.dart';

/// 先后天卦六爻干支和数法单元测试 - 癸巳甲子丁酉癸卯
///
/// 测试数据：阴男 癸巳 甲子 丁酉 癸卯
///
/// 验证内容：
/// - 干支配数
/// - 天地数计算
/// - 先天卦和后天卦生成
/// - 六爻纳甲配置
/// - 干支太玄数计算（和为10不计）
/// - 四位基础数组合
/// - 条文扩展（8个数）
void main() {
  late LiuYaoGanZhiHeStrategy strategy;
  late EightChars testEightChars;
  late LiuYaoGanZhiHeStrategyParams testParams;
  late LiuYaoGanZhiHeBaseNumberModel model;

  setUp(() {
    strategy = LiuYaoGanZhiHeStrategy();

    testEightChars = EightChars(
      year: JiaZi.getFromGanZhiValue("癸巳")!,
      month: JiaZi.getFromGanZhiValue("甲子")!,
      day: JiaZi.getFromGanZhiValue("丁酉")!,
      time: JiaZi.getFromGanZhiValue("癸卯")!,
    );

    testParams = LiuYaoGanZhiHeStrategyParams(
      eightChars: testEightChars,
      gender: Gender.male,
      threeYuan: YuanYunOrder.upper,
      birthAfterZhi: TwentyFourJieQi.XIA_ZHI,
    );

    final result = strategy.calculate(testParams);
    model = result.baseNumbers.first as LiuYaoGanZhiHeBaseNumberModel;
  });

  group('步骤1-2：生成天地卦和先后天卦 - 癸巳甲子丁酉癸卯', () {
    test('应该正确提取天干配数', () {
      expect(
        model.ganNumList,
        equals([2, 6, 7, 2]),
        reason: '天干配数应该按照 癸=2, 甲=6, 丁=7, 癸=2',
      );
    });

    test('先天卦应该是震坤', () {
      expect(model.xiantianGua, equals('震坤'), reason: '先天卦应该是震坤（雷地豫）');
    });

    test('后天卦应该已生成', () {
      expect(model.houtianGua, isNotEmpty, reason: '后天卦应该已生成');
      expect(model.houtianGua, equals('震坤'), reason: '后天卦应该是震坤（雷地豫）');
    });
  });

  group('步骤3-4：先天卦六爻纳甲和干支和数计算', () {
    test('先天卦应该有6个天干纳甲', () {
      expect(
        model.xiantianYaoTianGanList.length,
        equals(6),
        reason: '先天卦应该有6个爻，每爻配1个天干',
      );
    });

    test('先天卦应该有6个地支纳甲', () {
      expect(
        model.xiantianYaoDiZhiList.length,
        equals(6),
        reason: '先天卦应该有6个爻，每爻配1个地支',
      );
    });

    test('先天卦应该有6个干支和数', () {
      expect(
        model.xiantianYaoSumList.length,
        equals(6),
        reason: '先天卦应该有6个爻，每爻有1个干支和数',
      );
    });

    test('先天卦干支和数应该非负（和为10的爻应该为0）', () {
      for (var i = 0; i < model.xiantianYaoSumList.length; i++) {
        expect(
          model.xiantianYaoSumList[i],
          greaterThanOrEqualTo(0),
          reason: '第${i + 1}爻的干支和数应该非负（和为10时为0）',
        );
      }
    });

    test('先天卦上三爻和数应该已计算', () {
      expect(
        model.xiantianUpperSum,
        greaterThanOrEqualTo(0),
        reason: '上三爻和数应该非负',
      );
    });

    test('先天卦下三爻和数应该已计算', () {
      expect(
        model.xiantianLowerSum,
        greaterThanOrEqualTo(0),
        reason: '下三爻和数应该非负',
      );
    });

    test('先天卦基础数应该=上三爻和数*100+下三爻和数', () {
      final expectedBaseNumber =
          model.xiantianUpperSum * 100 + model.xiantianLowerSum;
      expect(
        model.xiantianBaseNumber,
        equals(expectedBaseNumber),
        reason: '基础数应该是上三爻和数（千百位）和下三爻和数（十位个位）组合而成',
      );
    });
  });

  group('步骤5-6：后天卦六爻纳甲和干支和数计算', () {
    test('后天卦应该有6个天干纳甲', () {
      expect(
        model.houtianYaoTianGanList.length,
        equals(6),
        reason: '后天卦应该有6个爻，每爻配1个天干',
      );
    });

    test('后天卦应该有6个地支纳甲', () {
      expect(
        model.houtianYaoDiZhiList.length,
        equals(6),
        reason: '后天卦应该有6个爻，每爻配1个地支',
      );
    });

    test('后天卦应该有6个干支和数', () {
      expect(
        model.houtianYaoSumList.length,
        equals(6),
        reason: '后天卦应该有6个爻，每爻有1个干支和数',
      );
    });

    test('后天卦干支和数应该非负（和为10的爻应该为0）', () {
      for (var i = 0; i < model.houtianYaoSumList.length; i++) {
        expect(
          model.houtianYaoSumList[i],
          greaterThanOrEqualTo(0),
          reason: '第${i + 1}爻的干支和数应该非负（和为10时为0）',
        );
      }
    });

    test('后天卦基础数应该=上三爻和数*100+下三爻和数', () {
      final expectedBaseNumber =
          model.houtianUpperSum * 100 + model.houtianLowerSum;
      expect(
        model.houtianBaseNumber,
        equals(expectedBaseNumber),
        reason: '基础数应该是上三爻和数（千百位）和下三爻和数（十位个位）组合而成',
      );
    });
  });

  group('完整计算流程验证 - 癸巳甲子丁酉癸卯', () {
    test('应该返回成功结果', () {
      final result = strategy.calculate(testParams);
      expect(result.hasError, isFalse, reason: '计算应该成功，无错误');
      expect(result.baseNumbers.length, equals(1), reason: '应该返回1个基础数结果');
    });

    test('所有关键字段应该已填充', () {
      expect(model.xiantianGua, equals('震坤'), reason: '先天卦应该是震坤');
      expect(model.houtianGua, isNotEmpty, reason: '后天卦应该已生成');
      expect(
        model.xiantianYaoTianGanList.length,
        equals(6),
        reason: '先天卦应该有6个天干',
      );
      expect(
        model.xiantianYaoDiZhiList.length,
        equals(6),
        reason: '先天卦应该有6个地支',
      );
      expect(
        model.houtianYaoTianGanList.length,
        equals(6),
        reason: '后天卦应该有6个天干',
      );
      expect(model.houtianYaoDiZhiList.length, equals(6), reason: '后天卦应该有6个地支');
      expect(model.xiantianBaseNumber, greaterThan(0), reason: '先天卦基础数应该大于0');
      expect(model.houtianBaseNumber, greaterThan(0), reason: '后天卦基础数应该大于0');
    });
  });

  group('Strategy 配置验证', () {
    test('默认条文计算配置应该是递增减96四次（8个数）', () {
      final config = strategy.defaultTiaoWenCalculationConfig;
      expect(config.name, contains('递增减96'), reason: '默认配置应该是递增减96四次');
    });

    test('策略名称应该正确', () {
      expect(
        strategy.name,
        equals('先后天卦六爻干支和数法'),
        reason: '策略名称应该是"先后天卦六爻干支和数法"',
      );
    });

    test('策略描述应该包含关键信息', () {
      expect(strategy.description, contains('六爻纳甲'), reason: '描述应该包含"六爻纳甲"');
      expect(strategy.description, contains('干支太玄数'), reason: '描述应该包含"干支太玄数"');
    });

    test('详细步骤应该有7个', () {
      expect(strategy.detailSteps.length, equals(7), reason: '应该有7个详细步骤');
    });
  });

  group('六爻纳甲装配逻辑验证', () {
    test('纳甲天干应该都是有效的天干', () {
      const validTianGan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
      for (var tianGan in model.xiantianYaoTianGanList) {
        expect(validTianGan, contains(tianGan), reason: '纳甲天干$tianGan应该是有效的天干');
      }
      for (var tianGan in model.houtianYaoTianGanList) {
        expect(validTianGan, contains(tianGan), reason: '纳甲天干$tianGan应该是有效的天干');
      }
    });

    test('纳甲地支应该都是有效的地支', () {
      const validDiZhi = [
        '子',
        '丑',
        '寅',
        '卯',
        '辰',
        '巳',
        '午',
        '未',
        '申',
        '酉',
        '戌',
        '亥',
      ];
      for (var diZhi in model.xiantianYaoDiZhiList) {
        expect(validDiZhi, contains(diZhi), reason: '纳甲地支$diZhi应该是有效的地支');
      }
      for (var diZhi in model.houtianYaoDiZhiList) {
        expect(validDiZhi, contains(diZhi), reason: '纳甲地支$diZhi应该是有效的地支');
      }
    });
  });
}
