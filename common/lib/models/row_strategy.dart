import 'package:common/enums.dart';
import 'package:common/features/four_zhu/four_zhu_engine.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_gender.dart';
import '../enums/enum_jia_zi.dart';
import '../enums/layout_template_enums.dart';
import '../utils/constant_values_utils.dart';
import 'eight_chars.dart';
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
    this.isShortName = false,
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
  // 是否为短名（如是什么中，印、枭 之类）
  final bool isShortName;

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

  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender);
}

class PillarComputationInput {
  const PillarComputationInput({
    required this.pillar,
    required this.pillars,
    required this.dayJiaZi,
    required this.gender,
    this.isShortName = false,
    this.referenceDateTime,
    this.context = const {},
  });

  final PillarContent pillar;
  final List<PillarContent> pillars;
  final JiaZi dayJiaZi;
  final Gender gender;
  final DateTime? referenceDateTime;
  final bool isShortName;
  final Map<String, dynamic> context;
}

class PillarComputationResult {
  PillarComputationResult({
    required this.pillarType,
    required this.pillarLabel,
    required this.perRowValues,
  });

  final PillarType pillarType;
  final String pillarLabel;
  final Map<RowType, String> perRowValues;
}

abstract class PillarComputationStrategy {
  PillarType get pillarType;

  String get defaultLabel;

  PillarComputationResult compute(PillarComputationInput input);

  String? computeSingleValue(
    RowType rowType,
    JiaZi pillarJiaZi,
    JiaZi dayJiaZi,
    Gender gender, {
    List<PillarContent>? pillars,
    DateTime? referenceDateTime,
    Map<String, dynamic> context = const {},
  });
}

/// 示例策略：空亡（占位示例，具体算法可在此实现或替换）。
class KongWangRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.kongWang;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

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
  /// 计算单柱的空亡展示值。
  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    // 这里可替换为：final kw = jz.getKongWang(input.dayJiaZi.tianGan, input.gender);
    final kw = pillarJiaZi.getKongWang();
    return '${kw.item1.value}${kw.item2.value}';
  }
}

/// 驿马行策略：按“每一柱的地支”计算驿马。
///
/// 规则：
/// - 申子辰见寅
/// - 寅午戌见申
/// - 巳酉丑见亥
/// - 亥卯未见巳
class YiMaRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.yiMa;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  /// 计算各柱的“驿马”文本。
  ///
  /// 参数：
  /// - input: 其中使用每柱的 `PillarContent.jiaZi.zhi`（地支）推导驿马。
  ///
  /// 返回：每柱对应的驿马地支（单字）。
  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      values[pillar.id] = computeSingleValue(
        pillar.jiaZi,
        input.dayJiaZi,
        input.gender,
      );
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  /// 计算单柱的驿马展示值。
  ///
  /// 参数：
  /// - pillarJiaZi: 该柱干支（仅使用其地支）。
  /// - dayJiaZi: 日柱干支（此策略不使用，但保留签名以保持一致）。
  /// - gender: 性别（此策略不使用，但保留签名以保持一致）。
  ///
  /// 返回：驿马地支（单字）。
  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    return _computeYiMaZhi(pillarJiaZi.zhi).value;
  }

  /// 根据“该柱地支”推导其驿马地支。
  ///
  /// 参数：
  /// - zhi: 当前柱的地支。
  ///
  /// 返回：对应的驿马地支。
  DiZhi _computeYiMaZhi(DiZhi zhi) {
    if (zhi == DiZhi.SHEN || zhi == DiZhi.ZI || zhi == DiZhi.CHEN) {
      return DiZhi.YIN;
    }
    if (zhi == DiZhi.YIN || zhi == DiZhi.WU || zhi == DiZhi.XU) {
      return DiZhi.SHEN;
    }
    if (zhi == DiZhi.SI || zhi == DiZhi.YOU || zhi == DiZhi.CHOU) {
      return DiZhi.HAI;
    }
    return DiZhi.SI;
  }
}

/// 孤行策略：按“该柱所在旬”的旬空（空亡）计算。
///
/// 定义：旬空的地支即“孤”。
class GuRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.gu;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  /// 计算各柱的“孤”文本。
  ///
  /// 参数：
  /// - input: 使用每柱的 `PillarContent.jiaZi.getKongWang()` 推导旬空。
  ///
  /// 返回：每柱对应的旬空地支（两个字，例如“戌亥”）。
  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      values[pillar.id] = computeSingleValue(
        pillar.jiaZi,
        input.dayJiaZi,
        input.gender,
      );
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  /// 计算单柱的“孤”展示值。
  ///
  /// 参数：
  /// - pillarJiaZi: 该柱干支。
  /// - dayJiaZi: 日柱干支（此策略不使用，但保留签名以保持一致）。
  /// - gender: 性别（此策略不使用，但保留签名以保持一致）。
  ///
  /// 返回：旬空地支（两个字）。
  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final kw = pillarJiaZi.getKongWang();
    return '${kw.item1.value}${kw.item2.value}';
  }
}

/// 虚行策略：按“孤位对冲（六冲）”计算。
///
/// 定义：虚 = 孤位的六冲。
class XuRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.xu;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  /// 计算各柱的“虚”文本。
  ///
  /// 参数：
  /// - input: 先取该柱旬空（孤），再做六冲得到虚。
  ///
  /// 返回：每柱对应的虚位地支（两个字，例如“辰巳”）。
  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      values[pillar.id] = computeSingleValue(
        pillar.jiaZi,
        input.dayJiaZi,
        input.gender,
      );
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  /// 计算单柱的“虚”展示值。
  ///
  /// 参数：
  /// - pillarJiaZi: 该柱干支。
  /// - dayJiaZi: 日柱干支（此策略不使用，但保留签名以保持一致）。
  /// - gender: 性别（此策略不使用，但保留签名以保持一致）。
  ///
  /// 返回：虚位地支（两个字）。
  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final kw = pillarJiaZi.getKongWang();
    final z1 = kw.item1.sixChongZhi;
    final z2 = kw.item2.sixChongZhi;
    return '${z1.value}${z2.value}';
  }
}

/// 示例策略：旬首（骨架示例，留给后续开发者填充实际算法）。
class XunShouRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.xunShou;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

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
  /// 计算单柱的旬首展示值。
  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    // 这里可替换为：final xunShou = _computeXunShouPlaceholder(pillarJiaZi, dayJiaZi);
    final xunShou = _computeXunShouPlaceholder(pillarJiaZi, dayJiaZi);
    return xunShou;
  }
}

/// 纳音计算策略：根据每柱的干支（JiaZi）返回其对应的纳音字符串。
class NaYinRowStrategy extends RowComputationStrategy {
  /// 返回该策略的行类型：纳音。
  @override
  RowType get rowType => RowType.naYin;

  /// 默认行标题：纳音。
  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

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

  /// 不再依赖柱序映射，直接使用 `PillarContent.pillarType`。
  /// 计算单柱的纳音展示值。
  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    return pillarJiaZi.naYinStr;
  }
}

class TenGodRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.tenGod;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  String _dayPillarTenGodPlaceholder(Gender gender) {
    return FourZhuText.zaoLabelForGender(gender);
  }

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      if (pillar.pillarType == PillarType.day) {
        values[pillarId] = _dayPillarTenGodPlaceholder(input.gender);
        continue;
      }
      final tenGods = pillarJiaZi.tianGan.getTenGods(input.dayJiaZi.tianGan);
      values[pillarId] = input.isShortName ? tenGods.singleName : tenGods.name;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  /// 不再依赖柱序映射，直接使用 `PillarContent.pillarType`。
  /// 计算单柱的十神展示值。
  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final tenGods = pillarJiaZi.tianGan.getTenGods(dayJiaZi.tianGan);
    return tenGods.name;
  }
}

class HiddenStemsRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.hiddenStems;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      final hiddenStems = pillarJiaZi.diZhi.cangGan;
      values[pillarId] = hiddenStems.map((e) => e.name).join();
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  /// 不再依赖柱序映射，直接使用 `PillarContent.pillarType`。
  /// 计算单柱的藏干十神展示值。
  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    final tenGods = hiddenStems.map((h) => h.getTenGods(dayJiaZi.tianGan));
    return tenGods.map((e) => e.singleName).join();
  }
}

class HiddenStemsTenGodsRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.hiddenStemsTenGod;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      final hiddenStems = pillarJiaZi.diZhi.cangGan;
      final tenGods =
          hiddenStems.map((h) => h.getTenGods(input.dayJiaZi.tianGan));
      values[pillarId] = tenGods.map((e) => e.singleName).join();
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    final tenGods = hiddenStems.map((h) => h.getTenGods(dayJiaZi.tianGan));
    return tenGods.map((e) => e.singleName).join();
  }
}

/// 藏干主气行策略：显示每柱地支的藏干主气。
class HiddenStemsPrimaryRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.hiddenStemsPrimary;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      final primary = _computeHiddenStemsPrimaryPlaceholder(pillarJiaZi);
      values[pillarId] = primary;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeHiddenStemsPrimaryPlaceholder(JiaZi pillarJiaZi) {
    // 占位实现：返回藏干列表的第一个元素
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    return hiddenStems.isNotEmpty ? hiddenStems.first.name : '';
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    return hiddenStems.isNotEmpty ? hiddenStems.first.name : '';
  }
}

/// 藏干中气行策略：显示每柱地支的藏干中气。
class HiddenStemsSecondaryRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.hiddenStemsSecondary;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      // TODO: 这里填入藏干中气的实际算法：取藏干列表的第二个（中气）
      final secondary = _computeHiddenStemsSecondaryPlaceholder(pillarJiaZi);
      values[pillarId] = secondary;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeHiddenStemsSecondaryPlaceholder(JiaZi pillarJiaZi) {
    // 占位实现：返回藏干列表的第二个元素
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    return hiddenStems.length > 1 ? hiddenStems[1].name : '';
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    return hiddenStems.length > 1 ? hiddenStems[1].name : '';
  }
}

/// 藏干余气行策略：显示每柱地支的藏干余气。
class HiddenStemsTertiaryRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.hiddenStemsTertiary;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      // TODO: 这里填入藏干余气的实际算法：取藏干列表的第三个（余气）
      final tertiary = _computeHiddenStemsTertiaryPlaceholder(pillarJiaZi);
      values[pillarId] = tertiary;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeHiddenStemsTertiaryPlaceholder(JiaZi pillarJiaZi) {
    // 占位实现：返回藏干列表的第三个元素
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    return hiddenStems.length > 2 ? hiddenStems[2].name : '';
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    return hiddenStems.length > 2 ? hiddenStems[2].name : '';
  }
}

/// 藏干主气十神行策略：显示每柱地支藏干主气的十神。
class HiddenStemsPrimaryGodsRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.hiddenStemsPrimaryGods;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      final primaryGod = _computeHiddenStemsPrimaryGodPlaceholder(
        pillarJiaZi,
        input.dayJiaZi,
        input.isShortName,
      );
      values[pillarId] = primaryGod;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeHiddenStemsPrimaryGodPlaceholder(
    JiaZi pillarJiaZi,
    JiaZi dayJiaZi,
    bool isShortName,
  ) {
    // 占位实现：取藏干主气的十神
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    if (hiddenStems.isEmpty) return '';
    final tenGod = hiddenStems.first.getTenGods(dayJiaZi.tianGan);
    return isShortName ? tenGod.singleName : tenGod.name;
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    if (hiddenStems.isEmpty) return '';
    final tenGod = hiddenStems.first.getTenGods(dayJiaZi.tianGan);
    return tenGod.singleName;
  }
}

/// 藏干中气十神行策略：显示每柱地支藏干中气的十神。
class HiddenStemsSecondaryGodsRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.hiddenStemsSecondaryGods;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      final secondaryGod = _computeHiddenStemsSecondaryGodPlaceholder(
        pillarJiaZi,
        input.dayJiaZi,
        input.isShortName,
      );
      values[pillarId] = secondaryGod;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeHiddenStemsSecondaryGodPlaceholder(
    JiaZi pillarJiaZi,
    JiaZi dayJiaZi,
    bool isShortName,
  ) {
    // 占位实现：取藏干中气的十神
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    if (hiddenStems.length <= 1) return '';
    final tenGod = hiddenStems[1].getTenGods(dayJiaZi.tianGan);
    return isShortName ? tenGod.singleName : tenGod.name;
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    if (hiddenStems.length <= 1) return '';
    final tenGod = hiddenStems[1].getTenGods(dayJiaZi.tianGan);
    return tenGod.singleName;
  }
}

/// 藏干余气十神行策略：显示每柱地支藏干余气的十神。
class HiddenStemsTertiaryGodsRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.hiddenStemsTertiaryGods;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      final tertiaryGod = _computeHiddenStemsTertiaryGodPlaceholder(
        pillarJiaZi,
        input.dayJiaZi,
        input.isShortName,
      );
      values[pillarId] = tertiaryGod;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeHiddenStemsTertiaryGodPlaceholder(
    JiaZi pillarJiaZi,
    JiaZi dayJiaZi,
    bool isShortName,
  ) {
    // 占位实现：取藏干余气的十神
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    if (hiddenStems.length <= 2) return '';
    final tenGod = hiddenStems[2].getTenGods(dayJiaZi.tianGan);
    return isShortName ? tenGod.singleName : tenGod.name;
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final hiddenStems = pillarJiaZi.diZhi.cangGan;
    if (hiddenStems.length <= 2) return '';
    final tenGod = hiddenStems[2].getTenGods(dayJiaZi.tianGan);
    return tenGod.singleName;
  }
}

/// 星运行策略：显示每柱的星运信息。
class StarYunRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.starYun;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      // TODO: 这里填入星运的实际算法
      final starYun = _computeStarYunPlaceholder(pillarJiaZi, input.dayJiaZi);
      values[pillarId] = starYun;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeStarYunPlaceholder(JiaZi pillarJiaZi, JiaZi dayJiaZi) {
    return TwelveZhangSheng.getZhangShengByTianGanDiZhi(
            dayJiaZi.tianGan, pillarJiaZi.diZhi)
        .name;
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final starYun = _computeStarYunPlaceholder(pillarJiaZi, dayJiaZi);
    return starYun;
  }
}

/// 自坐行策略：显示每柱天干的自坐信息。
class SelfSitingRowStrategy extends RowComputationStrategy {
  @override
  RowType get rowType => RowType.selfSiting;

  @override
  String get defaultLabel => ConstantValuesUtils.labelForRowType(rowType);

  @override
  RowComputationResult compute(RowComputationInput input) {
    final Map<String, String> values = {};
    for (final pillar in input.pillars) {
      final pillarJiaZi = pillar.jiaZi;
      final pillarId = pillar.id;
      // TODO: 这里填入自坐的实际算法
      final selfSiting =
          _computeSelfSitingPlaceholder(pillarJiaZi, input.dayJiaZi);
      values[pillarId] = selfSiting;
    }
    return RowComputationResult(
      rowType: rowType,
      rowLabel: defaultLabel,
      perPillarValues: values,
    );
  }

  String _computeSelfSitingPlaceholder(JiaZi pillarJiaZi, JiaZi dayJiaZi) {
    return TwelveZhangSheng.getZhangShengByTianGanDiZhi(
            pillarJiaZi.tianGan, pillarJiaZi.diZhi)
        .name;
  }

  @override
  String computeSingleValue(JiaZi pillarJiaZi, JiaZi dayJiaZi, Gender gender) {
    final selfSiting = _computeSelfSitingPlaceholder(pillarJiaZi, dayJiaZi);
    return selfSiting;
  }
}

abstract class _BaseHousePillarStrategy implements PillarComputationStrategy {
  const _BaseHousePillarStrategy();

  bool get isLifeHouse;

  @override
  PillarComputationResult compute(PillarComputationInput input) {
    final tuple = _computeHouse(
      pillars: input.pillars,
      referenceDateTime: input.referenceDateTime,
    );

    final perRowValues = <RowType, String>{};

    if (tuple != null) {
      perRowValues[RowType.columnHeaderRow] = defaultLabel;
      perRowValues[RowType.heavenlyStem] = tuple.item1.name;
      perRowValues[RowType.earthlyBranch] = tuple.item2.name;

      if (tuple.item1 != TianGan.KONG_WANG) {
        final jz = JiaZi.getFromGanZhiEnum(tuple.item1, tuple.item2);
        perRowValues[RowType.naYin] = jz.naYinStr;
      }
    }

    return PillarComputationResult(
      pillarType: pillarType,
      pillarLabel: defaultLabel,
      perRowValues: perRowValues,
    );
  }

  @override
  String? computeSingleValue(
    RowType rowType,
    JiaZi pillarJiaZi,
    JiaZi dayJiaZi,
    Gender gender, {
    List<PillarContent>? pillars,
    DateTime? referenceDateTime,
    Map<String, dynamic> context = const {},
  }) {
    final tuple = _computeHouse(
      pillars: pillars,
      referenceDateTime: referenceDateTime,
    );
    if (tuple == null) return null;

    final gan = tuple.item1;
    final zhi = tuple.item2;

    if (rowType == RowType.columnHeaderRow) return defaultLabel;

    final JiaZi? palaceJiaZi = gan == TianGan.KONG_WANG
        ? null
        : JiaZi.getFromGanZhiEnum(gan, zhi);

    switch (rowType) {
      case RowType.heavenlyStem:
        return gan.name;
      case RowType.earthlyBranch:
        return zhi.name;
      case RowType.naYin:
        return palaceJiaZi?.naYinStr ?? '';
      case RowType.kongWang:
      case RowType.gu:
        final kw = palaceJiaZi?.getKongWang();
        return kw == null ? '' : '${kw.item1.name}${kw.item2.name}';
      case RowType.xu:
        final kw = palaceJiaZi?.getKongWang();
        return kw == null
            ? ''
            : '${kw.item1.sixChongZhi.name}${kw.item2.sixChongZhi.name}';
      case RowType.xunShou:
        return palaceJiaZi?.xunHeader.name ?? '';
      case RowType.yiMa:
        final ym = _computeYiMaZhi(zhi);
        return ym.value;
      case RowType.hiddenStems:
        return zhi.cangGan.map((e) => e.name).join('');
      case RowType.tenGod:
        return gan == TianGan.KONG_WANG
            ? ''
            : gan.getTenGods(dayJiaZi.tianGan).name;
      case RowType.hiddenStemsTenGod:
        final tenGods = zhi.cangGan.map((h) => h.getTenGods(dayJiaZi.tianGan));
        return tenGods.map((e) => e.singleName).join();
      case RowType.hiddenStemsPrimary:
        return zhi.cangGan.isNotEmpty ? zhi.cangGan.first.name : '';
      case RowType.hiddenStemsSecondary:
        return zhi.cangGan.length > 1 ? zhi.cangGan[1].name : '';
      case RowType.hiddenStemsTertiary:
        return zhi.cangGan.length > 2 ? zhi.cangGan[2].name : '';
      case RowType.hiddenStemsPrimaryGods:
        return zhi.cangGan.isNotEmpty
            ? zhi.cangGan.first.getTenGods(dayJiaZi.tianGan).singleName
            : '';
      case RowType.hiddenStemsSecondaryGods:
        return zhi.cangGan.length > 1
            ? zhi.cangGan[1].getTenGods(dayJiaZi.tianGan).singleName
            : '';
      case RowType.hiddenStemsTertiaryGods:
        return zhi.cangGan.length > 2
            ? zhi.cangGan[2].getTenGods(dayJiaZi.tianGan).singleName
            : '';
      default:
        return null;
    }
  }

  Tuple2<TianGan, DiZhi>? _computeHouse({
    required List<PillarContent>? pillars,
    required DateTime? referenceDateTime,
  }) {
    if (pillars == null || referenceDateTime == null) return null;

    JiaZi? year;
    JiaZi? month;
    JiaZi? day;
    JiaZi? hour;

    for (final p in pillars) {
      if (p.pillarType == PillarType.year) year ??= p.jiaZi;
      if (p.pillarType == PillarType.month) month ??= p.jiaZi;
      if (p.pillarType == PillarType.day) day ??= p.jiaZi;
      if (p.pillarType == PillarType.hour) hour ??= p.jiaZi;
    }

    if (year == null || month == null || day == null || hour == null) {
      return null;
    }

    final eightChars = EightChars(
      year: year,
      month: month,
      day: day,
      time: hour,
    );

    return isLifeHouse
        ? LifeBodyHouseCalculator.calculateLifeHouse(
            birthDateTime: referenceDateTime,
            eightChars: eightChars,
          )
        : LifeBodyHouseCalculator.calculateBodyHouse(
            birthDateTime: referenceDateTime,
            eightChars: eightChars,
          );
  }

  DiZhi _computeYiMaZhi(DiZhi zhi) {
    if (zhi == DiZhi.SHEN || zhi == DiZhi.ZI || zhi == DiZhi.CHEN) {
      return DiZhi.YIN;
    }
    if (zhi == DiZhi.YIN || zhi == DiZhi.WU || zhi == DiZhi.XU) {
      return DiZhi.SHEN;
    }
    if (zhi == DiZhi.SI || zhi == DiZhi.YOU || zhi == DiZhi.CHOU) {
      return DiZhi.HAI;
    }
    return DiZhi.SI;
  }
}

class LifeHousePillarStrategy extends _BaseHousePillarStrategy {
  const LifeHousePillarStrategy();

  @override
  PillarType get pillarType => PillarType.lifeHouse;

  @override
  String get defaultLabel => '命宫';

  @override
  bool get isLifeHouse => true;
}

class BodyHousePillarStrategy extends _BaseHousePillarStrategy {
  const BodyHousePillarStrategy();

  @override
  PillarType get pillarType => PillarType.bodyHouse;

  @override
  String get defaultLabel => '身宫';

  @override
  bool get isLifeHouse => false;
}
