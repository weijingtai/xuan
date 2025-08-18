/// 原子操作模型
/// Version: v0.1
/// 定义原子操作的基础接口和实现
library atomic_operation;

import 'dart:core';

import 'execution_context.dart';

/// 原子操作抽象类
/// Version: v0.1
abstract class AtomicOperation {
  /// 操作ID
  final String id;

  /// 操作名称
  final String name;

  /// 操作描述
  final String description;

  /// 操作类别
  final String category;

  /// 操作版本
  final String version;

  /// 输入参数定义
  Map<String, ParameterDefinition> get inputParameters;

  /// 输出参数定义
  Map<String, ParameterDefinition> get outputParameters;

  /// 配置参数定义
  Map<String, ParameterDefinition> get configParameters;

  AtomicOperation({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.version,
  });

  /// 执行操作
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> inputs,
    Map<String, dynamic> config,
  );

  /// 验证输入参数
  bool validateInputs(Map<String, dynamic> inputs) {
    for (final entry in inputParameters.entries) {
      final paramName = entry.key;
      final paramDef = entry.value;

      if (paramDef.required && !inputs.containsKey(paramName)) {
        return false;
      }

      if (inputs.containsKey(paramName)) {
        final value = inputs[paramName];
        if (!paramDef.validateValue(value)) {
          return false;
        }
      }
    }
    return true;
  }

  /// 验证配置参数
  bool validateConfig(Map<String, dynamic> config) {
    for (final entry in configParameters.entries) {
      final paramName = entry.key;
      final paramDef = entry.value;

      if (paramDef.required && !config.containsKey(paramName)) {
        return false;
      }

      if (config.containsKey(paramName)) {
        final value = config[paramName];
        if (!paramDef.validateValue(value)) {
          return false;
        }
      }
    }
    return true;
  }

  /// 获取操作信息
  Map<String, dynamic> getInfo() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'version': version,
      'inputParameters': inputParameters.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'outputParameters': outputParameters.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'configParameters': configParameters.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }
}

/// 参数定义类
/// Version: v0.1
class ParameterDefinition {
  /// 参数名称
  final String name;

  /// 参数描述
  final String? description;

  /// 参数类型
  final ParameterType type;

  /// 是否必需
  final bool required;

  /// 默认值
  final dynamic defaultValue;

  /// 验证规则
  final List<ValidationRule> validationRules;

  /// 示例值
  final dynamic exampleValue;

  const ParameterDefinition({
    required this.name,
    this.description,
    required this.type,
    this.required = true,
    this.defaultValue,
    this.validationRules = const [],
    this.exampleValue,
  });

  /// 验证参数值
  bool validateValue(dynamic value) {
    // 检查类型
    if (!type.isValidType(value)) {
      return false;
    }

    // 执行验证规则
    for (final rule in validationRules) {
      if (!rule.validate(value)) {
        return false;
      }
    }

    return true;
  }

  /// 从JSON创建实例
  factory ParameterDefinition.fromJson(Map<String, dynamic> json) {
    return ParameterDefinition(
      name: json['name'] as String,
      description: json['description'] as String,
      type: ParameterType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
      required: json['required'] as bool? ?? true,
      defaultValue: json['defaultValue'],
      validationRules: (json['validationRules'] as List<dynamic>? ?? [])
          .map((rule) => ValidationRule.fromJson(rule as Map<String, dynamic>))
          .toList(),
      exampleValue: json['exampleValue'],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'required': required,
      if (defaultValue != null) 'defaultValue': defaultValue,
      'validationRules': validationRules.map((rule) => rule.toJson()).toList(),
      if (exampleValue != null) 'exampleValue': exampleValue,
    };
  }

  @override
  String toString() {
    return 'ParameterDefinition(name: $name, type: $type, required: $required)';
  }
}

/// 参数类型枚举
/// Version: v0.1
enum ParameterType {
  /// 字符串
  str,

  /// 整数
  intNum,

  /// 浮点数
  doubleNum,

  /// 布尔值
  boolean,

  /// 列表
  array,

  /// 映射
  dict,

  /// 任意类型
  any;

  /// 检查值是否为有效类型
  bool isValidType(dynamic value) {
    switch (this) {
      case ParameterType.str:
        return value is String;
      case ParameterType.intNum:
        return value is int;
      case ParameterType.doubleNum:
        return true;
      case ParameterType.boolean:
        return true;
      case ParameterType.array:
        return value is List;
      case ParameterType.dict:
        return value is Map;
      case ParameterType.any:
        return true;
      default:
        return false;
    }
    return false;
  }
}

/// 验证规则类
/// Version: v0.1
class ValidationRule {
  /// 规则类型
  final ValidationType type;

  /// 规则参数
  final Map<String, dynamic> parameters;

  /// 错误消息
  final String errorMessage;

  const ValidationRule({
    required this.type,
    required this.parameters,
    required this.errorMessage,
  });

  /// 验证值
  bool validate(dynamic value) {
    switch (type) {
      case ValidationType.minLength:
        if (value is String) {
          final minLength = parameters['minLength'] as int;
          return value.length >= minLength;
        }
        return false;

      case ValidationType.maxLength:
        if (value is String) {
          final maxLength = parameters['maxLength'] as int;
          return value.length <= maxLength;
        }
        return false;

      case ValidationType.range:
        if (value is num) {
          final min = parameters['min'] as num;
          final max = parameters['max'] as num;
          return value >= min && value <= max;
        }
        return false;

      case ValidationType.pattern:
        if (value is String) {
          final pattern = parameters['pattern'] as String;
          return RegExp(pattern).hasMatch(value);
        }
        return false;

      case ValidationType.custom:
        // 自定义验证逻辑
        return true;
    }
  }

  /// 从JSON创建实例
  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    return ValidationRule(
      type: ValidationType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
      parameters: json['parameters'] as Map<String, dynamic>,
      errorMessage: json['errorMessage'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'parameters': parameters,
      'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return 'ValidationRule(type: $type, parameters: $parameters)';
  }
}

/// 验证类型枚举
/// Version: v0.1
enum ValidationType {
  /// 最小长度
  minLength,

  /// 最大长度
  maxLength,

  /// 数值范围
  range,

  /// 正则表达式
  pattern,

  /// 自定义验证
  custom,
}
