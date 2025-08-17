/// 原子操作注册表
/// Version: v0.1
/// 管理所有可用的原子操作
library atomic_operation_registry;

import 'models/atomic_operation.dart';
import 'operations/input_decomposition.dart';
import 'operations/core_transformation.dart';
import 'operations/composition_construction.dart';
import 'operations/aggregation_calculation.dart';
import 'operations/flow_control.dart';
import 'operations/validation_generation.dart';

/// 原子操作注册表
/// Version: v0.1
class AtomicOperationRegistry {
  final Map<String, AtomicOperation> _operations = {};

  AtomicOperationRegistry() {
    _registerDefaultOperations();
  }

  /// 注册默认操作
  void _registerDefaultOperations() {
    // 输入与分解类操作
    for (final operation in InputDecomposition.getOperations()) {
      register(operation);
    }

    // 核心转换类操作
    for (final operation in CoreTransformation.getOperations()) {
      register(operation);
    }

    // 组合与建构类操作
    for (final operation in CompositionConstruction.getOperations()) {
      register(operation);
    }

    // 聚合与运算类操作
    for (final operation in AggregationCalculation.getOperations()) {
      register(operation);
    }

    // 流程控制类操作
    for (final operation in FlowControl.getOperations()) {
      register(operation);
    }

    // 验证与生成类操作
    for (final operation in ValidationGeneration.getOperations()) {
      register(operation);
    }
  }

  /// 注册操作
  void register(AtomicOperation operation) {
    _operations[operation.id] = operation;
  }

  /// 获取操作
  AtomicOperation? getOperation(String operationId) {
    return _operations[operationId];
  }

  /// 获取所有操作ID
  List<String> getAllOperationIds() {
    return _operations.keys.toList();
  }

  /// 检查操作是否存在
  bool hasOperation(String operationId) {
    return _operations.containsKey(operationId);
  }

  /// 按类别获取操作
  List<AtomicOperation> getOperationsByCategory(String category) {
    return _operations.values.where((op) => op.category == category).toList();
  }
}
