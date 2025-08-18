/// 条件分支模型
/// Version: v0.2 (json_serializable)
/// 定义条件逻辑和分支执行
library conditional_branch;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'conditional_branch.g.dart';

/// 条件分支类
/// Version: v0.2 (json_serializable)
@JsonSerializable()
class ConditionalBranch extends Equatable {
  /// 条件表达式
  final String condition;

  /// 条件描述
  final String description;

  /// 真分支步骤ID列表
  final List<String> trueSteps;

  /// 假分支步骤ID列表
  final List<String>? falseSteps;

  /// 条件类型
  final ConditionType type;

  /// 条件参数
  final Map<String, dynamic> parameters;

  const ConditionalBranch({
    required this.condition,
    this.description = '',
    required this.trueSteps,
    this.falseSteps,
    this.type = ConditionType.expression,
    this.parameters = const {},
  });

  @override
  List<Object?> get props => [
    condition,
    description,
    trueSteps,
    falseSteps,
    type,
    parameters,
  ];

  /// 从JSON创建实例
  factory ConditionalBranch.fromJson(Map<String, dynamic> json) =>
      _$ConditionalBranchFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ConditionalBranchToJson(this);

  @override
  String toString() {
    return 'ConditionalBranch(condition: $condition, trueSteps: ${trueSteps.length}, falseSteps: ${falseSteps?.length ?? 0})';
  }
}

/// 条件类型枚举
/// Version: v0.2 (json_serializable)
@JsonEnum()
enum ConditionType {
  /// 表达式条件
  expression,

  /// 数值比较
  numeric,

  /// 字符串匹配
  string,

  /// 布尔值
  boolean,

  /// 自定义函数
  custom,
}
