/// 条件分支模型
/// Version: v0.1
/// 定义条件逻辑和分支执行
library conditional_branch;

/// 条件分支类
/// Version: v0.1
class ConditionalBranch {
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
    required this.description,
    required this.trueSteps,
    this.falseSteps,
    this.type = ConditionType.expression,
    this.parameters = const {},
  });

  /// 从JSON创建实例
  factory ConditionalBranch.fromJson(Map<String, dynamic> json) {
    return ConditionalBranch(
      condition: json['condition'] as String,
      description: json['description'] as String,
      trueSteps: List<String>.from(json['trueSteps'] as List),
      falseSteps: json['falseSteps'] != null
          ? List<String>.from(json['falseSteps'] as List)
          : null,
      type: ConditionType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => ConditionType.expression,
      ),
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'condition': condition,
      'description': description,
      'trueSteps': trueSteps,
      if (falseSteps != null) 'falseSteps': falseSteps,
      'type': type.name,
      'parameters': parameters,
    };
  }

  @override
  String toString() {
    return 'ConditionalBranch(condition: $condition, trueSteps: ${trueSteps.length}, falseSteps: ${falseSteps?.length ?? 0})';
  }
}

/// 条件类型枚举
/// Version: v0.1
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