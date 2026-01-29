import 'package:common/enums.dart';
import '../../../repository/datamodels/tiao_wen_datamodel.dart';

/// 流度表条目
///
/// 代表流度表中的一个条目，包含密码文字和密码数字
class LiuDuEntry {
  /// 密码文字（如"辛甲月戊"）
  final String chiperText;

  /// 密码数字（如9103）
  /// 注意：chiperNumber 即为 tiaoWenNumber（条文编号）
  final int chiperNumber;

  /// 年干支（部分表有此字段，如木宫、金宫）
  final String? yearGanZhi;

  const LiuDuEntry({
    required this.chiperText,
    required this.chiperNumber,
    this.yearGanZhi,
  });

  /// 从JSON创建
  factory LiuDuEntry.fromJson(Map<String, dynamic> json) {
    return LiuDuEntry(
      chiperText: json['chiperText'] as String,
      chiperNumber: json['chiperNumber'] as int,
      yearGanZhi: json['yearGanZhi'] as String?,
    );
  }

  /// 转为JSON
  Map<String, dynamic> toJson() {
    return {
      'chiperText': chiperText,
      'chiperNumber': chiperNumber,
      if (yearGanZhi != null) 'yearGanZhi': yearGanZhi,
    };
  }

  /// 获取条文编号（chiperNumber 即为 tiaoWenNumber）
  int get tiaoWenNumber => chiperNumber;

  @override
  String toString() {
    return 'LiuDuEntry(chiperText: $chiperText, chiperNumber: $chiperNumber, yearGanZhi: $yearGanZhi)';
  }
}

/// 流度表条目（带条文内容）
///
/// 用于UI展示，包含完整的流度表条目和对应的条文内容
class LiuDuEntryWithTiaoWen {
  /// 流度表条目
  final LiuDuEntry entry;

  /// 对应的条文内容（通过 TiaoWenRepository 获取）
  final TiaoWenDataModel? tiaoWen;

  /// 是否是目标条目（用于高亮显示）
  final bool isTarget;

  /// 地支（如果是按地支索引的表）
  final DiZhi? zhi;

  const LiuDuEntryWithTiaoWen({
    required this.entry,
    this.tiaoWen,
    this.isTarget = false,
    this.zhi,
  });

  /// 条文编号
  int get tiaoWenNumber => entry.tiaoWenNumber;

  /// 密语
  String get chiperText => entry.chiperText;

  @override
  String toString() {
    return 'LiuDuEntryWithTiaoWen(zhi: ${zhi?.name}, chiperText: $chiperText, tiaoWenNumber: $tiaoWenNumber, isTarget: $isTarget)';
  }
}

/// 流度表类型
enum LiuDuTableType {
  /// 乾宫甲流度（考父）
  qianGong,

  /// 坤宫甲流度（考母）
  kunGong,

  /// 木宫甲流度（考妻，第一任）
  muGong,

  /// 金宫甲流度（考夫，第一任）
  jinGong,

  /// 纳比卦甲表（考兄弟）
  naBiGuaJia,

  /// 纳比卦乙表（考兄弟）
  naBiGuaYi,

  /// 纳艮卦乙表（考子）
  naGenGuaYi,

  /// 纳艮卦丙表（考女）
  naGenGuaBing,

  // ==== 继任夫妻支持 ====
  /// 木宫甲乙度（考妻，第二任）
  muGongJiaYiDu,
  /// 戊木甲流度（考妻，第三任）
  wuMuJia,
  /// 庚木甲流度（考妻，第四任）
  gengMuJia,
  /// 金甲乙流度（考夫，第二任）
  jinJiaYi,
  /// 戊金甲流度（考夫，第三任）
  wuJinJia,
}

/// 流度表
///
/// 代表一个完整的流度表，可以是按地支索引的表（zhiMapper）
/// 或固定列表的表（gongEachList，如纳比卦甲表）
class LiuDuTable {
  /// 表名
  final String name;

  /// 描述
  final String description;

  /// 表类型
  final LiuDuTableType type;

  /// 按地支索引的映射表（12个地支）
  final Map<DiZhi, LiuDuEntry>? zhiMapper;

  /// 固定列表（如纳比卦甲表的10个条目）
  final List<LiuDuEntry>? gongEachList;

  const LiuDuTable({
    required this.name,
    required this.description,
    required this.type,
    this.zhiMapper,
    this.gongEachList,
  });

  /// 从JSON创建
  factory LiuDuTable.fromJson(
    Map<String, dynamic> json,
    LiuDuTableType type,
  ) {
    Map<DiZhi, LiuDuEntry>? zhiMapper;
    List<LiuDuEntry>? gongEachList;

    if (json.containsKey('zhiMapper')) {
      final zhiMapperJson = json['zhiMapper'] as Map<String, dynamic>;
      zhiMapper = {};

      for (final entry in zhiMapperJson.entries) {
        final zhi = DiZhi.values.firstWhere(
          (z) => z.name == entry.key,
          orElse: () => throw Exception('Unknown DiZhi: ${entry.key}'),
        );
        zhiMapper[zhi] = LiuDuEntry.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    if (json.containsKey('gongEachList')) {
      final listJson = json['gongEachList'] as List<dynamic>;
      gongEachList = listJson
          .map((e) => LiuDuEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return LiuDuTable(
      name: json['name'] as String,
      description: json['description'] as String,
      type: type,
      zhiMapper: zhiMapper,
      gongEachList: gongEachList,
    );
  }

  /// 根据地支获取条目
  LiuDuEntry? getEntryByZhi(DiZhi zhi) {
    return zhiMapper?[zhi];
  }

  /// 获取所有条目
  List<LiuDuEntry> getAllEntries() {
    if (zhiMapper != null) {
      return zhiMapper!.values.toList();
    } else if (gongEachList != null) {
      return gongEachList!;
    } else {
      return [];
    }
  }

  /// 是否是按地支索引的表
  bool get hasZhiMapper => zhiMapper != null;

  /// 是否是固定列表的表
  bool get hasGongEachList => gongEachList != null;

  @override
  String toString() {
    return 'LiuDuTable(name: $name, type: $type, entries: ${getAllEntries().length})';
  }
}
