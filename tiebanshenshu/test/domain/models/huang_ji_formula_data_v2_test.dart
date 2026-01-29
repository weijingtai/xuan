import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_data_v2.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_v2.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';

void main() {
  // 使用与 huang_ji_strategy_test.dart 相同的测试数据
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

  group('皇极公式数据类 JSON 序列化测试', () {
    test('DataPredefinedBaseNumber JSON 序列化和反序列化', () {
      final dataPredefined = DataPredefinedBaseNumber(
        rawNumber: testYuanHuiYunShi.yuanHuiMergeNumber.number, // 1210
        name: "元会基础数",
        description: "来自元会的基础数",
        source: NumberSource.yuanHui,
      );

      // 测试 JSON 序列化
      final json = dataPredefined.toJson();
      expect(json['rawNumber'], equals(1210));
      expect(json['name'], equals("元会基础数"));
      expect(json['source'], equals('元会'));
      expect(json['type'], equals('predefined'));

      // 测试反序列化
      final restored = DataPredefinedBaseNumber.fromJson(json);
      expect(restored.number, equals(1210));
      expect(restored.name, equals("元会基础数"));
      expect(restored.source, equals(NumberSource.yuanHui));
      expect(restored.type, equals(BaseNumberDefinitionType.predefined));
    });

    test('DataSingleNumberPart JSON 序列化和反序列化', () {
      final dataSingle = DataSingleNumberPart(
        name: "年干千位",
        description: "年干太玄数的千位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.year,
        numberPlace: EnumNumberPlace.Thousands,
        raw: testYuanHuiYunShi.yearGanNumber, // 8
      );

      // 验证计算结果
      expect(dataSingle.rawNumber, equals(8000)); // 8 * 1000
      expect(dataSingle.raw, equals(8));

      // 测试 JSON 序列化
      final json = dataSingle.toJson();
      print(json);
      expect(json['name'], equals("年干千位"));
      expect(json['number'], equals(8000));
      expect(json['raw'], equals(8));
      expect(json['fourZhuGanZhiType'], equals('天干'));
      expect(json['type'], equals('singleNumber'));

      // 测试反序列化
      final restored = DataSingleNumberPart.fromJson(json);
      expect(restored.name, equals("年干千位"));
      expect(restored.rawNumber, equals(8000));
      expect(restored.raw, equals(8));
      expect(restored.fourZhuGanZhiType, equals(FourZhuGanZhiType.gan));
      expect(restored.fourZhuName, equals(FourZhuName.year));
      expect(restored.numberPlace, equals(EnumNumberPlace.Thousands));
    });

    test('DataCompositeNumberPart JSON 序列化和反序列化', () {
      // 创建组合数字部分：日干支合数（干在十位，支在个位）
      final dayGanTens = DataSingleNumberPart(
        name: "日干十位",
        description: "日干太玄数的十位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.day,
        numberPlace: EnumNumberPlace.Tens,
        raw: testYuanHuiYunShi.dayGanNumber, // 6
      );

      final dayZhiUnits = DataSingleNumberPart(
        name: "日支个位",
        description: "日支太玄数的个位",
        fourZhuGanZhiType: FourZhuGanZhiType.zhi,
        fourZhuName: FourZhuName.day,
        numberPlace: EnumNumberPlace.Units,
        raw: testYuanHuiYunShi.dayZhiNumber, // 9
      );

      final dataComposite = DataCompositeNumberPart(
        name: "日干支合数",
        description: "日干十位+日支个位",
        dataComponents: [dayGanTens, dayZhiUnits],
      );

      // 验证计算结果
      expect(dataComposite.rawNumber, equals(69)); // 60 + 9
      expect(dataComposite.dataComponents.length, equals(2));

      // 测试 JSON 序列化
      final json = dataComposite.toJson();
      expect(json['name'], equals("日干支合数"));
      expect(json['number'], equals(69));
      expect(json['dataComponents'], isA<List>());
      expect(json['type'], equals('compositeNumber'));

      // 测试反序列化
      final restored = DataCompositeNumberPart.fromJson(json);
      expect(restored.name, equals("日干支合数"));
      expect(restored.rawNumber, equals(69));
      expect(restored.dataComponents.length, equals(2));
      expect(restored.type, equals(CalculationPartType.compositeNumber));
    });

    test('DataDerivedBaseNumber JSON 序列化和反序列化', () {
      // 创建计算部分
      final monthGanHundreds = DataSingleNumberPart(
        name: "月干百位",
        description: "月干太玄数的百位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.month,
        numberPlace: EnumNumberPlace.Hundreds,
        raw: testYuanHuiYunShi.monthGanNumber, // 6
      );

      final dataDerived = DataDerivedBaseNumber(
        rawNumber: 600, // 月干百位的值
        name: "派生基础数",
        description: "从元会基础数派生",
        parentGroupId: "base_one",
        calculationParts: [monthGanHundreds],
        baseNumberDefinition: DataPredefinedBaseNumber(
          rawNumber: testYuanHuiYunShi.yuanHuiMergeNumber.number,
          name: "元会基础数",
          description: "元会基础数",
          source: NumberSource.yuanHui,
        ),
      );

      // 测试 JSON 序列化
      final json = dataDerived.toJson();
      expect(json['rawNumber'], equals(600));
      expect(json['name'], equals("派生基础数"));
      expect(json['parentGroupId'], equals("base_one"));
      expect(json['calculationParts'], isA<List>());
      expect(json['type'], equals('derived'));

      // 测试反序列化
      final restored = DataDerivedBaseNumber.fromJson(json);
      expect(restored.number, equals(600));
      expect(restored.name, equals("派生基础数"));
      expect(restored.parentGroupId, equals("base_one"));
      expect(restored.calculationParts.length, equals(1));
      expect(restored.type, equals(BaseNumberDefinitionType.derived));
    });

    test('DataSelectableBaseNumber JSON 序列化和反序列化', () {
      // 创建初始候选基础数
      final initialCandidate = DataPredefinedBaseNumber(
        rawNumber: testYuanHuiYunShi.timeGanNumber, // 7
        name: "初刻数",
        description: "时干太玄数",
        source: NumberSource.yunShi,
      );

      final dataSelectable = DataSelectableBaseNumber(
        rawNumber: 37, // 初刻数 + 30
        name: "选择式基础数",
        description: "通过初刻数±30确定",
        initialCandidate: initialCandidate,
        candidateValue: 37,
      );

      // 验证状态
      expect(dataSelectable.isCompleted, isTrue);
      expect(dataSelectable.number, equals(37));

      // 测试 JSON 序列化
      final json = dataSelectable.toJson();
      expect(json['rawNumber'], equals(37));
      expect(json['name'], equals("选择式基础数"));
      expect(json['candidateValue'], equals(37));
      expect(json['initialCandidate'], isA<Map>());
      expect(json['type'], equals('selectable'));

      // 测试反序列化
      final restored = DataSelectableBaseNumber.fromJson(json);
      expect(restored.number, equals(37));
      expect(restored.name, equals("选择式基础数"));
      expect(restored.candidateValue, equals(37));
      expect(restored.isCompleted, isTrue);
      expect(restored.type, equals(BaseNumberDefinitionType.selectable));
    });

    test('TiaoWenFormulaData JSON 序列化和反序列化', () {
      // 创建条文公式数据
      final yearGanThousands = DataSingleNumberPart(
        name: "年干千位",
        description: "年干太玄数的千位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.year,
        numberPlace: EnumNumberPlace.Thousands,
        raw: testYuanHuiYunShi.yearGanNumber, // 8
      );

      final monthGanHundreds = DataSingleNumberPart(
        name: "月干百位",
        description: "月干太玄数的百位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.month,
        numberPlace: EnumNumberPlace.Hundreds,
        raw: testYuanHuiYunShi.monthGanNumber, // 6
      );

      final tiaoWenData = TiaoWenFormulaData(
        name: "元会·条文一",
        description: "年干千位 + 月干百位",
        parts: [yearGanThousands, monthGanHundreds],
      );

      // 测试 JSON 序列化
      final json = tiaoWenData.toJson();
      expect(json['name'], equals("元会·条文一"));
      expect(json['parts'], isA<List>());
      expect((json['parts'] as List).length, equals(2));

      // 测试反序列化
      final restored = TiaoWenFormulaData.fromJson(json);
      expect(restored.name, equals("元会·条文一"));
      expect(restored.parts.length, equals(2));
    });

    test('DataCalculationGroup JSON 序列化和反序列化', () {
      // 创建基础数定义
      final baseNumberDef = DataPredefinedBaseNumber(
        rawNumber: testYuanHuiYunShi.yuanHuiMergeNumber.number, // 1210
        name: "元会基础数",
        description: "来自元会的基础数",
        source: NumberSource.yuanHui,
      );

      // 创建条文公式
      final yearGanThousands = DataSingleNumberPart(
        name: "年干千位",
        description: "年干太玄数的千位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.year,
        numberPlace: EnumNumberPlace.Thousands,
        raw: testYuanHuiYunShi.yearGanNumber, // 8
      );

      final tiaoWenData = TiaoWenFormulaData(
        name: "元会·条文一",
        description: "年干千位",
        parts: [yearGanThousands],
      );

      final dataGroup = DataCalculationGroup(
        groupId: "base_one",
        description: "围绕基础数一的计算",
        baseNumberDefinition: baseNumberDef,
        dataFormulas: [tiaoWenData],
      );

      // 测试 JSON 序列化
      final json = dataGroup.toJson();
      expect(json['groupId'], equals("base_one"));
      expect(json['description'], equals("围绕基础数一的计算"));
      expect(json['baseNumberDefinition'], isA<Map>());
      expect(json['dataFormulas'], isA<List>());

      // 测试反序列化
      final restored = DataCalculationGroup.fromJson(json);
      expect(restored.groupId, equals("base_one"));
      expect(restored.description, equals("围绕基础数一的计算"));
      expect(restored.baseNumberDefinition, isA<DataBaseNumberDefinition>());
      expect(restored.dataFormulas.length, equals(1));
    });

    test('HuangJiDataCalculationFormula JSON 序列化和反序列化', () {
      // 创建基础数定义
      final baseNumberDef = DataPredefinedBaseNumber(
        rawNumber: testYuanHuiYunShi.yuanHuiMergeNumber.number, // 1210
        name: "元会基础数",
        description: "来自元会的基础数",
        source: NumberSource.yuanHui,
      );

      // 创建条文公式
      final yearGanThousands = DataSingleNumberPart(
        name: "年干千位",
        description: "年干太玄数的千位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.year,
        numberPlace: EnumNumberPlace.Thousands,
        raw: testYuanHuiYunShi.yearGanNumber, // 8
      );

      final tiaoWenData = TiaoWenFormulaData(
        name: "元会·条文一",
        description: "年干千位",
        parts: [yearGanThousands],
      );

      final dataGroup = DataCalculationGroup(
        groupId: "base_one",
        description: "围绕基础数一的计算",
        baseNumberDefinition: baseNumberDef,
        dataFormulas: [tiaoWenData],
      );

      final dataFormula = HuangJiDataCalculationFormula(
        id: 1,
        name: "皇极取数法一",
        groups: [dataGroup],
      );

      // 测试 JSON 序列化
      final json = dataFormula.toJson();
      expect(json['id'], equals(1));
      expect(json['name'], equals("皇极取数法一"));
      expect(json['groups'], isA<List>());

      // 测试反序列化
      final restored = HuangJiDataCalculationFormula.fromJson(json);
      expect(restored.id, equals(1));
      expect(restored.name, equals("皇极取数法一"));
      expect(restored.groups.length, equals(1));
    });
  });

  group('数据转换验证测试', () {
    test('验证测试数据的正确性', () {
      // 验证八字数据
      expect(testEightChars.year, equals(JiaZi.YI_HAI));
      expect(testEightChars.month, equals(JiaZi.DING_HAI));
      expect(testEightChars.day, equals(JiaZi.REN_ZI));
      expect(testEightChars.time, equals(JiaZi.XIN_HAI));

      // 验证太玄数
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

      // 验证合并数值
      expect(testYuanHuiYunShi.yuanHuiMergeNumber.number, equals(1210));
      expect(testYuanHuiYunShi.yunShiMergeNumber.number, equals(5111));
    });

    test('从 V2 公式定义转换为数据类', () {
      // 创建 V2 公式定义
      final yuanHuiBaseNumber = PredefinedBaseNumber(
        name: "元会基础数",
        description: "来自元会的基础数",
        source: NumberSource.yuanHui,
      );

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

      final tiaoWenFormula = TiaoWenFormula(
        name: "元会·条文一",
        parts: [yearGanThousands, monthGanHundreds],
        description: "元会·条文一",
      );

      final calculationGroup = CalculationGroup(
        groupId: "base_one",
        description: "围绕基础数一的计算",
        baseNumberDefinition: yuanHuiBaseNumber,
        formulas: [tiaoWenFormula],
      );

      final formula = HuangJiCalculationFormula(
        id: 1,
        name: "皇极取数法一",
        description: "test: 来源《铁板神数预测学》中《皇极取数》",
        groups: [calculationGroup],
      );

      // 转换为数据类
      final dataFormula = formula.toData(testYuanHuiYunShi);

      // 验证转换结果
      expect(dataFormula.id, equals(1));
      expect(dataFormula.name, equals("皇极取数法一"));
      expect(dataFormula.groups.length, equals(1));

      final dataGroup = dataFormula.groups.first;
      expect(dataGroup.groupId, equals("base_one"));
      expect(dataGroup.baseNumberDefinition.number, equals(1210)); // 元会合并数
      expect(dataGroup.dataFormulas.length, equals(1));

      final dataTiaoWen = dataGroup.dataFormulas.first;
      expect(dataTiaoWen.name, equals("元会·条文一"));
      expect(dataTiaoWen.parts.length, equals(2));

      // 验证计算部分的数值
      final yearGanPart = dataTiaoWen.parts[0] as DataSingleNumberPart;
      expect(yearGanPart.rawNumber, equals(8000)); // 8 * 1000
      expect(yearGanPart.raw, equals(8));

      final monthGanPart = dataTiaoWen.parts[1] as DataSingleNumberPart;
      expect(monthGanPart.rawNumber, equals(600)); // 6 * 100
      expect(monthGanPart.raw, equals(6));
    });

    test('复杂公式的完整转换测试', () {
      // 创建运世基础数
      final yunShiBaseNumber = PredefinedBaseNumber(
        name: "运世基础数",
        description: "来自运世的基础数",
        source: NumberSource.yunShi,
      );

      // 创建日干支合数
      final dayGanTens = SingleNumberPart(
        name: "日干十位",
        description: "日干太玄数的十位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.day,
        numberPlace: EnumNumberPlace.Tens,
      );

      final dayZhiUnits = SingleNumberPart(
        name: "日支个位",
        description: "日支太玄数的个位",
        fourZhuGanZhiType: FourZhuGanZhiType.zhi,
        fourZhuName: FourZhuName.day,
        numberPlace: EnumNumberPlace.Units,
      );

      final dayGanZhiComposite = CompositeNumberPart(
        name: "日干支合数",
        description: "日干十位+日支个位",
        components: [dayGanTens, dayZhiUnits],
      );

      final timeGanUnits = SingleNumberPart(
        name: "时干个位",
        description: "时干太玄数的个位",
        fourZhuGanZhiType: FourZhuGanZhiType.gan,
        fourZhuName: FourZhuName.time,
        numberPlace: EnumNumberPlace.Units,
      );

      final complexFormula = TiaoWenFormula(
        name: "运世·条文一",
        parts: [dayGanZhiComposite, timeGanUnits],
        description: '运世·条文一',
      );

      final complexGroup = CalculationGroup(
        groupId: "base_two",
        description: "围绕基础数二的计算",
        baseNumberDefinition: yunShiBaseNumber,
        formulas: [complexFormula],
      );

      final complexCalculationFormula = HuangJiCalculationFormula(
        id: 2,
        name: "皇极取数法二",
        description: "test: 来源《铁板神数预测学》中《运世取数》",
        groups: [complexGroup],
      );

      // 转换为数据类
      final dataFormula = complexCalculationFormula.toData(testYuanHuiYunShi);

      // 验证转换结果
      expect(dataFormula.id, equals(2));
      expect(dataFormula.name, equals("皇极取数法二"));

      final dataGroup = dataFormula.groups.first;
      expect(dataGroup.baseNumberDefinition.number, equals(5111)); // 运世合并数

      final dataTiaoWen = dataGroup.dataFormulas.first;
      expect(dataTiaoWen.parts.length, equals(2));

      // 验证组合数字部分
      final compositeData = dataTiaoWen.parts[0] as DataCompositeNumberPart;
      expect(compositeData.name, equals("日干支合数"));
      expect(compositeData.rawNumber, equals(69)); // 60 + 9
      expect(compositeData.dataComponents.length, equals(2));

      // 验证时干个位
      final timeGanData = dataTiaoWen.parts[1] as DataSingleNumberPart;
      expect(timeGanData.name, equals("时干个位"));
      expect(timeGanData.rawNumber, equals(7)); // 7 * 1
      expect(timeGanData.raw, equals(7));
    });
  });
}
