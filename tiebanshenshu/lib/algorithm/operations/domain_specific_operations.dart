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

/// Wrapper class for domain-specific operations.
class DomainSpecificOperations {
  static List<AtomicOperation> getOperations() {
    return [
      GenerateNajiaAtom(),
      CalculateTaixuanSumsAtom(),
    ];
  }
}
