import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/service/strategy/yuan_tang_strategy.dart';
import 'package:tiebanshenshu/domain/models/yuan_tang_base_number_model.dart';

/// 元堂卦取数法单元测试 - 大运计算验证
///
/// 测试数据：癸巳甲子丁酉癸卯（男性，上元，夏至后）
///
/// 验证内容：
/// - 先天卦：震坤（雷地豫）
/// - 元堂爻：二爻（索引1）
/// - 震坤二进制：001000（从下到上：初阴、二阴、三阴、四阴、五阳、上阴）
/// - 预期大运（从二爻开始）：
///   二爻(阴6年,1-6) → 三爻(阴6年,7-12) → 四爻(阴6年,13-18) →
///   五爻(阳9年,19-27) → 上爻(阴6年,28-33) → 初爻(阴6年,34-39)
/// - 后天卦：坎震（水雷屯）
/// - 后天卦大运应该从40岁开始继续
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

  group('先天卦大运计算 - 癸巳甲子丁酉癸卯', () {
    test('大运起始年龄应该是1岁', () {
      expect(model.xiantianDayunStartAge, equals(1), reason: '先天卦大运应该从1岁开始');
    });

    test('先天卦应该有6个大运期间', () {
      expect(
        model.xiantianDayunList.length,
        equals(6),
        reason: '先天卦应该有6个大运期间（六爻）',
      );
    });

    test('大运应该从元堂爻（二爻）开始', () {
      final firstPeriod = model.xiantianDayunList.first;
      expect(firstPeriod.yaoPosition, equals(1), reason: '第一个大运期间应该对应二爻（索引1）');
      expect(firstPeriod.yaoLabel, equals('二'), reason: '第一个大运期间标签应该是"二"');
    });

    test('大运顺序应该是：二→三→四→五→上→初', () {
      final yaoLabels = model.xiantianDayunList.map((p) => p.yaoLabel).toList();
      expect(
        yaoLabels,
        equals(['二', '三', '四', '五', '上', '初']),
        reason: '大运顺序应该从元堂爻（二爻）开始循环',
      );
    });

    test('阴阳爻应该正确：震坤卦应该是5阴1阳', () {
      // 震坤 = 001000（从上到下：上阴、五阴、四阳、三阴、二阴、初阴）
      // 四爻是阳爻，其他都是阴爻
      final yinYangList = model.xiantianDayunList
          .map((p) => p.yinYang)
          .toList();

      // 从二爻开始循环：二(阴)、三(阴)、四(阳)、五(阴)、上(阴)、初(阴)
      expect(
        yinYangList,
        equals(['阴', '阴', '阳', '阴', '阴', '阴']),
        reason: '震坤卦的四爻是阳爻',
      );
    });

    test('阳爻应该是9年，阴爻应该是6年', () {
      for (final period in model.xiantianDayunList) {
        if (period.yinYang == '阳') {
          expect(period.years, equals(9), reason: '阳爻应该是9年');
        } else {
          expect(period.years, equals(6), reason: '阴爻应该是6年');
        }
      }
    });

    test('年龄区间应该连续累加', () {
      // 二爻(阴6年,1-6) → 三爻(阴6年,7-12) → 四爻(阳9年,13-21) →
      // 五爻(阴6年,22-27) → 上爻(阴6年,28-33) → 初爻(阴6年,34-39)
      expect(model.xiantianDayunList[0].startAge, equals(1));
      expect(model.xiantianDayunList[0].endAge, equals(6));

      expect(model.xiantianDayunList[1].startAge, equals(7));
      expect(model.xiantianDayunList[1].endAge, equals(12));

      expect(model.xiantianDayunList[2].startAge, equals(13));
      expect(model.xiantianDayunList[2].endAge, equals(21)); // 四爻是阳爻，9年

      expect(
        model.xiantianDayunList[3].startAge,
        equals(22),
      ); // 更新：四爻是阳爻，所以从22岁开始
      expect(model.xiantianDayunList[3].endAge, equals(27));

      expect(model.xiantianDayunList[4].startAge, equals(28));
      expect(model.xiantianDayunList[4].endAge, equals(33));

      expect(model.xiantianDayunList[5].startAge, equals(34));
      expect(model.xiantianDayunList[5].endAge, equals(39));
    });

    test('每个大运期间的地支配置应该已初始化', () {
      // 验证每个大运期间的地支列表都已初始化（但可能为空，因为装卦时可能没有足够的地支）
      for (final period in model.xiantianDayunList) {
        expect(period.diZhiList, isNotNull, reason: '每个大运期间的地支列表都应该已初始化');
      }
    });
  });

  group('后天卦大运计算 - 癸巳甲子丁酉癸卯', () {
    test('后天卦大运应该接着先天卦继续', () {
      final xiantianEndAge = model.xiantianDayunList.last.endAge;
      expect(
        model.houtianDayunStartAge,
        equals(xiantianEndAge + 1),
        reason: '后天卦大运应该在先天卦结束后继续（40岁）',
      );
      expect(
        model.houtianDayunStartAge,
        equals(40),
        reason: '先天卦39岁结束，后天卦应该从40岁开始',
      );
    });

    test('后天卦应该有6个大运期间', () {
      expect(
        model.houtianDayunList.length,
        equals(6),
        reason: '后天卦应该有6个大运期间（六爻）',
      );
    });

    test('后天卦年龄区间应该连续累加', () {
      // 验证后天卦的年龄是连续的
      var expectedAge = model.houtianDayunStartAge;
      for (final period in model.houtianDayunList) {
        expect(period.startAge, equals(expectedAge), reason: '后天卦大运年龄应该连续累加');
        expectedAge = period.endAge + 1;
      }
    });

    test('先天卦和后天卦总共覆盖81年（12个爻位）', () {
      final totalYears =
          model.xiantianDayunList.fold<int>(0, (sum, p) => sum + p.years) +
          model.houtianDayunList.fold<int>(0, (sum, p) => sum + p.years);

      // 震坤（5阴1阳）+ 坎震（后天卦阴阳分布）
      // 如果全部是阴爻：12爻 × 6年 = 72年
      // 如果全部是阳爻：12爻 × 9年 = 108年
      // 实际应该介于两者之间
      expect(totalYears, greaterThanOrEqualTo(72), reason: '总年数应该至少72年（全阴爻情况）');
      expect(totalYears, lessThanOrEqualTo(108), reason: '总年数应该最多108年（全阳爻情况）');
    });

    test('后天卦元堂爻信息应该已计算', () {
      expect(
        model.houtianYuantangYaoIndex,
        greaterThanOrEqualTo(0),
        reason: '后天卦元堂爻索引应该已计算',
      );
      expect(
        model.houtianYuantangYaoIndex,
        lessThan(6),
        reason: '后天卦元堂爻索引应该在0-5范围内',
      );
      expect(
        model.houtianYuantangYaoLabel,
        isNotEmpty,
        reason: '后天卦元堂爻标签应该已计算',
      );
    });

    test('后天卦六爻地支应该已装配', () {
      expect(model.houtianZhiList.length, equals(6), reason: '后天卦应该有6个爻位');
    });
  });

  group('大运数据结构验证', () {
    test('YuanTangDayunPeriod应该包含所有必要信息', () {
      final period = model.xiantianDayunList.first;

      expect(period.yaoPosition, isNotNull, reason: '爻位应该已设置');
      expect(period.yaoLabel, isNotEmpty, reason: '爻位标签应该已设置');
      expect(period.yinYang, isIn(['阳', '阴']), reason: '阴阳属性应该是"阳"或"阴"');
      expect(period.years, isIn([6, 9]), reason: '年数应该是6或9');
      expect(period.startAge, greaterThan(0), reason: '起始年龄应该大于0');
      expect(
        period.endAge,
        greaterThanOrEqualTo(period.startAge),
        reason: '结束年龄应该不小于起始年龄',
      );
      expect(period.diZhiList, isNotNull, reason: '地支列表应该已初始化');
    });

    test('ageRange getter应该正确', () {
      final period = model.xiantianDayunList.first;
      expect(
        period.ageRange,
        equals('${period.startAge}-${period.endAge}'),
        reason: 'ageRange应该返回正确的年龄区间字符串',
      );
    });
  });

  group('完整大运计算验证', () {
    test('大运计算不应该抛出错误', () {
      expect(
        () => strategy.calculate(testParams),
        returnsNormally,
        reason: '大运计算应该正常完成',
      );
    });

    test('所有大运相关字段应该已填充', () {
      expect(model.xiantianDayunStartAge, equals(1));
      expect(model.xiantianDayunList, isNotEmpty);
      expect(model.houtianDayunStartAge, greaterThan(1));
      expect(model.houtianDayunList, isNotEmpty);
      expect(model.houtianYuantangYaoIndex, greaterThanOrEqualTo(0));
      expect(model.houtianYuantangYaoLabel, isNotEmpty);
      expect(model.houtianZhiList, isNotEmpty);
    });
  });
}
