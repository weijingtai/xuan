/// 恢复管理器
/// Version: v0.1
/// 负责算法执行失败后的状态恢复
library recovery_manager;

import 'dart:convert';
import 'dart:io';

/// 恢复管理器类
/// Version: v0.1
class RecoveryManager {
  final String? _recoveryDirectory;
  final Map<String, RecoveryState> _memoryStates = {};
  final Duration _stateRetention;

  RecoveryManager({
    String? recoveryDirectory,
    Duration stateRetention = const Duration(days: 7),
  }) : _recoveryDirectory = recoveryDirectory,
       _stateRetention = stateRetention;

  /// 保存执行状态
  Future<void> saveState(
    String algorithmName,
    Map<String, dynamic> inputs,
    Map<String, dynamic> currentState,
    String? version,
  ) async {
    final stateKey = _generateStateKey(algorithmName, inputs, version);
    final recoveryState = RecoveryState(
      algorithmName: algorithmName,
      inputs: inputs,
      currentState: currentState,
      version: version,
      timestamp: DateTime.now(),
    );
    
    // 内存存储
    _memoryStates[stateKey] = recoveryState;
    
    // 文件存储（如果指定了恢复目录）
    if (_recoveryDirectory != null) {
      await _saveStateToDisk(stateKey, recoveryState);
    }
  }

  /// 获取恢复结果
  Future<Map<String, dynamic>?> getRecoveryResult(
    String algorithmName,
    Map<String, dynamic> inputs,
    String? version,
  ) async {
    final stateKey = _generateStateKey(algorithmName, inputs, version);
    
    // 检查内存状态
    if (_memoryStates.containsKey(stateKey)) {
      final state = _memoryStates[stateKey]!;
      if (_isStateValid(state)) {
        return state.currentState;
      } else {
        _memoryStates.remove(stateKey);
      }
    }
    
    // 检查文件状态
    if (_recoveryDirectory != null) {
      return await _loadStateFromDisk(stateKey);
    }
    
    return null;
  }

  /// 清除过期状态
  Future<void> cleanupExpiredStates() async {
    final now = DateTime.now();
    
    // 清除内存中的过期状态
    final expiredKeys = _memoryStates.entries
        .where((entry) => now.difference(entry.value.timestamp) > _stateRetention)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _memoryStates.remove(key);
    }
    
    // 清除文件中的过期状态
    if (_recoveryDirectory != null) {
      await _cleanupExpiredDiskStates();
    }
  }

  /// 获取恢复状态列表
  Future<List<RecoveryState>> getRecoveryStates({
    String? algorithmName,
  }) async {
    final states = <RecoveryState>[];
    
    // 从内存获取
    for (final state in _memoryStates.values) {
      if (algorithmName == null || state.algorithmName == algorithmName) {
        if (_isStateValid(state)) {
          states.add(state);
        }
      }
    }
    
    // 从文件获取
    if (_recoveryDirectory != null) {
      final diskStates = await _loadAllStatesFromDisk();
      for (final state in diskStates) {
        if (algorithmName == null || state.algorithmName == algorithmName) {
          if (_isStateValid(state)) {
            states.add(state);
          }
        }
      }
    }
    
    return states;
  }

  /// 删除指定状态
  Future<void> removeState(
    String algorithmName,
    Map<String, dynamic> inputs,
    String? version,
  ) async {
    final stateKey = _generateStateKey(algorithmName, inputs, version);
    
    // 从内存删除
    _memoryStates.remove(stateKey);
    
    // 从文件删除
    if (_recoveryDirectory != null) {
      await _removeStateFromDisk(stateKey);
    }
  }

  /// 生成状态键
  String _generateStateKey(
    String algorithmName,
    Map<String, dynamic> inputs,
    String? version,
  ) {
    final inputsJson = jsonEncode(inputs);
    final versionStr = version ?? 'latest';
    return '${algorithmName}_${versionStr}_${inputsJson.hashCode}';
  }

  /// 检查状态是否有效
  bool _isStateValid(RecoveryState state) {
    return DateTime.now().difference(state.timestamp) < _stateRetention;
  }

  /// 保存状态到磁盘
  Future<void> _saveStateToDisk(String stateKey, RecoveryState state) async {
    try {
      final directory = Directory(_recoveryDirectory!);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final file = File('${_recoveryDirectory!}/${_sanitizeKey(stateKey)}.json');
      await file.writeAsString(jsonEncode(state.toJson()));
    } catch (e) {
      // 忽略文件保存错误
    }
  }

  /// 从磁盘加载状态
  Future<Map<String, dynamic>?> _loadStateFromDisk(String stateKey) async {
    try {
      final file = File('${_recoveryDirectory!}/${_sanitizeKey(stateKey)}.json');
      if (!await file.exists()) return null;
      
      final content = await file.readAsString();
      final stateData = jsonDecode(content) as Map<String, dynamic>;
      final state = RecoveryState.fromJson(stateData);
      
      if (_isStateValid(state)) {
        return state.currentState;
      } else {
        await file.delete();
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// 加载所有磁盘状态
  Future<List<RecoveryState>> _loadAllStatesFromDisk() async {
    final states = <RecoveryState>[];
    
    try {
      final directory = Directory(_recoveryDirectory!);
      if (!await directory.exists()) return states;
      
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final content = await entity.readAsString();
            final stateData = jsonDecode(content) as Map<String, dynamic>;
            final state = RecoveryState.fromJson(stateData);
            states.add(state);
          } catch (e) {
            // 忽略无法解析的文件
          }
        }
      }
    } catch (e) {
      // 忽略目录读取错误
    }
    
    return states;
  }

  /// 清除过期的磁盘状态
  Future<void> _cleanupExpiredDiskStates() async {
    try {
      final directory = Directory(_recoveryDirectory!);
      if (!await directory.exists()) return;
      
      final now = DateTime.now();
      
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final content = await entity.readAsString();
            final stateData = jsonDecode(content) as Map<String, dynamic>;
            final state = RecoveryState.fromJson(stateData);
            
            if (now.difference(state.timestamp) > _stateRetention) {
              await entity.delete();
            }
          } catch (e) {
            // 删除无法解析的文件
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // 忽略清理错误
    }
  }

  /// 从磁盘删除状态
  Future<void> _removeStateFromDisk(String stateKey) async {
    try {
      final file = File('${_recoveryDirectory!}/${_sanitizeKey(stateKey)}.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // 忽略删除错误
    }
  }

  /// 清理文件名中的非法字符
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}

/// 恢复状态数据类
class RecoveryState {
  final String algorithmName;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> currentState;
  final String? version;
  final DateTime timestamp;

  const RecoveryState({
    required this.algorithmName,
    required this.inputs,
    required this.currentState,
    required this.version,
    required this.timestamp,
  });

  /// 从JSON创建实例
  factory RecoveryState.fromJson(Map<String, dynamic> json) {
    return RecoveryState(
      algorithmName: json['algorithmName'] as String,
      inputs: json['inputs'] as Map<String, dynamic>,
      currentState: json['currentState'] as Map<String, dynamic>,
      version: json['version'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'algorithmName': algorithmName,
      'inputs': inputs,
      'currentState': currentState,
      'version': version,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}