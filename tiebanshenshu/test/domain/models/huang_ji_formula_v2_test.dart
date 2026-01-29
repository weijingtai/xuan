import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_data_v2.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_v2.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';

void main() {
  late EightChars testEightChars;
  late YuanHuiYunShi testYuanHuiYunShi;

  setUp(() {
    testEightChars = EightChars(
      year: JiaZi.YI_HAI, // 乙亥
      month: JiaZi.DING_HAI, // 丁亥
      day: JiaZi.REN_ZI, // 壬子
      time: JiaZi.XIN_HAI, // 辛亥
    );
    testYuanHuiYunShi = YuanHuiYunShi.fromEightChars(testEightChars);
  });

  group('BaseNumberDefinition 多态 JSON 序列化测试', () {
    test('PredefinedBaseNumber JSON 序列化和反序列化', () {
      final predefined = PredefinedBaseNumber(
        name: "元会基础数",
        description: "来自元会的基础数",
        source: NumberSource.yuanHui,
      );

      // 测试 JSON 序列化
      final json = predefined.toJson();
      expect(json['name'], equals("元会基础数"));
      expect(json['source'], equals('元会'));
      // 测试多态反序列化
      final restored = PredefinedBaseNumber.fromJson(json);
      expect(restored, isA<BaseNumberDefinition>());
      expect(restored.type, equals(BaseNumberDefinitionType.predefined));
      expect(restored.name, equals("元会基础数"));
      expect(
        (restored as PredefinedBaseNumber).source,
        equals(NumberSource.yuanHui),
      );
    });

    test('DerivedBaseNumber JSON 序列化和反序列化', () {
      final singlePart = SingleNumberPart(
        name: "年干千位",
        description: "年干太玄数的千位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.year,
        numberPlace: EnumNumberPlace.Thousands,
      );

      final derived = DerivedBaseNumber(
        name: "派生基础数",
        description: "从元会基础数派生",
        parentGroupId: "base_one",
        parts: [singlePart],
        baseNumberDefinition: PredefinedBaseNumber(
          name: "元会基础数",
          description: "来自元会的基础数",
          source: NumberSource.yuanHui,
        ),
      );

      // 测试 JSON 序列化
      final json = derived.toJson();
      expect(json['name'], equals("派生基础数"));
      expect(json['parentGroupId'], equals("base_one"));
      print(json);

      // 测试多态反序列化
      final restored = DerivedBaseNumber.fromJson(json);
      expect(restored, isA<DerivedBaseNumber>());
      expect(restored.name, equals("派生基础数"));
      expect(restored.parentGroupId, equals("base_one"));
    });

    test('SelectableBaseNumber JSON 序列化和反序列化', () {
      final initialFormula = DerivedBaseNumber(
        name: "初刻数公式",
        description: "用于计算初刻数",
        parentGroupId: "base_one",
        parts: [],
        baseNumberDefinition: PredefinedBaseNumber(
          name: "元会基础数",
          description: "来自元会的基础数",
          source: NumberSource.yuanHui,
        ),
      );

      final selectable = SelectableBaseNumber(
        name: "选择式基础数",
        description: "通过初刻数±30确定",
        initialCandidateFormula: initialFormula,
      );

      // 测试 JSON 序列化
      final json = selectable.toJson();
      expect(json['name'], equals("选择式基础数"));
      expect(json['initialCandidateFormula'], isNotNull);

      // 测试多态反序列化
      final restored = SelectableBaseNumber.fromJson(json);
      // final res = restored as SelectableBaseNumber;
      expect(restored, isA<SelectableBaseNumber>());
      expect(restored.name, equals("选择式基础数"));
    });
  });

  group('CalculationPart 多态 JSON 序列化测试', () {
    test('SingleNumberPart JSON 序列化和反序列化', () {
      final singlePart = SingleNumberPart(
        name: "月干百位",
        description: "月干太玄数的百位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.month,
        numberPlace: EnumNumberPlace.Hundreds,
      );

      // 测试 JSON 序列化
      final json = singlePart.toJson();
      expect(json['name'], equals("月干百位"));
      expect(json['fourZhuGanZhiType'], equals('天干'));

      // 测试多态反序列化
      final restored = SingleNumberPart.fromJson(json);
      expect(restored, isA<SingleNumberPart>());
      expect(restored.name, equals("月干百位"));
      expect(
        (restored as SingleNumberPart).fourZhuGanZhiType,
        equals(FourZhuGanZhiType.gan),
      );
    });

    test('CompositeNumberPart JSON 序列化和反序列化', () {
      final component1 = SingleNumberPart(
        name: "日干十位",
        description: "日干太玄数的十位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.day,
        numberPlace: EnumNumberPlace.Tens,
      );

      final component2 = SingleNumberPart(
        name: "日支个位",
        description: "日支太玄数的个位",
        fourZhuGanZhiType: FourZhuGanZhiType.zhi,
        fourZhuName: FourZhuName.day,
        numberPlace: EnumNumberPlace.Units,
      );

      final composite = CompositeNumberPart(
        name: "日干支合数",
        description: "日干十位+日支个位",
        components: [component1, component2],
      );

      // 测试 JSON 序列化
      final json = composite.toJson();
      expect(json['name'], equals("日干支合数"));
      expect(json['components'], isA<List>());

      // 测试多态反序列化
      final restored = CompositeNumberPart.fromJson(json);
      expect(restored, isA<CompositeNumberPart>());
      expect(restored.name, equals("日干支合数"));
      expect((restored as CompositeNumberPart).components.length, equals(2));
    });
  });

  group('数据转换测试', () {
    test('PredefinedBaseNumber toData 转换', () {
      final predefined = PredefinedBaseNumber(
        name: "元会基础数",
        description: "来自元会的基础数",
        source: NumberSource.yuanHui,
      );

      final dataResult = predefined.toData(testYuanHuiYunShi);
      expect(dataResult.name, equals("元会基础数"));
      expect(dataResult.source, equals(NumberSource.yuanHui));
      expect(dataResult, isA<DataPredefinedBaseNumber>());
      expect(
        dataResult.number,
        equals(testYuanHuiYunShi.yuanHuiMergeNumber.number),
      );
    });

    test('SingleNumberPart toData 转换', () {
      final singlePart = SingleNumberPart(
        name: "年干千位",
        description: "年干太玄数的千位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.year,
        numberPlace: EnumNumberPlace.Thousands,
      );

      final dataResult = singlePart.toData(testYuanHuiYunShi);
      expect(dataResult.name, equals("年干千位"));
      expect(
        dataResult.rawNumber,
        equals(testYuanHuiYunShi.yearGanNumber * 1000),
      );
    });

    test('DerivedBaseNumber toData 转换', () {
      final singlePart = SingleNumberPart(
        name: "月干百位",
        description: "月干太玄数的百位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.month,
        numberPlace: EnumNumberPlace.Hundreds,
      );

      final derived = DerivedBaseNumber(
        name: "派生基础数",
        description: "从元会基础数派生",
        parentGroupId: "base_one",
        parts: [singlePart],
        baseNumberDefinition: PredefinedBaseNumber(
          name: "元会基础数",
          description: "来自元会的基础数",
          source: NumberSource.yuanHui,
        ),
      );

      final dataResult = derived.toData(testYuanHuiYunShi);
      expect(dataResult.name, equals("派生基础数"));
      expect(dataResult.parentGroupId, equals("base_one"));
      expect(dataResult.calculationParts.length, equals(1));
      expect(dataResult.number, equals(testYuanHuiYunShi.monthGanNumber * 100));
    });
  });

  group('完整计算流程测试', () {
    test('创建完整的 HuangJiCalculationFormula 并转换为数据', () {
      // 创建基础数定义
      final baseNumberDef = PredefinedBaseNumber(
        name: "元会基础数",
        description: "来自元会的基础数",
        source: NumberSource.yuanHui,
      );

      // 创建计算部分
      final yearGanPart = SingleNumberPart(
        name: "年干千位",
        description: "年干太玄数的千位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.year,
        numberPlace: EnumNumberPlace.Thousands,
      );

      final monthGanPart = SingleNumberPart(
        name: "月干百位",
        description: "月干太玄数的百位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.month,
        numberPlace: EnumNumberPlace.Hundreds,
      );

      // 创建条文公式
      final tiaoWenFormula = TiaoWenFormula(
        name: "条文一",
        parts: [yearGanPart, monthGanPart],
        description: "年干千位+月干百位",
      );

      // 创建计算组
      final calculationGroup = CalculationGroup(
        groupId: "group_one",
        description: "第一组计算",
        baseNumberDefinition: baseNumberDef,
        formulas: [tiaoWenFormula],
      );

      // 创建完整的计算公式
      final huangJiFormula = HuangJiCalculationFormula(
        id: 1,
        name: "皇极取数法测试",

        description: "test: 来源《铁板神数预测学》中《皇极取数》",
        groups: [calculationGroup],
      );

      // 转换为数据
      final dataFormula = huangJiFormula.toData(testYuanHuiYunShi);

      // 验证结果
      expect(dataFormula.id, equals(1));
      expect(dataFormula.name, equals("皇极取数法测试"));
      expect(dataFormula.groups.length, equals(1));

      final dataGroup = dataFormula.groups.first;
      expect(dataGroup.groupId, equals("group_one"));
      expect(dataGroup.baseNumberDefinition.name, equals("元会基础数"));
      expect(dataGroup.dataFormulas.length, equals(1));

      final dataTiaoWen = dataGroup.dataFormulas.first;
      expect(dataTiaoWen.name, equals("条文一"));
      expect(dataTiaoWen.parts.length, equals(2));
    });

    test('测试与原有测试数据的兼容性', () {
      // 使用与原测试相同的八字数据
      expect(testYuanHuiYunShi.yearGanNumber, equals(8)); // 乙
      expect(testYuanHuiYunShi.yearZhiNumber, equals(4)); // 亥
      expect(testYuanHuiYunShi.monthGanNumber, equals(6)); // 丁
      expect(testYuanHuiYunShi.monthZhiNumber, equals(4)); // 亥
      expect(testYuanHuiYunShi.dayGanNumber, equals(6)); // 壬
      expect(testYuanHuiYunShi.dayZhiNumber, equals(9)); // 子
      expect(testYuanHuiYunShi.timeGanNumber, equals(7)); // 辛
      expect(testYuanHuiYunShi.timeZhiNumber, equals(4)); // 亥

      // 验证元会运世数值
      expect(testYuanHuiYunShi.yuanNumber, equals(12));
      expect(testYuanHuiYunShi.huiNumber, equals(10));
      expect(testYuanHuiYunShi.yunNumber, equals(15));
      expect(testYuanHuiYunShi.shiNumber, equals(11));

      expect(testYuanHuiYunShi.yuanHuiMergeNumber.number, equals(1210));
      expect(testYuanHuiYunShi.yunShiMergeNumber.number, equals(5111));
    });
  });
}
