/// 配置引擎
/// Version: v0.1
/// 负责加载和管理算法配置
library configuration_engine;

import 'dart:convert';
import 'dart:io';
import 'models/algorithm_config.dart';
import 'json_config_loader.dart';
import 'version_manager.dart';

/// 配置引擎类
/// Version: v0.1
class ConfigurationEngine {
  final JSONConfigLoader _configLoader;
  final VersionManager _versionManager;

  ConfigurationEngine({
    required JSONConfigLoader configLoader,
    required VersionManager versionManager,
  }) : _configLoader = configLoader,
       _versionManager = versionManager;

  /// 加载算法配置
  Future<AlgorithmConfig> loadConfig(
    String algorithmName, {
    String? version,
  }) async {
    final targetVersion = version ?? await _getLatestVersion(algorithmName);
    final configData = await _configLoader.loadConfig(
      algorithmName,
      targetVersion,
    );
    return AlgorithmConfig.fromJson(configData);
  }

  /// 获取可用算法列表
  Future<List<String>> getAvailableAlgorithms() async {
    return await _configLoader.getAvailableAlgorithms();
  }

  /// 获取算法版本列表
  Future<List<String>> getVersions(String algorithmName) async {
    return await _versionManager.getAvailableVersions(algorithmName);
  }

  /// 验证配置有效性
  Future<bool> validateConfig(String algorithmName, String version) async {
    try {
      await loadConfig(algorithmName, version: version);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取最新版本
  Future<String> _getLatestVersion(String algorithmName) async {
    final versions = await _versionManager.getAvailableVersions(algorithmName);
    if (versions.isEmpty) {
      throw Exception('No versions found for algorithm: $algorithmName');
    }
    return versions.last; // 版本已经按顺序排序，最后一个是最新版本
  }
}
