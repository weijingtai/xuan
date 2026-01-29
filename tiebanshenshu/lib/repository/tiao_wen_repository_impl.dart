import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:common/enums.dart';
import 'tiao_wen_repository.dart';
import 'datamodels/tiao_wen_datamodel.dart';

/// 条文数据仓库实现类
///
/// 基于 CSV 资源文件的条文数据访问实现
class TiaoWenRepositoryImpl implements TiaoWenRepository {
  static TiaoWenRepositoryImpl? _instance;

  final String tiaoWenDataPath;

  // 缓存变量
  static List<TiaoWenDataModel>? _cachedTiaoWenList;
  static Map<int, TiaoWenDataModel>? _cachedTiaoWenMap;

  // 并发安全控制
  static final Completer<void>? _loadingCompleter = null;
  static Completer<void>? _currentLoadingCompleter;

  // 私有构造函数
  TiaoWenRepositoryImpl._({required this.tiaoWenDataPath});

  /// 工厂构造函数
  ///
  /// [dataPath] 条文数据文件路径
  factory TiaoWenRepositoryImpl({required String dataPath}) {
    _instance ??= TiaoWenRepositoryImpl._(tiaoWenDataPath: dataPath);
    return _instance!;
  }

  /// 从 CSV 资源文件加载条文数据
  ///
  /// 加载并缓存所有条文数据，提高后续访问性能
  /// 使用Completer机制确保并发安全，多个同时调用只会加载一次
  Future<void> _loadTiaoWenFromAssets() async {
    // 如果数据已经加载完成，直接返回
    if (_cachedTiaoWenList != null && _cachedTiaoWenMap != null) {
      return;
    }

    // 如果正在加载中，等待当前加载完成
    if (_currentLoadingCompleter != null) {
      await _currentLoadingCompleter!.future;
      return;
    }

    // 开始新的加载过程
    _currentLoadingCompleter = Completer<void>();

    try {
      final String csvString = await rootBundle.loadString(tiaoWenDataPath);
      final List<String> lines = csvString.split('\n');

      // 创建临时变量，避免在加载过程中其他线程访问到不完整的数据
      final List<TiaoWenDataModel> tempList = [];
      final Map<int, TiaoWenDataModel> tempMap = {};

      for (String line in lines) {
        if (line.trim().isEmpty) continue;

        try {
          final tiaoWen = _parseCsvLine(line);
          if (tiaoWen != null) {
            tempList.add(tiaoWen);
            tempMap[tiaoWen.id] = tiaoWen;
          }
        } catch (e) {
          // 记录解析错误但继续处理其他数据
          print('Error parsing TiaoWen line: $line, error: $e');
        }
      }

      // 原子性地更新缓存
      _cachedTiaoWenList = tempList;
      _cachedTiaoWenMap = tempMap;

      // 标记加载完成
      _currentLoadingCompleter!.complete();
    } catch (e) {
      // 加载失败，标记错误
      _currentLoadingCompleter!.completeError(e);
      throw Exception('Failed to load TiaoWen data: $e');
    } finally {
      // 清理加载状态
      _currentLoadingCompleter = null;
    }
  }

  /// 解析 CSV 行数据
  ///
  /// CSV 格式: id,setName,content1,ageSet1
  /// 例如: 1001,子,一树残花，有枝复茂。,(47)
  TiaoWenDataModel? _parseCsvLine(String line) {
    try {
      // 简单的 CSV 解析，处理逗号分隔
      final List<String> parts = _splitCsvLine(line);

      if (parts.length < 3) {
        return null;
      }

      final int id = int.parse(parts[0].trim());
      final String setNameStr = parts[1].trim();
      final String content1 = parts[2].trim();

      // 解析地支
      DiZhi? setName;
      try {
        setName = DiZhi.values.firstWhere(
          (diZhi) =>
              diZhi.name == setNameStr || diZhi.toString().contains(setNameStr),
        );
      } catch (e) {
        // 如果找不到对应的地支，使用默认值或跳过
        print('Unknown DiZhi: $setNameStr');
        return null;
      }

      // 解析年龄集合（如果存在）
      List<int>? ageSet1;
      if (parts.length > 3 && parts[3].trim().isNotEmpty) {
        ageSet1 = _parseAgeSet(parts[3].trim());
      }

      return TiaoWenDataModel(
        id: id,
        setName: setName,
        content1: content1,
        content2: null, // CSV 中暂时没有 content2
        ageSet1: ageSet1,
        ageSet2: null, // CSV 中暂时没有 ageSet2
      );
    } catch (e) {
      print('Error parsing CSV line: $line, error: $e');
      return null;
    }
  }

  /// 分割 CSV 行，处理逗号分隔
  List<String> _splitCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final String char = line[i];

      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }

    result.add(current.toString());
    return result;
  }

  /// 解析年龄集合字符串
  /// 格式: (47) 或 (21 22) 或 (11 12)
  /// 支持各种不规范格式: 小数点、冒号、连字符、字母等
  List<int>? _parseAgeSet(String ageSetStr) {
    if (ageSetStr.isEmpty) return null;

    // 移除括号和其他特殊字符
    String cleaned = ageSetStr
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('.', '')  // 移除小数点
        .replaceAll(':', ' ') // 冒号替换为空格
        .replaceAll('-', ' ') // 连字符替换为空格
        .replaceAll('μ', ' ') // 特殊字符替换为空格
        .replaceAll("'", ' ') // 单引号替换为空格
        .replaceAll(RegExp(r'[a-zA-Z\u4e00-\u9fa5]'), '') // 移除字母和中文字符
        .replaceAll(RegExp(r'\s+'), ' ') // 多个空格合并为一个
        .trim();
    
    if (cleaned.isEmpty) return null;

    try {
      // 按空格分割数字
      final List<String> numberStrs = cleaned.split(' ');
      final List<int> numbers = [];

      for (String numStr in numberStrs) {
        final trimmed = numStr.trim();
        if (trimmed.isNotEmpty) {
          // 尝试解析为整数
          final parsed = int.tryParse(trimmed);
          if (parsed != null) {
            numbers.add(parsed);
          }
        }
      }

      return numbers.isEmpty ? null : numbers;
    } catch (e) {
      // 静默处理解析错误，避免日志污染
      return null;
    }
  }

  @override
  Future<TiaoWenDataModel?> getById(int id) async {
    await _loadTiaoWenFromAssets();
    return _cachedTiaoWenMap![id];
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdsWithPageRange({
    required List<int> ids,
    required List<int> pageRange,
    int steps = 1,
  }) async {
    await _loadTiaoWenFromAssets();

    // 验证分页范围参数
    if (pageRange.length != 2) {
      throw ArgumentError(
        'pageRange must contain exactly 2 elements [startIndex, endIndex]',
      );
    }

    final int startIndex = pageRange[0];
    final int endIndex = pageRange[1];

    if (startIndex < 0 || endIndex < startIndex) {
      throw ArgumentError(
        'Invalid page range: startIndex must be >= 0 and endIndex must be >= startIndex',
      );
    }

    if (steps <= 0) {
      throw ArgumentError('steps must be greater than 0');
    }

    // 根据分页范围和步长筛选ID
    final List<int> filteredIds = [];
    for (int i = startIndex; i <= endIndex && i < ids.length; i += steps) {
      filteredIds.add(ids[i]);
    }

    // 获取对应的条文数据
    final List<TiaoWenDataModel> result = [];
    for (int id in filteredIds) {
      final tiaoWen = _cachedTiaoWenMap![id];
      if (tiaoWen != null) {
        result.add(tiaoWen);
      }
    }

    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> listAll() async {
    await _loadTiaoWenFromAssets();
    return List.from(_cachedTiaoWenList!);
  }

  @override
  Future<List<TiaoWenDataModel>> search({
    String? setName,
    String? contentKeyword,
  }) async {
    await _loadTiaoWenFromAssets();

    List<TiaoWenDataModel> results = List.from(_cachedTiaoWenList!);

    // 按地支名称筛选
    if (setName != null && setName.isNotEmpty) {
      try {
        final DiZhi targetSetName = DiZhi.values.firstWhere(
          (diZhi) =>
              diZhi.name == setName || diZhi.toString().contains(setName),
        );
        results = results
            .where((tiaoWen) => tiaoWen.setName == targetSetName)
            .toList();
      } catch (e) {
        // 如果找不到对应的地支，返回空列表
        return [];
      }
    }

    // 按内容关键词搜索
    if (contentKeyword != null && contentKeyword.isNotEmpty) {
      results = results.where((tiaoWen) {
        final content1Match = tiaoWen.content1.contains(contentKeyword);
        final content2Match =
            tiaoWen.content2?.contains(contentKeyword) ?? false;
        return content1Match || content2Match;
      }).toList();
    }

    return results;
  }

  @override
  Future<int> getCount() async {
    await _loadTiaoWenFromAssets();
    return _cachedTiaoWenList!.length;
  }

  /// 清除缓存
  ///
  /// 用于测试或需要重新加载数据的场景
  static void clearCache() {
    _cachedTiaoWenList = null;
    _cachedTiaoWenMap = null;
  }

  /// 根据年龄集合获取条文
  ///
  /// [ageSet] 年龄集合
  /// [useSecondSet] 是否使用第二个年龄集合进行匹配
  /// 返回包含指定年龄的条文列表
  Future<List<TiaoWenDataModel>> getByAgeSet({
    required List<int> ageSet,
    bool useSecondSet = false,
  }) async {
    await _loadTiaoWenFromAssets();

    return _cachedTiaoWenList!.where((tiaoWen) {
      final targetAgeSet = useSecondSet ? tiaoWen.ageSet2 : tiaoWen.ageSet1;
      if (targetAgeSet == null) return false;

      // 检查是否有交集
      return ageSet.any((age) => targetAgeSet.contains(age));
    }).toList();
  }

  /// 根据地支获取条文
  ///
  /// [diZhi] 地支枚举值
  /// 返回对应地支的所有条文
  Future<List<TiaoWenDataModel>> getByDiZhi(DiZhi diZhi) async {
    await _loadTiaoWenFromAssets();
    return _cachedTiaoWenList!
        .where((tiaoWen) => tiaoWen.setName == diZhi)
        .toList();
  }

  @override
  Future<List<TiaoWenDataModel>> getAroundById({
    required int centerId,
    required int beforeCount,
    required int afterCount,
    bool includeCenterItem = true,
  }) async {
    await _loadTiaoWenFromAssets();

    // 参数验证
    if (beforeCount < 0 || afterCount < 0) {
      throw ArgumentError('beforeCount and afterCount must be >= 0');
    }

    // 计算ID范围
    final int startId = centerId - beforeCount;
    final int endId = centerId + afterCount;

    // 获取范围内的条文
    final List<TiaoWenDataModel> result = [];
    for (int id = startId; id <= endId; id++) {
      // 如果不包含中心项且当前ID是中心ID，则跳过
      if (!includeCenterItem && id == centerId) {
        continue;
      }

      final tiaoWen = _cachedTiaoWenMap![id];
      if (tiaoWen != null) {
        result.add(tiaoWen);
      }
    }

    // 按ID升序排列
    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> getByIntervalAroundId({
    required int centerId,
    required int interval,
    required int minCount,
    int? maxRange,
    bool includeCenterItem = true,
  }) async {
    await _loadTiaoWenFromAssets();

    // 参数验证
    if (interval <= 0) {
      throw ArgumentError('interval must be > 0');
    }
    if (minCount <= 0) {
      throw ArgumentError('minCount must be > 0');
    }

    final List<TiaoWenDataModel> result = [];
    final Set<int> addedIds = <int>{};

    // 如果包含中心项，先添加中心条文
    if (includeCenterItem) {
      final centerTiaoWen = _cachedTiaoWenMap![centerId];
      if (centerTiaoWen != null) {
        result.add(centerTiaoWen);
        addedIds.add(centerId);
      }
    }

    // 设置最大搜索范围，防止无限扩展
    final int searchRange = maxRange ?? 1000;

    // 向前和向后交替搜索，确保平衡获取
    int forwardStep = 1;
    int backwardStep = 1;

    while (result.length < minCount &&
        (forwardStep * interval <= searchRange ||
            backwardStep * interval <= searchRange)) {
      // 向后搜索
      if (forwardStep * interval <= searchRange) {
        final int forwardId = centerId + (forwardStep * interval);
        if (!addedIds.contains(forwardId)) {
          final tiaoWen = _cachedTiaoWenMap![forwardId];
          if (tiaoWen != null) {
            result.add(tiaoWen);
            addedIds.add(forwardId);
          }
        }
        forwardStep++;
      }

      // 如果还需要更多条文，向前搜索
      if (result.length < minCount && backwardStep * interval <= searchRange) {
        final int backwardId = centerId - (backwardStep * interval);
        if (!addedIds.contains(backwardId)) {
          final tiaoWen = _cachedTiaoWenMap![backwardId];
          if (tiaoWen != null) {
            result.add(tiaoWen);
            addedIds.add(backwardId);
          }
        }
        backwardStep++;
      }
    }

    // 按ID升序排列
    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdRange({
    required int startId,
    required int endId,
  }) async {
    await _loadTiaoWenFromAssets();

    // 参数验证
    if (startId > endId) {
      throw ArgumentError('startId must be <= endId');
    }

    final List<TiaoWenDataModel> result = [];
    for (int id = startId; id <= endId; id++) {
      final tiaoWen = _cachedTiaoWenMap![id];
      if (tiaoWen != null) {
        result.add(tiaoWen);
      }
    }

    // 按ID升序排列
    result.sort((a, b) => a.id.compareTo(b.id));
    return result;
  }

  @override
  Future<List<TiaoWenDataModel>> getByIdList({
    required List<int> queryList,
    bool preserveOrder = false,
    bool skipNotFound = true,
  }) async {
    await _loadTiaoWenFromAssets();

    // 参数验证
    if (queryList.isEmpty) {
      return [];
    }

    final List<TiaoWenDataModel> result = [];
    final List<int> notFoundIds = [];

    if (preserveOrder) {
      // 保持输入顺序
      for (int id in queryList) {
        final tiaoWen = _cachedTiaoWenMap![id];
        if (tiaoWen != null) {
          result.add(tiaoWen);
        } else {
          notFoundIds.add(id);
          if (!skipNotFound) {
            // 如果不跳过未找到的ID，可以选择抛出异常或添加占位符
            // 这里选择记录未找到的ID，在方法结束时处理
          }
        }
      }
    } else {
      // 按ID升序排列
      final Set<int> uniqueIds = queryList.toSet(); // 去重
      final List<int> sortedIds = uniqueIds.toList()..sort();

      for (int id in sortedIds) {
        final tiaoWen = _cachedTiaoWenMap![id];
        if (tiaoWen != null) {
          result.add(tiaoWen);
        } else {
          notFoundIds.add(id);
        }
      }
    }

    // 如果不跳过未找到的ID且有未找到的ID，抛出异常
    if (!skipNotFound && notFoundIds.isNotEmpty) {
      throw ArgumentError(
        'The following IDs were not found: ${notFoundIds.join(', ')}',
      );
    }

    return result;
  }

  @override
  Future<Map<int, String>> getTiaoWenContentByNumbers(List<int> numbers) async {
    await _loadTiaoWenFromAssets();

    if (numbers.isEmpty) {
      return {};
    }

    final result = <int, String>{};
    for (final number in numbers) {
      final tiaoWen = _cachedTiaoWenMap![number];
      if (tiaoWen != null) {
        result[number] = tiaoWen.content1;
      }
    }

    return result;
  }

  @override
  Future<String?> getTiaoWenContentByNumber(int number) async {
    await _loadTiaoWenFromAssets();

    final tiaoWen = _cachedTiaoWenMap![number];
    return tiaoWen?.content1;
  }
}
