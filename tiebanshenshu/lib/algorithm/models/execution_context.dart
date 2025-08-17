/// 执行上下文模型
/// Version: v0.1
/// 管理算法执行过程中的状态和数据
library execution_context;

import '../error_handler.dart';
import 'algorithm_config.dart';
import '../atomic_operation_registry.dart';
import 'execution_step.dart';

/// 执行上下文类
/// Version: v0.1
class ExecutionContext {
  /// 输入数据
  final Map<String, dynamic> inputs;

  /// 算法配置
  final AlgorithmConfig config;

  /// 原子操作注册表
  final AtomicOperationRegistry operationRegistry;

  /// 中间结果存储
  final Map<String, dynamic> _intermediateResults = {};

  /// 输出结果
  final Map<String, dynamic> _outputs = {};

  /// 执行历史
  final List<ExecutionRecord> _executionHistory = [];

  /// 错误列表
  final List<ExecutionError> _errors = [];

  /// 开始时间
  final DateTime startTime;

  /// 当前步骤索引
  int _currentStepIndex = 0;

  ExecutionContext({
    required this.inputs,
    required this.config,
    required this.operationRegistry,
    ExecutionContext? parent,
  }) : startTime = DateTime.now(),
       _parent = parent;

  /// 获取中间结果
  Map<String, dynamic> get intermediateResults =>
      Map.unmodifiable(_intermediateResults);

  /// 获取输出结果
  Map<String, dynamic> get outputs => Map.unmodifiable(_outputs);

  /// 获取执行历史
  List<ExecutionRecord> get executionHistory =>
      List.unmodifiable(_executionHistory);

  /// 获取错误列表
  List<ExecutionError> get errors => List.unmodifiable(_errors);

  /// 获取当前步骤索引
  int get currentStepIndex => _currentStepIndex;

  /// 检查步骤是否已完成
  bool isStepCompleted(String stepId) {
    return _executionHistory.any(
      (record) =>
          record.stepId == stepId && record.status == ExecutionStatus.success,
    );
  }

  /// 检查是否有指定的输入
  bool hasInput(String key) {
    return inputs.containsKey(key);
  }

  /// 检查是否有指定的中间结果
  bool hasIntermediateResult(String key) {
    return _intermediateResults.containsKey(key);
  }

  /// 检查是否有指定的输出
  bool hasOutput(String key) {
    return _outputs.containsKey(key);
  }

  /// 获取输入值
  T? getInput<T>(String key) {
    return inputs[key] as T?;
  }

  /// 获取全局配置值
  T? getGlobalConfig<T>(String key) {
    return config.globalConfig?[key] as T?;
  }

  /// 获取执行时长
  Duration get executionDuration => DateTime.now().difference(startTime);

  /// 设置中间结果
  void setIntermediateResult(String key, dynamic value) {
    _intermediateResults[key] = value;
  }

  /// 获取中间结果
  T? getIntermediateResult<T>(String key) {
    return _intermediateResults[key] as T?;
  }

  /// 设置输出结果
  void setOutput(String key, dynamic value) {
    _outputs[key] = value;
  }

  /// 获取输出结果
  T? getOutput<T>(String key) {
    return _outputs[key] as T?;
  }

  /// 添加执行记录
  void addExecutionRecord(ExecutionRecord record) {
    _executionHistory.add(record);
  }

  /// 添加错误
  void addError(ExecutionError error) {
    _errors.add(error);
  }

  /// 移动到下一步
  void moveToNextStep() {
    _currentStepIndex++;
  }

  /// 重置步骤索引
  void resetStepIndex() {
    _currentStepIndex = 0;
  }

  /// 获取当前步骤ID
  String? get currentStepId {
    if (_currentStepIndex < config.steps.length) {
      return config.steps[_currentStepIndex].id;
    }
    return null;
  }

  /// 获取当前步骤
  ExecutionStep? getCurrentStep() {
    if (_currentStepIndex < config.steps.length) {
      return config.steps[_currentStepIndex];
    }
    return null;
  }

  /// 记录步骤开始
  void recordStepStart(String stepId) {
    final step = config.steps.firstWhere((s) => s.id == stepId);
    final record = ExecutionRecord(
      stepId: stepId,
      stepName: step.name,
      operationId: step.operationId,
      startTime: DateTime.now(),
      status: ExecutionStatus.running,
      inputs: {},
      outputs: {},
    );
    _executionHistory.add(record);
  }

  /// 记录步骤完成
  void recordStepComplete(String stepId, Map<String, dynamic> outputs) {
    final recordIndex = _executionHistory.indexWhere(
      (r) => r.stepId == stepId && r.endTime == null,
    );
    if (recordIndex != -1) {
      final oldRecord = _executionHistory[recordIndex];
      final newRecord = ExecutionRecord(
        stepId: oldRecord.stepId,
        stepName: oldRecord.stepName,
        operationId: oldRecord.operationId,
        startTime: oldRecord.startTime,
        endTime: DateTime.now(),
        status: ExecutionStatus.success,
        inputs: oldRecord.inputs,
        outputs: outputs,
      );
      _executionHistory[recordIndex] = newRecord;
    }
  }

  /// 记录步骤错误
  void recordStepError(String stepId, dynamic error) {
    final recordIndex = _executionHistory.indexWhere(
      (r) => r.stepId == stepId && r.endTime == null,
    );
    if (recordIndex != -1) {
      final oldRecord = _executionHistory[recordIndex];
      final newRecord = ExecutionRecord(
        stepId: oldRecord.stepId,
        stepName: oldRecord.stepName,
        operationId: oldRecord.operationId,
        startTime: oldRecord.startTime,
        endTime: DateTime.now(),
        status: ExecutionStatus.failed,
        inputs: oldRecord.inputs,
        outputs: oldRecord.outputs,
        errorMessage: error.toString(),
      );
      _executionHistory[recordIndex] = newRecord;
    }

    // 同时添加到错误列表
    addError(
      ExecutionError(
        code: 'STEP_ERROR',
        message: error.toString(),
        stepId: stepId,
        timestamp: DateTime.now(),
        errorType: ErrorType.error,
      ),
    );
  }

  /// 记录步骤跳过
  void recordStepSkipped(String stepId, String reason) {
    final step = config.steps.firstWhere((s) => s.id == stepId);
    final record = ExecutionRecord(
      stepId: stepId,
      stepName: step.name,
      operationId: step.operationId,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
      status: ExecutionStatus.skipped,
      inputs: {},
      outputs: {},
      errorMessage: reason,
    );
    _executionHistory.add(record);
  }

  /// 回滚到最后检查点
  void rollbackToLastCheckpoint() {
    // 简单实现：清除当前步骤之后的所有记录
    _executionHistory.removeWhere(
      (record) =>
          config.steps.indexWhere((step) => step.id == record.stepId) >
          _currentStepIndex,
    );

    // 清除相关的中间结果和输出
    _intermediateResults.clear();
    _outputs.clear();
  }

  /// 记录错误（别名方法，兼容error_handler.dart中的调用）
  void recordError(dynamic error) {
    if (error is ExecutionError) {
      addError(error);
    } else {
      addError(
        ExecutionError(
          code: 'GENERAL_ERROR',
          message: error.toString(),
          timestamp: DateTime.now(),
          errorType: ErrorType.error,
        ),
      );
    }
  }

  /// 获取变量值（支持输入、中间结果、输出）
  dynamic getVariable(String key) {
    // 优先级：输出 > 中间结果 > 输入
    if (_outputs.containsKey(key)) {
      return _outputs[key];
    }
    if (_intermediateResults.containsKey(key)) {
      return _intermediateResults[key];
    }
    if (inputs.containsKey(key)) {
      return inputs[key];
    }
    return null;
  }

  /// 检查是否有错误
  bool get hasErrors => _errors.isNotEmpty;

  /// 获取最后一个错误
  ExecutionError? get lastError => _errors.isNotEmpty ? _errors.last : null;

  /// 清除错误
  void clearErrors() {
    _errors.clear();
  }

  /// 变量存储（用于循环等场景）
  final Map<String, dynamic> _variables = {};

  /// 父上下文（用于子上下文）
  final ExecutionContext? _parent;

  /// 创建子上下文（用于循环等场景）
  ExecutionContext createChild() {
    return ExecutionContext(
      inputs: inputs,
      config: config,
      operationRegistry: operationRegistry,
      parent: this,
    );
  }

  /// 设置变量值
  void setVariable(String key, dynamic value) {
    _variables[key] = value;
  }

  /// 获取变量值（支持从父上下文继承）
  dynamic getVariableValue(String key) {
    // 先从当前上下文查找
    if (_variables.containsKey(key)) {
      return _variables[key];
    }

    // 再从父上下文查找
    if (_parent != null) {
      return _parent!.getVariableValue(key);
    }

    // 最后从输入、中间结果、输出中查找
    return getVariable(key);
  }

  /// 检查是否有指定变量
  bool hasVariable(String key) {
    return _variables.containsKey(key) ||
        (_parent?.hasVariable(key) ?? false) ||
        hasInput(key) ||
        hasIntermediateResult(key) ||
        hasOutput(key);
  }

  // /// 检查是否有错误
  // bool get hasErrors => _errors.isNotEmpty;

  // /// 获取最后一个错误
  // ExecutionError? get lastError => _errors.isNotEmpty ? _errors.last : null;

  // /// 清除错误
  // void clearErrors() {
  //   _errors.clear();
  // }

  /// 转换为JSON（用于缓存和恢复）
  Map<String, dynamic> toJson() {
    return {
      'inputs': inputs,
      'intermediateResults': _intermediateResults,
      'outputs': _outputs,
      'variables': _variables,
      'executionHistory': _executionHistory
          .map((record) => record.toJson())
          .toList(),
      'errors': _errors.map((error) => error.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'currentStepIndex': _currentStepIndex,
    };
  }

  @override
  String toString() {
    return 'ExecutionContext(inputs: ${inputs.length}, outputs: ${_outputs.length}, errors: ${_errors.length})';
  }
}

/// 执行记录类
/// Version: v0.1
class ExecutionRecord {
  /// 步骤ID
  final String stepId;

  /// 步骤名称
  final String stepName;

  /// 操作ID
  final String operationId;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime? endTime;

  /// 执行状态
  final ExecutionStatus status;

  /// 输入数据
  final Map<String, dynamic> inputs;

  /// 输出数据
  final Map<String, dynamic> outputs;

  /// 错误信息
  final String? errorMessage;

  const ExecutionRecord({
    required this.stepId,
    required this.stepName,
    required this.operationId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.inputs,
    required this.outputs,
    this.errorMessage,
  });

  /// 获取执行时长
  Duration? get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return null;
  }

  /// 从JSON创建实例
  factory ExecutionRecord.fromJson(Map<String, dynamic> json) {
    return ExecutionRecord(
      stepId: json['stepId'] as String,
      stepName: json['stepName'] as String,
      operationId: json['operationId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      status: ExecutionStatus.values.firstWhere(
        (status) => status.name == json['status'],
      ),
      inputs: json['inputs'] as Map<String, dynamic>,
      outputs: json['outputs'] as Map<String, dynamic>,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'stepId': stepId,
      'stepName': stepName,
      'operationId': operationId,
      'startTime': startTime.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      'status': status.name,
      'inputs': inputs,
      'outputs': outputs,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  @override
  String toString() {
    return 'ExecutionRecord(stepId: $stepId, status: $status, duration: ${duration?.inMilliseconds}ms)';
  }

  /// 检查是否已完成
  bool get isCompleted => status == ExecutionStatus.success;

  /// 检查是否有错误
  bool get hasError => status == ExecutionStatus.failed;
}

/// 执行错误类
/// Version: v0.1
class ExecutionError {
  /// 错误代码
  final String code;

  /// 错误消息
  final String message;

  /// 步骤ID
  final String? stepId;

  /// 操作ID
  final String? operationId;

  /// 发生时间
  final DateTime timestamp;

  /// 错误详情
  final Map<String, dynamic> details;

  /// 原始异常
  final dynamic originalException;

  final ErrorType errorType;

  const ExecutionError({
    required this.code,
    required this.message,
    this.stepId,
    this.operationId,
    required this.timestamp,
    this.details = const {},
    this.originalException,
    required this.errorType,
  });

  /// 从JSON创建实例
  factory ExecutionError.fromJson(Map<String, dynamic> json) {
    return ExecutionError(
      code: json['code'] as String,
      message: json['message'] as String,
      stepId: json['stepId'] as String?,
      operationId: json['operationId'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as Map<String, dynamic>? ?? {},
      originalException: json['originalException'],
      errorType: json['errorType'] as ErrorType,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (stepId != null) 'stepId': stepId,
      if (operationId != null) 'operationId': operationId,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }

  @override
  String toString() {
    return 'ExecutionError(code: $code, message: $message, stepId: $stepId, operationId: $operationId)';
  }

  /// 错误类型
  String get type => code.split(':').first;
}

/// 执行状态枚举
/// Version: v0.1
enum ExecutionStatus {
  /// 等待执行
  pending,

  /// 正在执行
  running,

  /// 执行成功
  success,

  /// 执行失败
  failed,

  /// 已跳过
  skipped,
}
