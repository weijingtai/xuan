/// 算法编译器核心类
/// Version: v0.1
/// 负责加载配置、执行算法和处理缓存及错误
library algorithm_compiler;

import 'dart:convert';
import 'configuration_engine.dart';
import 'atomic_operation_registry.dart';
import 'execution_engine.dart';
import 'cache_manager.dart';
import 'models/algorithm_config.dart';
import 'models/execution_context.dart';
import '../service/calculation_strategy.dart';

/// 算法编译器主类
/// Version: v0.1
class AlgorithmCompiler {
  final ConfigurationEngine _configEngine;
  final AtomicOperationRegistry _operationRegistry;
  final ExecutionEngine _executionEngine;
  final CacheManager _cacheManager;

  AlgorithmCompiler({
    required ConfigurationEngine configEngine,
    required AtomicOperationRegistry operationRegistry,
    required ExecutionEngine executionEngine,
    required CacheManager cacheManager,
  }) : _configEngine = configEngine,
       _operationRegistry = operationRegistry,
       _executionEngine = executionEngine,
       _cacheManager = cacheManager;

  /// 加载算法配置
  Future<AlgorithmConfig> loadAlgorithm(
    String algorithmName, {
    String? version,
  }) async {
    return await _configEngine.loadConfig(algorithmName, version: version);
  }

  /// 执行算法
  Future<Map<String, dynamic>> executeAlgorithm(
    String algorithmName,
    Map<String, dynamic> inputs, {
    String? version,
    bool useCache = true,
  }) async {
    try {
      // 检查缓存
      if (useCache) {
        final cachedResult = await _cacheManager.getResult(
          algorithmName,
          inputs,
          version,
        );
        if (cachedResult != null) {
          return cachedResult;
        }
      }

      // 加载配置
      final config = await loadAlgorithm(algorithmName, version: version);

      // 创建执行上下文
      final context = ExecutionContext(
        inputs: inputs,
        config: config,
        operationRegistry: _operationRegistry,
      );

      // 执行算法
      final result = await _executionEngine.execute(context);

      // 缓存结果
      if (useCache) {
        await _cacheManager.cacheResult(algorithmName, inputs, result, version);
      }

      return result;
    } catch (e) {
      // 错误处理和恢复
      return await _handleExecutionError(algorithmName, inputs, e, version);
    }
  }

  /// 处理执行错误
  Future<Map<String, dynamic>> _handleExecutionError(
    String algorithmName,
    Map<String, dynamic> inputs,
    dynamic error,
    String? version,
  ) async {
    // 尝试从恢复缓存获取结果
    final recoveryResult = await _cacheManager.getRecoveryResult(
      algorithmName,
      inputs,
      version,
    );
    if (recoveryResult != null) {
      return recoveryResult;
    }

    // 重新抛出异常
    throw AlgorithmExecutionException(
      'Algorithm execution failed: $algorithmName',
      originalError: error,
    );
  }

  /// 获取可用的算法列表
  Future<List<String>> getAvailableAlgorithms() async {
    return await _configEngine.getAvailableAlgorithms();
  }

  /// 获取算法的可用版本
  Future<List<String>> getAlgorithmVersions(String algorithmName) async {
    return await _configEngine.getVersions(algorithmName);
  }
}

/// 算法执行异常
/// Version: v0.1
class AlgorithmExecutionException implements Exception {
  final String message;
  final dynamic originalError;

  const AlgorithmExecutionException(this.message, {this.originalError});

  @override
  String toString() {
    return 'AlgorithmExecutionException: $message${originalError != null ? ' (Original: $originalError)' : ''}';
  }
}
