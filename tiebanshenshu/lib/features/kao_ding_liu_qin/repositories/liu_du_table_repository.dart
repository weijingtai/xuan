import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/liu_du_table.dart';
import '../models/liu_qin_type.dart';

/// 流度表数据仓库
///
/// 负责加载和管理考订六亲功能的8个流度表JSON数据
class LiuDuTableRepository {
  /// 缓存所有流度表
  Map<LiuDuTableType, LiuDuTable>? _tables;

  /// 获取所有流度表
  ///
  /// 首次调用时从assets加载，后续调用返回缓存
  Future<Map<LiuDuTableType, LiuDuTable>> getAllTables() async {
    if (_tables != null) {
      return _tables!;
    }

    _tables = {};

    // 加载8个流度表
    await _loadTable(
      LiuDuTableType.qianGong,
      'assets/kao_ke/qian_gong_jia_liu_du.json',
    );
    await _loadTable(
      LiuDuTableType.kunGong,
      'assets/kao_ke/kun_gong_jia_liu_du.json',
    );
    await _loadTable(
      LiuDuTableType.muGong,
      'assets/kao_ke/mu_gong_jia_liu_du.json',
    );
    await _loadTable(
      LiuDuTableType.jinGong,
      'assets/kao_ke/jin_gong_jia_liu_du.json',
    );
    await _loadTable(
      LiuDuTableType.naBiGuaJia,
      'assets/kao_ke/na_bi_gua_jia.json',
    );
    await _loadTable(
      LiuDuTableType.naBiGuaYi,
      'assets/kao_ke/na_bi_gua_yi.json',
    );
    await _loadTable(
      LiuDuTableType.naGenGuaYi,
      'assets/kao_ke/na_gen_gua_yi.json',
    );
    await _loadTable(
      LiuDuTableType.naGenGuaBing,
      'assets/kao_ke/na_gen_gua_bing.json',
    );

    return _tables!;
  }

  /// 根据六亲类型获取对应的流度表
  Future<LiuDuTable> getTableByLiuQinType(LiuQinType liuQinType) async {
    final tables = await getAllTables();
    final tableType = _liuQinTypeToTableType(liuQinType);

    if (!tables.containsKey(tableType)) {
      throw Exception('未找到六亲类型 ${liuQinType.displayName} 对应的流度表');
    }

    return tables[tableType]!;
  }

  /// 获取特定类型的流度表
  Future<LiuDuTable> getTable(LiuDuTableType type) async {
    final tables = await getAllTables();

    if (!tables.containsKey(type)) {
      throw Exception('未找到流度表类型: $type');
    }

    return tables[type]!;
  }

  /// 清除缓存
  void clearCache() {
    _tables = null;
  }

  /// 加载单个流度表
  Future<void> _loadTable(LiuDuTableType type, String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final table = LiuDuTable.fromJson(jsonData, type);
      _tables![type] = table;
    } catch (e) {
      throw Exception('加载流度表失败 [$assetPath]: $e');
    }
  }

  /// 将六亲类型映射到流度表类型
  LiuDuTableType _liuQinTypeToTableType(LiuQinType liuQinType) {
    switch (liuQinType) {
      case LiuQinType.father:
        return LiuDuTableType.qianGong;
      case LiuQinType.mother:
        return LiuDuTableType.kunGong;
      case LiuQinType.wife:
        return LiuDuTableType.muGong;
      case LiuQinType.husband:
        return LiuDuTableType.jinGong;
      case LiuQinType.sibling:
        // 兄弟姐妹默认使用纳比卦甲表
        return LiuDuTableType.naBiGuaJia;
      case LiuQinType.son:
        return LiuDuTableType.naGenGuaYi;
      case LiuQinType.daughter:
        return LiuDuTableType.naGenGuaBing;
    }
  }

  /// 获取兄弟姐妹的所有可能流度表（甲表和乙表）
  Future<List<LiuDuTable>> getSiblingTables() async {
    final tables = await getAllTables();
    return [
      tables[LiuDuTableType.naBiGuaJia]!,
      tables[LiuDuTableType.naBiGuaYi]!,
    ];
  }
}
