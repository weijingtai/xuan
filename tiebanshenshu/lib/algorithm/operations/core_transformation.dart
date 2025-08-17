/// 算法编译器 - 核心转换原子操作
///
/// 版本: v0.1
/// 作者: Algorithm Compiler Team
/// 创建时间: 2024
///
/// 功能说明:
/// - 提供数据转换和映射操作
/// - 支持类型转换和格式化
/// - 实现业务逻辑转换规则

import '../models/atomic_operation.dart';
import '../models/execution_context.dart';

/// 数据类型转换操作
class DataTypeConversionOperation extends AtomicOperation {
  DataTypeConversionOperation()
    : super(
        id: 'data_type_conversion',
        name: '数据类型转换',
        category: '核心转换',
        description: '在不同数据类型之间进行转换',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'value': ParameterDefinition(
      name: 'value',
      type: ParameterType.any,
      required: true,
      description: '待转换的值',
    ),
    'target_type': ParameterDefinition(
      name: 'target_type',
      type: ParameterType.str,
      required: true,
      description: '目标类型',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'converted_value': ParameterDefinition(
      name: 'converted_value',
      type: ParameterType.any,
      required: true,
      description: '转换后的值',
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
    final value = inputs['value'];
    final targetType = inputs['target_type'] as String;

    final converted = _convertType(value, targetType);

    return {
      'converted_value': converted,
      'original_type': value.runtimeType.toString(),
      'target_type': targetType,
      'conversion_success': converted != null,
    };
  }

  dynamic _convertType(dynamic value, String targetType) {
    try {
      switch (targetType.toLowerCase()) {
        case 'string':
          return value.toString();
        case 'int':
          if (value is int) return value;
          if (value is double) return value.toInt();
          if (value is String) return int.tryParse(value);
          return null;
        case 'double':
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) return double.tryParse(value);
          return null;
        case 'bool':
          if (value is bool) return value;
          if (value is String) {
            return value.toLowerCase() == 'true' || value == '1';
          }
          if (value is num) return value != 0;
          return null;
        case 'list':
          if (value is List) return value;
          return [value];
        default:
          return value;
      }
    } catch (e) {
      return null;
    }
  }
}

/// 数据映射操作
class DataMappingOperation extends AtomicOperation {
  DataMappingOperation()
    : super(
        id: 'data_mapping',
        name: '数据映射',
        category: '核心转换',
        description: '根据映射规则转换数据结构',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'data': ParameterDefinition(
      name: 'data',
      type: ParameterType.any,
      required: true,
      description: '待映射的数据',
    ),
    'mapping_rules': ParameterDefinition(
      name: 'mapping_rules',
      type: ParameterType.dict,
      required: true,
      description: '映射规则，键为源字段路径，值为目标字段路径',
      defaultValue: {},
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'mapped_data': ParameterDefinition(
      name: 'mapped_data',
      type: ParameterType.dict,
      required: true,
      description: '映射后的数据',
    ),
    'mapping_count': ParameterDefinition(
      name: 'mapping_count',
      type: ParameterType.intNum,
      required: true,
      description: '成功映射的字段数量',
    ),
    'applied_rules': ParameterDefinition(
      name: 'applied_rules',
      type: ParameterType.intNum,
      required: true,
      description: '应用的映射规则数量',
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
    final data = input['data'];
    final mappingRules = input['mapping_rules'] as Map<String, String>? ?? {};

    final mapped = <String, dynamic>{};

    for (final entry in mappingRules.entries) {
      final sourceField = entry.key;
      final targetField = entry.value;

      final value = _getNestedValue(data, sourceField);
      if (value != null) {
        _setNestedValue(mapped, targetField, value);
      }
    }

    return {
      'mapped_data': mapped,
      'mapping_count': mapped.length,
      'applied_rules': mappingRules.length,
    };
  }

  dynamic _getNestedValue(dynamic data, String path) {
    final parts = path.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return null;
      }
    }

    return current;
  }

  void _setNestedValue(
    Map<String, dynamic> target,
    String path,
    dynamic value,
  ) {
    final parts = path.split('.');
    Map<String, dynamic> current = target;

    for (int i = 0; i < parts.length - 1; i++) {
      final part = parts[i];
      if (!current.containsKey(part)) {
        current[part] = <String, dynamic>{};
      }
      current = current[part] as Map<String, dynamic>;
    }

    current[parts.last] = value;
  }
}

/// 格式化操作
class FormattingOperation extends AtomicOperation {
  FormattingOperation()
    : super(
        id: 'formatting',
        name: '格式化',
        category: '核心转换',
        description: '对数据进行格式化处理',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'value': ParameterDefinition(
      name: 'value',
      type: ParameterType.any,
      required: true,
      description: '待格式化的值',
    ),
    'format': ParameterDefinition(
      name: 'format',
      type: ParameterType.str,
      required: false,
      description:
          '格式化类型：currency, percentage, date, uppercase, lowercase, capitalize',
      defaultValue: 'default',
    ),
    'options': ParameterDefinition(
      name: 'options',
      type: ParameterType.dict,
      required: false,
      description: '格式化选项，如货币符号、精度等',
      defaultValue: {},
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'formatted_value': ParameterDefinition(
      name: 'formatted_value',
      type: ParameterType.str,
      required: true,
      description: '格式化后的值',
    ),
    'original_value': ParameterDefinition(
      name: 'original_value',
      type: ParameterType.any,
      required: true,
      description: '原始值',
    ),
    'format_type': ParameterDefinition(
      name: 'format_type',
      type: ParameterType.str,
      required: true,
      description: '使用的格式化类型',
    ),
    'format_options': ParameterDefinition(
      name: 'format_options',
      type: ParameterType.dict,
      required: true,
      description: '使用的格式化选项',
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
    final value = input['value'];
    final format = input['format'] as String? ?? 'default';
    final options = input['options'] as Map<String, dynamic>? ?? {};

    final formatted = _formatValue(value, format, options);

    return {
      'formatted_value': formatted,
      'original_value': value,
      'format_type': format,
      'format_options': options,
    };
  }

  String _formatValue(
    dynamic value,
    String format,
    Map<String, dynamic> options,
  ) {
    switch (format.toLowerCase()) {
      case 'currency':
        final currency = options['currency'] as String? ?? 'CNY';
        final precision = options['precision'] as int? ?? 2;
        if (value is num) {
          return '$currency ${value.toStringAsFixed(precision)}';
        }
        return value.toString();

      case 'percentage':
        final precision = options['precision'] as int? ?? 1;
        if (value is num) {
          return '${(value * 100).toStringAsFixed(precision)}%';
        }
        return value.toString();

      case 'date':
        final pattern = options['pattern'] as String? ?? 'yyyy-MM-dd';
        if (value is DateTime) {
          return _formatDate(value, pattern);
        }
        return value.toString();

      case 'uppercase':
        return value.toString().toUpperCase();

      case 'lowercase':
        return value.toString().toLowerCase();

      case 'capitalize':
        final str = value.toString();
        if (str.isEmpty) return str;
        return str[0].toUpperCase() + str.substring(1).toLowerCase();

      default:
        return value.toString();
    }
  }

  String _formatDate(DateTime date, String pattern) {
    // 简化的日期格式化实现
    return pattern
        .replaceAll('yyyy', date.year.toString())
        .replaceAll('MM', date.month.toString().padLeft(2, '0'))
        .replaceAll('dd', date.day.toString().padLeft(2, '0'))
        .replaceAll('HH', date.hour.toString().padLeft(2, '0'))
        .replaceAll('mm', date.minute.toString().padLeft(2, '0'))
        .replaceAll('ss', date.second.toString().padLeft(2, '0'));
  }
}

/// 核心转换操作包装类
class CoreTransformation {
  static List<AtomicOperation> getOperations() {
    return [
      DataTypeConversionOperation(),
      DataMappingOperation(),
      FormattingOperation(),
    ];
  }
}
