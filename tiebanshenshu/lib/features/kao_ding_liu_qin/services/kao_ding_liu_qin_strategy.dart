import 'package:common/enums.dart';
import '../../../features/six_yao_gua/pure_six_yao_gua.dart';
import '../repositories/liu_du_table_repository.dart';
import '../services/qi_gua_helper.dart';
import '../services/na_jia_liu_qin_helper.dart';
import '../models/liu_qin_type.dart';
import '../models/liu_du_table.dart';
import '../models/spouse_ordinal.dart';

/// 考订六亲计算结果
///
/// 包含完整的计算流程结果，用于展示和用户选择
class KaoDingLiuQinResult {
  /// 六亲类型
  final LiuQinType liuQinType;

  /// 选择的四柱
  final JiaZi pillar;

  /// 起卦结果
  final QiGuaResult qiGuaResult;

  /// 纳甲六亲结果
  final NaJiaLiuQinResult naJiaResult;

  /// 找到的目标爻（父母爻/妻财爻等）
  final GuaYao? targetYao;

  /// 完整的流度表（供用户在UI界面选择）
  final LiuDuTable? liuDuTable;

  /// 目标爻对应的流度表条目（高亮显示用）
  final LiuDuEntry? targetEntry;

  /// 计算详情
  final String calculationDetail;

  const KaoDingLiuQinResult({
    required this.liuQinType,
    required this.pillar,
    required this.qiGuaResult,
    required this.naJiaResult,
    this.targetYao,
    this.liuDuTable,
    this.targetEntry,
    required this.calculationDetail,
  });

  /// 是否成功找到结果
  bool get isSuccess => targetYao != null && liuDuTable != null;

  /// 获取流度表的所有条文编号（chiperNumber 即 tiaoWenNumber）
  List<int> get allTiaoWenNumbers {
    if (liuDuTable == null) return [];
    return liuDuTable!.getAllEntries().map((e) => e.chiperNumber).toList();
  }
}

/// 考订六亲策略
///
/// 实现完整的考订六亲计算流程：
/// 1. 起卦（从四柱干支）
/// 2. 装纳甲和六亲
/// 3. 找目标爻
/// 4. 查流度表
/// 5. 展示流度表供用户选择
class KaoDingLiuQinStrategy {
  final LiuDuTableRepository _repository;

  KaoDingLiuQinStrategy(this._repository);

  /// 计算考订六亲
  ///
  /// [liuQinType] 六亲类型（父/母/夫/妻/兄弟/子/女）
  /// [pillar] 选择的四柱（年柱考父母，日柱考夫妻，月柱考兄弟，时柱考子女）
  /// [dayGan] 日干（用于定六亲）
  /// [spouseOrdinal] 夫妻继任（仅当 [liuQinType.isSpouse] 时生效）
  ///
  /// 返回完整的计算结果，包含流度表供用户选择
  Future<KaoDingLiuQinResult> calculate({
    required LiuQinType liuQinType,
    required JiaZi pillar,
    required TianGan dayGan,
    SpouseOrdinal? spouseOrdinal,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('【考订六亲计算流程】');
    buffer.writeln('六亲类型: ${liuQinType.displayName}');
    buffer.writeln('选择柱: ${pillar.name} (${liuQinType.correspondingPillar})');
    buffer.writeln('日干: ${dayGan.name}');
    if (liuQinType.isSpouse && spouseOrdinal != null) {
      buffer.writeln('继任: ${spouseOrdinal.displayName}');
    }
    buffer.writeln();

    // 1. 起卦
    buffer.writeln('【步骤1: 起卦】');
    final qiGuaResult = QiGuaHelper.qiGuaFromGanZhiPair(pillar);
    buffer.writeln(qiGuaResult.formula);
    final gua64 = QiGuaHelper.get64Gua(qiGuaResult);
    buffer.writeln('64卦: ${gua64.name}');
    buffer.writeln();

    // 2. 装纳甲和六亲
    buffer.writeln('【步骤2: 装纳甲和六亲】');
    final naJiaResult = NaJiaLiuQinHelper.installNaJiaAndLiuQin(gua64, dayGan);
    buffer.writeln('归宫: ${naJiaResult.gongGua.name}宫');
    buffer.writeln(
      '世爻: ${naJiaResult.shiYao.order.name}爻 - ${naJiaResult.shiYao.ganZhi?.name}',
    );
    buffer.writeln(
      '应爻: ${naJiaResult.yingYao.order.name}爻 - ${naJiaResult.yingYao.ganZhi?.name}',
    );
    buffer.writeln();

    // 3. 找目标爻
    buffer.writeln('【步骤3: 查找目标爻】');
    final targetYao = NaJiaLiuQinHelper.findTargetYao(naJiaResult, liuQinType);

    if (targetYao == null) {
      buffer.writeln('未找到${liuQinType.displayName}对应的爻');
      return KaoDingLiuQinResult(
        liuQinType: liuQinType,
        pillar: pillar,
        qiGuaResult: qiGuaResult,
        naJiaResult: naJiaResult,
        calculationDetail: buffer.toString(),
      );
    }

    buffer.writeln('找到目标爻: ${targetYao.order.name}爻');
    buffer.writeln('纳支: ${targetYao.naZhi?.name}');
    buffer.writeln('干支: ${targetYao.ganZhi?.name}');
    buffer.writeln('六亲: ${targetYao.liuQin?.name}');
    buffer.writeln();

    // 4. 查流度表
    buffer.writeln('【步骤4: 查流度表】');
    LiuDuTable liuDuTable;
    if (liuQinType.isSpouse && spouseOrdinal != null) {
      liuDuTable = await _repository.getSpouseTable(liuQinType, spouseOrdinal);
    } else {
      liuDuTable = await _repository.getTableByLiuQinType(liuQinType);
    }
    buffer.writeln('使用流度表: ${liuDuTable.name}');
    buffer.writeln('流度表类型: ${liuDuTable.type.name}');
    buffer.writeln('流度表条目数: ${liuDuTable.getAllEntries().length}');

    final targetZhi = targetYao.naZhi;
    if (targetZhi == null) {
      buffer.writeln('目标爻无纳支');
      return KaoDingLiuQinResult(
        liuQinType: liuQinType,
        pillar: pillar,
        qiGuaResult: qiGuaResult,
        naJiaResult: naJiaResult,
        targetYao: targetYao,
        liuDuTable: liuDuTable,
        calculationDetail: buffer.toString(),
      );
    }

    // 查询目标爻对应的流度表条目（用于高亮显示）
    LiuDuEntry? targetEntry;
    if (liuDuTable.hasZhiMapper) {
      targetEntry = liuDuTable.getEntryByZhi(targetZhi);
      buffer.writeln('目标地支: ${targetZhi.name}');
      if (targetEntry != null) {
        buffer.writeln('对应密语: ${targetEntry.chiperText}');
        buffer.writeln('对应条文编号: ${targetEntry.chiperNumber}');
      }
    } else {
      // 纳比卦甲表等固定列表表，需要特殊处理
      // TODO: 实现固定列表表的查询逻辑
      buffer.writeln('固定列表表，暂不支持自动匹配');
    }

    buffer.writeln();
    buffer.writeln('【步骤5: 展示流度表供用户选择】');
    buffer.writeln('流度表已加载，包含 ${liuDuTable.getAllEntries().length} 个条目');
    buffer.writeln('每个条目的 chiperNumber 即为条文编号（tiaoWenNumber）');
    buffer.writeln('用户可在UI界面选择最贴近的条文');
    buffer.writeln();
    buffer.writeln('【计算完成】');

    return KaoDingLiuQinResult(
      liuQinType: liuQinType,
      pillar: pillar,
      qiGuaResult: qiGuaResult,
      naJiaResult: naJiaResult,
      targetYao: targetYao,
      liuDuTable: liuDuTable,
      targetEntry: targetEntry,
      calculationDetail: buffer.toString(),
    );
  }
}
