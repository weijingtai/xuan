/// 算法编译器 - 聚合与运算原子操作
///
/// 版本: v0.1
/// 作者: Algorithm Compiler Team
/// 创建时间: 2024
///
/// 功能说明:
/// - 提供数据聚合和数学运算操作
/// - 支持统计计算和数值处理
/// - 实现复杂的数学运算逻辑

import '../models/atomic_operation.dart';
import '../models/execution_context.dart';
import 'dart:math' as math;

/// 数学运算操作
class MathCalculationOperation extends AtomicOperation {
  MathCalculationOperation()
    : super(
        id: 'math_calculation',
        name: '数学运算',
        category: '聚合与运算',
        description: '执行基础数学运算',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'operands': ParameterDefinition(
      name: 'operands',
      type: ParameterType.array,
      required: true,
      description: '运算操作数列表',
    ),
    'operation': ParameterDefinition(
      name: 'operation',
      type: ParameterType.str,
      required: false,
      description: '运算类型',
      defaultValue: 'add',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'result': ParameterDefinition(
      name: 'result',
      type: ParameterType.intNum,
      required: true,
      description: '运算结果',
    ),
    'operation': ParameterDefinition(
      name: 'operation',
      type: ParameterType.str,
      required: true,
      description: '执行的运算类型',
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
    final operands = inputs['operands'] as List? ?? [];
    final operation = inputs['operation'] as String? ?? 'add';

    if (operands.isEmpty) {
      throw ArgumentError('运算需要至少一个操作数');
    }

    final numericOperands = operands
        .map((e) => _toNumber(e))
        .where((e) => e != null)
        .cast<num>()
        .toList();

    if (numericOperands.isEmpty) {
      throw ArgumentError('没有有效的数值操作数');
    }

    final result = _performCalculation(numericOperands, operation);

    return {
      'result': result,
      'operation': operation,
      'operand_count': numericOperands.length,
      'original_operands': operands,
    };
  }

  num? _toNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  num _performCalculation(List<num> operands, String operation) {
    switch (operation.toLowerCase()) {
      case 'add':
      case '+':
        return operands.reduce((a, b) => a + b);

      case 'subtract':
      case '-':
        return operands.reduce((a, b) => a - b);

      case 'multiply':
      case '*':
        return operands.reduce((a, b) => a * b);

      case 'divide':
      case '/':
        return operands.reduce((a, b) => b != 0 ? a / b : 0);

      case 'power':
      case '^':
        return operands.reduce((a, b) => math.pow(a, b));

      case 'modulo':
      case '%':
        return operands.reduce((a, b) => a % b);

      case 'max':
        return operands.reduce(math.max);

      case 'min':
        return operands.reduce(math.min);

      case 'average':
      case 'avg':
        return operands.reduce((a, b) => a + b) / operands.length;

      default:
        throw ArgumentError('不支持的运算操作: $operation');
    }
  }
}

/// 统计聚合操作
class StatisticalAggregationOperation extends AtomicOperation {
  StatisticalAggregationOperation()
    : super(
        id: 'statistical_aggregation',
        name: '统计聚合',
        category: '聚合与运算',
        description: '执行统计分析和数据聚合',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'data': ParameterDefinition(
      name: 'data',
      type: ParameterType.array,
      required: true,
      description: '待统计的数据列表',
    ),
    'metrics': ParameterDefinition(
      name: 'metrics',
      type: ParameterType.array,
      required: false,
      description: '统计指标列表',
      defaultValue: ['count', 'sum', 'avg'],
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'statistics': ParameterDefinition(
      name: 'statistics',
      type: ParameterType.dict,
      required: true,
      description: '统计结果',
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
    final data = inputs['data'] as List? ?? [];
    final metrics =
        inputs['metrics'] as List<String>? ?? ['count', 'sum', 'avg'];

    final numbers = data
        .map((e) => _toNumber(e))
        .where((e) => e != null)
        .cast<num>()
        .toList();

    final results = <String, dynamic>{};

    for (final metric in metrics) {
      results[metric] = _calculateMetric(numbers, metric);
    }

    return {
      'statistics': results,
      'data_count': data.length,
      'valid_numbers': numbers.length,
      'calculated_metrics': metrics,
    };
  }

  num? _toNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  dynamic _calculateMetric(List<num> numbers, String metric) {
    if (numbers.isEmpty) return null;

    switch (metric.toLowerCase()) {
      case 'count':
        return numbers.length;

      case 'sum':
        return numbers.reduce((a, b) => a + b);

      case 'avg':
      case 'average':
      case 'mean':
        return numbers.reduce((a, b) => a + b) / numbers.length;

      case 'max':
        return numbers.reduce(math.max);

      case 'min':
        return numbers.reduce(math.min);

      case 'median':
        final sorted = List<num>.from(numbers)..sort();
        final middle = sorted.length ~/ 2;
        if (sorted.length % 2 == 0) {
          return (sorted[middle - 1] + sorted[middle]) / 2;
        } else {
          return sorted[middle];
        }

      case 'variance':
        final mean = numbers.reduce((a, b) => a + b) / numbers.length;
        final variance =
            numbers.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            numbers.length;
        return variance;

      case 'stddev':
      case 'standard_deviation':
        final mean = numbers.reduce((a, b) => a + b) / numbers.length;
        final variance =
            numbers.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b) /
            numbers.length;
        return math.sqrt(variance);

      default:
        return null;
    }
  }
}

/// 数据累积操作
class DataAccumulationOperation extends AtomicOperation {
  DataAccumulationOperation()
    : super(
        id: 'data_accumulation',
        name: '数据累积',
        category: '聚合与运算',
        description: '累积处理数据序列',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'data': ParameterDefinition(
      name: 'data',
      type: ParameterType.array,
      required: true,
      description: '待累积的数据列表',
    ),
    'mode': ParameterDefinition(
      name: 'mode',
      type: ParameterType.str,
      required: false,
      description: '累积模式：sum, product, concat, list, max, min',
      defaultValue: 'sum',
    ),
    'initial_value': ParameterDefinition(
      name: 'initial_value',
      type: ParameterType.any,
      required: false,
      description: '初始值',
      defaultValue: 0,
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'accumulated_result': ParameterDefinition(
      name: 'accumulated_result',
      type: ParameterType.any,
      required: true,
      description: '最终累积结果',
    ),
    'accumulation_sequence': ParameterDefinition(
      name: 'accumulation_sequence',
      type: ParameterType.array,
      required: true,
      description: '累积过程序列',
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
    final data = input['data'] as List? ?? [];
    final mode = input['mode'] as String? ?? 'sum';
    final initialValue = input['initial_value'] ?? 0;

    final accumulated = _accumulate(data, mode, initialValue);

    return {
      'accumulated_result': accumulated.last,
      'accumulation_sequence': accumulated,
      'mode': mode,
      'initial_value': initialValue,
      'data_count': data.length,
    };
  }

  List<dynamic> _accumulate(List data, String mode, dynamic initialValue) {
    final result = <dynamic>[initialValue];
    dynamic current = initialValue;

    for (final item in data) {
      switch (mode.toLowerCase()) {
        case 'sum':
          if (item is num && current is num) {
            current = current + item;
          }
          break;

        case 'product':
          if (item is num && current is num) {
            current = current * item;
          }
          break;

        case 'concat':
          current = current.toString() + item.toString();
          break;

        case 'list':
          if (current is List) {
            current = [...current, item];
          } else {
            current = [current, item];
          }
          break;

        case 'max':
          if (item is num && current is num) {
            current = math.max(current, item);
          }
          break;

        case 'min':
          if (item is num && current is num) {
            current = math.min(current, item);
          }
          break;

        default:
          current = item;
      }

      result.add(current);
    }

    return result;
  }
}

/// 数据分组操作
class DataGroupingOperation extends AtomicOperation {
  DataGroupingOperation()
    : super(
        id: 'data_grouping',
        name: '数据分组',
        category: '聚合与运算',
        description: '按指定条件对数据进行分组',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'data': ParameterDefinition(
      name: 'data',
      type: ParameterType.array,
      required: true,
      description: '待分组的数据列表',
    ),
    'group_by': ParameterDefinition(
      name: 'group_by',
      type: ParameterType.str,
      required: true,
      description: '分组字段或条件',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'groups': ParameterDefinition(
      name: 'groups',
      type: ParameterType.dict,
      required: true,
      description: '分组结果',
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
    final data = inputs['data'] as List? ?? [];
    final groupBy = inputs['group_by'] as String? ?? '';

    final groups = <String, List<dynamic>>{};

    for (final item in data) {
      final groupKey = _getGroupKey(item, groupBy);
      groups.putIfAbsent(groupKey, () => []).add(item);
    }

    return {
      'groups': groups,
      'group_count': groups.length,
      'total_items': data.length,
      'group_by': groupBy,
    };
  }

  /// 根据分组条件获取分组键
  String _getGroupKey(dynamic item, String groupBy) {
    if (item == null) return 'null';

    // 如果是 Map 类型，尝试获取指定字段的值
    if (item is Map<String, dynamic>) {
      final value = item[groupBy];
      return value?.toString() ?? 'null';
    }

    // 如果是其他类型，直接转换为字符串
    return item.toString();
  }

  num? _toNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

/// 聚合与运算操作包装类
class AggregationCalculation {
  static List<AtomicOperation> getOperations() {
    return [
      MathCalculationOperation(),
      StatisticalAggregationOperation(),
      DataAccumulationOperation(),
      DataGroupingOperation(),
    ];
  }
}
