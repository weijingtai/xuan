import 'package:equatable/equatable.dart';
import 'package:common/enums/layout_template_enums.dart';
import 'package:common/enums/enum_jia_zi.dart';

/// 定义柱来源类别：运算、用户输入、当前时间。
enum PillarSourceKind {
  /// 通过算法/策略计算得到（如胎元、身宫、命宫、大运）。
  operation,

  /// 由用户直接指定干支值。
  userInput,

  /// 基于系统当前时间换算（如流年等）。
  currentTime,
}

/// 运算类型，仅当 [PillarSourceKind.operation] 时生效。
enum PillarOperationType {
  /// 胎元
  taiYuan,

  /// 身宫
  shenGong,

  /// 命宫
  mingGong,

  /// 大运
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

  /// 反序列化：从 JSON 映射为 `PillarContent`。
  ///
  /// 参数：`json` 为键值映射对象。
  /// 返回：解析后的 `PillarContent` 实例。
  /// 反序列化：从 JSON 映射为 `PillarContent`。
  ///
  /// 支持枚举以其 `name` 字符串进行映射；`JiaZi` 额外支持以其中文 `value` 映射。
  /// 当提供的字符串无法匹配对应枚举值时，将抛出 `ArgumentError`。
  factory PillarContent.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    final String label = json['label'] as String;
    final String version = json['version'] as String;

    final String pillarTypeStr = json['pillarType'] as String;
    final PillarType pillarType = _decodeEnum(
      PillarType.values,
      pillarTypeStr,
      'PillarType',
    );

    final String jiaZiStr = json['jiaZi'] as String;
    final JiaZi jiaZi = _decodeJiaZi(jiaZiStr);

    final String sourceKindStr = json['sourceKind'] as String;
    final PillarSourceKind sourceKind = _decodeEnum(
      PillarSourceKind.values,
      sourceKindStr,
      'PillarSourceKind',
    );

    final String? description = json['description'] as String?;

    final String? operationTypeStr = json['operationType'] as String?;
    final PillarOperationType? operationType = operationTypeStr == null
        ? null
        : _decodeEnum(
            PillarOperationType.values,
            operationTypeStr,
            'PillarOperationType',
          );

    return PillarContent(
      id: id,
      pillarType: pillarType,
      label: label,
      jiaZi: jiaZi,
      description: description,
      version: version,
      sourceKind: sourceKind,
      operationType: operationType,
    );
  }

  /// 序列化：将 `PillarContent` 转换为 JSON 映射。
  ///
  /// 返回：可用于持久化/传输的键值映射对象。
  /// 序列化：将 `PillarContent` 转换为 JSON 映射。
  ///
  /// 所有枚举均以其 `name` 输出，`JiaZi` 同样以 `name` 输出（建议统一存储）。
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'pillarType': pillarType.name,
        'label': label,
        'jiaZi': jiaZi.name,
        'description': description,
        'version': version,
        'sourceKind': sourceKind.name,
        'operationType': operationType?.name,
      };

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
