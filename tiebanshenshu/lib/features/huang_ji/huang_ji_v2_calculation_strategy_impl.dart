import './huang_ji_v2_calculation_strategy.dart';
import '../../domain/models/yuan_hui_yun_shi.dart';
import 'huang_ji_formula_data_v2.dart';
import '../../domain/models/base_number_selection_record.dart';
import '../../domain/models/huang_ji_number.dart';
import 'package:common/models/eight_chars.dart';

/// 皇极 V2 计算策略实现
class HuangJiV2CalculationStrategyImpl implements HuangJiV2CalculationStrategy {
  @override
  YuanHuiYunShi calculateYuanHuiYunShi(EightChars eightChars) {
    return YuanHuiYunShi.fromEightChars(eightChars);
  }

  @override
  List<BaseNumberCandidate> generateCandidates({
    required int initialNumber,
    required CandidateGenerationConfig config,
  }) {
    final candidates = <BaseNumberCandidate>[];

    // 生成前后各 count 个候选项
    for (int i = -config.count; i <= config.count; i++) {
      final number = initialNumber + (i * config.offset);

      // 过滤范围
      if (number < config.minValue || number > config.maxValue) {
        continue;
      }

      candidates.add(
        BaseNumberCandidate(
          id: 'candidate_$number',
          number: number,
          offsetFromInitial: i * config.offset,
          tiaoWenContent: '', // 后续由 UseCase 填充
          isInitial: i == 0,
        ),
      );
    }

    return candidates;
  }

  @override
  int calculateDerivedBaseNumber({
    required DataBaseNumberDefinition baseDefinition,
    required YuanHuiYunShi yhys,
  }) {
    return baseDefinition.number;
  }

  @override
  int calculateTiaoWenNumber({
    required int baseNumber,
    required TiaoWenFormulaData formula,
  }) {
    // 条文数 = 基础数 + sum(formula.parts)
    final partsSum = formula.parts.fold<int>(
      0,
      (sum, part) => sum + part.rawNumber,
    );

    final result = baseNumber + partsSum;

    // 确保结果在范围内
    return HuangJiBaseNumber.checkToTiaoWenNumber(result);
  }

  @override
  BaseNumberDerivationChain buildDerivationChain({
    required DataBaseNumberDefinition definition,
    required YuanHuiYunShi yhys,
  }) {
    // 递归追溯到 PredefinedBaseNumber
    if (definition is DataPredefinedBaseNumber) {
      // 已到达根源
      return BaseNumberDerivationChain(
        source: definition,
        derivationSteps: [],
        finalDefinition: definition,
      );
    } else if (definition is DataDerivedBaseNumber) {
      // 继续追溯父级
      final parentChain = buildDerivationChain(
        definition: definition.baseNumberDefinition,
        yhys: yhys,
      );

      // 构建当前派生步骤
      final operation = _buildOperationDescription(definition.calculationParts);
      final value = definition.calculationParts.fold<int>(
        0,
        (sum, part) => sum + part.rawNumber,
      );

      final step = DerivationStep(
        operation: operation,
        value: value,
        description: definition.description,
      );

      return BaseNumberDerivationChain(
        source: parentChain.source,
        derivationSteps: [...parentChain.derivationSteps, step],
        finalDefinition: definition,
      );
    } else if (definition is DataSelectableBaseNumber) {
      // Selectable 包装了另一个定义
      return buildDerivationChain(
        definition: definition.initialCandidate,
        yhys: yhys,
      );
    }

    throw UnsupportedError(
      'Unknown BaseNumberDefinition type: ${definition.runtimeType}',
    );
  }

  /// 构建操作描述字符串
  String _buildOperationDescription(List<DataCalculationPart> parts) {
    if (parts.isEmpty) return '';

    return parts
        .map((part) {
          if (part is DataSingleNumberPart) {
            return '+${part.name}';
          } else if (part is DataCompositeNumberPart) {
            return '+${part.name}';
          }
          return '+${part.name}';
        })
        .join('');
  }
}
