/// 同步执行器
/// Version: v0.1
/// 负责同步执行算法步骤
library sync_executor;

import 'models/execution_context.dart';
import 'models/execution_step.dart';
import 'models/atomic_operation.dart';

/// 同步执行器类
/// Version: v0.1
class SyncExecutor {
  /// 执行单个步骤
  Future<void> executeStep(ExecutionStep step, ExecutionContext context) async {
    try {
      // 记录步骤开始
      context.recordStepStart(step.id);

      // 获取原子操作
      final operation = context.operationRegistry.getOperation(
        step.operationType,
      );
      if (operation == null) {
        throw ExecutionException(
          'Unknown operation type: ${step.operationType}',
          stepId: step.id,
        );
      }

      // 准备输入数据
      final inputs = await _prepareInputs(step, context);

      // 执行操作
      final result = await operation.execute(context, inputs, step.config);

      // 处理输出
      await _processOutputs(step, result, context);

      // 记录步骤完成
      context.recordStepComplete(step.id, result);
    } catch (e) {
      // 记录步骤错误
      context.recordStepError(step.id, e);
      rethrow;
    }
  }

  /// 准备输入数据
  Future<Map<String, dynamic>> _prepareInputs(
    ExecutionStep step,
    ExecutionContext context,
  ) async {
    final inputs = <String, dynamic>{};

    // 处理输入映射
    for (final entry in step.inputMapping.entries) {
      final inputKey = entry.key;
      final sourceKey = entry.value;

      // 从不同来源获取数据
      if (sourceKey.startsWith('input.')) {
        // 从原始输入获取
        final key = sourceKey.substring(6); // 移除 'input.' 前缀
        inputs[inputKey] = context.getInput(key);
      } else if (sourceKey.startsWith('intermediate.')) {
        // 从中间结果获取
        final key = sourceKey.substring(13); // 移除 'intermediate.' 前缀
        inputs[inputKey] = context.getIntermediateResult(key);
      } else if (sourceKey.startsWith('output.')) {
        // 从输出结果获取
        final key = sourceKey.substring(7); // 移除 'output.' 前缀
        inputs[inputKey] = context.getOutput(key);
      } else if (sourceKey.startsWith('config.')) {
        // 从全局配置获取
        final key = sourceKey.substring(7); // 移除 'config.' 前缀
        inputs[inputKey] = context.getGlobalConfig(key);
      } else {
        // 直接使用字面值
        inputs[inputKey] = sourceKey;
      }
    }

    return inputs;
  }

  /// 处理输出数据
  Future<void> _processOutputs(
    ExecutionStep step,
    Map<String, dynamic> result,
    ExecutionContext context,
  ) async {
    // 处理输出映射
    for (final entry in step.outputMapping.entries) {
      final resultKey = entry.key;
      final targetKey = entry.value;

      if (result.containsKey(resultKey)) {
        final value = result[resultKey];

        // 根据目标类型存储数据
        if (targetKey.startsWith('intermediate.')) {
          // 存储为中间结果
          final key = targetKey.substring(13); // 移除 'intermediate.' 前缀
          context.setIntermediateResult(key, value);
        } else if (targetKey.startsWith('output.')) {
          // 存储为最终输出
          final key = targetKey.substring(7); // 移除 'output.' 前缀
          context.setOutput(key, value);
        } else {
          // 默认存储为中间结果
          context.setIntermediateResult(targetKey, value);
        }
      }
    }
  }

  /// 验证步骤前置条件
  Future<bool> validatePreconditions(
    ExecutionStep step,
    ExecutionContext context,
  ) async {
    // 检查依赖步骤是否已完成
    for (final dependency in step.dependencies) {
      if (!context.isStepCompleted(dependency)) {
        return false;
      }
    }

    // 检查必需的输入是否存在
    for (final inputKey in step.inputMapping.keys) {
      final sourceKey = step.inputMapping[inputKey]!;

      if (sourceKey.startsWith('input.')) {
        final key = sourceKey.substring(6);
        if (!context.hasInput(key)) {
          return false;
        }
      } else if (sourceKey.startsWith('intermediate.')) {
        final key = sourceKey.substring(13);
        if (!context.hasIntermediateResult(key)) {
          return false;
        }
      } else if (sourceKey.startsWith('output.')) {
        final key = sourceKey.substring(7);
        if (!context.hasOutput(key)) {
          return false;
        }
      }
    }

    return true;
  }

  /// 获取步骤执行统计
  Map<String, dynamic> getExecutionStats(ExecutionContext context) {
    final history = context.executionHistory;
    final totalSteps = history.length;
    final completedSteps = history.where((record) => record.isCompleted).length;
    final errorSteps = history.where((record) => record.hasError).length;

    Duration totalDuration = Duration.zero;
    for (final record in history) {
      if (record.endTime != null) {
        totalDuration += record.endTime!.difference(record.startTime);
      }
    }

    return {
      'totalSteps': totalSteps,
      'completedSteps': completedSteps,
      'errorSteps': errorSteps,
      'successRate': totalSteps > 0 ? completedSteps / totalSteps : 0.0,
      'totalDuration': totalDuration.inMilliseconds,
      'averageDuration': totalSteps > 0
          ? totalDuration.inMilliseconds / totalSteps
          : 0.0,
    };
  }
}

/// 执行异常类
class ExecutionException implements Exception {
  final String message;
  final String? stepId;
  final dynamic originalError;

  const ExecutionException(this.message, {this.stepId, this.originalError});

  @override
  String toString() {
    final buffer = StringBuffer('ExecutionException: $message');
    if (stepId != null) {
      buffer.write(' (Step: $stepId)');
    }
    if (originalError != null) {
      buffer.write(' - Original error: $originalError');
    }
    return buffer.toString();
  }
}
