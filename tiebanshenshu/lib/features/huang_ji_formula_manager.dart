import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'huang_ji/huang_ji_formula_v2.dart';

/// HuangJi公式管理器
///
/// 负责加载、缓存和管理 HuangJiCalculationFormula 实例
/// 支持从 assets/formulas 目录加载 JSON 格式的公式文件
class HuangJiFormulaManager {
  static HuangJiFormulaManager? _instance;
  static HuangJiFormulaManager get instance =>
      _instance ??= HuangJiFormulaManager._();

  HuangJiFormulaManager._();

  /// 公式缓存，key为公式ID，value为公式实例
  final Map<int, HuangJiCalculationFormula> _formulaCache = {};

  /// 获取所有公式实例
  List<HuangJiCalculationFormula> get allFormulas =>
      _formulaCache.values.toList();

  /// 公式名称到ID的映射
  final Map<String, int> _nameToIdMap = {};

  /// 是否已初始化
  bool _isInitialized = false;

  /// 可用的公式文件列表
  static const List<String> _formulaFiles = [
    'assets/formulas/huang_ji_1_formula.json',
    'assets/formulas/huang_ji_2_formula.json',
    'assets/formulas/huang_ji_3_formula.json',
  ];

  /// 初始化管理器，加载所有可用的公式
  ///
  /// 返回加载成功的公式数量
  Future<int> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('🔄 HuangJiFormulaManager: 已经初始化，跳过重复初始化');
      }
      return _formulaCache.length;
    }

    if (kDebugMode) {
      print('🚀 HuangJiFormulaManager: 开始初始化');
    }

    int loadedCount = 0;

    for (final filePath in _formulaFiles) {
      try {
        final formula = await _loadFormulaFromAsset(filePath);
        if (formula != null) {
          _formulaCache[formula.id] = formula;
          _nameToIdMap[formula.name] = formula.id;
          loadedCount++;

          if (kDebugMode) {
            print('✅ 加载公式: ${formula.name} (ID: ${formula.id})');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ 加载公式失败: $filePath, 错误: $e');
        }
      }
    }

    _isInitialized = true;

    if (kDebugMode) {
      print('🎉 HuangJiFormulaManager: 初始化完成，共加载 $loadedCount 个公式');
    }

    return loadedCount;
  }

  /// 从资源文件加载公式
  ///
  /// [assetPath] 资源文件路径
  /// 返回加载的公式实例，失败时返回null
  Future<HuangJiCalculationFormula?> _loadFormulaFromAsset(
    String assetPath,
  ) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // 验证必要字段
      if (!_validateFormulaJson(jsonData)) {
        throw FormatException('公式JSON格式无效: $assetPath');
      }

      return HuangJiCalculationFormula.fromJson(jsonData);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 加载公式文件失败: $assetPath, 错误: $e');
      }
      rethrow;
    }
  }

  /// 验证公式JSON数据格式
  ///
  /// [jsonData] 待验证的JSON数据
  /// 返回验证结果
  bool _validateFormulaJson(Map<String, dynamic> jsonData) {
    // 检查必要字段
    if (!jsonData.containsKey('id') ||
        !jsonData.containsKey('name') ||
        !jsonData.containsKey('description') ||
        !jsonData.containsKey('groups')) {
      return false;
    }

    // 检查字段类型
    if (jsonData['id'] is! int ||
        jsonData['name'] is! String ||
        jsonData['description'] is! String ||
        jsonData['groups'] is! List) {
      return false;
    }

    return true;
  }

  /// 根据ID获取公式
  ///
  /// [id] 公式ID
  /// 返回对应的公式实例，不存在时返回null
  HuangJiCalculationFormula? getFormulaById(int id) {
    if (!_isInitialized) {
      throw StateError('HuangJiFormulaManager 尚未初始化，请先调用 initialize()');
    }

    return _formulaCache[id];
  }

  /// 根据名称获取公式
  ///
  /// [name] 公式名称
  /// 返回对应的公式实例，不存在时返回null
  HuangJiCalculationFormula? getFormulaByName(String name) {
    if (!_isInitialized) {
      throw StateError('HuangJiFormulaManager 尚未初始化，请先调用 initialize()');
    }

    final id = _nameToIdMap[name];
    if (id == null) return null;

    return _formulaCache[id];
  }

  /// 获取所有可用的公式
  ///
  /// 返回所有已加载的公式列表
  List<HuangJiCalculationFormula> getAllFormulas() {
    if (!_isInitialized) {
      throw StateError('HuangJiFormulaManager 尚未初始化，请先调用 initialize()');
    }

    return _formulaCache.values.toList();
  }

  /// 获取所有公式的名称列表
  ///
  /// 返回所有公式名称的列表
  List<String> getAllFormulaNames() {
    if (!_isInitialized) {
      throw StateError('HuangJiFormulaManager 尚未初始化，请先调用 initialize()');
    }

    return _nameToIdMap.keys.toList();
  }

  /// 检查指定ID的公式是否存在
  ///
  /// [id] 公式ID
  /// 返回是否存在
  bool hasFormula(int id) {
    if (!_isInitialized) {
      throw StateError('HuangJiFormulaManager 尚未初始化，请先调用 initialize()');
    }

    return _formulaCache.containsKey(id);
  }

  /// 检查指定名称的公式是否存在
  ///
  /// [name] 公式名称
  /// 返回是否存在
  bool hasFormulaByName(String name) {
    if (!_isInitialized) {
      throw StateError('HuangJiFormulaManager 尚未初始化，请先调用 initialize()');
    }

    return _nameToIdMap.containsKey(name);
  }

  /// 获取已加载的公式数量
  ///
  /// 返回公式数量
  int get formulaCount {
    return _formulaCache.length;
  }

  /// 获取初始化状态
  ///
  /// 返回是否已初始化
  bool get isInitialized => _isInitialized;

  /// 清空缓存并重置状态
  ///
  /// 主要用于测试或重新初始化
  void reset() {
    _formulaCache.clear();
    _nameToIdMap.clear();
    _isInitialized = false;

    if (kDebugMode) {
      print('🔄 HuangJiFormulaManager: 已重置');
    }
  }

  /// 重新加载所有公式
  ///
  /// 清空缓存后重新从资源文件加载
  /// 返回加载成功的公式数量
  Future<int> reload() async {
    if (kDebugMode) {
      print('🔄 HuangJiFormulaManager: 开始重新加载');
    }

    reset();
    return await initialize();
  }

  /// 获取公式的详细信息
  ///
  /// [id] 公式ID
  /// 返回包含公式详细信息的Map
  Map<String, dynamic>? getFormulaInfo(int id) {
    final formula = getFormulaById(id);
    if (formula == null) return null;

    return {
      'id': formula.id,
      'name': formula.name,
      'description': formula.description,
      'groupCount': formula.groups.length,
      'totalFormulas': formula.groups.fold<int>(
        0,
        (sum, group) => sum + group.formulas.length,
      ),
    };
  }

  /// 获取所有公式的概览信息
  ///
  /// 返回包含所有公式基本信息的列表
  List<Map<String, dynamic>> getAllFormulasInfo() {
    if (!_isInitialized) {
      throw StateError('HuangJiFormulaManager 尚未初始化，请先调用 initialize()');
    }

    return _formulaCache.values.map((formula) {
      return {
        'id': formula.id,
        'name': formula.name,
        'description': formula.description,
        'groupCount': formula.groups.length,
        'totalFormulas': formula.groups.fold<int>(
          0,
          (sum, group) => sum + group.formulas.length,
        ),
      };
    }).toList();
  }
}
