import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_formula_v2.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_formula_data_v2.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';

void main() {
  late EightChars testEightChars;
  late YuanHuiYunShi testYuanHuiYunShi;

  setUp(() {
    // 使用与 huang_ji_strategy_test.dart 相同的测试数据
    testEightChars = EightChars(
      year: JiaZi.YI_HAI, // 乙亥
      month: JiaZi.DING_HAI, // 丁亥
      day: JiaZi.REN_ZI, // 壬子
      time: JiaZi.XIN_HAI, // 辛亥
    );
    testYuanHuiYunShi = YuanHuiYunShi.fromEightChars(testEightChars);
  });

  group('皇极取数法 V2 集成测试', () {
    test('完整的公式定义、JSON序列化、数据转换流程', () {
      // 1. 创建基础数定义
      final yuanHuiBaseNumber = PredefinedBaseNumber(
        name: "元会基础数",
        description: "来自元会的基础数",
        source: NumberSource.yuanHui,
      );

      final yunShiBaseNumber = PredefinedBaseNumber(
        name: "运世基础数",
        description: "来自运世的基础数",
        source: NumberSource.yunShi,
      );

      // 2. 创建计算部分
      final yearGanThousands = SingleNumberPart(
        name: "年干千位",
        description: "年干太玄数的千位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.year,
        numberPlace: EnumNumberPlace.Thousands,
      );

      final monthGanHundreds = SingleNumberPart(
        name: "月干百位",
        description: "月干太玄数的百位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.month,
        numberPlace: EnumNumberPlace.Hundreds,
      );

      final dayGanTens = SingleNumberPart(
        name: "日干十位",
        description: "日干太玄数的十位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.day,
        numberPlace: EnumNumberPlace.Tens,
      );

      final timeZhiUnits = SingleNumberPart(
        name: "时支个位",
        description: "时支太玄数的个位",
        fourZhuGanZhiType: FourZhuGanZhiType.zhi,
        fourZhuName: FourZhuName.time,
        numberPlace: EnumNumberPlace.Units,
      );

      // 3. 创建复合计算部分
      final compositeFormula = CompositeNumberPart(
        name: "四柱合数",
        description: "年干千位+月干百位+日干十位+时支个位",
        components: [
          yearGanThousands,
          monthGanHundreds,
          dayGanTens,
          timeZhiUnits,
        ],
      );

      // 4. 创建条文公式
      final tiaoWenOne = TiaoWenFormula(
        name: "条文一：四柱合数",
        parts: [compositeFormula],
      );

      final tiaoWenTwo = TiaoWenFormula(
        name: "条文二：年月干",
        parts: [yearGanThousands, monthGanHundreds],
      );

      // 5. 创建计算组
      final groupOne = CalculationGroup(
        groupId: "base_one",
        description: "基础数一组",
        baseNumberDefinition: yuanHuiBaseNumber,
        formulas: [tiaoWenOne, tiaoWenTwo],
      );

      final groupTwo = CalculationGroup(
        groupId: "base_two",
        description: "基础数二组",
        baseNumberDefinition: yunShiBaseNumber,
        formulas: [tiaoWenOne],
      );

      // 6. 创建完整的皇极计算公式
      final huangJiFormula = HuangJiCalculationFormula(
        id: 1,
        name: "皇极取数法测试公式",
        groups: [groupOne, groupTwo],
      );

      // 7. 测试 JSON 序列化
      final formulaJson = huangJiFormula.toJson();
      expect(formulaJson['id'], equals(1));
      expect(formulaJson['name'], equals("皇极取数法测试公式"));
      expect(formulaJson['groups'], isA<List>());

      // 8. 测试 JSON 反序列化
      final restoredFormula = HuangJiCalculationFormula.fromJson(formulaJson);
      expect(restoredFormula.id, equals(1));
      expect(restoredFormula.name, equals("皇极取数法测试公式"));
      expect(restoredFormula.groups.length, equals(2));

      // 9. 转换为数据模型
      final dataFormula = huangJiFormula.toData(testYuanHuiYunShi);
      expect(dataFormula.id, equals(1));
      expect(dataFormula.name, equals("皇极取数法测试公式"));
      expect(dataFormula.groups.length, equals(2));

      // 10. 验证第一组数据
      final dataGroupOne = dataFormula.groups[0];
      expect(dataGroupOne.groupId, equals("base_one"));
      expect(dataGroupOne.baseNumberDefinition.number, equals(1210)); // 元会基础数
      expect(dataGroupOne.dataFormulas.length, equals(2));

      // 11. 验证条文一的计算结果
      final dataTiaoWenOne = dataGroupOne.dataFormulas[0];
      expect(dataTiaoWenOne.name, equals("条文一：四柱合数"));
      expect(dataTiaoWenOne.parts.length, equals(1));

      final dataComposite = dataTiaoWenOne.parts[0] as DataCompositeNumberPart;
      expect(dataComposite.components.length, equals(4));

      // 验证各个组件的数值
      final expectedYearGan =
          testYuanHuiYunShi.yearGanNumber * 1000; // 8 * 1000 = 8000
      final expectedMonthGan =
          testYuanHuiYunShi.monthGanNumber * 100; // 6 * 100 = 600
      final expectedDayGan = testYuanHuiYunShi.dayGanNumber * 10; // 6 * 10 = 60
      final expectedTimeZhi = testYuanHuiYunShi.timeZhiNumber; // 4

      expect(dataComposite.components[0].number, equals(expectedYearGan));
      expect(dataComposite.components[1].number, equals(expectedMonthGan));
      expect(dataComposite.components[2].number, equals(expectedDayGan));
      expect(dataComposite.components[3].number, equals(expectedTimeZhi));

      final expectedTotal =
          expectedYearGan + expectedMonthGan + expectedDayGan + expectedTimeZhi;
      expect(
        dataComposite.rawNumber,
        equals(expectedTotal),
      ); // 8000 + 600 + 60 + 4 = 8664

      // 12. 验证条文二的计算结果
      final dataTiaoWenTwo = dataGroupOne.dataFormulas[1];
      expect(dataTiaoWenTwo.name, equals("条文二：年月干"));
      expect(dataTiaoWenTwo.parts.length, equals(2));
      expect(
        dataTiaoWenTwo.number,
        equals(expectedYearGan + expectedMonthGan),
      ); // 8600

      // 13. 验证第二组数据
      final dataGroupTwo = dataFormula.groups[1];
      expect(dataGroupTwo.groupId, equals("base_two"));
      expect(dataGroupTwo.baseNumberDefinition.number, equals(5111)); // 运世基础数
      expect(dataGroupTwo.dataFormulas.length, equals(1));
    });

    test('派生基础数的完整流程测试', () {
      // 1. 创建派生基础数的计算部分
      final dayZhiUnits = SingleNumberPart(
        name: "日支个位",
        description: "日支太玄数的个位",
        fourZhuGanZhiType: FourZhuGanZhiType.zhi,
        fourZhuName: FourZhuName.day,
        numberPlace: EnumNumberPlace.Units,
      );

      // 2. 创建派生基础数
      final derivedBaseNumber = DerivedBaseNumber(
        name: "派生基础数",
        description: "从基础数一组派生",
        parentGroupId: "base_one",
        parts: [dayZhiUnits],
      );

      // 3. 创建使用派生基础数的计算组
      final derivedGroup = CalculationGroup(
        groupId: "derived_group",
        description: "派生组",
        baseNumberDefinition: derivedBaseNumber,
        formulas: [],
      );

      // 4. 创建包含派生组的公式
      final formulaWithDerived = HuangJiCalculationFormula(
        id: 2,
        name: "包含派生基础数的公式",
        groups: [derivedGroup],
      );

      // 5. 转换为数据模型
      final dataFormula = formulaWithDerived.toData(testYuanHuiYunShi);
      final dataGroup = dataFormula.groups.first;
      final dataBaseNumber =
          dataGroup.baseNumberDefinition as DataDerivedBaseNumber;

      // 6. 验证派生基础数的计算
      expect(dataBaseNumber.parentGroupId, equals("base_one"));
      expect(dataBaseNumber.calculationParts.length, equals(1));
      expect(
        dataBaseNumber.number,
        equals(testYuanHuiYunShi.dayZhiNumber),
      ); // 日支个位 = 9
    });

    test('选择式基础数的完整流程测试', () {
      // 1. 创建初始候选公式
      final timeGanUnits = SingleNumberPart(
        name: "时干个位",
        description: "时干太玄数的个位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.time,
        numberPlace: EnumNumberPlace.Units,
      );

      final initialFormula = DerivedBaseNumber(
        name: "初刻数公式",
        description: "用于计算初刻数",
        parentGroupId: "base_one",
        parts: [timeGanUnits],
      );

      // 2. 创建选择式基础数
      final selectableBaseNumber = SelectableBaseNumber(
        name: "选择式基础数",
        description: "通过初刻数±30确定",
        initialCandidateFormula: initialFormula,
      );

      // 3. 创建使用选择式基础数的计算组
      final selectableGroup = CalculationGroup(
        groupId: "selectable_group",
        description: "选择式组",
        baseNumberDefinition: selectableBaseNumber,
        formulas: [],
      );

      // 4. 创建包含选择式组的公式
      final formulaWithSelectable = HuangJiCalculationFormula(
        id: 3,
        name: "包含选择式基础数的公式",
        groups: [selectableGroup],
      );

      // 5. 转换为数据模型
      final dataFormula = formulaWithSelectable.toData(testYuanHuiYunShi);
      final dataGroup = dataFormula.groups.first;
      final dataBaseNumber =
          dataGroup.baseNumberDefinition as DataSelectableBaseNumber;

      // 6. 验证选择式基础数的计算
      expect(
        dataBaseNumber.initialCandidateNumber,
        equals(testYuanHuiYunShi.timeGanNumber),
      ); // 时干个位 = 7
      expect(
        dataBaseNumber.number,
        equals(testYuanHuiYunShi.timeGanNumber),
      ); // 默认使用初始候选数
    });

    test('与原有测试数据的兼容性验证', () {
      // 验证测试数据与原有测试的一致性
      expect(testEightChars.year, equals(JiaZi.YI_HAI));
      expect(testEightChars.month, equals(JiaZi.DING_HAI));
      expect(testEightChars.day, equals(JiaZi.REN_ZI));
      expect(testEightChars.time, equals(JiaZi.XIN_HAI));

      // 验证元会运世数值
      expect(testYuanHuiYunShi.yuanNumber, equals(12));
      expect(testYuanHuiYunShi.huiNumber, equals(10));
      expect(testYuanHuiYunShi.yunNumber, equals(15));
      expect(testYuanHuiYunShi.shiNumber, equals(11));

      // 验证干支数值
      expect(testYuanHuiYunShi.yearGanNumber, equals(8)); // 乙
      expect(testYuanHuiYunShi.yearZhiNumber, equals(4)); // 亥
      expect(testYuanHuiYunShi.monthGanNumber, equals(6)); // 丁
      expect(testYuanHuiYunShi.monthZhiNumber, equals(4)); // 亥
      expect(testYuanHuiYunShi.dayGanNumber, equals(6)); // 壬
      expect(testYuanHuiYunShi.dayZhiNumber, equals(9)); // 子
      expect(testYuanHuiYunShi.timeGanNumber, equals(7)); // 辛
      expect(testYuanHuiYunShi.timeZhiNumber, equals(4)); // 亥

      // 验证合并数值
      expect(testYuanHuiYunShi.yuanHuiMergeNumber.number, equals(1210));
      expect(testYuanHuiYunShi.yunShiMergeNumber.number, equals(5111));
    });
  });
}
