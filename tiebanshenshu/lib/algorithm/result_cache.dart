/// 结果缓存组件
/// Version: v0.1
/// 负责缓存算法执行结果
library result_cache;

import 'dart:convert';
import 'dart:io';

/// 结果缓存类
/// Version: v0.1
class ResultCache {
  final Map<String, Map<String, dynamic>> _memoryCache = {};
  final String? _cacheDirectory;
  final Duration _defaultTtl;
  final Map<String, DateTime> _cacheTimestamps = {};

  ResultCache({
    String? cacheDirectory,
    Duration defaultTtl = const Duration(hours: 24),
  }) : _cacheDirectory = cacheDirectory,
       _defaultTtl = defaultTtl;

  /// 存储缓存结果
  Future<void> put(
    String key,
    Map<String, dynamic> value, {
    Duration? ttl,
  }) async {
    final effectiveTtl = ttl ?? _defaultTtl;
    
    // 内存缓存
    _memoryCache[key] = Map<String, dynamic>.from(value);
    _cacheTimestamps[key] = DateTime.now();
    
    // 文件缓存（如果指定了缓存目录）
    if (_cacheDirectory != null) {
      await _saveToDisk(key, value, effectiveTtl);
    }
  }

  /// 获取缓存结果
  Future<Map<String, dynamic>?> get(String key) async {
    // 检查内存缓存
    if (_memoryCache.containsKey(key)) {
      if (_isValid(key)) {
        return Map<String, dynamic>.from(_memoryCache[key]!);
      } else {
        // 过期，清除缓存
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
      }
    }
    
    // 检查文件缓存
    if (_cacheDirectory != null) {
      return await _loadFromDisk(key);
    }
    
    return null;
  }

  /// 清除指定前缀的缓存
  Future<void> clearByPrefix(String prefix) async {
    // 清除内存缓存
    final keysToRemove = _memoryCache.keys
        .where((key) => key.startsWith(prefix))
        .toList();
    
    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }
    
    // 清除文件缓存
    if (_cacheDirectory != null) {
      await _clearDiskByPrefix(prefix);
    }
  }

  /// 清除所有缓存
  Future<void> clear() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    
    if (_cacheDirectory != null) {
      await _clearAllDisk();
    }
  }

  /// 检查缓存是否有效
  bool _isValid(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _defaultTtl;
  }

  /// 保存到磁盘
  Future<void> _saveToDisk(
    String key,
    Map<String, dynamic> value,
    Duration ttl,
  ) async {
    try {
      final directory = Directory(_cacheDirectory!);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final file = File('${_cacheDirectory!}/${_sanitizeKey(key)}.json');
      final cacheData = {
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
        'ttl': ttl.inMilliseconds,
      };
      
      await file.writeAsString(jsonEncode(cacheData));
    } catch (e) {
      // 忽略文件缓存错误，不影响内存缓存
    }
  }

  /// 从磁盘加载
  Future<Map<String, dynamic>?> _loadFromDisk(String key) async {
    try {
      final file = File('${_cacheDirectory!}/${_sanitizeKey(key)}.json');
      if (!await file.exists()) return null;
      
      final content = await file.readAsString();
      final cacheData = jsonDecode(content) as Map<String, dynamic>;
      
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      final ttl = Duration(milliseconds: cacheData['ttl'] as int);
      
      if (DateTime.now().difference(timestamp) < ttl) {
        return cacheData['value'] as Map<String, dynamic>;
      } else {
        // 过期，删除文件
        await file.delete();
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 清除指定前缀的磁盘缓存
  Future<void> _clearDiskByPrefix(String prefix) async {
    try {
      final directory = Directory(_cacheDirectory!);
      if (!await directory.exists()) return;
      
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.contains(prefix)) {
          await entity.delete();
        }
      }
    } catch (e) {
      // 忽略清除错误
    }
  }

  /// 清除所有磁盘缓存
  Future<void> _clearAllDisk() async {
    try {
      final directory = Directory(_cacheDirectory!);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      // 忽略清除错误
    }
  }

  /// 清理文件名中的非法字符
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    return {
      'memoryEntries': _memoryCache.length,
      'oldestEntry': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values.reduce((a, b) => a.isBefore(b) ? a : b),
      'newestEntry': _cacheTimestamps.values.isEmpty
          ? null
          : _cacheTimestamps.values.reduce((a, b) => a.isAfter(b) ? a : b),
    };
  }
}