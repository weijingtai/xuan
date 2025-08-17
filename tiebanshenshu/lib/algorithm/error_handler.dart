/// 错误处理器
/// Version: v0.1
/// 负责处理算法执行过程中的错误
library error_handler;

import 'models/execution_context.dart';

/// 错误处理器类
/// Version: v0.1
class ErrorHandler {
  final List<ErrorRecoveryStrategy> _recoveryStrategies = [];
  final bool _enableLogging;
  final Function(String)? _logger;

  ErrorHandler({bool enableLogging = true, Function(String)? logger})
    : _enableLogging = enableLogging,
      _logger = logger {
    // 注册默认恢复策略
    _registerDefaultStrategies();
  }

  /// 处理错误
  Future<void> handleError(dynamic error, ExecutionContext context) async {
    // 记录错误
    if (_enableLogging) {
      _logError(error, context);
    }

    // 尝试恢复策略
    for (final strategy in _recoveryStrategies) {
      if (await strategy.canHandle(error, context)) {
        try {
          await strategy.recover(error, context);
          return; // 恢复成功，退出
        } catch (recoveryError) {
          // 恢复失败，尝试下一个策略
          if (_enableLogging) {
            _log(
              'Recovery strategy failed: ${strategy.runtimeType} - $recoveryError',
            );
          }
        }
      }
    }

    // 所有恢复策略都失败，记录最终错误
    context.recordError(
      AlgorithmError(
        message: 'Unrecoverable error: ${error.toString()}',
        errorType: ErrorType.fatal,
        originalError: error,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// 添加恢复策略
  void addRecoveryStrategy(ErrorRecoveryStrategy strategy) {
    _recoveryStrategies.add(strategy);
  }

  /// 移除恢复策略
  void removeRecoveryStrategy(ErrorRecoveryStrategy strategy) {
    _recoveryStrategies.remove(strategy);
  }

  /// 注册默认恢复策略
  void _registerDefaultStrategies() {
    _recoveryStrategies.addAll([
      RetryStrategy(),
      SkipStepStrategy(),
      FallbackValueStrategy(),
      RollbackStrategy(),
    ]);
  }

  /// 记录错误日志
  void _logError(dynamic error, ExecutionContext context) {
    final message = 'Error in algorithm ${context.config.name}: $error';
    _log(message);
  }

  /// 输出日志
  void _log(String message) {
    if (_logger != null) {
      _logger!(message);
    } else {
      print('[ErrorHandler] $message');
    }
  }

  /// 获取错误统计
  Map<String, dynamic> getErrorStats(ExecutionContext context) {
    final errors = context.errors;
    final errorsByType = <ErrorType, int>{};

    for (final error in errors) {
      errorsByType[error.errorType] = (errorsByType[error.errorType] ?? 0) + 1;
    }

    return {
      'totalErrors': errors.length,
      'errorsByType': errorsByType.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'lastError': errors.isNotEmpty ? errors.last.toJson() : null,
    };
  }
}

/// 错误恢复策略抽象类
abstract class ErrorRecoveryStrategy {
  /// 检查是否可以处理该错误
  Future<bool> canHandle(dynamic error, ExecutionContext context);

  /// 执行恢复操作
  Future<void> recover(dynamic error, ExecutionContext context);
}

/// 重试策略
class RetryStrategy extends ErrorRecoveryStrategy {
  final int maxRetries;
  final Duration retryDelay;
  final Map<String, int> _retryCount = {};

  RetryStrategy({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  Future<bool> canHandle(dynamic error, ExecutionContext context) async {
    // 只处理可重试的错误
    return error is! FatalException && error is! ValidationException;
  }

  @override
  Future<void> recover(dynamic error, ExecutionContext context) async {
    final currentStep = context.currentStepId;
    if (currentStep == null) return;

    final retryKey = '${context.config.name}_$currentStep';
    final currentRetries = _retryCount[retryKey] ?? 0;

    if (currentRetries < maxRetries) {
      _retryCount[retryKey] = currentRetries + 1;

      // 等待重试延迟
      await Future.delayed(retryDelay);

      // 重置当前步骤状态
      context.resetStepIndex();

      throw RetryException(
        'Retrying step $currentStep (${currentRetries + 1}/$maxRetries)',
      );
    } else {
      // 超过最大重试次数
      _retryCount.remove(retryKey);
      throw MaxRetriesExceededException(
        'Max retries exceeded for step $currentStep',
      );
    }
  }
}

/// 跳过步骤策略
class SkipStepStrategy extends ErrorRecoveryStrategy {
  @override
  Future<bool> canHandle(dynamic error, ExecutionContext context) async {
    // 只跳过非关键步骤
    final currentStep = context.getCurrentStep();
    return currentStep?.isOptional ?? false;
  }

  @override
  Future<void> recover(dynamic error, ExecutionContext context) async {
    final currentStep = context.getCurrentStep();
    if (currentStep != null) {
      context.recordStepSkipped(currentStep.id, error.toString());
      context.moveToNextStep();
    }
  }
}

/// 回退值策略
class FallbackValueStrategy extends ErrorRecoveryStrategy {
  @override
  Future<bool> canHandle(dynamic error, ExecutionContext context) async {
    // 检查是否有配置的回退值
    final currentStep = context.getCurrentStep();
    return currentStep?.config.containsKey('fallbackValue') ?? false;
  }

  @override
  Future<void> recover(dynamic error, ExecutionContext context) async {
    final currentStep = context.getCurrentStep();
    if (currentStep != null) {
      final fallbackValue = currentStep.config['fallbackValue'];

      // 使用回退值作为步骤输出
      for (final entry in currentStep.outputMapping.entries) {
        final targetKey = entry.value;
        if (targetKey.startsWith('output.')) {
          final key = targetKey.substring(7);
          context.setOutput(key, fallbackValue);
        } else if (targetKey.startsWith('intermediate.')) {
          final key = targetKey.substring(13);
          context.setIntermediateResult(key, fallbackValue);
        }
      }

      context.recordStepComplete(currentStep.id, {'fallback': fallbackValue});
    }
  }
}

/// 回滚策略
class RollbackStrategy extends ErrorRecoveryStrategy {
  @override
  Future<bool> canHandle(dynamic error, ExecutionContext context) async {
    // 只在严重错误时回滚
    return error is FatalException;
  }

  @override
  Future<void> recover(dynamic error, ExecutionContext context) async {
    // 回滚到最近的检查点
    context.rollbackToLastCheckpoint();
  }
}

/// 算法错误类
class AlgorithmError {
  final String message;
  final ErrorType errorType;
  final dynamic originalError;
  final DateTime timestamp;
  final String? stepId;

  const AlgorithmError({
    required this.message,
    required this.errorType,
    required this.timestamp,
    this.originalError,
    this.stepId,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'errorType': errorType.name,
      'timestamp': timestamp.toIso8601String(),
      'stepId': stepId,
      'originalError': originalError?.toString(),
    };
  }
}

/// 错误类型枚举
enum ErrorType { warning, error, fatal }

/// 异常类定义
class FatalException implements Exception {
  final String message;
  const FatalException(this.message);
  @override
  String toString() => 'FatalException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
  @override
  String toString() => 'ValidationException: $message';
}

class RetryException implements Exception {
  final String message;
  const RetryException(this.message);
  @override
  String toString() => 'RetryException: $message';
}

class MaxRetriesExceededException implements Exception {
  final String message;
  const MaxRetriesExceededException(this.message);
  @override
  String toString() => 'MaxRetriesExceededException: $message';
}
