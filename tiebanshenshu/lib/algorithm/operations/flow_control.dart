/// 算法编译器 - 流程控制原子操作
///
/// 版本: v0.1
/// 作者: Algorithm Compiler Team
/// 创建时间: 2024
///
/// 功能说明:
/// - 提供条件判断和流程控制操作
/// - 支持循环和分支逻辑
/// - 实现复杂的业务流程控制

import '../models/atomic_operation.dart';
import '../models/execution_context.dart';

/// 条件判断操作
class ConditionalOperation extends AtomicOperation {
  ConditionalOperation()
    : super(
        id: 'conditional',
        name: '条件判断',
        category: '流程控制',
        description: '根据条件执行不同的逻辑分支',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'condition': ParameterDefinition(
      name: 'condition',
      type: ParameterType.dict,
      required: true,
      description: '条件表达式',
    ),
    'true_value': ParameterDefinition(
      name: 'true_value',
      type: ParameterType.any,
      required: false,
      description: '条件为真时的值',
    ),
    'false_value': ParameterDefinition(
      name: 'false_value',
      type: ParameterType.any,
      required: false,
      description: '条件为假时的值',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'result': ParameterDefinition(
      name: 'result',
      type: ParameterType.any,
      required: true,
      description: '条件判断结果',
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
    final condition = inputs['condition'] as Map<String, dynamic>? ?? {};
    final trueValue = inputs['true_value'];
    final falseValue = inputs['false_value'];

    final conditionResult = _evaluateCondition(condition, context);
    final selectedValue = conditionResult ? trueValue : falseValue;

    return {
      'result': selectedValue,
      'condition_result': conditionResult,
      'condition': condition,
      'selected_branch': conditionResult ? 'true' : 'false',
    };
  }

  bool _evaluateCondition(
    Map<String, dynamic> condition,
    ExecutionContext context,
  ) {
    final operator = condition['operator'] as String? ?? 'equals';
    final left = _resolveValue(condition['left'], context);
    final right = _resolveValue(condition['right'], context);

    switch (operator.toLowerCase()) {
      case 'equals':
      case '==':
        return left == right;

      case 'not_equals':
      case '!=':
        return left != right;

      case 'greater_than':
      case '>':
        return _compareNumbers(left, right, (a, b) => a > b);

      case 'greater_than_or_equal':
      case '>=':
        return _compareNumbers(left, right, (a, b) => a >= b);

      case 'less_than':
      case '<':
        return _compareNumbers(left, right, (a, b) => a < b);

      case 'less_than_or_equal':
      case '<=':
        return _compareNumbers(left, right, (a, b) => a <= b);

      case 'contains':
        return _checkContains(left, right);

      case 'starts_with':
        return left.toString().startsWith(right.toString());

      case 'ends_with':
        return left.toString().endsWith(right.toString());

      case 'is_null':
        return left == null;

      case 'is_not_null':
        return left != null;

      case 'is_empty':
        return _isEmpty(left);

      case 'is_not_empty':
        return !_isEmpty(left);

      default:
        return false;
    }
  }

  dynamic _resolveValue(dynamic value, ExecutionContext context) {
    if (value is String && value.startsWith('\$')) {
      // 从上下文中获取变量值
      final varName = value.substring(1);
      return context.getVariable(varName);
    }
    return value;
  }

  bool _compareNumbers(
    dynamic left,
    dynamic right,
    bool Function(num, num) compareFn,
  ) {
    final leftNum = _toNumber(left);
    final rightNum = _toNumber(right);

    if (leftNum == null || rightNum == null) {
      return false;
    }

    return compareFn(leftNum, rightNum);
  }

  num? _toNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  bool _checkContains(dynamic container, dynamic item) {
    if (container is List) {
      return container.contains(item);
    }
    if (container is Map) {
      return container.containsKey(item) || container.containsValue(item);
    }
    if (container is String) {
      return container.contains(item.toString());
    }
    return false;
  }

  bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }
}

/// 循环操作
class LoopOperation extends AtomicOperation {
  LoopOperation()
    : super(
        id: 'loop',
        name: '循环操作',
        category: '流程控制',
        description: '对数据集合执行循环处理',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'items': ParameterDefinition(
      name: 'items',
      type: ParameterType.array,
      required: true,
      description: '待循环处理的数据集合',
    ),
    'operation': ParameterDefinition(
      name: 'operation',
      type: ParameterType.dict,
      required: true,
      description: '循环体操作配置',
      defaultValue: {},
    ),
    'max_iterations': ParameterDefinition(
      name: 'max_iterations',
      type: ParameterType.intNum,
      required: false,
      description: '最大迭代次数限制',
      defaultValue: 1000,
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'results': ParameterDefinition(
      name: 'results',
      type: ParameterType.array,
      required: true,
      description: '循环处理结果集合',
    ),
    'iterations': ParameterDefinition(
      name: 'iterations',
      type: ParameterType.intNum,
      required: true,
      description: '实际执行的迭代次数',
    ),
    'total_items': ParameterDefinition(
      name: 'total_items',
      type: ParameterType.intNum,
      required: true,
      description: '输入数据项总数',
    ),
    'completed': ParameterDefinition(
      name: 'completed',
      type: ParameterType.boolean,
      required: true,
      description: '是否完成所有项的处理',
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
    final items = input['items'] as List? ?? [];
    final operation = input['operation'] as Map<String, dynamic>? ?? {};
    final maxIterations = input['max_iterations'] as int? ?? 1000;

    final results = <dynamic>[];
    int iterations = 0;

    for (final item in items) {
      if (iterations >= maxIterations) {
        break;
      }

      // 创建循环上下文
      final loopContext = context.createChild();
      loopContext.setVariable('current_item', item);
      loopContext.setVariable('current_index', iterations);

      // 执行循环体操作
      final result = await _executeLoopBody(operation, loopContext);
      results.add(result);

      iterations++;
    }

    return {
      'results': results,
      'iterations': iterations,
      'total_items': items.length,
      'completed': iterations == items.length,
    };
  }

  Future<dynamic> _executeLoopBody(
    Map<String, dynamic> operation,
    ExecutionContext loopContext,
  ) async {
    final operationType = operation['type'] as String? ?? 'transform';
    final config = operation['config'] as Map<String, dynamic>? ?? {};

    switch (operationType) {
      case 'transform':
        return _transformItem(config, loopContext);
      case 'filter':
        return _filterItem(config, loopContext);
      case 'aggregate':
        return _aggregateItem(config, loopContext);
      default:
        return loopContext.getVariable('current_item');
    }
  }

  dynamic _transformItem(
    Map<String, dynamic> config,
    ExecutionContext context,
  ) {
    final item = context.getVariable('current_item');
    final transformRules = config['rules'] as Map<String, dynamic>? ?? {};

    if (item is Map<String, dynamic>) {
      final transformed = <String, dynamic>{};

      for (final entry in transformRules.entries) {
        final sourceField = entry.key;
        final targetField = entry.value as String;

        if (item.containsKey(sourceField)) {
          transformed[targetField] = item[sourceField];
        }
      }

      return transformed;
    }

    return item;
  }

  Future<bool> _filterItem(
    Map<String, dynamic> config,
    ExecutionContext context,
  ) async {
    final condition = config['condition'] as Map<String, dynamic>? ?? {};

    if (condition.isEmpty) {
      return true;
    }

    final conditionalOp = ConditionalOperation();
    final result = await conditionalOp.execute(
      context,
      {'condition': condition, 'true_value': true, 'false_value': false},
      {}, // 空的配置参数
    );

    return result['result'] as bool;
  }

  dynamic _aggregateItem(
    Map<String, dynamic> config,
    ExecutionContext context,
  ) {
    final item = context.getVariable('current_item');
    final operation = config['operation'] as String? ?? 'sum';
    final field = config['field'] as String?;

    if (field != null && item is Map<String, dynamic>) {
      return item[field];
    }

    return item;
  }
}

/// 分支选择操作
class SwitchOperation extends AtomicOperation {
  SwitchOperation()
    : super(
        id: 'switch',
        name: '分支选择',
        category: '流程控制',
        description: '根据值选择对应的执行分支',
        version: 'v0.1',
      );

  @override
  Map<String, ParameterDefinition> get inputParameters => {
    'value': ParameterDefinition(
      name: 'value',
      type: ParameterType.any,
      required: true,
      description: '用于匹配分支的值',
    ),
    'cases': ParameterDefinition(
      name: 'cases',
      type: ParameterType.dict,
      required: true,
      description: '分支案例映射，键为匹配值，值为对应结果',
      defaultValue: {},
    ),
    'default': ParameterDefinition(
      name: 'default',
      type: ParameterType.any,
      required: false,
      description: '默认分支的值，当没有匹配的case时使用',
    ),
  };

  @override
  Map<String, ParameterDefinition> get outputParameters => {
    'result': ParameterDefinition(
      name: 'result',
      type: ParameterType.any,
      required: true,
      description: '选中分支的结果值',
    ),
    'matched_case': ParameterDefinition(
      name: 'matched_case',
      type: ParameterType.str,
      required: true,
      description: '匹配的分支键名',
    ),
    'input_value': ParameterDefinition(
      name: 'input_value',
      type: ParameterType.any,
      required: true,
      description: '输入的匹配值',
    ),
    'available_cases': ParameterDefinition(
      name: 'available_cases',
      type: ParameterType.array,
      required: true,
      description: '可用的分支键列表',
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
    final cases = input['cases'] as Map<String, dynamic>? ?? {};
    final defaultCase = input['default'];

    final valueStr = value.toString();
    dynamic selectedCase;
    String selectedKey = 'default';

    // 查找匹配的case
    for (final entry in cases.entries) {
      if (entry.key == valueStr) {
        selectedCase = entry.value;
        selectedKey = entry.key;
        break;
      }
    }

    // 如果没有匹配的case，使用默认值
    selectedCase ??= defaultCase;

    return {
      'result': selectedCase,
      'matched_case': selectedKey,
      'input_value': value,
      'available_cases': cases.keys.toList(),
    };
  }
}

/// 流程控制操作包装类
class FlowControl {
  /// 获取所有流程控制类操作实例
  static List<AtomicOperation> getOperations() {
    return [ConditionalOperation(), LoopOperation(), SwitchOperation()];
  }
}
