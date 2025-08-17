/// 算法编译器 - 输入与分解原子操作
///
/// 版本: v0.1
/// 作者: Algorithm Compiler Team
/// 创建时间: 2024
///
/// 功能说明:
/// - 提供输入数据的解析和分解操作
/// - 支持多种输入格式的标准化处理
/// - 实现数据验证和预处理逻辑

import '../models/atomic_operation.dart';
import '../models/execution_context.dart';

/// 输入处理操作
class InputProcessingOperation extends AtomicOperation {
  InputProcessingOperation()
    : super(
        id: 'input_processing',
        name: '输入处理',
        category: '输入与分解',
        description: '处理和验证输入数据',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'raw_input': ParameterDefinition(
      name: 'raw_input',
      type: ParameterType.any,
      required: true,
      description: '原始输入数据',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'processed_input': ParameterDefinition(
      name: 'processed_input',
      type: ParameterType.dict,
      required: true,
      description: '处理后的输入数据',
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
    final rawInput = inputs['raw_input'];

    // 验证输入格式
    if (rawInput == null) {
      throw ArgumentError('缺少必要的输入数据');
    }

    // 标准化处理
    final processedInput = _normalizeInput(rawInput);

    return {
      'processed_input': processedInput,
      'input_type': _detectInputType(rawInput),
      'validation_status': 'valid',
    };
  }

  Map<String, dynamic> _normalizeInput(dynamic input) {
    if (input is Map<String, dynamic>) {
      return input;
    } else if (input is String) {
      return {'text': input};
    } else {
      return {'value': input};
    }
  }

  String _detectInputType(dynamic input) {
    if (input is Map) return 'object';
    if (input is List) return 'array';
    if (input is String) return 'string';
    if (input is num) return 'number';
    return 'unknown';
  }
}

/// 数据分解操作
class DataDecompositionOperation extends AtomicOperation {
  DataDecompositionOperation()
    : super(
        id: 'data_decomposition',
        name: '数据分解',
        category: '输入与分解',
        description: '将复合数据分解为基础组件',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'data': ParameterDefinition(
      name: 'data',
      type: ParameterType.any,
      description: '要分解的数据',
      required: true,
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'components': ParameterDefinition(
      name: 'components',
      type: ParameterType.array,
      description: '分解后的组件列表',
      required: true,
    ),
    'structure': ParameterDefinition(
      name: 'structure',
      type: ParameterType.str,
      description: '数据结构类型',
      required: true,
    ),
    'size': ParameterDefinition(
      name: 'size',
      type: ParameterType.intNum,
      description: '数据大小',
      required: true,
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

    if (data is Map<String, dynamic>) {
      return _decomposeObject(data);
    } else if (data is List) {
      return _decomposeArray(data);
    } else {
      return {
        'components': [data],
        'structure': 'primitive',
        'size': 1,
      };
    }
  }

  Map<String, dynamic> _decomposeObject(Map<String, dynamic> obj) {
    return {
      'components': obj.entries
          .map(
            (e) => {
              'key': e.key,
              'value': e.value,
              'type': e.value.runtimeType.toString(),
            },
          )
          .toList(),
      'structure': 'object',
      'size': obj.length,
    };
  }

  Map<String, dynamic> _decomposeArray(List arr) {
    return {
      'components': arr
          .asMap()
          .entries
          .map(
            (e) => {
              'index': e.key,
              'value': e.value,
              'type': e.value.runtimeType.toString(),
            },
          )
          .toList(),
      'structure': 'array',
      'size': arr.length,
    };
  }
}

class FieldExtractionOperation extends AtomicOperation {
  FieldExtractionOperation()
    : super(
        id: 'field_extraction',
        name: '字段提取',
        category: '输入与分解',
        description: '从数据结构中提取指定字段',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'data': ParameterDefinition(
      name: 'data',
      type: ParameterType.any,
      description: '要提取字段的数据',
      required: true,
    ),
    'fields': ParameterDefinition(
      name: 'fields',
      type: ParameterType.array,
      description: '要提取的字段路径列表',
      required: true,
      defaultValue: [],
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'extracted_fields': ParameterDefinition(
      name: 'extracted_fields',
      type: ParameterType.dict,
      description: '提取的字段及其值',
      required: true,
    ),
    'extraction_count': ParameterDefinition(
      name: 'extraction_count',
      type: ParameterType.intNum,
      description: '成功提取的字段数量',
      required: true,
    ),
    'missing_fields': ParameterDefinition(
      name: 'missing_fields',
      type: ParameterType.array,
      description: '未找到的字段列表',
      required: true,
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
    final fields = input['fields'] as List<String>? ?? [];

    final extracted = <String, dynamic>{};

    for (final field in fields) {
      final value = _extractField(data, field);
      if (value != null) {
        extracted[field] = value;
      }
    }

    return {
      'extracted_fields': extracted,
      'extraction_count': extracted.length,
      'missing_fields': fields.where((f) => !extracted.containsKey(f)).toList(),
    };
  }

  dynamic _extractField(dynamic data, String fieldPath) {
    final parts = fieldPath.split('.');
    dynamic current = data;

    for (final part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else if (current is List && int.tryParse(part) != null) {
        final index = int.parse(part);
        if (index >= 0 && index < current.length) {
          current = current[index];
        } else {
          return null;
        }
      } else {
        return null;
      }
    }

    return current;
  }
}

/// 输入与分解操作包装类
class InputDecomposition {
  /// 获取所有输入与分解类操作实例
  static List<AtomicOperation> getOperations() {
    return [
      InputProcessingOperation(),
      DataDecompositionOperation(),
      FieldExtractionOperation(),
    ];
  }
}
