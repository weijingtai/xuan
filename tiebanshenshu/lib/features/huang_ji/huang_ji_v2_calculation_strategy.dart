import '../../domain/models/yuan_hui_yun_shi.dart';
import 'huang_ji_formula_data_v2.dart';
import '../../domain/models/base_number_selection_record.dart';
import 'package:common/models/eight_chars.dart';

/// 皇极 V2 计算策略接口
abstract class HuangJiV2CalculationStrategy {
  /// 计算元会运世
  YuanHuiYunShi calculateYuanHuiYunShi(EightChars eightChars);

  /// 生成候选列表 (不含条文内容)
  List<BaseNumberCandidate> generateCandidates({
    required int initialNumber,
    required CandidateGenerationConfig config,
  });

  /// 计算派生基础数的数值
  int calculateDerivedBaseNumber({
    required DataBaseNumberDefinition baseDefinition,
    required YuanHuiYunShi yhys,
  });

  /// 计算最终条文数
  int calculateTiaoWenNumber({
    required int baseNumber,
    required TiaoWenFormulaData formula,
  });

  /// 构建派生链路
  BaseNumberDerivationChain buildDerivationChain({
    required DataBaseNumberDefinition definition,
    required YuanHuiYunShi yhys,
  });
}
