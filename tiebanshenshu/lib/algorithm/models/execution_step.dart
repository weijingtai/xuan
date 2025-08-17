/// 执行步骤模型
/// Version: v0.1
/// 定义算法执行的单个步骤
library execution_step;

import 'conditional_branch.dart';

/// 执行步骤类
/// Version: v0.1
class ExecutionStep {
  /// 步骤ID
  final String id;
  
  /// 步骤名称
  final String name;
  
  /// 步骤描述
  final String description;
  
  /// 操作ID
  final String operationId;
  
  /// 步骤配置
  final Map<String, dynamic> config;
  
  /// 输入映射
  final Map<String, String> inputs;
  
  /// 输出映射
  final Map<String, String> outputs;
  
  /// 条件分支
  final List<ConditionalBranch>? conditionalBranches;
  
  /// 是否必需
  final bool required;
  
  /// 超时时间（毫秒）
  final int? timeoutMs;
  
  /// 重试次数
  final int retryCount;

  /// 依赖步骤列表
  final List<String> dependencies;
  
  /// 是否可选（非必需）
  final bool isOptional;
  
  /// 操作类型（兼容性别名）
  String get operationType => operationId;
  
  /// 输入映射（兼容性别名）
  Map<String, String> get inputMapping => inputs;
  
  /// 输出映射（兼容性别名）
  Map<String, String> get outputMapping => outputs;

  const ExecutionStep({
    required this.id,
    required this.name,
    required this.description,
    required this.operationId,
    required this.config,
    required this.inputs,
    required this.outputs,
    this.conditionalBranches,
    this.required = true,
    this.timeoutMs,
    this.retryCount = 0,
    this.dependencies = const [],
    this.isOptional = false,
  });

  /// 从JSON创建实例
  factory ExecutionStep.fromJson(Map<String, dynamic> json) {
    return ExecutionStep(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      operationId: json['operationId'] as String,
      config: json['config'] as Map<String, dynamic>,
      inputs: Map<String, String>.from(json['inputs'] as Map),
      outputs: Map<String, String>.from(json['outputs'] as Map),
      conditionalBranches: json['conditionalBranches'] != null
          ? (json['conditionalBranches'] as List<dynamic>)
              .map((branch) => ConditionalBranch.fromJson(branch as Map<String, dynamic>))
              .toList()
          : null,
      required: json['required'] as bool? ?? true,
      timeoutMs: json['timeoutMs'] as int?,
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'operationId': operationId,
      'config': config,
      'inputs': inputs,
      'outputs': outputs,
      if (conditionalBranches != null)
        'conditionalBranches': conditionalBranches!.map((branch) => branch.toJson()).toList(),
      'required': required,
      if (timeoutMs != null) 'timeoutMs': timeoutMs,
      'retryCount': retryCount,
    };
  }

  /// 是否有条件分支
  bool get hasConditionalBranches => conditionalBranches != null && conditionalBranches!.isNotEmpty;

  /// 获取输入键列表
  List<String> get inputKeys => inputs.keys.toList();

  /// 获取输出键列表
  List<String> get outputKeys => outputs.keys.toList();

  @override
  String toString() {
    return 'ExecutionStep(id: $id, name: $name, operationId: $operationId)';
  }
}