import 'package:tiebanshenshu/algorithm/models/atomic_operation.dart';
import 'package:tiebanshenshu/algorithm/models/execution_context.dart';
import 'package:tiebanshenshu/domain/six_yao_gua.dart';

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
    final hexagram = inputs['hexagram'] as Map<String, dynamic>?;
    final isYang = inputs['isYang'] as bool? ?? true;

    if (hexagram == null || hexagram['upper'] == null || hexagram['lower'] == null) {
      throw ArgumentError("Input 'hexagram' must be a map with 'upper' and 'lower' keys.");
    }

    final guaName = "${hexagram['upper']}${hexagram['lower']}";

    // Replicate the logic of getEachYaoGan from the original service
    List<String> Function(String) createSpecialGanFunc(bool isYangYear) {
      return (String guaName) {
        List<String> getGanList(String gua) {
          if (isYangYear) {
            return {
              "乾": ["壬", "壬", "壬"], "兑": ["丁", "丁", "丁"], "离": ["己", "己", "己"],
              "震": ["庚", "庚", "庚"], "巽": ["辛", "辛", "辛"], "坎": ["戊", "戊", "戊"],
              "艮": ["丙", "丙", "丙"], "坤": ["癸", "癸", "癸"],
            }[gua]!;
          } else { // 阴年
            return {
              "乾": ["甲", "甲", "甲"], "兑": ["丁", "丁", "丁"], "离": ["己", "己", "己"],
              "震": ["庚", "庚", "庚"], "巽": ["辛", "辛", "辛"], "坎": ["戊", "戊", "戊"],
              "艮": ["丙", "丙", "丙"], "坤": ["乙", "乙", "乙"],
            }[gua]!;
          }
        }
        final upperGuaGanList = getGanList(guaName[0]);
        final lowerGuaGanList = getGanList(guaName[guaName.length - 1]);
        return [...upperGuaGanList, ...lowerGuaGanList];
      };
    }

    final specialGanFunc = createSpecialGanFunc(isYang);

    final sixYaoGua = SixYaoGua.generateFromGuaBySpecial(guaName, specialGanFunc);

    return {
      'najia_list': sixYaoGua.ganzhiList,
    };
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
class GuaToGanzhiAtom extends AtomicOperation {
  GuaToGanzhiAtom() : super(id: 'gua_to_ganzhi', name: '卦转干支', category: '领域专用', description: '将卦象根据阴阳属性转换为对应的天干和地支', version: 'v0.1');
  @override Map<String, ParameterDefinition> get inputParameters => {'gua': ParameterDefinition(name: 'gua', type: ParameterType.str, required: true), 'isYang': ParameterDefinition(name: 'isYang', type: ParameterType.boolean, required: true)};
  @override Map<String, ParameterDefinition> get outputParameters => {'gan': ParameterDefinition(name: 'gan', type: ParameterType.str, required: true), 'zhi': ParameterDefinition(name: 'zhi', type: ParameterType.str, required: true)};
  @override Map<String, ParameterDefinition> get configParameters => {};
  @override Future<Map<String, dynamic>> execute(ExecutionContext context, Map<String, dynamic> inputs, Map<String, dynamic> config) async => throw UnimplementedError();
}

class CalculateFourDoorsTiaowenAtom extends AtomicOperation {
  CalculateFourDoorsTiaowenAtom() : super(id: 'calculate_four_doors_tiaowen', name: '计算四门条文', category: '领域专用', description: '执行四门法最终的条文计算', version: 'v0.1');
  @override Map<String, ParameterDefinition> get inputParameters => {'xiantianNumbers': ParameterDefinition(name: 'xiantianNumbers', type: ParameterType.array, required: true), 'secretNumbers': ParameterDefinition(name: 'secretNumbers', type: ParameterType.array, required: true)};
  @override Map<String, ParameterDefinition> get outputParameters => {'tiaowenList': ParameterDefinition(name: 'tiaowenList', type: ParameterType.array, required: true)};
  @override Map<String, ParameterDefinition> get configParameters => {};
  @override Future<Map<String, dynamic>> execute(ExecutionContext context, Map<String, dynamic> inputs, Map<String, dynamic> config) async => throw UnimplementedError();
}

class CalculateYuanhuiNumberAtom extends AtomicOperation {
  CalculateYuanhuiNumberAtom() : super(id: 'calculate_yuanhui_number', name: '计算元会数', category: '领域专用', description: '根据四柱计算元会基本数', version: 'v0.1');
  @override Map<String, ParameterDefinition> get inputParameters => {'fourZhu': ParameterDefinition(name: 'fourZhu', type: ParameterType.any, required: true)};
  @override Map<String, ParameterDefinition> get outputParameters => {'yuanhuiNumber': ParameterDefinition(name: 'yuanhuiNumber', type: ParameterType.intNum, required: true)};
  @override Map<String, ParameterDefinition> get configParameters => {};
  @override Future<Map<String, dynamic>> execute(ExecutionContext context, Map<String, dynamic> inputs, Map<String, dynamic> config) async => throw UnimplementedError();
}

class CalculateYunshiNumberAtom extends AtomicOperation {
  CalculateYunshiNumberAtom() : super(id: 'calculate_yunshi_number', name: '计算运世数', category: '领域专用', description: '根据四柱计算运世基本数', version: 'v0.1');
  @override Map<String, ParameterDefinition> get inputParameters => {'fourZhu': ParameterDefinition(name: 'fourZhu', type: ParameterType.any, required: true)};
  @override Map<String, ParameterDefinition> get outputParameters => {'yunshiNumber': ParameterDefinition(name: 'yunshiNumber', type: ParameterType.intNum, required: true)};
  @override Map<String, ParameterDefinition> get configParameters => {};
  @override Future<Map<String, dynamic>> execute(ExecutionContext context, Map<String, dynamic> inputs, Map<String, dynamic> config) async => throw UnimplementedError();
}

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
      GuaToGanzhiAtom(),
      CalculateFourDoorsTiaowenAtom(),
      CalculateYuanhuiNumberAtom(),
      CalculateYunshiNumberAtom(),
    ];
  }
}
