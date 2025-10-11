import 'dart:convert';
import 'dart:io';

import 'package:common/enums.dart';
import 'package:common/models/eight_chars.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_data_v2.dart';
import 'package:tiebanshenshu/features/huang_ji/huang_ji_formula_v2.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';
import 'package:tiebanshenshu/domain/models/yuan_hui_yun_shi.dart';

Future<void> main() async {
  // 使用与 huang_ji_strategy_test.dart 相同的测试数据
  late EightChars testEightChars = EightChars(
    year: JiaZi.GUI_SI, // 癸巳
    month: JiaZi.JIA_ZI, // 甲子
    day: JiaZi.DING_YOU, // 丁酉
    time: JiaZi.GUI_MAO, // 癸卯
  );
  final YuanHuiYunShi testYuanHuiYunShi = YuanHuiYunShi.fromEightChars(
    testEightChars,
  );

  // 从 test/domain/models 中读取 first_yuanhui.json 与 first_yunshi.json
  final String firstYuanHuiJson = await File(
    'test/domain/models/first_yuanhui.json',
  ).readAsString();
  final CalculationGroup firstYuanHuiTiaoWenFormula = CalculationGroup.fromJson(
    json.decode(firstYuanHuiJson),
  );
  final String firstYunShiJson = await File(
    'test/domain/models/first_yunshi.json',
  ).readAsString();

  final CalculationGroup firstYunShiTiaoWenFormula = CalculationGroup.fromJson(
    json.decode(firstYunShiJson),
  );

  final String huangji2Json = await File(
    'test/domain/models/huang_ji_2.json',
  ).readAsString();
  final HuangJiCalculationFormula huangji2TiaoWenFormula =
      HuangJiCalculationFormula.fromJson(json.decode(huangji2Json));

  final String huangji3Json = await File(
    'test/domain/models/huang_ji_3.json',
  ).readAsString();
  final HuangJiCalculationFormula huangji3TiaoWenFormula =
      HuangJiCalculationFormula.fromJson(json.decode(huangji3Json));

  group('《铁板神数预测学》皇极  ', () {
    test('元会·基础数一', () {
      final formulaGroup = firstYuanHuiTiaoWenFormula.toData(testYuanHuiYunShi);
      int baseNumber = formulaGroup.baseNumberDefinition.number;
      expect(formulaGroup.baseNumberDefinition.number, equals(2018));
      expect(formulaGroup.baseNumberDefinition.rawNumber, equals(14018));
      expect(testYuanHuiYunShi.yuanHuiMergeNumber.number, equals(9018));
      // expect(testYuanHuiYunShi.yearGanNumber, equals(5));
      // expect(
      //   testYuanHuiYunShi.yuanHuiMergeNumber.number +
      //       testYuanHuiYunShi.yearGanNumber * 1000,
      //   equals(14018),
      // );
      // expect(formulaGroup.baseNumberDefinition.number, equals(2018));
      // expect(baseNumber, equals(14018));
      // baseNumber = HuangJiBaseNumber.checkToTiaoWenNumber(baseNumber);
      expect(baseNumber, equals(2018));
      final int tiaoWen1 = formulaGroup.dataFormulas[0].number + baseNumber;
      expect(tiaoWen1, equals(6018));
      final int tiaoWen2 = formulaGroup.dataFormulas[1].number + baseNumber;
      expect(tiaoWen2, equals(2918));
      final int tiaoWen3 = formulaGroup.dataFormulas[2].number + baseNumber;
      expect(tiaoWen3, equals(2918));
      final int tiaoWen4 = formulaGroup.dataFormulas[3].number + baseNumber;
      expect(
        formulaGroup.dataFormulas[3].number,
        equals(66),
        reason: formulaGroup.dataFormulas[3].name,
      );
      expect(
        tiaoWen4,
        equals(2018 + 66),
        reason: formulaGroup.dataFormulas[3].name,
      );
      final int tiaoWen5 = formulaGroup.dataFormulas[4].number + baseNumber;
      expect(tiaoWen5, equals(2023), reason: formulaGroup.dataFormulas[4].name);
      final int tiaoWen6 = formulaGroup.dataFormulas[5].number + baseNumber;
      expect(tiaoWen6, equals(2024), reason: formulaGroup.dataFormulas[5].name);
      final int tiaoWen7 = formulaGroup.dataFormulas[6].number + baseNumber;
      expect(
        tiaoWen7,
        equals(2018 + 66 + 6),
        reason: formulaGroup.dataFormulas[6].name,
      );
      final int tiaoWen8 = formulaGroup.dataFormulas[7].number + baseNumber;
      expect(
        tiaoWen8,
        equals(2018 + 66 + 5),
        reason: formulaGroup.dataFormulas[7].name,
      );

      // final dataPredefined = formulaGroup.parts.first as DataPredefinedBaseNumber;

      // // 测试 JSON 序列化
      // final json = dataPredefined.toJson();
      // expect(json['rawNumber'], equals(1210));
      // expect(json['name'], equals("元会基础数"));
      // expect(json['source'], equals('元会'));
      // expect(json['type'], equals('predefined'));

      // 测试反序列化
      // final restored = DataPredefinedBaseNumber.fromJson(json);
      // expect(restored.number, equals(1210));
      // expect(restored.name, equals("元会基础数"));
      // expect(restored.source, equals(NumberSource.yuanHui));
      // expect(restored.type, equals(BaseNumberDefinitionType.predefined));
    });
    test("运世", () {
      final formulaGroup = firstYunShiTiaoWenFormula.toData(testYuanHuiYunShi);
      int baseNumber = testYuanHuiYunShi.yunShiMergeNumber.number;
      expect(testYuanHuiYunShi.yunShiMergeNumber.number, equals(2111));
      expect(baseNumber, equals(2111));
      baseNumber = HuangJiBaseNumber.checkToTiaoWenNumber(baseNumber);
      expect(baseNumber, equals(2111));

      final int tiaoWen1 = formulaGroup.dataFormulas[0].number + baseNumber;
      expect(
        tiaoWen1,
        equals(2111 + 66),
        reason: formulaGroup.dataFormulas[0].name,
      );
      final int tiaoWen2 = formulaGroup.dataFormulas[1].number + baseNumber;
      expect(
        tiaoWen2,
        equals(2111 + 5),
        reason: formulaGroup.dataFormulas[1].name,
      );
      final int tiaoWen3 = formulaGroup.dataFormulas[2].number + baseNumber;
      expect(
        tiaoWen3,
        equals(2111 + 6),
        reason: formulaGroup.dataFormulas[2].name,
      );
      final int tiaoWen4 = formulaGroup.dataFormulas[3].number + baseNumber;
      expect(
        tiaoWen4,
        equals(2111 + 66 + 5),
        reason: formulaGroup.dataFormulas[3].name,
      );
      final int tiaoWen5 = formulaGroup.dataFormulas[4].number + baseNumber;
      expect(
        tiaoWen5,
        equals(2111 + 66 + 6),
        reason: formulaGroup.dataFormulas[4].name,
      );
    });
  });

  group("《图解易经象数学铁板神数》", () {
    final tEC = EightChars(
      year: JiaZi.YI_HAI,
      month: JiaZi.DING_HAI,
      day: JiaZi.REN_ZI,
      time: JiaZi.XIN_HAI,
    );
    final yhys = YuanHuiYunShi.fromEightChars(tEC);
    test("元会运世基础数", () {
      expect(yhys.yuanHuiMergeNumber.number, equals(1210));
      expect(yhys.yunShiMergeNumber.number, equals(5111));
    });

    test("元会运世法（一） 元会", () {
      final formulaGroup = huangji2TiaoWenFormula.toData(yhys).groups;

      final int baseNumber = formulaGroup[0].baseNumberDefinition.number;
      expect(baseNumber, equals(9210));

      final tiaoWen1 = formulaGroup[0].dataFormulas[0].number + baseNumber;
      expect(
        tiaoWen1,
        equals(9210 + 600),
        reason: formulaGroup[0].dataFormulas[0].name,
      );

      final tiaoWen2 = formulaGroup[0].dataFormulas[1].number + baseNumber;
      expect(
        tiaoWen2,
        equals(9210 + 60),
        reason: formulaGroup[0].dataFormulas[1].name,
      );

      final tiaoWen3 = formulaGroup[0].dataFormulas[2].number + baseNumber;
      expect(
        tiaoWen3,
        equals(9210 + 7),
        reason: formulaGroup[0].dataFormulas[2].name,
      );

      final tiaoWen4 = formulaGroup[0].dataFormulas[3].number + baseNumber;
      expect(
        tiaoWen4,
        equals(9210 + 6),
        reason: formulaGroup[0].dataFormulas[3].name,
      );
    });

    test("元会运世法（一） 运世", () {
      final formulaGroup = huangji2TiaoWenFormula.toData(yhys).groups;

      final int baseNumber = formulaGroup[1].baseNumberDefinition.number;
      expect(formulaGroup[1].baseNumberDefinition.rawNumber, equals(13111));
      expect(baseNumber, equals(1111));

      final tiaoWen1 = formulaGroup[1].dataFormulas[0].number + baseNumber;
      expect(
        tiaoWen1,
        equals(1111 + 600),
        reason: formulaGroup[1].dataFormulas[0].name,
      );

      final tiaoWen2 = formulaGroup[1].dataFormulas[1].number + baseNumber;
      expect(
        tiaoWen2,
        equals(1111 + 60),
        reason: formulaGroup[1].dataFormulas[1].name,
      );

      final tiaoWen3 = formulaGroup[1].dataFormulas[2].number + baseNumber;
      expect(
        tiaoWen3,
        equals(1111 + 7),
        reason: formulaGroup[1].dataFormulas[2].name,
      );

      final tiaoWen4 = formulaGroup[0].dataFormulas[3].number + baseNumber;
      expect(
        tiaoWen4,
        equals(1111 + 6),
        reason: formulaGroup[1].dataFormulas[3].name,
      );
    });

    test("元会运世法（二）元会", () {
      final formulaGroup = huangji3TiaoWenFormula.toData(yhys).groups;

      int baseNumber = formulaGroup[0].baseNumberDefinition.number;
      // expect(formulaGroup[0].baseNumberDefinition.rawNumber, equals(9210));
      expect(baseNumber, equals(9210));
      final tiaoWen1 = formulaGroup[0].dataFormulas[0].number + baseNumber;
      expect(
        tiaoWen1,
        equals(9210 + 600),
        reason: formulaGroup[0].dataFormulas[0].name,
      );

      final tiaoWen2 = formulaGroup[0].dataFormulas[1].number + baseNumber;
      expect(
        tiaoWen2,
        equals(9210 + 400),
        reason: formulaGroup[0].dataFormulas[1].name,
      );
      baseNumber = formulaGroup[1].baseNumberDefinition.number;
      expect(baseNumber, equals(9279));
      final tiaoWen3 = formulaGroup[1].dataFormulas[0].number + baseNumber;
      expect(
        tiaoWen3,
        equals(9279 + 7),
        reason: formulaGroup[1].dataFormulas[0].name,
      );
      final tiaoWen4 = formulaGroup[1].dataFormulas[1].number + baseNumber;
      expect(
        tiaoWen4,
        equals(9279 + 4),
        reason: formulaGroup[1].dataFormulas[1].name,
      );
    });

    test("元会运世法（二）运世", () {
      final formulaGroup = huangji3TiaoWenFormula.toData(yhys).groups;

      int baseNumber = formulaGroup[2].baseNumberDefinition.number;
      // expect(formulaGroup[0].baseNumberDefinition.rawNumber, equals(9210));
      expect(baseNumber, equals(1111));
      final tiaoWen1 = formulaGroup[2].dataFormulas[0].number + baseNumber;
      expect(
        tiaoWen1,
        equals(1111 + 600),
        reason: formulaGroup[2].dataFormulas[0].name,
      );

      final tiaoWen2 = formulaGroup[2].dataFormulas[1].number + baseNumber;
      expect(
        tiaoWen2,
        equals(1111 + 400),
        reason: formulaGroup[2].dataFormulas[1].name,
      );
      baseNumber = formulaGroup[3].baseNumberDefinition.number;
      expect(baseNumber, equals(1180));
      final tiaoWen3 = formulaGroup[3].dataFormulas[0].number + baseNumber;
      expect(
        tiaoWen3,
        equals(1180 + 7),
        reason: formulaGroup[3].dataFormulas[0].name,
      );
      final tiaoWen4 = formulaGroup[3].dataFormulas[1].number + baseNumber;
      expect(
        tiaoWen4,
        equals(1180 + 4),
        reason: formulaGroup[3].dataFormulas[1].name,
      );
    });
  });
}
