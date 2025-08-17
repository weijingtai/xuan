import 'package:tiebanshenshu/algorithm/models/atomic_operation.dart';
import 'package:tiebanshenshu/algorithm/models/execution_context.dart';

/// A new domain-specific operation to generate Najia stems and branches.
/// The actual logic is highly dependent on domain knowledge (e.g., SixYaoGua class)
/// and is left unimplemented for now.
class GenerateNajiaAtom extends AtomicOperation {
  GenerateNajiaAtom()
      : super(
          id: 'generate_najia',
          name: '生成纳甲',
          category: '领域专用',
          description: '根据重卦和阴阳属性，生成六爻纳甲干支列表。',
          version: 'v0.1',
        );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
        'hexagram': ParameterDefinition(
          name: 'hexagram',
          type: ParameterType.dict,
          required: true,
          description: '包含upper和lower卦的重卦对象',
        ),
        'isYang': ParameterDefinition(
          name: 'isYang',
          type: ParameterType.boolean,
          required: true,
          description: '用于决定纳甲规则的阴阳标志',
        ),
      };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
        'najia_list': ParameterDefinition(
          name: 'najia_list',
          type: ParameterType.array,
          required: true,
          description: '包含六个干支字符串的列表',
        ),
      };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> inputs,
    Map<String, dynamic> config,
  ) async {
    // The real implementation of this method would require the complex logic
    // from the original `SixYaoGua.generateFromGuaBySpecial` method.
    // As that logic is not available, we throw an error.
    // This definition is sufficient for building the JSON configuration flow.
    throw UnimplementedError(
        "The core logic for 'generate_najia' is domain-specific and has not been implemented.");
  }
}

/// A new domain-specific operation to calculate Taixuan sums for a list of Najia GanZhi.
/// This encapsulates complex logic: looping, splitting, mapping, summing, and filtering.
class CalculateTaixuanSumsAtom extends AtomicOperation {
  CalculateTaixuanSumsAtom()
      : super(
          id: 'calculate_taixuan_sums',
          name: '计算太玄数和',
          category: '领域专用',
          description: '计算六爻纳甲的太玄数和，并过滤掉和为10的结果。',
          version: 'v0.1',
        );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
        'najia_list': ParameterDefinition(
          name: 'najia_list',
          type: ParameterType.array,
          required: true,
          description: '六爻纳甲干支列表',
        ),
        'taixuan_map': ParameterDefinition(
          name: 'taixuan_map',
          type: ParameterType.dict,
          required: true,
          description: '太玄数映射规则',
        ),
      };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
        'taixuan_sums': ParameterDefinition(
          name: 'taixuan_sums',
          type: ParameterType.array,
          required: true,
          description: '经过计算和过滤的太玄数和列表',
        ),
      };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> inputs,
    Map<String, dynamic> config,
  ) async {
    throw UnimplementedError(
        "The core logic for 'calculate_taixuan_sums' is domain-specific and has not been implemented.");
  }
}

class GenerateFourGuaAtom extends AtomicOperation {
  GenerateFourGuaAtom()
      : super(
          id: 'generate_four_gua',
          name: '生成前四卦',
          category: '领域专用',
          description: '根据四柱、三元、性别和多种配置策略，生成基础的前四卦。',
          version: 'v0.1',
        );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
        'fourZhu': ParameterDefinition(name: 'fourZhu', type: ParameterType.any, required: true),
        'threeYuan': ParameterDefinition(name: 'threeYuan', type: ParameterType.str, required: true),
        'gender': ParameterDefinition(name: 'gender', type: ParameterType.str, required: true),
        'config': ParameterDefinition(name: 'config', type: ParameterType.dict, required: true, description: '包含所有计算策略的配置对象'),
      };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
        'basicGua': ParameterDefinition(name: 'basicGua', type: ParameterType.str, required: true),
        'basicNumber': ParameterDefinition(name: 'basicNumber', type: ParameterType.intNum, required: true),
        'variationBase': ParameterDefinition(name: 'variationBase', type: ParameterType.intNum, required: true),
        'fourGuaList': ParameterDefinition(name: 'fourGuaList', type: ParameterType.array, required: true),
      };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> inputs,
    Map<String, dynamic> config,
  ) async {
    throw UnimplementedError(
        "The core logic for 'generate_four_gua' is highly complex and has not been implemented.");
  }
}


/// Wrapper class for domain-specific operations.
class GetChangePositionsAtom extends AtomicOperation {
  GetChangePositionsAtom() : super(id: 'get_change_positions', name: '获取变爻位置', category: '领域专用', description: '根据余数获取需要变化的爻位置', version: 'v0.1');
  @override Map<String, ParameterDefinition> get inputParameters => {'remainder': ParameterDefinition(name: 'remainder', type: ParameterType.intNum, required: true)};
  @override Map<String, ParameterDefinition> get outputParameters => {'positions': ParameterDefinition(name: 'positions', type: ParameterType.array, required: true)};
  @override Map<String, ParameterDefinition> get configParameters => {};
  @override Future<Map<String, dynamic>> execute(ExecutionContext context, Map<String, dynamic> inputs, Map<String, dynamic> config) async => throw UnimplementedError();
}

class ApplyGuaExchangeTransformAtom extends AtomicOperation {
  ApplyGuaExchangeTransformAtom() : super(id: 'apply_gua_exchange_transform', name: '执行卦变换', category: '领域专用', description: '执行卦的变爻和上下交换', version: 'v0.1');
  @override Map<String, ParameterDefinition> get inputParameters => {'gua': ParameterDefinition(name: 'gua', type: ParameterType.str, required: true), 'positions': ParameterDefinition(name: 'positions', type: ParameterType.array, required: true)};
  @override Map<String, ParameterDefinition> get outputParameters => {'resultGua': ParameterDefinition(name: 'resultGua', type: ParameterType.str, required: true)};
  @override Map<String, ParameterDefinition> get configParameters => {};
  @override Future<Map<String, dynamic>> execute(ExecutionContext context, Map<String, dynamic> inputs, Map<String, dynamic> config) async => throw UnimplementedError();
}

class GetGuaThreeNumbersAtom extends AtomicOperation {
  GetGuaThreeNumbersAtom() : super(id: 'get_gua_three_numbers', name: '获取卦三数', category: '领域专用', description: '获取一个卦对应的天地人三数', version: 'v0.1');
  @override Map<String, ParameterDefinition> get inputParameters => {'gua': ParameterDefinition(name: 'gua', type: ParameterType.str, required: true)};
  @override Map<String, ParameterDefinition> get outputParameters => {'numbers': ParameterDefinition(name: 'numbers', type: ParameterType.dict, required: true)};
  @override Map<String, ParameterDefinition> get configParameters => {};
  @override Future<Map<String, dynamic>> execute(ExecutionContext context, Map<String, dynamic> inputs, Map<String, dynamic> config) async => throw UnimplementedError();
}

class CalculateTiaowenFromNumbersAtom extends AtomicOperation {
  CalculateTiaowenFromNumbersAtom() : super(id: 'calculate_tiaowen_from_numbers', name: '根据三数计算条文', category: '领域专用', description: '根据天地人三数计算条文列表', version: 'v0.1');
  @override Map<String, ParameterDefinition> get inputParameters => {'numbers': ParameterDefinition(name: 'numbers', type: ParameterType.dict, required: true)};
  @override Map<String, ParameterDefinition> get outputParameters => {'tiaowenList': ParameterDefinition(name: 'tiaowenList', type: ParameterType.array, required: true)};
  @override Map<String, ParameterDefinition> get configParameters => {};
  @override Future<Map<String, dynamic>> execute(ExecutionContext context, Map<String, dynamic> inputs, Map<String, dynamic> config) async => throw UnimplementedError();
}


/// Wrapper class for domain-specific operations.
class DomainSpecificOperations {
  static List<AtomicOperation> getOperations() {
    return [
      GenerateNajiaAtom(),
      CalculateTaixuanSumsAtom(),
      GenerateFourGuaAtom(),
      GetChangePositionsAtom(),
      ApplyGuaExchangeTransformAtom(),
      GetGuaThreeNumbersAtom(),
      CalculateTiaowenFromNumbersAtom(),
    ];
  }
}
