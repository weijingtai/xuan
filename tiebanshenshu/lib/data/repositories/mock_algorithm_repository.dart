import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tiebanshenshu/algorithm/models/algorithm_config.dart';
import 'package:tiebanshenshu/data/models/algorithm_summary.dart';
import 'package:tiebanshenshu/data/repositories/algorithm_repository.dart';

// 注意：这是一个模拟实现，用于UI原型开发。
// 它假定可以从assets目录读取算法定义。在真实实现中，
// 用户创建的算法需要被保存在一个可写目录中，比如应用文档目录。
class MockAlgorithmRepository implements AlgorithmRepository {
  // 使用一个简单的内存缓存来模拟保存/删除操作
  final Map<String, AlgorithmConfig> _inMemoryCache = {};

  Future<String> _getJsonString(String path) async {
    return await rootBundle.loadString(path);
  }

  @override
  Future<List<AlgorithmSummary>> getAlgorithmSummaries() async {
    // Dynamically load all algorithms from the assets directory.
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final algorithmAssets = manifestMap.keys
        .where((String key) => key.startsWith('assets/algorithms/'))
        .toList();

    final summaries = <AlgorithmSummary>[];
    for (final path in algorithmAssets) {
      try {
        final jsonString = await rootBundle.loadString(path);
        final Map<String, dynamic> configMap = json.decode(jsonString);

        // Extract the ID from the filename, e.g., "assets/algorithms/gun_fa_v2.json" -> "gun_fa_v2"
        final id = path.split('/').last.replaceAll('.json', '');

        summaries.add(
          AlgorithmSummary(
            id: id,
            name: configMap['name'] ?? '未命名算法',
            description: configMap['description'] ?? '无描述',
          ),
        );
      } catch (e) {
        // Ignore files that fail to parse
        print("Failed to load or parse algorithm from $path: $e");
      }
    }

    // Also include any new algorithms created in-memory during the session
    final cachedSummaries = _inMemoryCache.values
        .map(
          (config) => AlgorithmSummary(
            id: config
                .name, // In-memory algorithms might not have a persistent ID yet
            name: config.name,
            description: config.description,
          ),
        )
        .toList();

    // Combine and return, avoiding duplicates if any were cached
    final combined = [...summaries, ...cachedSummaries];
    final uniqueIds = <String>{};
    return combined.where((summary) => uniqueIds.add(summary.id)).toList();
  }

  @override
  Future<AlgorithmConfig> getAlgorithmById(String id) async {
    if (_inMemoryCache.containsKey(id)) {
      return _inMemoryCache[id]!;
    }

    // 假设ID和文件名相关
    final jsonString = await _getJsonString('assets/algorithms/$id.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    // 注意：AlgorithmConfig.fromJson可能需要一个id字段，如果模型没有，
    // 我们需要在这里或ViewModel中处理ID。
    // 根据我们之前的分析，模型本身不包含ID。
    final config = AlgorithmConfig.fromJson(jsonMap);

    _inMemoryCache[id] = config;
    return config;
  }

  @override
  Future<void> deleteAlgorithm(String id) async {
    print("Mock: Deleting algorithm $id.");
    _inMemoryCache.remove(id);
    // 在真实应用中，需要删除应用文档目录中的对应文件
    return Future.value();
  }

  @override
  Future<void> saveAlgorithm(AlgorithmConfig config) async {
    // 在模拟实现中，我们简单地使用算法名称作为ID，并保存在内存缓存中
    final id = config.name;
    print("Mock: Saving algorithm to in-memory cache with id: $id.");
    _inMemoryCache[id] = config;

    // 打印JSON以供调试
    print(json.encode(config.toJson()));

    return Future.value();
  }
}
