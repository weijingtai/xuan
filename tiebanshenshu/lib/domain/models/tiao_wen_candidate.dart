/// 条文候选项模型
///
/// 定义交互式策略中的条文候选项数据结构
library;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
part 'tiao_wen_candidate.g.dart';

/// 条文候选项类型枚举
enum TiaoWenCandidateType {
  /// 基础数值选择
  @JsonValue('baseNumber')
  baseNumber,

  /// 卦象选择
  @JsonValue('gua')
  gua,

  /// 干支选择
  @JsonValue('ganzhi')
  ganzhi,

  /// 四柱选择
  @JsonValue('fourZhu')
  fourZhu,

  /// 卦象映射选择
  @JsonValue('guaMapping')
  guaMapping,

  /// 确认选择
  @JsonValue('confirmation')
  confirmation,

  /// 计算方法选择
  @JsonValue('calculationMethod')
  calculationMethod,

  /// 其他自定义类型
  @JsonValue('custom')
  custom,
}

/// 条文候选项
///
/// 表示交互式策略中用户可以选择的候选项
@JsonSerializable()
class TiaoWenCandidate extends Equatable {
  /// 候选项唯一标识
  final String id;

  /// 候选项显示名称
  final String displayName;

  /// 候选项描述
  final String description;

  /// 候选项类型
  final TiaoWenCandidateType type;

  /// 候选项值（可以是任意类型的数据）
  final dynamic value;

  /// 是否为默认选项
  final bool isDefault;

  /// 是否可用
  final bool isEnabled;

  /// 额外的元数据
  final Map<String, dynamic>? metadata;

  /// 构造函数
  const TiaoWenCandidate({
    required this.id,
    required this.displayName,
    required this.description,
    required this.type,
    required this.value,
    this.isDefault = false,
    this.isEnabled = true,
    this.metadata,
  });

  /// 创建基础数值候选项
  factory TiaoWenCandidate.baseNumber({
    required String id,
    required String displayName,
    required String description,
    required int value,
    bool isDefault = false,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    return TiaoWenCandidate(
      id: id,
      displayName: displayName,
      description: description,
      type: TiaoWenCandidateType.baseNumber,
      value: value,
      isDefault: isDefault,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }

  /// 创建卦象候选项
  factory TiaoWenCandidate.gua({
    required String id,
    required String displayName,
    required String description,
    required dynamic guaValue,
    bool isDefault = false,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    return TiaoWenCandidate(
      id: id,
      displayName: displayName,
      description: description,
      type: TiaoWenCandidateType.gua,
      value: guaValue,
      isDefault: isDefault,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }

  /// 创建干支候选项
  factory TiaoWenCandidate.ganzhi({
    required String id,
    required String displayName,
    required String description,
    required String ganzhiValue,
    bool isDefault = false,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    return TiaoWenCandidate(
      id: id,
      displayName: displayName,
      description: description,
      type: TiaoWenCandidateType.ganzhi,
      value: ganzhiValue,
      isDefault: isDefault,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }

  /// 创建计算方法候选项
  factory TiaoWenCandidate.calculationMethod({
    required String id,
    required String displayName,
    required String description,
    required String methodName,
    bool isDefault = false,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    return TiaoWenCandidate(
      id: id,
      displayName: displayName,
      description: description,
      type: TiaoWenCandidateType.calculationMethod,
      value: methodName,
      isDefault: isDefault,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }

  /// 创建四柱候选项
  factory TiaoWenCandidate.fourZhu({
    required String id,
    required String displayName,
    required String description,
    required dynamic fourZhuValue,
    bool isDefault = false,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    return TiaoWenCandidate(
      id: id,
      displayName: displayName,
      description: description,
      type: TiaoWenCandidateType.fourZhu,
      value: fourZhuValue,
      isDefault: isDefault,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }

  /// 创建卦象映射候选项
  factory TiaoWenCandidate.guaMapping({
    required String id,
    required String displayName,
    required String description,
    required dynamic mappingValue,
    bool isDefault = false,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    return TiaoWenCandidate(
      id: id,
      displayName: displayName,
      description: description,
      type: TiaoWenCandidateType.guaMapping,
      value: mappingValue,
      isDefault: isDefault,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }

  /// 创建确认候选项
  factory TiaoWenCandidate.confirmation({
    required String id,
    required String displayName,
    required String description,
    required bool confirmationValue,
    bool isDefault = false,
    bool isEnabled = true,
    Map<String, dynamic>? metadata,
  }) {
    return TiaoWenCandidate(
      id: id,
      displayName: displayName,
      description: description,
      type: TiaoWenCandidateType.confirmation,
      value: confirmationValue,
      isDefault: isDefault,
      isEnabled: isEnabled,
      metadata: metadata,
    );
  }

  /// 复制并修改候选项
  TiaoWenCandidate copyWith({
    String? id,
    String? displayName,
    String? description,
    TiaoWenCandidateType? type,
    dynamic value,
    bool? isDefault,
    bool? isEnabled,
    Map<String, dynamic>? metadata,
  }) {
    return TiaoWenCandidate(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TiaoWenCandidate &&
        other.id == id &&
        other.displayName == displayName &&
        other.description == description &&
        other.type == type &&
        other.value == value &&
        other.isDefault == isDefault &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      displayName,
      description,
      type,
      value,
      isDefault,
      isEnabled,
    );
  }

  @override
  String toString() {
    return 'TiaoWenCandidate('
        'id: $id, '
        'displayName: $displayName, '
        'description: $description, '
        'type: $type, '
        'value: $value, '
        'isDefault: $isDefault, '
        'isEnabled: $isEnabled, '
        'metadata: $metadata)';
  }

  /// 从 JSON 数据创建候选项
  factory TiaoWenCandidate.fromJson(Map<String, dynamic> json) =>
      _$TiaoWenCandidateFromJson(json);

  /// 将候选项转换为 JSON 数据
  Map<String, dynamic> toJson() => _$TiaoWenCandidateToJson(this);

  @override
  // TODO: implement props
  List<Object?> get props => [
    id,
    displayName,
    description,
    type,
    value,
    isDefault,
    isEnabled,
    metadata,
  ];
}
