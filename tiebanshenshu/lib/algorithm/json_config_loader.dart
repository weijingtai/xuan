/// 算法编译器 - JSON配置加载器
///
/// 版本: v0.1
/// 作者: Algorithm Compiler Team
/// 创建时间: 2024
///
/// 功能说明:
/// - 负责加载和解析JSON格式的算法配置
/// - 支持配置文件验证和错误处理
/// - 提供配置缓存和热重载功能

import 'dart:convert';
import 'dart:io';
import 'models/algorithm_config.dart';

/// JSON配置加载器
class JSONConfigLoader {
  final Map<String, AlgorithmConfig> _configCache = {};
  final Map<String, DateTime> _lastModified = {};
  final String _configDirectory;

  JSONConfigLoader(this._configDirectory);

  /// 从文件加载配置
  Future<AlgorithmConfig> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);

      if (!await file.exists()) {
        throw FileSystemException('配置文件不存在', filePath);
      }

      // 检查缓存
      final lastModified = await file.lastModified();
      if (_configCache.containsKey(filePath) &&
          _lastModified[filePath] != null &&
          _lastModified[filePath]!.isAtSameMomentAs(lastModified)) {
        return _configCache[filePath]!;
      }

      final content = await file.readAsString();
      final config = loadFromString(content);

      // 更新缓存
      _configCache[filePath] = config;
      _lastModified[filePath] = lastModified;

      return config;
    } catch (e) {
      throw ConfigLoadException('加载配置文件失败: $filePath', e);
    }
  }

  /// 从字符串加载配置
  AlgorithmConfig loadFromString(String jsonString) {
    try {
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      return AlgorithmConfig.fromJson(jsonData);
    } catch (e) {
      throw ConfigParseException('解析JSON配置失败', e);
    }
  }

  /// 从Map加载配置
  AlgorithmConfig loadFromMap(Map<String, dynamic> configMap) {
    try {
      return AlgorithmConfig.fromJson(configMap);
    } catch (e) {
      throw ConfigParseException('解析配置Map失败', e);
    }
  }

  /// 验证配置格式
  bool validateConfig(Map<String, dynamic> configData) {
    try {
      // 检查必需字段
      final requiredFields = ['name', 'version', 'steps'];
      for (final field in requiredFields) {
        if (!configData.containsKey(field)) {
          return false;
        }
      }

      // 检查步骤格式
      final steps = configData['steps'];
      if (steps is! List) {
        return false;
      }

      for (final step in steps) {
        if (step is! Map<String, dynamic>) {
          return false;
        }

        if (!step.containsKey('id') || !step.containsKey('operation_id')) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 保存配置到文件
  Future<void> saveToFile(AlgorithmConfig config, String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = json.encode(config.toJson());
      await file.writeAsString(jsonString);

      // 更新缓存
      _configCache[filePath] = config;
      _lastModified[filePath] = await file.lastModified();
    } catch (e) {
      throw ConfigSaveException('保存配置文件失败: $filePath', e);
    }
  }

  /// 清除缓存
  void clearCache() {
    _configCache.clear();
    _lastModified.clear();
  }

  /// 获取缓存状态
  Map<String, dynamic> getCacheStatus() {
    return {
      'cached_configs': _configCache.length,
      'cache_keys': _configCache.keys.toList(),
      'last_modified': _lastModified.map(
        (k, v) => MapEntry(k, v.toIso8601String()),
      ),
    };
  }

  /// 获取可用算法列表
  Future<List<String>> getAvailableAlgorithms() async {
    final algorithms = <String>{};
    final directory = Directory(_configDirectory);
    
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final config = await loadFromFile(entity.path);
            algorithms.add(config.name);
          } catch (e) {
            // 忽略无法加载的配置文件
          }
        }
      }
    }
    
    return algorithms.toList()..sort();
  }

  /// 加载指定算法和版本的配置
  Future<Map<String, dynamic>> loadConfig(
    String algorithmName,
    String version,
  ) async {
    final directory = Directory(_configDirectory);
    
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final config = await loadFromFile(entity.path);
            if (config.name == algorithmName && config.version == version) {
              return config.toJson();
            }
          } catch (e) {
            // 忽略无法加载的配置文件
          }
        }
      }
    }
    
    throw ConfigLoadException('未找到算法配置: $algorithmName v$version');
  }
}

/// 配置加载异常
class ConfigLoadException implements Exception {
  final String message;
  final dynamic cause;

  ConfigLoadException(this.message, [this.cause]);

  @override
  String toString() {
    return 'ConfigLoadException: $message${cause != null ? ' (原因: $cause)' : ''}';
  }
}

/// 配置解析异常
class ConfigParseException implements Exception {
  final String message;
  final dynamic cause;

  ConfigParseException(this.message, [this.cause]);

  @override
  String toString() {
    return 'ConfigParseException: $message${cause != null ? ' (原因: $cause)' : ''}';
  }
}

/// 配置保存异常
class ConfigSaveException implements Exception {
  final String message;
  final dynamic cause;

  ConfigSaveException(this.message, [this.cause]);

  @override
  String toString() {
    return 'ConfigSaveException: $message${cause != null ? ' (原因: $cause)' : ''}';
  }
}
