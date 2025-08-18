/// 规则集模型
/// Version: v0.2 (json_serializable)
/// 定义算法中使用的规则集合
library rule_set;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'rule_set.g.dart';

/// 规则集类
/// Version: v0.2 (json_serializable)
@JsonSerializable(explicitToJson: true)
class RuleSet extends Equatable {
  /// 规则集名称
  final String name;
  
  /// 规则集描述
  @JsonKey(defaultValue: '')
  final String description;
  
  /// 规则列表
  final List<Rule> rules;
  
  /// 规则集类型
  @JsonKey(defaultValue: RuleSetType.standard)
  final RuleSetType type;
  
  /// 优先级
  @JsonKey(defaultValue: 0)
  final int priority;
  
  /// 是否启用
  @JsonKey(defaultValue: true)
  final bool enabled;

  const RuleSet({
    required this.name,
    this.description = '',
    required this.rules,
    this.type = RuleSetType.standard,
    this.priority = 0,
    this.enabled = true,
  });

  @override
  List<Object?> get props => [name, description, rules, type, priority, enabled];

  /// 从JSON创建实例
  factory RuleSet.fromJson(Map<String, dynamic> json) => _$RuleSetFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RuleSetToJson(this);

  /// 根据ID获取规则
  Rule? getRuleById(String ruleId) {
    try {
      return rules.firstWhere((rule) => rule.id == ruleId);
    } catch (e) {
      return null;
    }
  }

  /// 获取启用的规则
  List<Rule> get enabledRules => rules.where((rule) => rule.enabled).toList();

  @override
  String toString() {
    return 'RuleSet(name: $name, rules: ${rules.length}, enabled: $enabled)';
  }
}

/// 规则类
/// Version: v0.2 (json_serializable)
@JsonSerializable()
class Rule extends Equatable {
  /// 规则ID
  final String id;
  
  /// 规则名称
  final String name;
  
  /// 规则描述
  @JsonKey(defaultValue: '')
  final String description;
  
  /// 条件表达式
  final String condition;
  
  /// 动作配置
  final Map<String, dynamic> action;
  
  /// 优先级
  @JsonKey(defaultValue: 0)
  final int priority;
  
  /// 是否启用
  @JsonKey(defaultValue: true)
  final bool enabled;
  
  /// 规则参数
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> parameters;

  const Rule({
    required this.id,
    required this.name,
    this.description = '',
    required this.condition,
    required this.action,
    this.priority = 0,
    this.enabled = true,
    this.parameters = const {},
  });

  @override
  List<Object?> get props =>
      [id, name, description, condition, action, priority, enabled, parameters];

  /// 从JSON创建实例
  factory Rule.fromJson(Map<String, dynamic> json) => _$RuleFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RuleToJson(this);

  @override
  String toString() {
    return 'Rule(id: $id, name: $name, enabled: $enabled)';
  }
}

/// 规则集类型枚举
/// Version: v0.2 (json_serializable)
@JsonEnum()
enum RuleSetType {
  /// 标准规则集
  standard,
  
  /// 条件规则集
  conditional,
  
  /// 验证规则集
  validation,
  
  /// 转换规则集
  transformation,
  
  /// 自定义规则集
  custom,
}