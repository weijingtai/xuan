/// 执行步骤模型
/// Version: v0.1
/// 定义算法执行的单个步骤
library execution_step;

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'conditional_branch.dart';

part 'execution_step.g.dart';

/// 执行步骤类
/// Version: v0.2 (json_serializable)
@JsonSerializable(explicitToJson: true)
class ExecutionStep extends Equatable {
  /// 步骤ID
  final String id;

  /// 步骤名称
  @JsonKey(defaultValue: '')
  final String name;

  /// 步骤描述
  @JsonKey(defaultValue: '')
  final String description;

  /// 操作ID
  final String operationId;

  /// 步骤配置
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> config;

  /// 输入映射
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> inputs;

  /// 输出映射
  @JsonKey(defaultValue: {})
  final Map<String, dynamic> outputs;

  /// 条件分支
  final List<ConditionalBranch>? conditionalBranches;

  /// 是否必需
  @JsonKey(defaultValue: true)
  final bool required;

  /// 超时时间（毫秒）
  final int? timeoutMs;

  /// 重试次数
  @JsonKey(defaultValue: 0)
  final int retryCount;

  /// 依赖步骤列表
  @JsonKey(defaultValue: [])
  final List<String> dependencies;

  /// 是否可选（非必需）
  @JsonKey(defaultValue: false)
  final bool isOptional;

  /// 操作类型（兼容性别名）
  @JsonKey(includeFromJson: false, includeToJson: false)
  String get operationType => operationId;

  /// 输入映射（兼容性别名）
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic> get inputMapping => inputs;

  /// 输出映射（兼容性别名）
  @JsonKey(includeFromJson: false, includeToJson: false)
  Map<String, dynamic> get outputMapping => outputs;

  const ExecutionStep({
    required this.id,
    this.name = '',
    this.description = '',
    required this.operationId,
    this.config = const {},
    this.inputs = const {},
    this.outputs = const {},
    this.conditionalBranches,
    this.required = true,
    this.timeoutMs,
    this.retryCount = 0,
    this.dependencies = const [],
    this.isOptional = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    operationId,
    config,
    inputs,
    outputs,
    conditionalBranches,
    required,
    timeoutMs,
    retryCount,
    dependencies,
    isOptional,
  ];

  /// 从JSON创建实例
  factory ExecutionStep.fromJson(Map<String, dynamic> json) =>
      _$ExecutionStepFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ExecutionStepToJson(this);

  /// 复制实例并更新字段
  ExecutionStep copyWith({
    String? id,
    String? name,
    String? description,
    String? operationId,
    Map<String, dynamic>? config,
    Map<String, dynamic>? inputs,
    Map<String, dynamic>? outputs,
    List<ConditionalBranch>? conditionalBranches,
    bool? required,
    int? timeoutMs,
    int? retryCount,
    List<String>? dependencies,
    bool? isOptional,
  }) {
    return ExecutionStep(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      operationId: operationId ?? this.operationId,
      config: config ?? this.config,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      conditionalBranches: conditionalBranches ?? this.conditionalBranches,
      required: required ?? this.required,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      retryCount: retryCount ?? this.retryCount,
      dependencies: dependencies ?? this.dependencies,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  /// 是否有条件分支
  bool get hasConditionalBranches =>
      conditionalBranches != null && conditionalBranches!.isNotEmpty;

  /// 获取输入键列表
  List<String> get inputKeys => inputs.keys.toList();

  /// 获取输出键列表
  List<String> get outputKeys => outputs.keys.toList();

  @override
  String toString() {
    return 'ExecutionStep(id: $id, name: $name, operationId: $operationId)';
  }
}
