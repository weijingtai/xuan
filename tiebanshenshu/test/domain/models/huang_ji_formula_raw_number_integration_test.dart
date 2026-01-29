import 'dart:convert';
import 'dart:io';
import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_v2.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_data_v2.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';

void main() {
  late List<HuangJiCalculationFormula> formulas;
  late EightChars testEightChars;
  late YuanHuiYunShi testYuanHuiYunShi;

  setUpAll(() async {
    // 加载 JSON 文件
    final file = File('test/assets/formula/huang_ji_formula.json');
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = json.decode(jsonString);

    formulas = jsonList
        .map((json) => HuangJiCalculationFormula.fromJson(json))
        .toList();

    // 设置测试用的八字数据
    testEightChars = EightChars(
      year: JiaZi.YI_HAI, // 乙亥
      month: JiaZi.DING_HAI, // 丁亥
      day: JiaZi.REN_ZI, // 壬子
      time: JiaZi.XIN_HAI, // 辛亥
    );
    testYuanHuiYunShi = YuanHuiYunShi.fromEightChars(testYuanHuiYunShi);
  });

  group('rawNumber 功能与 JSON 公式集成测试', () {
    test('从 JSON 加载的公式应该正确处理 rawNumber', () {
      final formula = formulas.first;
      final yuanHuiGroup = formula.groups.firstWhere(
        (g) => g.groupId == 'yuanHuiBase',
      );

      final predefinedBase =
          yuanHuiGroup.baseNumberDefinition as PredefinedBaseNumber;
      final dataBase = predefinedBase.toData(testYuanHuiYunShi);

      // 验证 rawNumber 存储原始值
      expect(
        dataBase.rawNumber,
        equals(testYuanHuiYunShi.yuanHuiMergeNumber.number),
      );

      // 验证 number getter 的逻辑
      if (dataBase.rawNumber > 13000) {
        expect(dataBase.number, equals(dataBase.rawNumber - 12000));
      } else {
        expect(dataBase.number, equals(dataBase.rawNumber));
      }
    });

    test('大数值计算应该正确应用 rawNumber 逻辑', () {
      final formula = formulas.first;
      final baseOneGroup = formula.groups.firstWhere(
        (g) => g.groupId == 'base_one',
      );

      // 创建一个会产生大数值的测试场景
      final testLargeEightChars = EightChars(
        year: JiaZi.GUI_YOU, // 癸酉 (10)
        month: JiaZi.GUI_YOU, // 癸酉 (10)
        day: JiaZi.GUI_YOU, // 癸酉 (10)
        time: JiaZi.GUI_YOU, // 癸酉 (10)
      );
      final testLargeYuanHuiYunShi = YuanHuiYunShi.fromEightChars(
        testLargeEightChars,
      );

      // 测试条文公式计算
      final firstFormula = baseOneGroup.formulas.first; // 加月干百位数
      final dataFormula = firstFormula.toData(testLargeYuanHuiYunShi);

      final monthGanData = dataFormula.parts.first;
      final expectedRawValue = testLargeYuanHuiYunShi.monthGanNumber * 100;

      // 验证 rawNumber 和 number 的关系
      if (expectedRawValue > 13000) {
        expect(monthGanData.rawNumber, equals(expectedRawValue - 12000));
      } else {
        expect(monthGanData.rawNumber, equals(expectedRawValue));
      }
    });

    test('复合数字计算的 rawNumber 处理', () {
      final formula = formulas.first;
      final baseOneGroup = formula.groups.firstWhere(
        (g) => g.groupId == 'base_one',
      );

      // 测试月干支互数
      final compositeFormula = baseOneGroup.formulas.firstWhere(
        (f) => f.name == '加月干支互数',
      );
      final dataFormula = compositeFormula.toData(testYuanHuiYunShi);

      final compositeData = dataFormula.parts.first;
      final expectedRawValue =
          testYuanHuiYunShi.monthGanNumber * 10 +
          testYuanHuiYunShi.monthZhiNumber;

      // 验证复合数字也遵循 rawNumber 逻辑
      if (expectedRawValue > 13000) {
        expect(compositeData.rawNumber, equals(expectedRawValue - 12000));
      } else {
        expect(compositeData.rawNumber, equals(expectedRawValue));
      }
    });

    test('选择式基础数的 rawNumber 处理', () {
      final formula = formulas.first;
      final baseOneGroup = formula.groups.firstWhere(
        (g) => g.groupId == 'base_one',
      );

      final selectableBase =
          baseOneGroup.baseNumberDefinition as SelectableBaseNumber;
      final dataSelectableBase = selectableBase.toData(testYuanHuiYunShi);

      // 验证初始候选值的 rawNumber 处理
      expect(
        dataSelectableBase.initialCandidate,
        isA<DataBaseNumberDefinition>(),
      );

      final initialCandidate = dataSelectableBase.initialCandidate;
      if (initialCandidate.rawNumber > 13000) {
        expect(
          initialCandidate.number,
          equals(initialCandidate.rawNumber - 12000),
        );
      } else {
        expect(initialCandidate.number, equals(initialCandidate.rawNumber));
      }

      // 验证选择式基础数本身的 number getter
      final finalNumber = dataSelectableBase.number;
      expect(finalNumber, isA<int>());
    });

    test('完整计算流程的 rawNumber 一致性', () {
      final formula = formulas.first;

      // 执行完整的计算流程
      final dataFormula = formula.toData(testYuanHuiYunShi);

      // 验证所有基础数定义都正确处理了 rawNumber
      for (final group in dataFormula.groups) {
        final baseNumberDef = group.baseNumberDefinition;

        // 验证 rawNumber 和 number 的一致性
        if (baseNumberDef.rawNumber > 13000) {
          expect(baseNumberDef.number, equals(baseNumberDef.rawNumber - 12000));
        } else {
          expect(baseNumberDef.number, equals(baseNumberDef.rawNumber));
        }

        // 验证所有条文公式的计算部分
        for (final dataFormulaItem in group.dataFormulas) {
          for (final part in dataFormulaItem.parts) {
            // 每个计算部分都应该有正确的 number 值
            expect(part.rawNumber, isA<int>());
            expect(part.rawNumber, greaterThanOrEqualTo(0));
            expect(part.rawNumber, lessThanOrEqualTo(13000)); // 确保不超过上限
          }
        }
      }
    });

    test('JSON 序列化应该包含 rawNumber 字段', () {
      final formula = formulas.first;
      final dataFormula = formula.toData(testYuanHuiYunShi);

      // 序列化为 JSON
      final json = dataFormula.toJson();

      // 验证 JSON 结构
      expect(json, isA<Map<String, dynamic>>());
      expect(json['groups'], isA<List>());

      // 检查第一个组的基础数定义
      final firstGroupJson = json['groups'][0] as Map<String, dynamic>;
      final baseNumberDefJson =
          firstGroupJson['baseNumberDefinition'] as Map<String, dynamic>;

      // 验证 rawNumber 字段存在
      expect(baseNumberDefJson.containsKey('rawNumber'), isTrue);
      expect(baseNumberDefJson['rawNumber'], isA<int>());

      // 验证可以正确反序列化
      final restoredDataFormula = HuangJiDataCalculationFormula.fromJson(json);
      final restoredBaseNumberDef =
          restoredDataFormula.groups.first.baseNumberDefinition;

      expect(
        restoredBaseNumberDef.rawNumber,
        equals(baseNumberDefJson['rawNumber']),
      );
    });
  });

  group('边界值测试', () {
    test('rawNumber 等于 13000 的边界情况', () {
      // 创建一个 rawNumber 正好等于 13000 的测试数据
      final testData = DataPredefinedBaseNumber(
        rawNumber: 13000,
        name: "边界测试",
        description: "测试 rawNumber = 13000 的情况",
        source: NumberSource.yuanHui,
      );

      // 应该返回原值，因为条件是 > 13000
      expect(testData.number, equals(13000));
    });

    test('rawNumber 等于 13001 的边界情况', () {
      final testData = DataPredefinedBaseNumber(
        rawNumber: 13001,
        name: "边界测试",
        description: "测试 rawNumber = 13001 的情况",
        source: NumberSource.yuanHui,
      );

      // 应该减去 12000
      expect(testData.number, equals(1001));
    });

    test('极大数值的处理', () {
      final testData = DataPredefinedBaseNumber(
        rawNumber: 25000,
        name: "极大数值测试",
        description: "测试极大 rawNumber 的情况",
        source: NumberSource.yuanHui,
      );

      expect(testData.number, equals(13000)); // 25000 - 12000 = 13000
    });
  });
}
