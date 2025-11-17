import 'package:equatable/equatable.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/enums/enum_jia_zi.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pillar_content.g.dart';

/// 定义柱来源类别：运算、用户输入、当前时间。
enum PillarSourceKind {
  /// 通过算法/策略计算得到（如胎元、身宫、命宫、大运）。
  @JsonValue('operation')
  operation,

  /// 由用户直接指定干支值。
  @JsonValue('userInput')
  userInput,

  /// 基于系统当前时间换算（如流年等）。
  /// 仅当 [PillarSourceKind.currentTime] 时可选携带。
  @JsonValue('currentTime')
  currentTime,
}

/// 运算类型，仅当 [PillarSourceKind.operation] 时生效。
enum PillarOperationType {
  /// 胎元
  @JsonValue('taiYuan')
  taiYuan,

  /// 身宫
  @JsonValue('shenGong')
  shenGong,

  /// 命宫
  @JsonValue('mingGong')
  mingGong,

  /// 大运
  @JsonValue('daYun')
  daYun,
}

/// 时间范围，仅当 [PillarSourceKind.currentTime] 时可选携带。
/// PillarContent：仅承载领域核心数据，脱离 UI 表现层。
///
/// 字段说明：
/// - id：唯一标识（String）。
/// - pillarType：柱类型（年/月/日/时/大运等）。
/// - label：显示或检索标签。
/// - jiaZi：核心干支值。
/// - description：补充说明，可选。
/// - version：语义版本（String）。
/// - sourceKind：来源类别（运算/用户输入/当前时间）。
/// - operationType：当 sourceKind=operation 时的运算类型。
@JsonSerializable()
class PillarContent extends Equatable {
  /// 构造函数
  ///
  /// 参数：参见字段说明。确保 `id` 唯一，`orderIndex` 为稳定排序索引。
  const PillarContent({
    required this.id,
    required this.pillarType,
    required this.label,
    required this.jiaZi,
    this.description,
    required this.version,
    required this.sourceKind,
    this.operationType,
  });

  /// 唯一标识当前柱内容，跨序列/刷新保持不变。
  final String id;

  /// 柱类型（如年柱、月柱、日柱、时柱、luckCycle 等）。
  final PillarType pillarType;

  /// 用于显示/查找的标签（如“年柱”“大运1”等）。
  final String label;

  /// 核心干支值，域内唯一标准类型。
  final JiaZi jiaZi;

  /// 补充说明，用于解释来源或计算过程（可选）。
  final String? description;

  /// 语义版本（String），如 "1", "1.0.0"。
  final String version;

  /// 来源类别：运算 / 用户输入 / 当前时间。
  final PillarSourceKind sourceKind;

  /// 运算类型：当 sourceKind=operation 时应提供。
  final PillarOperationType? operationType;

  /// 复制并更新部分字段，保持不可变性与易用性。
  ///
  /// 参数：仅提供需要变更的字段即可。
  /// 返回：新的 `PillarContent` 实例。
  PillarContent copyWith({
    String? id,
    PillarType? pillarType,
    String? label,
    JiaZi? jiaZi,
    String? description,
    String? version,
    PillarSourceKind? sourceKind,
    PillarOperationType? operationType,
  }) {
    return PillarContent(
      id: id ?? this.id,
      pillarType: pillarType ?? this.pillarType,
      label: label ?? this.label,
      jiaZi: jiaZi ?? this.jiaZi,
      description: description ?? this.description,
      version: version ?? this.version,
      sourceKind: sourceKind ?? this.sourceKind,
      operationType: operationType ?? this.operationType,
    );
  }

  /// 从 JSON 数据创建 `PillarContent` 实例。
  factory PillarContent.fromJson(Map<String, dynamic> json) =>
      _$PillarContentFromJson(json);

  /// 将 `PillarContent` 实例编码为 JSON 数据。
  Map<String, dynamic> toJson() => _$PillarContentToJson(this);

  @override
  List<Object?> get props => [
        id,
        pillarType,
        label,
        jiaZi,
        description,
        version,
        sourceKind,
        operationType,
      ];
}

/// 根据枚举的 `name` 解码字符串为对应的枚举值。
///
/// 参数：
/// - [values]：目标枚举的所有取值列表。
/// - [name]：期望匹配的枚举 `name` 字符串。
/// - [typeName]：仅用于错误信息的人类可读类型名。
/// 返回：与 `name` 匹配的枚举值；若未匹配则抛出 `ArgumentError`。
T _decodeEnum<T extends Enum>(List<T> values, String name, String typeName) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  throw ArgumentError('Invalid $typeName value: $name');
}

/// 将字符串解码为 `JiaZi`：优先按 `name`/`ganZhiStr` 匹配，失败时使用
/// `JiaZi.getFromGanZhiValue` 作为回退。
///
/// 参数：
/// - [s]：期望匹配的干支字符串（如“甲子”）。
/// 返回：匹配到的 `JiaZi`；若未匹配则抛出 `ArgumentError`。
JiaZi _decodeJiaZi(String s) {
  for (final j in JiaZi.values) {
    if (j.name == s || j.ganZhiStr == s) return j;
  }
  final viaGanZhi = JiaZi.getFromGanZhiValue(s);
  if (viaGanZhi != null) return viaGanZhi;
  throw ArgumentError('Invalid JiaZi value: $s');
}
