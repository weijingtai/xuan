import 'package:tiebanshenshu/domain/models/huang_ji_formula_data_v2.dart';
import 'package:common/enums.dart';
import 'package:tiebanshenshu/domain/models/huang_ji_number.dart';

void main() {
  print('=== 验证 DataBaseNumberDefinition rawNumber 修改 ===\n');

  // 测试 1: DataPredefinedBaseNumber 的 number getter
  print('测试 1: DataPredefinedBaseNumber number getter');

  // 测试 rawNumber <= 13000 的情况
  final predefined1 = DataPredefinedBaseNumber(
    rawNumber: 1210,
    name: "元会基础数",
    description: "来自元会的基础数",
    source: NumberSource.yuanHui,
  );
  print('rawNumber: ${predefined1.rawNumber}, number: ${predefined1.number}');
  assert(predefined1.number == 1210, 'rawNumber <= 13000 时应该返回原值');

  // 测试 rawNumber > 13000 的情况
  final predefined2 = DataPredefinedBaseNumber(
    rawNumber: 15000,
    name: "大数基础数",
    description: "测试大数处理",
    source: NumberSource.yuanHui,
  );
  print('rawNumber: ${predefined2.rawNumber}, number: ${predefined2.number}');
  assert(
    predefined2.number == 3000,
    'rawNumber > 13000 时应该返回 rawNumber - 12000',
  );

  // 测试 2: DataDerivedBaseNumber 的 number getter
  print('\n测试 2: DataDerivedBaseNumber number getter');

  final derived1 = DataDerivedBaseNumber(
    rawNumber: 8000,
    name: "派生基础数",
    description: "从元会基础数派生",
    parentGroupId: "base_one",
    calculationParts: [],
  );
  print('rawNumber: ${derived1.rawNumber}, number: ${derived1.number}');
  assert(derived1.number == 8000, 'rawNumber <= 13000 时应该返回原值');

  final derived2 = DataDerivedBaseNumber(
    rawNumber: 20000,
    name: "大数派生基础数",
    description: "测试大数派生",
    parentGroupId: "base_two",
    calculationParts: [],
  );
  print('rawNumber: ${derived2.rawNumber}, number: ${derived2.number}');
  assert(derived2.number == 8000, 'rawNumber > 13000 时应该返回 rawNumber - 12000');

  // 测试 3: DataSelectableBaseNumber 的 number getter
  print('\n测试 3: DataSelectableBaseNumber number getter');

  final initialCandidate = DataPredefinedBaseNumber(
    rawNumber: 7,
    name: "初刻数",
    description: "时干太玄数",
    source: NumberSource.yunShi,
  );

  // 测试没有候选值的情况
  final selectable1 = DataSelectableBaseNumber(
    rawNumber: 37,
    name: "选择式基础数",
    description: "通过初刻数±30确定",
    initialCandidate: initialCandidate,
    candidateValue: null,
  );
  print(
    '无候选值 - rawNumber: ${selectable1.rawNumber}, number: ${selectable1.number}',
  );
  assert(selectable1.number == 7, '无候选值时应该返回 initialCandidate.number');

  // 测试有候选值且 <= 13000 的情况
  final selectable2 = DataSelectableBaseNumber(
    rawNumber: 37,
    name: "选择式基础数",
    description: "通过初刻数±30确定",
    initialCandidate: initialCandidate,
    candidateValue: 5000,
  );
  print(
    '有候选值 <= 13000 - candidateValue: ${selectable2.candidateValue}, number: ${selectable2.number}',
  );
  assert(selectable2.number == 5000, '候选值 <= 13000 时应该返回候选值');

  // 测试有候选值且 > 13000 的情况
  final selectable3 = DataSelectableBaseNumber(
    rawNumber: 37,
    name: "选择式基础数",
    description: "通过初刻数±30确定",
    initialCandidate: initialCandidate,
    candidateValue: 18000,
  );
  print(
    '有候选值 > 13000 - candidateValue: ${selectable3.candidateValue}, number: ${selectable3.number}',
  );
  assert(
    selectable3.number == 6000,
    '候选值 > 13000 时应该返回 candidateValue - 12000',
  );

  // 测试 4: JSON 序列化
  print('\n测试 4: JSON 序列化');

  final testPredefined = DataPredefinedBaseNumber(
    rawNumber: 15500,
    name: "测试序列化",
    description: "测试 JSON 序列化",
    source: NumberSource.yuanHui,
  );

  final json = testPredefined.toJson();
  print('JSON 序列化结果: $json');
  print('rawNumber 在 JSON 中: ${json['rawNumber']}');
  print('number getter 值: ${testPredefined.number}');

  assert(json.containsKey('rawNumber'), 'JSON 应该包含 rawNumber 字段');
  assert(testPredefined.number == 3500, '大数应该正确处理');

  print('\n=== 所有测试通过！rawNumber 修改成功 ===');
}
