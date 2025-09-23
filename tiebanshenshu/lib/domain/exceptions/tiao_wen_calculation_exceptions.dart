/// 条文计算相关异常基类
abstract class TiaoWenCalculationException implements Exception {
  /// 错误消息
  final String message;

  /// 错误代码
  final String code;

  /// 原始异常
  final Object? originalException;

  const TiaoWenCalculationException({
    required this.message,
    required this.code,
    this.originalException,
  });

  @override
  String toString() {
    return '$runtimeType(code: $code, message: $message)';
  }
}

/// Strategy计算异常
class StrategyCalculationException extends TiaoWenCalculationException {
  /// Strategy名称
  final String strategyName;

  const StrategyCalculationException({
    required this.strategyName,
    required super.message,
    super.code = 'STRATEGY_CALCULATION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'StrategyCalculationException(strategy: $strategyName, code: $code, message: $message)';
  }
}

/// 条文列表计算异常
class TiaoWenListCalculationException extends TiaoWenCalculationException {
  /// 基础数字
  final int? baseNumber;

  const TiaoWenListCalculationException({
    this.baseNumber,
    required super.message,
    super.code = 'TIAO_WEN_LIST_CALCULATION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'TiaoWenListCalculationException(baseNumber: $baseNumber, code: $code, message: $message)';
  }
}

/// 条文数据获取异常
class TiaoWenDataException extends TiaoWenCalculationException {
  /// 条文编号列表
  final List<int>? tiaoWenNumbers;

  const TiaoWenDataException({
    this.tiaoWenNumbers,
    required super.message,
    super.code = 'TIAO_WEN_DATA_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'TiaoWenDataException(tiaoWenNumbers: $tiaoWenNumbers, code: $code, message: $message)';
  }
}

/// 输入参数验证异常
class InputValidationException extends TiaoWenCalculationException {
  /// 参数名称
  final String parameterName;

  /// 参数值
  final Object? parameterValue;

  const InputValidationException(
    String s, {
    required this.parameterName,
    this.parameterValue,
    required super.message,
    super.code = 'INPUT_VALIDATION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'InputValidationException(parameter: $parameterName, value: $parameterValue, code: $code, message: $message)';
  }
}

/// UseCase执行异常
class UseCaseExecutionException extends TiaoWenCalculationException {
  /// UseCase名称
  final String useCaseName;

  const UseCaseExecutionException({
    required this.useCaseName,
    required super.message,
    super.code = 'USE_CASE_EXECUTION_ERROR',
    super.originalException,
  });

  @override
  String toString() {
    return 'UseCaseExecutionException(useCase: $useCaseName, code: $code, message: $message)';
  }
}

/// 会话不存在异常
class SessionNotFoundException extends TiaoWenCalculationException {
  /// 会话ID
  final String sessionId;

  const SessionNotFoundException(
    String message, {
    this.sessionId = '',
    super.code = 'SESSION_NOT_FOUND_ERROR',
    super.originalException,
  }) : super(message: message);

  @override
  String toString() {
    return 'SessionNotFoundException(sessionId: $sessionId, code: $code, message: $message)';
  }
}

/// 会话状态异常
class SessionStateException extends TiaoWenCalculationException {
  /// 当前状态
  final String? currentState;

  /// 期望状态
  final String? expectedState;

  const SessionStateException(
    String message, {
    this.currentState,
    this.expectedState,
    super.code = 'SESSION_STATE_ERROR',
    super.originalException,
  }) : super(message: message);

  @override
  String toString() {
    return 'SessionStateException(currentState: $currentState, expectedState: $expectedState, code: $code, message: $message)';
  }
}

/// 无效候选项异常
class InvalidCandidateException extends TiaoWenCalculationException {
  /// 候选项ID
  final String candidateId;

  const InvalidCandidateException(
    String message, {
    this.candidateId = '',
    super.code = 'INVALID_CANDIDATE_ERROR',
    super.originalException,
  }) : super(message: message);

  @override
  String toString() {
    return 'InvalidCandidateException(candidateId: $candidateId, code: $code, message: $message)';
  }
}

/// 无效步骤索引异常
class InvalidStepIndexException extends TiaoWenCalculationException {
  /// 步骤索引
  final int stepIndex;

  /// 最大有效索引
  final int? maxIndex;

  const InvalidStepIndexException(
    String message, {
    this.stepIndex = -1,
    this.maxIndex,
    super.code = 'INVALID_STEP_INDEX_ERROR',
    super.originalException,
  }) : super(message: message);

  @override
  String toString() {
    return 'InvalidStepIndexException(stepIndex: $stepIndex, maxIndex: $maxIndex, code: $code, message: $message)';
  }
}

/// 会话未完成异常
class SessionNotCompletedException extends TiaoWenCalculationException {
  /// 会话ID
  final String sessionId;

  /// 当前步骤
  final int? currentStep;

  /// 总步骤数
  final int? totalSteps;

  const SessionNotCompletedException(
    String message, {
    this.sessionId = '',
    this.currentStep,
    this.totalSteps,
    super.code = 'SESSION_NOT_COMPLETED_ERROR',
    super.originalException,
  }) : super(message: message);

  @override
  String toString() {
    return 'SessionNotCompletedException(sessionId: $sessionId, currentStep: $currentStep, totalSteps: $totalSteps, code: $code, message: $message)';
  }
}

/// 错误异常包装类
///
/// 用于将Error类型包装成Exception类型，以便统一异常处理
class ErrorException implements Exception {
  /// 原始错误对象
  final Error originalError;

  /// 错误消息
  final String message;

  /// 构造函数
  ///
  /// [originalError] 原始的Error对象
  /// [message] 可选的自定义错误消息，如果不提供则使用originalError.toString()
  ErrorException(this.originalError, [String? message])
    : message = message ?? originalError.toString();

  @override
  String toString() => 'ErrorException: $message';
}
