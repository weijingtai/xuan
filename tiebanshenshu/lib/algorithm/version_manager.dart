/// 算法编译器 - 版本管理器
/// 
/// 版本: v0.1
/// 作者: Algorithm Compiler Team
/// 创建时间: 2024
/// 
/// 功能说明:
/// - 管理算法配置的版本控制
/// - 支持版本比较和兼容性检查
/// - 提供版本升级和回退功能

import 'dart:io';
import 'dart:convert';
import 'models/algorithm_config.dart';
import 'json_config_loader.dart';

/// 版本管理器
class VersionManager {
  final JSONConfigLoader _configLoader;
  final String _configDirectory;
  final Map<String, List<String>> _versionCache = {};
  
  VersionManager(this._configLoader, this._configDirectory);
  
  /// 获取指定算法的所有可用版本
  Future<List<String>> getAvailableVersions(String algorithmName) async {
    if (_versionCache.containsKey(algorithmName)) {
      return _versionCache[algorithmName]!;
    }
    
    final versions = <String>[];
    final directory = Directory(_configDirectory);
    
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final config = await _configLoader.loadFromFile(entity.path);
            if (config.name == algorithmName) {
              versions.add(config.version);
            }
          } catch (e) {
            // 忽略无法加载的配置文件
          }
        }
      }
    }
    
    // 按版本号排序
    versions.sort(_compareVersions);
    _versionCache[algorithmName] = versions;
    
    return versions;
  }
  
  /// 获取指定版本的配置
  Future<AlgorithmConfig?> getConfigByVersion(
    String algorithmName,
    String version,
  ) async {
    final directory = Directory(_configDirectory);
    
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final config = await _configLoader.loadFromFile(entity.path);
            if (config.name == algorithmName && config.version == version) {
              return config;
            }
          } catch (e) {
            // 忽略无法加载的配置文件
          }
        }
      }
    }
    
    return null;
  }
  
  /// 获取最新版本的配置
  Future<AlgorithmConfig?> getLatestConfig(String algorithmName) async {
    final versions = await getAvailableVersions(algorithmName);
    if (versions.isEmpty) return null;
    
    final latestVersion = versions.last;
    return await getConfigByVersion(algorithmName, latestVersion);
  }
  
  /// 检查版本兼容性
  bool isVersionCompatible(String currentVersion, String requiredVersion) {
    final current = _parseVersion(currentVersion);
    final required = _parseVersion(requiredVersion);
    
    // 主版本号必须相同
    if (current['major'] != required['major']) {
      return false;
    }
    
    // 次版本号必须大于等于要求的版本
    if (current['minor']! < required['minor']!) {
      return false;
    }
    
    // 如果次版本号相同，修订版本号必须大于等于要求的版本
    if (current['minor'] == required['minor'] && 
        current['patch']! < required['patch']!) {
      return false;
    }
    
    return true;
  }
  
  /// 比较两个版本号
  int _compareVersions(String version1, String version2) {
    final v1 = _parseVersion(version1);
    final v2 = _parseVersion(version2);
    
    // 比较主版本号
    if (v1['major'] != v2['major']) {
      return v1['major']!.compareTo(v2['major']!);
    }
    
    // 比较次版本号
    if (v1['minor'] != v2['minor']) {
      return v1['minor']!.compareTo(v2['minor']!);
    }
    
    // 比较修订版本号
    return v1['patch']!.compareTo(v2['patch']!);
  }
  
  /// 解析版本号
  Map<String, int> _parseVersion(String version) {
    final parts = version.split('.');
    
    return {
      'major': parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      'minor': parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      'patch': parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
    };
  }
  
  /// 创建新版本
  Future<String> createNewVersion(
    String algorithmName,
    AlgorithmConfig config,
    VersionBumpType bumpType,
  ) async {
    final versions = await getAvailableVersions(algorithmName);
    final currentVersion = versions.isNotEmpty ? versions.last : '0.0.0';
    
    final newVersion = _bumpVersion(currentVersion, bumpType);
    final newConfig = config.copyWith(version: newVersion);
    
    // 保存新版本配置
    final fileName = '${algorithmName}_$newVersion.json';
    final filePath = '$_configDirectory/$fileName';
    await _configLoader.saveToFile(newConfig, filePath);
    
    // 清除缓存
    _versionCache.remove(algorithmName);
    
    return newVersion;
  }
  
  /// 版本号递增
  String _bumpVersion(String currentVersion, VersionBumpType bumpType) {
    final version = _parseVersion(currentVersion);
    
    switch (bumpType) {
      case VersionBumpType.major:
        return '${version['major']! + 1}.0.0';
      case VersionBumpType.minor:
        return '${version['major']}.${version['minor']! + 1}.0';
      case VersionBumpType.patch:
        return '${version['major']}.${version['minor']}.${version['patch']! + 1}';
    }
  }
  
  /// 删除指定版本
  Future<bool> deleteVersion(String algorithmName, String version) async {
    final config = await getConfigByVersion(algorithmName, version);
    if (config == null) return false;
    
    final fileName = '${algorithmName}_$version.json';
    final filePath = '$_configDirectory/$fileName';
    final file = File(filePath);
    
    if (await file.exists()) {
      await file.delete();
      _versionCache.remove(algorithmName);
      return true;
    }
    
    return false;
  }
  
  /// 获取版本历史
  Future<List<VersionInfo>> getVersionHistory(String algorithmName) async {
    final versions = await getAvailableVersions(algorithmName);
    final history = <VersionInfo>[];
    
    for (final version in versions) {
      final config = await getConfigByVersion(algorithmName, version);
      if (config != null) {
        final fileName = '${algorithmName}_$version.json';
        final filePath = '$_configDirectory/$fileName';
        final file = File(filePath);
        
        DateTime? createdAt;
        if (await file.exists()) {
          createdAt = await file.lastModified();
        }
        
        history.add(VersionInfo(
          version: version,
          algorithmName: algorithmName,
          description: config.description ?? '',
          createdAt: createdAt,
          stepCount: config.steps.length,
        ));
      }
    }
    
    return history;
  }
  
  /// 清除版本缓存
  void clearCache() {
    _versionCache.clear();
  }
}

/// 版本递增类型
enum VersionBumpType {
  major,
  minor,
  patch,
}

/// 版本信息
class VersionInfo {
  final String version;
  final String algorithmName;
  final String description;
  final DateTime? createdAt;
  final int stepCount;
  
  VersionInfo({
    required this.version,
    required this.algorithmName,
    required this.description,
    this.createdAt,
    required this.stepCount,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'algorithm_name': algorithmName,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'step_count': stepCount,
    };
  }
  
  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      version: json['version'] as String,
      algorithmName: json['algorithm_name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      stepCount: json['step_count'] as int? ?? 0,
    );
  }
}