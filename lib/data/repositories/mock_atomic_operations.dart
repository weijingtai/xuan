import 'package:tiebanshenshu/algorithm/models/atomic_operation.dart';
import 'package:tiebanshenshu/algorithm/models/execution_context.dart';

// This file contains dummy implementations of AtomicOperations for UI prototyping.
// The execute methods are not implemented as they are not needed for the UI editor.

class GetFourPillarsAtom extends AtomicOperation {
  GetFourPillarsAtom()
      : super(
          id: 'get_four_pillars',
          name: '获取四柱',
          description: '将 BirthInfo 转换为 FourPillars 对象。',
          category: '输入与分解',
          version: '1.0.0',
        );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
        'birthInfo': ParameterDefinition(
          name: 'birthInfo',
          description: '出生信息',
          type: ParameterType.any,
          exampleValue: 'input.birthInfo',
        ),
      };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
        'fourPillars': ParameterDefinition(
          name: 'fourPillars',
          description: '四柱对象',
          type: ParameterType.any,
        ),
      };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(ExecutionContext context,
      Map<String, dynamic> inputs, Map<String, dynamic> config) {
    throw UnimplementedError("This is a mock implementation for UI prototyping.");
  }
}

class ConvertStemToNumberAtom extends AtomicOperation {
  ConvertStemToNumberAtom()
      : super(
          id: 'convert_stem_to_number',
          name: '干支化数',
          description: '将天干或地支按可配置的规则集转换为数值。',
          category: '核心转换',
          version: '1.0.0',
        );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
        'stem': ParameterDefinition(
          name: 'stem',
          description: '天干',
          type: ParameterType.str,
          exampleValue: 'intermediate.four_pillars_data.year.stem',
        ),
      };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
        'number': ParameterDefinition(
          name: 'number',
          description: '数值',
          type: ParameterType.intNum,
        ),
      };

  @override
  Map<String, ParameterDefinition> get configParameters => {
        'ruleSetId': ParameterDefinition(
          name: 'ruleSetId',
          description: '规则集ID',
          type: ParameterType.str,
          defaultValue: 'taixuan',
          exampleValue: 'taixuan',
        )
      };

  @override
  Future<Map<String, dynamic>> execute(ExecutionContext context,
      Map<String, dynamic> inputs, Map<String, dynamic> config) {
    throw UnimplementedError("This is a mock implementation for UI prototyping.");
  }
}

class BranchAtom extends AtomicOperation {
  BranchAtom()
      : super(
          id: 'branch',
          name: '逻辑分支 (IF/ELSE)',
          description: '根据条件执行不同分支。这是一个特殊的操作，它的作用是控制流程，而不是转换数据。',
          category: '流程控制',
          version: '1.0.0',
        );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
        'condition': ParameterDefinition(
          name: 'condition',
          description: '布尔条件',
          type: ParameterType.boolean,
          exampleValue: 'intermediate.is_yang_male',
          required: true,
        )
      };

  @override
  Map<String, ParameterDefinition> get outputParameters => {};

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(ExecutionContext context,
      Map<String, dynamic> inputs, Map<String, dynamic> config) {
    // This operation doesn't produce data, it directs flow.
    // The engine handles this logic. The atom itself does nothing.
    return Future.value({});
  }
}
