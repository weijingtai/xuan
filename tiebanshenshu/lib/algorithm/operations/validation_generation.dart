/// 算法编译器 - 验证与生成原子操作
///
/// 版本: v0.1
/// 作者: Algorithm Compiler Team
/// 创建时间: 2024
///
/// 功能说明:
/// - 提供数据验证和内容生成操作
/// - 支持规则验证和格式检查
/// - 实现动态内容生成逻辑

import '../models/atomic_operation.dart';
import '../models/execution_context.dart';

/// 数据验证操作
class DataValidationOperation extends AtomicOperation {
  DataValidationOperation()
    : super(
        id: 'data_validation',
        name: '数据验证',
        category: '验证与生成',
        description: '验证数据是否符合指定规则',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'data': ParameterDefinition(
      name: 'data',
      type: ParameterType.any,
      required: true,
      description: '待验证的数据',
    ),
    'rules': ParameterDefinition(
      name: 'rules',
      type: ParameterType.array,
      required: true,
      description: '验证规则列表',
    ),
    'strict': ParameterDefinition(
      name: 'strict',
      type: ParameterType.boolean,
      required: false,
      description: '严格模式',
      defaultValue: false,
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'valid': ParameterDefinition(
      name: 'valid',
      type: ParameterType.boolean,
      required: true,
      description: '验证结果',
    ),
  };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> inputs,
    Map<String, dynamic> config,
  ) async {
    final data = inputs['data'];
    final rules = inputs['rules'] as List? ?? [];
    final strict = inputs['strict'] as bool? ?? false;

    final validationResults = <Map<String, dynamic>>[];
    bool allValid = true;

    for (final rule in rules) {
      if (rule is Map<String, dynamic>) {
        final result = _validateRule(data, rule);
        validationResults.add(result);

        if (!result['valid'] as bool) {
          allValid = false;
          if (strict) break;
        }
      }
    }

    return {
      'valid': allValid,
      'validation_results': validationResults,
      'rules_checked': validationResults.length,
      'strict_mode': strict,
      'data': data,
    };
  }

  Map<String, dynamic> _validateRule(dynamic data, Map<String, dynamic> rule) {
    final ruleType = rule['type'] as String? ?? 'required';
    final field = rule['field'] as String?;
    final value = field != null ? _getFieldValue(data, field) : data;

    switch (ruleType.toLowerCase()) {
      case 'required':
        return {
          'rule': ruleType,
          'field': field,
          'valid': value != null,
          'message': value != null ? '字段存在' : '字段不能为空',
        };

      case 'type':
        final expectedType = rule['expected_type'] as String? ?? 'string';
        final actualType = value.runtimeType.toString().toLowerCase();
        final valid = _checkType(value, expectedType);
        return {
          'rule': ruleType,
          'field': field,
          'valid': valid,
          'expected_type': expectedType,
          'actual_type': actualType,
          'message': valid ? '类型匹配' : '类型不匹配: 期望 $expectedType, 实际 $actualType',
        };

      case 'range':
        final min = rule['min'];
        final max = rule['max'];
        final valid = _checkRange(value, min, max);
        return {
          'rule': ruleType,
          'field': field,
          'valid': valid,
          'min': min,
          'max': max,
          'value': value,
          'message': valid ? '值在范围内' : '值超出范围 [$min, $max]',
        };

      case 'length':
        final minLength = rule['min_length'] as int? ?? 0;
        final maxLength = rule['max_length'] as int?;
        final valid = _checkLength(value, minLength, maxLength);
        return {
          'rule': ruleType,
          'field': field,
          'valid': valid,
          'min_length': minLength,
          'max_length': maxLength,
          'actual_length': _getLength(value),
          'message': valid ? '长度符合要求' : '长度不符合要求',
        };

      case 'pattern':
        final pattern = rule['pattern'] as String? ?? '';
        final valid = _checkPattern(value, pattern);
        return {
          'rule': ruleType,
          'field': field,
          'valid': valid,
          'pattern': pattern,
          'value': value,
          'message': valid ? '格式正确' : '格式不匹配模式: $pattern',
        };

      case 'custom':
        final validator = rule['validator'] as Function?;
        final valid = validator?.call(value) ?? true;
        return {
          'rule': ruleType,
          'field': field,
          'valid': valid,
          'message': valid ? '自定义验证通过' : '自定义验证失败',
        };

      default:
        return {
          'rule': ruleType,
          'field': field,
          'valid': false,
          'message': '未知的验证规则: $ruleType',
        };
    }
  }

  dynamic _getFieldValue(dynamic data, String field) {
    if (data is Map<String, dynamic>) {
      return data[field];
    }
    return null;
  }

  bool _checkType(dynamic value, String expectedType) {
    switch (expectedType.toLowerCase()) {
      case 'string':
        return value is String;
      case 'int':
      case 'integer':
        return value is int;
      case 'double':
        return value is double;
      case 'num':
      case 'number':
        return value is num;
      case 'bool':
      case 'boolean':
        return value is bool;
      case 'list':
      case 'array':
        return value is List;
      case 'map':
      case 'object':
        return value is Map;
      default:
        return true;
    }
  }

  bool _checkRange(dynamic value, dynamic min, dynamic max) {
    if (value is! num) return false;

    if (min != null && min is num && value < min) return false;
    if (max != null && max is num && value > max) return false;

    return true;
  }

  bool _checkLength(dynamic value, int minLength, int? maxLength) {
    final length = _getLength(value);
    if (length == null) return false;

    if (length < minLength) return false;
    if (maxLength != null && length > maxLength) return false;

    return true;
  }

  int? _getLength(dynamic value) {
    if (value is String) return value.length;
    if (value is List) return value.length;
    if (value is Map) return value.length;
    return null;
  }

  bool _checkPattern(dynamic value, String pattern) {
    if (value is! String || pattern.isEmpty) return false;

    try {
      final regex = RegExp(pattern);
      return regex.hasMatch(value);
    } catch (e) {
      return false;
    }
  }
}

/// 内容生成操作
class ContentGenerationOperation extends AtomicOperation {
  ContentGenerationOperation()
    : super(
        id: 'content_generation',
        name: '内容生成',
        category: '验证与生成',
        description: '根据模板和数据生成内容',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'template': ParameterDefinition(
      name: 'template',
      type: ParameterType.str,
      required: true,
      description: '内容生成模板',
    ),
    'data': ParameterDefinition(
      name: 'data',
      type: ParameterType.dict,
      required: false,
      description: '模板数据',
      defaultValue: {},
    ),
    'format': ParameterDefinition(
      name: 'format',
      type: ParameterType.str,
      required: false,
      description: '输出格式 (text, json, html, markdown)',
      defaultValue: 'text',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'generated_content': ParameterDefinition(
      name: 'generated_content',
      type: ParameterType.str,
      required: true,
      description: '生成的内容',
    ),
    'generation_time': ParameterDefinition(
      name: 'generation_time',
      type: ParameterType.intNum,
      required: false,
      description: '生成时间戳',
    ),
  };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> input,
    Map<String, dynamic> config,
  ) async {
    final template = input['template'] as String? ?? '';
    final data = input['data'] as Map<String, dynamic>? ?? {};
    final format = input['format'] as String? ?? 'text';

    final generated = _generateContent(template, data, format);

    return {
      'generated_content': generated,
      'template': template,
      'data': data,
      'format': format,
      'generation_time': DateTime.now().millisecondsSinceEpoch,
    };
  }

  String _generateContent(
    String template,
    Map<String, dynamic> data,
    String format,
  ) {
    String result = template;

    // 替换变量占位符 {{variable}}
    final variablePattern = RegExp(r'\{\{\s*(\w+)\s*\}\}');
    result = result.replaceAllMapped(variablePattern, (match) {
      final variable = match.group(1)!;
      return data[variable]?.toString() ?? '';
    });

    // 替换表达式占位符 {%expression%}
    final expressionPattern = RegExp(r'\{%\s*(.+?)\s*%\}');
    result = result.replaceAllMapped(expressionPattern, (match) {
      final expression = match.group(1)!;
      return _evaluateExpression(expression, data);
    });

    // 根据格式进行后处理
    switch (format.toLowerCase()) {
      case 'json':
        try {
          // 尝试解析为JSON并格式化
          return result;
        } catch (e) {
          return result;
        }

      case 'html':
        return _formatAsHtml(result);

      case 'markdown':
        return _formatAsMarkdown(result);

      default:
        return result;
    }
  }

  String _evaluateExpression(String expression, Map<String, dynamic> data) {
    // 简化的表达式求值
    try {
      // 处理简单的条件表达式
      if (expression.contains('?')) {
        final parts = expression.split('?');
        if (parts.length == 2) {
          final condition = parts[0].trim();
          final branches = parts[1].split(':');
          if (branches.length == 2) {
            final conditionResult = _evaluateCondition(condition, data);
            return conditionResult ? branches[0].trim() : branches[1].trim();
          }
        }
      }

      // 处理变量引用
      if (data.containsKey(expression)) {
        return data[expression].toString();
      }

      return expression;
    } catch (e) {
      return expression;
    }
  }

  bool _evaluateCondition(String condition, Map<String, dynamic> data) {
    // 简化的条件求值
    final parts = condition.split(' ');
    if (parts.length >= 3) {
      final left = data[parts[0]];
      final operator = parts[1];
      final right = parts[2];

      switch (operator) {
        case '==':
          return left.toString() == right;
        case '!=':
          return left.toString() != right;
        case '>':
          return left is num &&
              num.tryParse(right) != null &&
              left > num.parse(right);
        case '<':
          return left is num &&
              num.tryParse(right) != null &&
              left < num.parse(right);
        default:
          return false;
      }
    }

    return data[condition] == true;
  }

  String _formatAsHtml(String content) {
    return content.replaceAll('\n', '<br>\n').replaceAll('  ', '&nbsp;&nbsp;');
  }

  String _formatAsMarkdown(String content) {
    // 基础的Markdown格式化
    return content;
  }
}

/// 序列生成操作
class SequenceGenerationOperation extends AtomicOperation {
  SequenceGenerationOperation()
    : super(
        id: 'sequence_generation',
        name: '序列生成',
        category: '验证与生成',
        description: '生成数字或字符序列',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'type': ParameterDefinition(
      name: 'type',
      type: ParameterType.str,
      required: false,
      description: '序列类型 (numeric, alphabetic, pattern, fibonacci, prime)',
      defaultValue: 'numeric',
    ),
    'start': ParameterDefinition(
      name: 'start',
      type: ParameterType.any,
      required: false,
      description: '起始值',
      defaultValue: 0,
    ),
    'count': ParameterDefinition(
      name: 'count',
      type: ParameterType.intNum,
      required: false,
      description: '生成数量',
      defaultValue: 10,
    ),
    'step': ParameterDefinition(
      name: 'step',
      type: ParameterType.any,
      required: false,
      description: '步长',
      defaultValue: 1,
    ),
    'pattern': ParameterDefinition(
      name: 'pattern',
      type: ParameterType.str,
      required: false,
      description: '模式字符串 (用于pattern类型)',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'sequence': ParameterDefinition(
      name: 'sequence',
      type: ParameterType.array,
      required: true,
      description: '生成的序列',
    ),
  };

  @override
  Map<String, ParameterDefinition> get configParameters => {};

  @override
  Future<Map<String, dynamic>> execute(
    ExecutionContext context,
    Map<String, dynamic> input,
    Map<String, dynamic> config,
  ) async {
    final type = input['type'] as String? ?? 'numeric';
    final start = input['start'] ?? 0;
    final count = input['count'] as int? ?? 10;
    final step = input['step'] ?? 1;
    final pattern = input['pattern'] as String?;

    final sequence = _generateSequence(type, start, count, step, pattern);

    return {
      'sequence': sequence,
      'type': type,
      'start': start,
      'count': count,
      'step': step,
      'pattern': pattern,
    };
  }

  List<dynamic> _generateSequence(
    String type,
    dynamic start,
    int count,
    dynamic step,
    String? pattern,
  ) {
    final sequence = <dynamic>[];

    switch (type.toLowerCase()) {
      case 'numeric':
        if (start is num && step is num) {
          for (int i = 0; i < count; i++) {
            sequence.add(start + (step * i));
          }
        }
        break;

      case 'alphabetic':
        if (start is String && start.length == 1) {
          final startCode = start.codeUnitAt(0);
          final stepValue = step is int ? step : 1;
          for (int i = 0; i < count; i++) {
            sequence.add(String.fromCharCode(startCode + (stepValue * i)));
          }
        }
        break;

      case 'pattern':
        if (pattern != null) {
          for (int i = 0; i < count; i++) {
            sequence.add(_applyPattern(pattern, i));
          }
        }
        break;

      case 'fibonacci':
        sequence.addAll(_generateFibonacci(count));
        break;

      case 'prime':
        sequence.addAll(_generatePrimes(count));
        break;

      default:
        for (int i = 0; i < count; i++) {
          sequence.add(i);
        }
    }

    return sequence;
  }

  String _applyPattern(String pattern, int index) {
    return pattern
        .replaceAll('{i}', index.toString())
        .replaceAll('{i+1}', (index + 1).toString())
        .replaceAll('{i*2}', (index * 2).toString());
  }

  List<int> _generateFibonacci(int count) {
    if (count <= 0) return [];
    if (count == 1) return [0];
    if (count == 2) return [0, 1];

    final fib = [0, 1];
    for (int i = 2; i < count; i++) {
      fib.add(fib[i - 1] + fib[i - 2]);
    }
    return fib;
  }

  List<int> _generatePrimes(int count) {
    final primes = <int>[];
    int candidate = 2;

    while (primes.length < count) {
      if (_isPrime(candidate)) {
        primes.add(candidate);
      }
      candidate++;
    }

    return primes;
  }

  bool _isPrime(int n) {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;

    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return false;
    }

    return true;
  }
}

/// 验证与生成操作包装类
class ValidationGeneration {
  /// 获取所有验证与生成类操作实例
  static List<AtomicOperation> getOperations() {
    return [
      DataValidationOperation(),
      ContentGenerationOperation(),
      SequenceGenerationOperation(),
    ];
  }
}
