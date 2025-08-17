/// 算法配置模型
/// Version: v0.1
/// 定义算法的完整配置结构
library algorithm_config;

import 'execution_step.dart';
import 'rule_set.dart';

/// 算法配置类
/// Version: v0.1
class AlgorithmConfig {
  /// 算法名称
  final String name;

  /// 算法版本
  final String version;

  /// 算法描述
  final String description;

  /// 执行步骤列表
  final List<ExecutionStep> steps;

  /// 全局配置
  final Map<String, dynamic>? globalConfig;

  /// 规则集
  final List<RuleSet> ruleSets;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  const AlgorithmConfig({
    required this.name,
    required this.version,
    required this.description,
    required this.steps,
    this.ruleSets = const [],
    this.globalConfig,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON创建实例
  factory AlgorithmConfig.fromJson(Map<String, dynamic> json) {
    return AlgorithmConfig(
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((step) => ExecutionStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      globalConfig: json['globalConfig'] as Map<String, dynamic>,
      ruleSets: (json['ruleSets'] as List<dynamic>)
          .map((ruleSet) => RuleSet.fromJson(ruleSet as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// 复制配置
  AlgorithmConfig copyWith({
    String? name,
    String? version,
    String? description,
    List<ExecutionStep>? steps,
    Map<String, dynamic>? globalConfig,
    List<RuleSet>? ruleSets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlgorithmConfig(
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      globalConfig: globalConfig ?? this.globalConfig,
      ruleSets: ruleSets ?? this.ruleSets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'description': description,
      'steps': steps.map((step) => step.toJson()).toList(),
      'globalConfig': globalConfig,
      'ruleSets': ruleSets.map((ruleSet) => ruleSet.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 获取指定ID的步骤
  ExecutionStep? getStepById(String stepId) {
    try {
      return steps.firstWhere((step) => step.id == stepId);
    } catch (e) {
      return null;
    }
  }

  /// 获取指定名称的规则集
  RuleSet? getRuleSetByName(String name) {
    try {
      return ruleSets.firstWhere((ruleSet) => ruleSet.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 验证配置有效性
  bool validate() {
    // 检查基本字段
    if (name.isEmpty || version.isEmpty || steps.isEmpty) {
      return false;
    }

    // 检查步骤ID唯一性
    final stepIds = steps.map((step) => step.id).toSet();
    if (stepIds.length != steps.length) {
      return false;
    }

    // 检查规则集名称唯一性
    final ruleSetNames = ruleSets.map((ruleSet) => ruleSet.name).toSet();
    if (ruleSetNames.length != ruleSets.length) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'AlgorithmConfig(name: $name, version: $version, steps: ${steps.length}, ruleSets: ${ruleSets.length})';
  }
}
