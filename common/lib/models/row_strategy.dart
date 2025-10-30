import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/layout_template_enums.dart';
import 'pillar_content.dart';

/// 输入契约：为某一“行策略”提供所需的上下文信息，
/// 以便一次性计算该行在所有柱上的显示值。
class RowComputationInput {
  /// 构造函数
  ///
  /// 参数：
  /// - pillars: 卡片中所有柱的核心数据 `PillarContent` 列表（按当前顺序），用于跨柱计算。
  /// - dayJiaZi: 出生日的甲子（包含日干日支），便于策略中引用“日元”。
  /// - gender: 性别（部分算法可能需要，如空亡/神煞类按性别不同）。
  /// - referenceDateTime: 参考的时间（可选），在需要具体历法时间计算时使用。
  /// - context: 额外的上下文扩展（如历法系统、地理位置、流年信息等）。
  const RowComputationInput({
    required this.pillars,
    required this.dayJiaZi,
    required this.gender,
    this.referenceDateTime,
    this.context = const {},
  });

  /// 卡片中的柱信息：核心数据 `PillarContent`（如 年/月/日/时/大运 等）。
  final List<PillarContent> pillars;

  /// 出生日的甲子（可由其中的天干视作“日元”）。
  final JiaZi dayJiaZi;

  /// 性别（部分算法需求）。
  final Gender gender;

  /// 可选：参考时间（用于涉及具体日期/节气的策略）。
  final DateTime? referenceDateTime;

  /// 扩展上下文：用于未来新增参数，提升复用性。
  final Map<String, dynamic> context;
}

/// 输出契约：描述一条“行”的计算结果（纯数据，无 UI 语义）。
class RowComputationResult {
  /// 构造函数
  ///
  /// 参数：
  /// - rowType: 行的类型（如 空亡/旬首/纳音 等），用于语义标识与样式选择。
  /// - rowLabel: 行标题（显示在左侧标题列）。
  /// - perPillarValues: 每一柱对应的显示文本（键为柱唯一 `id`，避免类型冲突与重复列）。
  RowComputationResult({
    required this.rowType,
    required this.rowLabel,
    required this.perPillarValues,
  });

  final RowType rowType;
  final String rowLabel;

  /// 每柱的渲染值：例如 {"year#1": "戌亥", "month#1": "子丑", "day#1": "寅卯", "hour#1": "辰巳"}。
  /// 键使用 `PillarContent.id`，以便在存在多个相同类型柱（如多段大运）时正确区分。
  final Map<String, String> perPillarValues;

  /// 提供给上层使用的便捷数据结构，避免与 UI 层产生循环依赖。
}

/// 行策略接口：面向扩展的新“行”（如：旬首），
/// 策略实现者只需维护算法逻辑与输出契约，不需关心 UI 细节。
abstract class RowComputationStrategy {
  /// 返回该策略对应的行类型。
  RowType get rowType;

  /// 默认行标题（可被上层覆盖）。
  String get defaultLabel;

  /// 核心计算函数：一次性返回该行在“所有柱”上的显示值。
  ///
  /// 参数：
  /// - input: 行策略所需的上下文（包含每柱的甲子与“日元”等）。
  /// 返回：
  /// - RowComputationResult：包含行类型、标题、每柱文本。
  RowComputationResult compute(RowComputationInput input);
}

/// 示例策略：空亡（占位示例，具体算法可在此实现或替换）。
class KongWangRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.kongWang;

  @override
  String get defaultLabel => '空亡';

  /// 计算每柱的空亡展示值。
  /// 策略示例：可依据 dayJiaZi（日元）与各柱甲子，调用已有工具方法生成空亡。
  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    // 示例：将各柱的空亡占位为其自身的空亡值（真实算法请替换为项目内的实现）。
    for (final pillar in input.pillars) {
      final jz = pillar.jiaZi;
      final pillarId = pillar.id;
      // 这里可替换为：final kw = jz.getKongWang(input.dayJiaZi.tianGan, input.gender);
      final kw = jz.getKongWang();
      values[pillarId] = '${kw.item1.value}${kw.item2.value}';
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  /// 不再依赖柱序映射，直接使用 `PillarContent.pillarType`。
}

/// 示例策略：旬首（骨架示例，留给后续开发者填充实际算法）。
class XunShouRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.xunShou;

  @override
  String get defaultLabel => '旬首';

  /// 计算各柱的“旬首”文本。
  /// 建议：以 input.dayJiaZi 为基准，结合柱的甲子与参考时间，推导所在旬与旬首。
  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      // TODO: 这里填入旬首的实际算法：根据 pillarJiaZi 与 dayJiaZi（视作日元）计算旬与旬首。
      final xunShou = _computeXunShouPlaceholder(pillarJiaZi, input.dayJiaZi);
      values[pillarId] = xunShou;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeXunShouPlaceholder(JiaZi pillarJiaZi, JiaZi dayJiaZi) {
    // 占位实现：返回该柱甲子的“甲子”作为示例。实际实现请替换为旬首计算。
    return JiaZi.JIA_ZI.ganZhiStr;
  }

  /// 不再依赖柱序映射，直接使用 `PillarContent.pillarType`。
}

/// 纳音计算策略：根据每柱的干支（JiaZi）返回其对应的纳音字符串。
class NaYinRowStrategy extends RowComputationStrategy {
  /// 返回该策略的行类型：纳音。
  @override
  RowType get rowType => RowType.naYin;

  /// 默认行标题：纳音。
  @override
  String get defaultLabel => '纳音';

  /// 核心计算：遍历输入中的各柱数据，使用 `JiaZi.naYinStr` 生成每柱的纳音文本。
  ///
  /// 参数：
  /// - input: 包含所有柱的 `PillarContent`、日柱甲子（dayJiaZi）与性别等上下文。
  ///
  /// 返回：`RowComputationResult`，其中 `perPillarValues` 为 {柱类型: 纳音字符串} 映射。
  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarId = pillar.id;
      final jiaZi = pillar.jiaZi;
      values[pillarId] = jiaZi.naYinStr;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }
}
