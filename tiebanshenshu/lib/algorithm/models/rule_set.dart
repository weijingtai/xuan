/// 规则集模型
/// Version: v0.1
/// 定义算法中使用的规则集合
library rule_set;

/// 规则集类
/// Version: v0.1
class RuleSet {
  /// 规则集名称
  final String name;
  
  /// 规则集描述
  final String description;
  
  /// 规则列表
  final List<Rule> rules;
  
  /// 规则集类型
  final RuleSetType type;
  
  /// 优先级
  final int priority;
  
  /// 是否启用
  final bool enabled;

  const RuleSet({
    required this.name,
    required this.description,
    required this.rules,
    this.type = RuleSetType.standard,
    this.priority = 0,
    this.enabled = true,
  });

  /// 从JSON创建实例
  factory RuleSet.fromJson(Map<String, dynamic> json) {
    return RuleSet(
      name: json['name'] as String,
      description: json['description'] as String,
      rules: (json['rules'] as List<dynamic>)
          .map((rule) => Rule.fromJson(rule as Map<String, dynamic>))
          .toList(),
      type: RuleSetType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => RuleSetType.standard,
      ),
      priority: json['priority'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'rules': rules.map((rule) => rule.toJson()).toList(),
      'type': type.name,
      'priority': priority,
      'enabled': enabled,
    };
  }

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
/// Version: v0.1
class Rule {
  /// 规则ID
  final String id;
  
  /// 规则名称
  final String name;
  
  /// 规则描述
  final String description;
  
  /// 条件表达式
  final String condition;
  
  /// 动作配置
  final Map<String, dynamic> action;
  
  /// 优先级
  final int priority;
  
  /// 是否启用
  final bool enabled;
  
  /// 规则参数
  final Map<String, dynamic> parameters;

  const Rule({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.action,
    this.priority = 0,
    this.enabled = true,
    this.parameters = const {},
  });

  /// 从JSON创建实例
  factory Rule.fromJson(Map<String, dynamic> json) {
    return Rule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      condition: json['condition'] as String,
      action: json['action'] as Map<String, dynamic>,
      priority: json['priority'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'condition': condition,
      'action': action,
      'priority': priority,
      'enabled': enabled,
      'parameters': parameters,
    };
  }

  @override
  String toString() {
    return 'Rule(id: $id, name: $name, enabled: $enabled)';
  }
}

/// 规则集类型枚举
/// Version: v0.1
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