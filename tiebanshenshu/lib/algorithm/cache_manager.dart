/// 缓存管理器
/// Version: v0.1
/// 负责结果缓存和失败恢复
library cache_manager;

import 'dart:convert';
import 'result_cache.dart';
import 'recovery_manager.dart';

/// 缓存管理器类
/// Version: v0.1
class CacheManager {
  final ResultCache _resultCache;
  final RecoveryManager _recoveryManager;

  CacheManager({
    required ResultCache resultCache,
    required RecoveryManager recoveryManager,
  }) : _resultCache = resultCache,
       _recoveryManager = recoveryManager;

  /// 缓存计算结果
  Future<void> cacheResult(
    String algorithmName,
    Map<String, dynamic> inputs,
    Map<String, dynamic> result,
    String? version,
  ) async {
    final cacheKey = _generateCacheKey(algorithmName, inputs, version);
    await _resultCache.put(cacheKey, result);
  }

  /// 获取缓存结果
  Future<Map<String, dynamic>?> getResult(
    String algorithmName,
    Map<String, dynamic> inputs,
    String? version,
  ) async {
    final cacheKey = _generateCacheKey(algorithmName, inputs, version);
    return await _resultCache.get(cacheKey);
  }

  /// 保存恢复状态
  Future<void> saveRecoveryState(
    String algorithmName,
    Map<String, dynamic> inputs,
    Map<String, dynamic> currentState,
    String? version,
  ) async {
    await _recoveryManager.saveState(
      algorithmName,
      inputs,
      currentState,
      version,
    );
  }

  /// 获取恢复结果
  Future<Map<String, dynamic>?> getRecoveryResult(
    String algorithmName,
    Map<String, dynamic> inputs,
    String? version,
  ) async {
    return await _recoveryManager.getRecoveryResult(
      algorithmName,
      inputs,
      version,
    );
  }

  /// 清除缓存
  Future<void> clearCache({String? algorithmName}) async {
    if (algorithmName != null) {
      await _resultCache.clearByPrefix(algorithmName);
    } else {
      await _resultCache.clear();
    }
  }

  /// 生成缓存键
  String _generateCacheKey(
    String algorithmName,
    Map<String, dynamic> inputs,
    String? version,
  ) {
    final inputsJson = jsonEncode(inputs);
    final versionSuffix = version != null ? '_$version' : '';
    return '${algorithmName}${versionSuffix}_${inputsJson.hashCode}';
  }
}
