/// 执行引擎
/// Version: v0.1
/// 负责按顺序执行算法步骤
library execution_engine;

import 'models/execution_context.dart';
import 'models/execution_step.dart';
import 'models/conditional_branch.dart';
import 'sync_executor.dart';
import 'error_handler.dart';

/// 执行引擎类
/// Version: v0.1
class ExecutionEngine {
  final SyncExecutor _syncExecutor;
  final ErrorHandler _errorHandler;

  ExecutionEngine({
    required SyncExecutor syncExecutor,
    required ErrorHandler errorHandler,
  }) : _syncExecutor = syncExecutor,
       _errorHandler = errorHandler;

  /// 执行算法
  Future<Map<String, dynamic>> execute(ExecutionContext context) async {
    try {
      for (final step in context.config.steps) {
        await _executeStep(step, context);
      }
      return context.outputs;
    } catch (e) {
      await _errorHandler.handleError(e, context);
      rethrow;
    }
  }

  /// 执行单个步骤
  Future<void> _executeStep(
    ExecutionStep step,
    ExecutionContext context,
  ) async {
    // 检查条件分支
    if (step.conditionalBranches != null &&
        step.conditionalBranches!.isNotEmpty) {
      await _executeConditionalStep(step, context);
    } else {
      await _syncExecutor.executeStep(step, context);
    }
  }

  /// 执行条件步骤
  Future<void> _executeConditionalStep(
    ExecutionStep step,
    ExecutionContext context,
  ) async {
    for (final branch in step.conditionalBranches!) {
      if (await _evaluateCondition(branch.condition, context)) {
        // 执行真分支
        for (final trueStepId in branch.trueSteps) {
          final trueStep = _findStepById(trueStepId, context);
          if (trueStep != null) {
            await _executeStep(trueStep, context);
          }
        }
        return;
      }
    }

    // 如果没有条件匹配，执行假分支（如果存在）
    final firstBranch = step.conditionalBranches!.first;
    if (firstBranch.falseSteps != null) {
      for (final falseStepId in firstBranch.falseSteps!) {
        final falseStep = _findStepById(falseStepId, context);
        if (falseStep != null) {
          await _executeStep(falseStep, context);
        }
      }
    }
  }

  /// 评估条件
  Future<bool> _evaluateCondition(
    String condition,
    ExecutionContext context,
  ) async {
    try {
      // 解析条件字符串为条件对象
      final conditionMap = _parseConditionString(condition);

      // 评估条件
      return _evaluateConditionMap(conditionMap, context);
    } catch (e) {
      // 如果解析失败，返回false
      return false;
    }
  }

  /// 解析条件字符串
  Map<String, dynamic> _parseConditionString(String condition) {
    // 简单的条件解析实现
    // 支持格式: "variable operator value"
    // 例如: "age > 18", "name == 'John'", "status != null"

    condition = condition.trim();

    // 查找操作符
    final operators = [
      '>=',
      '<=',
      '!=',
      '==',
      '>',
      '<',
      'contains',
      'starts_with',
      'ends_with',
    ];

    for (final op in operators) {
      if (condition.contains(op)) {
        final parts = condition.split(op);
        if (parts.length == 2) {
          return {
            'operator': op.trim(),
            'left': parts[0].trim(),
            'right': parts[1].trim().replaceAll(
              RegExp(r"""^["']|["']$"""),
              '',
            ), // 移除引号
          };
        }
      }
    }

    // 特殊条件处理
    if (condition.endsWith(' is null')) {
      return {
        'operator': 'is_null',
        'left': condition.substring(0, condition.length - 8).trim(),
        'right': null,
      };
    }

    if (condition.endsWith(' is not null')) {
      return {
        'operator': 'is_not_null',
        'left': condition.substring(0, condition.length - 12).trim(),
        'right': null,
      };
    }

    // 默认返回简单的相等比较
    return {'operator': 'equals', 'left': condition, 'right': true};
  }

  /// 评估条件映射
  bool _evaluateConditionMap(
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

  /// 解析值
  dynamic _resolveValue(dynamic value, ExecutionContext context) {
    if (value == null) return null;

    final valueStr = value.toString();

    // 从不同来源获取数据
    if (valueStr.startsWith('input.')) {
      final key = valueStr.substring(6);
      return context.getInput(key);
    } else if (valueStr.startsWith('intermediate.')) {
      final key = valueStr.substring(13);
      return context.getIntermediateResult(key);
    } else if (valueStr.startsWith('output.')) {
      final key = valueStr.substring(7);
      return context.getOutput(key);
    } else if (valueStr.startsWith('config.')) {
      final key = valueStr.substring(7);
      return context.getGlobalConfig(key);
    } else {
      // 尝试解析为数字
      final numValue = num.tryParse(valueStr);
      if (numValue != null) return numValue;

      // 尝试解析为布尔值
      if (valueStr.toLowerCase() == 'true') return true;
      if (valueStr.toLowerCase() == 'false') return false;
      if (valueStr.toLowerCase() == 'null') return null;

      // 返回原始值
      return value;
    }
  }

  /// 比较数字
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

  /// 转换为数字
  num? _toNumber(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  /// 检查包含关系
  bool _checkContains(dynamic left, dynamic right) {
    if (left is String && right is String) {
      return left.contains(right);
    }
    if (left is List) {
      return left.contains(right);
    }
    if (left is Map && right is String) {
      return left.containsKey(right);
    }
    return false;
  }

  /// 检查是否为空
  bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  /// 根据ID查找步骤
  ExecutionStep? _findStepById(String stepId, ExecutionContext context) {
    return context.config.steps.firstWhere(
      (step) => step.id == stepId,
      orElse: () => throw ArgumentError('Step not found: $stepId'),
    );
  }
}
