// lib/model/nine_zong_men_calculator_v1_2.dart

// ignore_for_file: constant_identifier_names, unused_local_variable // Example linter ignores

import 'package:collection/collection.dart';
import 'package:common/enums.dart';
import 'package:common/shared/shared.dart';
import 'package:daliuren/core/constants/da_liu_ren_common_constants.dart';
import 'package:daliuren/domain/enums/nine_zong_men.dart';
import 'package:daliuren/domain/enums/pan_type.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/raw_pan_datamodel.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../entities/raw_pan_info_model.dart';
import '../enums/gui_ren.dart';
import '../enums/three_chuan_staff.dart';
import 'calculate_month_general_service.dart';

/// 定义三传的输出结果
class ThreeChuanOutput {
  final ThreeClassItem first; // 计算得出的初传
  final ThreeClassItem second; // 计算得出的中传
  final ThreeClassItem third; // 计算得出的末传
  final List<String> patternName;
  final String content;

  final NineZongMen nineZongmen;
  // final List<ThreeClassItem> originalThreeChuan; // 保存从 RawPan 传入的原始三传数据

  ThreeChuanOutput({
    required this.first,
    required this.second,
    required this.third,
    required this.patternName,
    required this.content,
    required this.nineZongmen,
    // required this.originalThreeChuan,
  });

  @override
  String toString() {
    String calculatedStr =
        '计算三传结果:\n  课式: $patternName (${nineZongmen.name})\n  依据: $content\n  初传: ${first.diZhi.name} (六亲: ${first.liuQin.name})\n  中传: ${second.diZhi.name} (六亲: ${second.liuQin.name})\n  末传: ${third.diZhi.name} (六亲: ${third.liuQin.name})';

    return calculatedStr;
  }
}

class EachGongItem {
  final DiZhi ground;
  final DiZhi sky;
  final GuiRen guiRen;
  final FiveEnergyStatus skyStatusAtGong;
  final FiveEnergyStatus skyStatusFourSeasons;
  final FiveEnergyStatus guiRenStatusAtGong;
  final FiveEnergyStatus guiRenStatusAtFourSeasons;
  final JiaZi? dayJiaZi;
  TianGan? get gan => dayJiaZi?.tianGan;
  EachGongItem({
    required this.ground,
    required this.sky,
    required this.guiRen,
    required this.dayJiaZi,
    required this.skyStatusAtGong,
    required this.skyStatusFourSeasons,
    required this.guiRenStatusAtGong,
    required this.guiRenStatusAtFourSeasons,
  });
}

class GongOutput {
  PanType panType;
  // ”甲戊庚牛羊“ 之类
  GuiRenType guiRenType;
  DiZhi guiRenPosition;

  Map<DiZhi, EachGongItem> gong = {};
  GongOutput({
    required this.panType,
    required this.guiRenType,
    required this.guiRenPosition,
    required this.gong,
  });
}

/// 内部处理时，对四课信息进行增强，方便计算
class _ProcessedFourClassItem extends FourClassItem {
  // 动态计算的属性
  ZeiKeType zeiKeType = ZeiKeType.NONE; // 贼克类型 (下贼上ZEI, 上克下KE, 无NONE)
  bool isSkyKeDayGan = false; // 天盘神是否克日干(寄宫) (用于遥克)
  bool isDayGanKeSky = false; // 日干(寄宫)是否克天盘神 (用于遥克)
  int sheHaiTimes = 0; // 涉害深度
  bool isSkySameYinYangWithDayGan = false; // 天盘神与日干(天干本身)阴阳是否相同

  _ProcessedFourClassItem(
      {required super.order, required super.sky, required super.ground});
  // _ProcessedFourClassItem({required FourClassItem original})
  //     : super(
  //           order: original.order, sky: original.sky, ground: original.ground);
}

/// 大六壬九宗门三传计算器 (方案B)
class DaLiuRenModelCalculator {
  // ‌节气前三天‌：新旧月将交替，旺衰力量不稳定（如立春前三日，寅木将未完全得令）
  final JiaZi monthJiaZi;
  final JiaZi dayJiaZi;
  final JiaZi timeJiaZi;
  // final RawPan rawPanData;
  List<RawEachClass> fourClass;
  Map<DiZhi, EachGong> gong;

  final DiZhi guiRenPosition;

  final SheHaiStrategy sheHaiStrategy;
  final GuiRenType guiRenType;
  // 昼夜分解 用于确定贵人阴阳
  final DayNightBoundaryType dayNightBoundaryType;
  final EnumDayNight dayNight;

  // 内部预处理的数据和日课基本信息
  late final List<_ProcessedFourClassItem> _processedFourClass;
  TianGan get _dayGan => dayJiaZi.gan;
  DiZhi get _dayZhi => dayJiaZi.zhi;
  bool get _isDayGanYang => dayJiaZi.gan.isYang;
  late final DiZhi _dayGanJiGongDiZhi; // 日干寄宫的地支

  GongOutput? gongOutput;

  /// 构造函数，接收原始盘数据和涉害策略
  DaLiuRenModelCalculator({
    required this.monthJiaZi,
    required this.timeJiaZi,
    required this.dayJiaZi,
    required this.fourClass,
    // required this.rawPanData,
    required this.gong,
    required this.dayNight,
    required this.guiRenType,
    required this.guiRenPosition,
    required this.dayNightBoundaryType,
    this.sheHaiStrategy = SheHaiStrategy.COMPREHENSIVE, // 默认综合策略
  }) {
    // _dayGan = rawPanData.day.tianGan;
    // _dayZhi = rawPanData.day.diZhi;
    _dayGanJiGongDiZhi = _getTianGanJiGong(_dayGan); // 获取日干的寄宫地支

    // 预处理四课信息，计算并附加初始关系属性
    _processedFourClass = fourClass.map((item) {
      final processedItem = _ProcessedFourClassItem(
          order: item.order, sky: item.sky, ground: item.ground);
      _calculateInitialRelations(
          processedItem, _dayGan, _dayGanJiGongDiZhi, item.sky, item.ground);
      return processedItem;
    }).toList();
    // 确保四课按order排序，如果输入不能保证的话
    _processedFourClass.sort((a, b) => a.order.compareTo(b.order));
  }

  // main enterence
  ThreeChuanOutput calculate() {
    return resolveThreeChuan();
  }

  // @Deprecated("冗余重复代码")
  // GongOutput calculateGong() {
  //   final ziUponZhi = gong[DiZhi.ZI];
  //   PanType panType =
  //       DaLiuRenCommonConstants.ziGongUponPanTypeMapper[ziUponZhi!]!;
  //   // Map<DiZhi, GuiRen> gongGuiRenMapper =
  //   // calculateGodsMapper(timeJiaZi.zhi, gong, guiRenPosition);
  //   // 装配日干支
  //   // JiaZi dayJiaZi = dayJiaZi;
  //   List<JiaZi> tenXun = JiaZi.getTenXunByXunHeader(dayJiaZi.xunHeader);
  //   Map<DiZhi, JiaZi> skyJiaZi =
  //       Map.fromEntries(tenXun.map((e) => MapEntry(e.diZhi, e)));

  //   Map<DiZhi, EachGongItem> gongMapper = {};

  //   FourSeasons fourSeasons = FourSeasons.getFourSeason(monthJiaZi.diZhi);

  //   for (var g in DiZhi.listAll) {
  //     GuiRen guiRen = gongGuiRenMapper[g]!;
  //     DiZhi gongSky = gong[g]!.skyPanDiZhi;
  //     gongMapper[g] = EachGongItem(
  //         ground: g,
  //         sky: gongSky,
  //         dayJiaZi: skyJiaZi[gong],
  //         guiRen: guiRen,
  //         skyStatusAtGong:
  //             FiveEnergyStatus.getFiveXingWangShuaiAtDiZhi(g, gongSky.fiveXing),
  //         skyStatusFourSeasons: FiveEnergyStatus.getDiZhiWangShuaiAtFourSeasons(
  //             gongSky, fourSeasons),
  //         guiRenStatusAtGong: FiveEnergyStatus.getFiveXingWangShuaiAtDiZhi(
  //             g, guiRen.zhi.fiveXing),
  //         guiRenStatusAtFourSeasons:
  //             FiveEnergyStatus.getDiZhiWangShuaiAtFourSeasons(
  //                 guiRen.zhi, fourSeasons));
  //   }

  //   return GongOutput(
  //       panType: panType,
  //       guiRenType: guiRenType,
  //       guiRenPosition: guiRenPosition,
  //       gong: gongMapper);
  // }

  // @Deprecated("冗余重复代码")
  // Map<DiZhi, GuiRen> calculateGodsMapper(
  //     DiZhi timeDiZhi, Map<DiZhi, DiZhi> tianDiPanMapper, DiZhi guiRenDiZhi) {
  //   /// @return: key 是 地盘地支
  //   Map<DiZhi, DiZhi> skyAsKey = tianDiPanMapper.map((k, v) => MapEntry(v, k));
  //   // 天盘的顺序
  //   List<DiZhi> skySeq = skyAsKey.values.toList();

  //   List<DiZhi> tianSeq4Gods = CollectUtils.changeSeq(guiRenDiZhi, skySeq);
  //   // 根据 skyAsKey 以及 diSeq4Gods.first得到对应的 地盘落宫
  //   DiZhi diPanLuoGong = skyAsKey[tianSeq4Gods.first]!;

  //   List<DiZhi> diSeq4Gods = CollectUtils.changeSeq(diPanLuoGong, skySeq);

  //   // 贵人随天盘转，但顺逆排是根据贵人天盘落宫对应的地盘
  //   // List<String> twelveGodsList = List.from(TWELVE_GODS_LIST);

  //   bool isAntiClockedGodsSeq = dayNight.isNight;
  //   if (isAntiClockedGodsSeq) {
  //     // List<String> antiClockSeq = List.from(twelveGodsList.reversed,growable: true);
  //     // antiClockSeq = [antiClockSeq.last, ...antiClockSeq.sublist(0,11)];
  //     return Map<DiZhi, GuiRen>.fromIterables(
  //         diSeq4Gods, GuiRen.antiClockwiseList);
  //   } else {
  //     return Map<DiZhi, GuiRen>.fromIterables(diSeq4Gods, GuiRen.clockwiseList);
  //   }
  // }

  /// 获取天干的寄宫地支
  DiZhi _getTianGanJiGong(TianGan gan) {
    final res = DaLiuRenCommonConstants.tianGanJiGongMapper[gan];
    if (res == null) {
      throw ArgumentError("不包含的地址 ${gan.name}");
    }
    return res;
  }

  List<TianGan> _getTianGanJiGongList(DiZhi currentPathDiPan) {
    return DaLiuRenCommonConstants.diZhiJiMapper[currentPathDiPan] ?? [];
  }

  /// 为每个预处理的四课项计算并附加初始关系属性
  /// 当前使用的是遥克方案为"日干本身"
  void _calculateInitialRelations(
      _ProcessedFourClassItem item,
      TianGan dayGanItself,
      DiZhi dayGanRepresentedByJiGong,
      DiZhi skyDiZhi,
      DiZhi groundDiZhi) {
    // 1. 天盘神与日干的阴阳关系 (日干阴阳直接看天干本身)
    item.isSkySameYinYangWithDayGan = skyDiZhi.yinYang == dayGanItself.yinYang;

    // 2. 贼克类型判断 (课内天地盘生克)
    FiveXing skyXing = skyDiZhi.fiveXing;
    FiveXing groundXing = groundDiZhi.fiveXing;
    if (FiveXingRelationship.checkRelationship(groundXing, skyXing) ==
        FiveXingRelationship.KE) {
      item.zeiKeType = ZeiKeType.ZEI; // 地盘克天盘 (下贼上)
    } else if (FiveXingRelationship.checkRelationship(skyXing, groundXing) ==
        FiveXingRelationship.KE) {
      item.zeiKeType = ZeiKeType.KE; // 天盘克地盘 (上克下)
    } else {
      item.zeiKeType = ZeiKeType.NONE;
    }

    // 3. 遥克关系判断 (天盘神与日干本身的生克)
    FiveXing dayGanXing = dayGanItself.fiveXing; // 直接使用日干的五行
    if (FiveXingRelationship.checkRelationship(skyXing, dayGanXing) ==
        FiveXingRelationship.KE) {
      item.isSkyKeDayGan = true; // 天盘神克日干
    } else {
      item.isSkyKeDayGan = false;
    }

    if (FiveXingRelationship.checkRelationship(dayGanXing, skyXing) ==
        FiveXingRelationship.KE) {
      item.isDayGanKeSky = true; // 日干克天盘神
    } else {
      item.isDayGanKeSky = false;
    }

    item.sheHaiTimes = 0; // 涉害深度在涉害计算时才赋值
  }

  /// 核心方法：根据方案B的优先级顺序解析三传
  ThreeChuanOutput resolveThreeChuan() {
    ThreeChuanOutput? result;

    // 方案B 优先级: 伏吟 -> 反吟 -> 贼克 -> [比用 -> 涉害] -> 遥克 -> [比用 -> 涉害] -> 昴星 -> 别责 -> 八专

    // 伏吟法判断
    if (_isFuYin()) {
      result = _resolveFuYin();
      if (result != null) return result;
    }

    // 反吟法判断
    if (_isFanYin()) {
      result = _resolveFanYin();
      if (result != null) return result;
    }

    result = _resolveZeiKe();
    if (result != null) return result;

    result = _resolveYaoKe();
    if (result != null) return result;

    result = _resolveMaoXing();
    if (result != null) return result;

    // 别责法判断前，先确认四课是否不全
    if (_isSiKeBuQuan()) {
      result = _resolveBieZe();
      if (result != null) return result;
    }

    // 八专法判断前，先确认是否满足八专条件
    if (_isBaZhuanCondition()) {
      result = _resolveBaZhuan();
      if (result != null) return result;
    }

    // 如果所有规则都不适用，则抛出异常，表示存在未覆盖的课格或逻辑错误
    throw Exception('九宗门规则错误：无法确定三传。请检查输入数据或排盘逻辑。');
  }

  @Deprecated("use resolveThreeChuan. 新版本中别责 与 昴星 使用更高效的日干查找确定是否进行 别责 与 昴星计算")
  ThreeChuanOutput resolveThreeChuan_old() {
    ThreeChuanOutput? result;

    // 方案B 优先级: 伏吟 -> 反吟 -> 贼克 -> [比用 -> 涉害] -> 遥克 -> [比用 -> 涉害] -> 昴星 -> 别责 -> 八专

    // 伏吟法判断
    if (_isFuYin()) {
      result = _resolveFuYin();
      if (result != null) return result;
    }

    // 反吟法判断
    if (_isFanYin()) {
      result = _resolveFanYin();
      if (result != null) return result;
    }

    result = _resolveZeiKe();
    if (result != null) return result;

    result = _resolveYaoKeByGan();
    if (result != null) return result;

    result = _resolveMaoXing();
    if (result != null) return result;

    // 别责法判断前，先确认四课是否不全
    if (_isSiKeBuQuan()) {
      result = _resolveBieZeOptimized();
      if (result != null) return result;
    }

    // 八专法判断前，先确认是否满足八专条件
    if (_isBaZhuanCondition()) {
      result = _resolveBaZhuan();
      if (result != null) return result;
    }

    // 如果所有规则都不适用，则抛出异常，表示存在未覆盖的课格或逻辑错误
    throw Exception('九宗门规则错误：无法确定三传。请检查输入数据或排盘逻辑。');
  }

  // ----------------------------------------------------------------------
  // Section: 辅助判断方法 (判断是否满足特定宗门的前置条件)
  // ----------------------------------------------------------------------

  /// 判断四课是否不全 (有重复的课项)
  bool _isSiKeBuQuan() {
    if (fourClass.length < 4) return true; // 输入的课数就少于4，则不全
    // 严谨的判断是看是否有两个FourClassItem的sky和ground都相同
    Set<String> uniqueClassSignatures = _processedFourClass
        .map((k) => "${k.sky.name}-${k.ground.name}")
        .toSet();
    return uniqueClassSignatures.length < _processedFourClass.length;
  }

  /// 判断是否满足八专课的核心条件 (不含无贼克判断，因贼克已优先处理)
  bool _isBaZhuanCondition() {
    // 1. 是否为特定八专日干支 (甲寅, 庚申, 丁未, 己未, 癸丑)
    // final jiaZi = dayJiaZi;
    bool isBaZhuanDay = [
      JiaZi.JIA_YIN,
      JiaZi.GENG_SHEN,
      JiaZi.DING_WEI,
      JiaZi.JI_WEI,
      JiaZi.GUI_CHOU
    ].contains(dayJiaZi);
    if (!isBaZhuanDay) return false;

    // 2. 日干寄宫是否与日支相同
    // _dayGanJiGongDiZhi 已在构造函数中计算
    if (_dayGanJiGongDiZhi != _dayZhi) return false;

    // 根据方案B，八专在无克无遥之后判断。若到此步骤，则满足条件。
    return true;
  }

  /// 判断四课是否构成伏吟 (严格指四课全伏吟)
  bool _isFuYin() {
    // 严格伏吟：四课的天盘神均等于其地盘神
    // 之前的实现是 this._processedFourClass.every((item) => item.sky == item.ground);
    // 但更传统的伏吟判断是 日干上神 与其所落宫位相同，以及 日支上神 与其所落宫位相同
    // 即第一课和第三课（干上阳神，支上阳神）是伏吟的
    // 我们参考 DaLiuRenKePan.dart 中的 isFuYin 实现：
    if (_processedFourClass.length < 3) return false; // 至少需要干上和支上两课信息
    final firstKe = _processedFourClass[0]; // 干上阳神课
    final thirdKe = _processedFourClass[2]; // 支上阳神课 (通常order 0,1,2,3)
    return firstKe.sky == firstKe.ground && thirdKe.sky == thirdKe.ground;
  }

  /// 判断四课是否构成反吟 (严格指四课全反吟)
  bool _isFanYin() {
    // 严格反吟：四课的天盘神均与其地盘神相冲
    // 类似于伏吟，传统反吟判断也是关注关键课（干上、支上）
    // 参考 DaLiuRenKePan.dart 中的 isFanYin 实现：
    if (_processedFourClass.length < 3) return false;
    final firstKe = _processedFourClass[0];
    final thirdKe = _processedFourClass[2];

    return firstKe.sky == firstKe.ground.sixChongZhi &&
        thirdKe.sky == firstKe.ground.sixChongZhi;
  }

  // ----------------------------------------------------------------------
  // Section: 各宗门判断的具体解析方法
  // ----------------------------------------------------------------------

  /// 1. 解析贼克 (ZEI_KE)
  ///    包含单一克贼的直接取传，多克贼时内部会转比用或涉害。
  ThreeChuanOutput? _resolveZeiKe() {
    // a. 识别所有“下贼上”(zeiList)和“上克下”(keList)
    List<_ProcessedFourClassItem> zeiList =
        _processedFourClass.where((k) => k.zeiKeType == ZeiKeType.ZEI).toList();
    List<_ProcessedFourClassItem> keList =
        _processedFourClass.where((k) => k.zeiKeType == ZeiKeType.KE).toList();

    List<_ProcessedFourClassItem> candidateClasses = [];
    String initialBasis = "";
    bool isPrimaryRuleZei = false; // 标记最优先考虑的是贼还是克

    if (zeiList.isNotEmpty) {
      candidateClasses = zeiList;
      initialBasis =
          "下贼上优先 (${candidateClasses.map((k) => "${k.ground.name}贼${k.sky.name}").join(',')})";
      isPrimaryRuleZei = true;
    } else if (keList.isNotEmpty) {
      candidateClasses = keList;
      initialBasis =
          "无贼，取上克下 (${candidateClasses.map((k) => "${k.sky.name}克${k.ground.name}").join(',')})";
      isPrimaryRuleZei = false;
    } else {
      return null; // 无贼无克，不入此宗门
    }

    // b. 单一克/贼处理
    if (candidateClasses.length == 1) {
      _ProcessedFourClassItem chuChuanKe = candidateClasses.first;
      final threeChuanItems = _createChainThreeChuanItems(chuChuanKe.sky);
      String keShiName = isPrimaryRuleZei ? "重审课" : "元首课";
      return ThreeChuanOutput(
        first: threeChuanItems.item1,
        second: threeChuanItems.item2,
        third: threeChuanItems.item3,
        patternName: [keShiName],
        content: initialBasis + ", 仅一处，取 ${chuChuanKe.sky.name} 发用",
        nineZongmen: NineZongMen.ZEI_KE,
        // originalThreeChuan: rawPanData.three,
      );
    }

    // c. 多克/贼，转入比用或涉害逻辑
    // isKeRuleForSheHai: true 表示候选是“克”性质(上克下)，false 表示是“贼”性质(下贼上)
    return _resolveBiYongOrSheHai(candidateClasses,
        isFromZeiKe: true, // 明确是从贼克流程来的
        isPrimaryKeRule:
            !isPrimaryRuleZei, // 如果是贼(isPrimaryRuleZei=true)，则涉害规则按被克论(false)
        initialBasis: initialBasis);
  }

  /// 辅助方法：处理多克贼或多遥克时的比用与涉害逻辑
  /// [candidates] - 多个候选课
  /// [isFromZeiKe] - true表示从贼克流程转入，false表示从遥克流程转入
  /// [isPrimaryKeRule] - 对于贼克：true指原始是上克下(KE)，false指原始是下贼上(ZEI)。
  ///                     对于遥克：true指原始是神克日(HaoShi)，false指原始是日克神(TanShe)。
  ///                     此参数用于指导后续涉害计算的“克”方向。
  /// [initialBasis] - 从上层传递来的初步判断依据字符串。
  ThreeChuanOutput? _resolveBiYongOrSheHai(
      List<_ProcessedFourClassItem> candidates,
      {required bool isFromZeiKe,
      required bool isPrimaryKeRule,
      String initialBasis = ""}) {
    // a. 比用法：筛选与日干(天干本身)阴阳相同的候选课的天盘神
    List<_ProcessedFourClassItem> biyongCandidates =
        candidates.where((k) => k.isSkySameYinYangWithDayGan).toList();
    String biyongBasis = initialBasis +
        "; ${candidates.length}个候选，转比用(${_isDayGanYang ? '阳日用阳' : '阴日用阴'})";

    if (biyongCandidates.length == 1) {
      // 比用成功，仅一个符合
      _ProcessedFourClassItem chuChuanKe = biyongCandidates.first;
      final threeChuanItems = _createChainThreeChuanItems(chuChuanKe.sky);
      String keShiName = "比用课";
      // 根据方案B，可以根据原候选数量确定更具体的课名
      if (isFromZeiKe) {
        // 仅在贼克转比用时使用这些特定名称
        if (candidates.length == 2)
          keShiName = "知一课";
        else if (candidates.length == 3)
          keShiName = "度厄课";
        else if (candidates.length == 4) keShiName = "无禄课"; // 或绝嗣课
      } else {
        keShiName = "遥克比用"; // 遥克比用通常不直接叫知一等
      }

      return ThreeChuanOutput(
        first: threeChuanItems.item1,
        second: threeChuanItems.item2,
        third: threeChuanItems.item3,
        patternName: [keShiName],
        content: biyongBasis + ", 比用唯一，取 ${chuChuanKe.sky.name} 发用",
        nineZongmen: NineZongMen.BI_YONG,
        // originalThreeChuan: rawPanData.three,
      );
    }

    // b. 俱比（多个符合阴阳）或俱不比（无符合阴阳），转入涉害法
    //    若俱不比，则对原始候选列表进行涉害；若俱比，则对符合比用的列表进行涉害。
    List<_ProcessedFourClassItem> candidatesForSheHai =
        biyongCandidates.isNotEmpty ? biyongCandidates : candidates;
    String sheHaiBasis = biyongBasis +
        (biyongCandidates.isNotEmpty
            ? "; 俱比 (${biyongCandidates.map((k) => k.sky.name).join(',')})，转涉害"
            : "; 俱不比，对原候补转涉害");

    return _resolveSheHai(candidatesForSheHai,
        isCompareRuleAsKe: isPrimaryKeRule, // 传递克的主动方是谁
        basis: sheHaiBasis,
        isFromYaoKe: !isFromZeiKe // 传递是否从遥克来
        );
  }

  /// 2. 解析遥克 (YAO_KE)
  ///    在无直接贼克时调用。判断日干与四课上神的遥相生克。
  ThreeChuanOutput? _resolveYaoKe() {
    // isSkyKeDayGan 和 isDayGanKeSky 已在 _calculateInitialRelations 中基于日干本身计算
    List<_ProcessedFourClassItem> haoShiList =
        _processedFourClass.where((k) => k.isSkyKeDayGan).toList();
    List<_ProcessedFourClassItem> tanSheList = _processedFourClass
        .where((k) => !k.isSkyKeDayGan && k.isDayGanKeSky)
        .toList();

    List<_ProcessedFourClassItem> candidateClasses = [];
    String initialBasis = "";
    bool isHaoShi = false; // true代表蒿矢（神克日），false代表弹射（日克神）

    if (haoShiList.isNotEmpty) {
      candidateClasses = haoShiList;
      initialBasis =
          "神遥克日优先 (${candidateClasses.map((k) => k.sky.name).join(',')})";
      isHaoShi = true;
    } else if (tanSheList.isNotEmpty) {
      candidateClasses = tanSheList;
      initialBasis =
          "无神克日，取日遥克神 (${candidateClasses.map((k) => k.sky.name).join(',')})";
      isHaoShi = false;
    } else {
      return null; // 无遥克关系
    }

    // 单一遥克
    if (candidateClasses.length == 1) {
      _ProcessedFourClassItem chuChuanKe = candidateClasses.first;
      final threeChuanItems = _createChainThreeChuanItems(chuChuanKe.sky);
      String keShiName = isHaoShi ? "蒿矢课" : "弹射课";
      return ThreeChuanOutput(
        first: threeChuanItems.item1,
        second: threeChuanItems.item2,
        third: threeChuanItems.item3,
        patternName: [keShiName],
        content: initialBasis + ", 仅一处遥克，取 ${chuChuanKe.sky.name} 发用",
        nineZongmen: NineZongMen.YAO_KE,
        // originalThreeChuan: rawPanData.three,
      );
    }

    // 多遥克，转比用或涉害
    // isPrimaryKeRule: 对于蒿矢(神克日), 天盘神是主动克者，为true。
    //                  对于弹射(日克神), 天盘神是被动被克者，为false。
    return _resolveBiYongOrSheHai(candidateClasses,
        isFromZeiKe: false, // 从遥克来
        isPrimaryKeRule: isHaoShi,
        initialBasis: initialBasis);
  }

  /// 2. 解析遥克 (YAO_KE)
  ///    在无直接贼克时调用。判断日干与四课上神的遥相生克。
  ThreeChuanOutput? _resolveYaoKeByGan() {
    // isSkyKeDayGan 和 isDayGanKeSky 已在 _calculateInitialRelations 中基于日干本身计算
    List<_ProcessedFourClassItem> haoShiList =
        _processedFourClass.where((k) => k.isSkyKeDayGan).toList();
    List<_ProcessedFourClassItem> tanSheList = _processedFourClass
        .where((k) => !k.isSkyKeDayGan && k.isDayGanKeSky)
        .toList();

    List<_ProcessedFourClassItem> candidateClasses = [];
    String initialBasis = "";
    bool isHaoShi = false; // true代表蒿矢（神克日），false代表弹射（日克神）

    if (haoShiList.isNotEmpty) {
      candidateClasses = haoShiList;
      initialBasis =
          "神遥克日干优先 (${candidateClasses.map((k) => k.sky.name).join(',')})";
      isHaoShi = true;
    } else if (tanSheList.isNotEmpty) {
      candidateClasses = tanSheList;
      initialBasis =
          "无神克日，取日干遥克神 (${candidateClasses.map((k) => k.sky.name).join(',')})";
      isHaoShi = false;
    } else {
      return null; // 无遥克关系
    }

    // 单一遥克
    if (candidateClasses.length == 1) {
      _ProcessedFourClassItem chuChuanKe = candidateClasses.first;
      final threeChuanItems = _createChainThreeChuanItems(chuChuanKe.sky);
      String keShiName = isHaoShi ? "蒿矢课" : "弹射课";
      return ThreeChuanOutput(
        first: threeChuanItems.item1,
        second: threeChuanItems.item2,
        third: threeChuanItems.item3,
        patternName: [keShiName],
        content: initialBasis + ", 仅一处遥克，取 ${chuChuanKe.sky.name} 发用",
        nineZongmen: NineZongMen.YAO_KE,
        // originalThreeChuan: rawPanData.three,
      );
    }

    // 多遥克，转比用或涉害
    // isPrimaryKeRule: 对于蒿矢(神克日), 天盘神是主动克者，为true。
    //                  对于弹射(日克神), 天盘神是被动被克者，为false。
    return _resolveBiYongOrSheHai(candidateClasses,
        isFromZeiKe: false, // 从遥克来
        isPrimaryKeRule: isHaoShi,
        initialBasis: initialBasis);
  }

  /// 内部涉害法实现 (SHE_HAI)
  ThreeChuanOutput? _resolveSheHai(
    List<_ProcessedFourClassItem> candidatesForSheHai, {
    required bool isCompareRuleAsKe, // true: 比较sky克target, false: 比较target克sky
    required String basis, // 已累积的判断依据
    required bool isFromYaoKe, // 标记是否从遥克流程转入
  }) {
    if (candidatesForSheHai.isEmpty) {
      throw Exception("涉害法错误：候选列表为空。");
    }
    if (candidatesForSheHai.length == 1) {
      _ProcessedFourClassItem chuChuanKe = candidatesForSheHai.first;
      final threeChuanItems = _createChainThreeChuanItems(chuChuanKe.sky);
      return ThreeChuanOutput(
        first: threeChuanItems.item1,
        second: threeChuanItems.item2,
        third: threeChuanItems.item3,
        patternName: ["涉害课"],
        content: basis + ", 单一候选(${chuChuanKe.sky.name})不需涉害比较,直接发用",
        nineZongmen: NineZongMen.SHE_HAI,
        // originalThreeChuan: rawPanData.three,
      );
    }

    // 1. 为所有候选课计算涉害深度
    for (var ke in candidatesForSheHai) {
      ke.sheHaiTimes = _calculateSheHaiDepth(
          ke, isCompareRuleAsKe, isFromYaoKe ? _dayGanJiGongDiZhi : null);
    }

    _ProcessedFourClassItem theChosenKe;
    String sheHaiDetailBasis = "";

    // 2. 根据指定的涉害策略 (this.sheHaiStrategy) 进行选择
    if (this.sheHaiStrategy == SheHaiStrategy.COMPREHENSIVE) {
      // 深浅法：纯粹按涉害深度排序
      candidatesForSheHai
          .sort((a, b) => b.sheHaiTimes.compareTo(a.sheHaiTimes));
      int maxDepth = candidatesForSheHai.first.sheHaiTimes;
      List<_ProcessedFourClassItem> sameDepthCandidates =
          candidatesForSheHai.where((k) => k.sheHaiTimes == maxDepth).toList();

      if (sameDepthCandidates.length == 1) {
        theChosenKe = sameDepthCandidates.first;
        sheHaiDetailBasis =
            "; 深浅法：涉害最深者(${theChosenKe.sky.name}, 深${theChosenKe.sheHaiTimes})发用";
      } else {
        sheHaiDetailBasis = "; 深浅法：涉害同深(深${maxDepth})，";
        // 涉害相同时，阳日取干上神，阴日取支上神
        _ProcessedFourClassItem? preferredKe = _isDayGanYang
            ? sameDepthCandidates
                .firstWhereOrNull((k) => k.order == 0) // 第一课(干上)
            : sameDepthCandidates
                .firstWhereOrNull((k) => k.order == 2); // 第三课(支上)

        if (preferredKe != null) {
          theChosenKe = preferredKe;
          sheHaiDetailBasis +=
              "${_isDayGanYang ? '阳日取干上神' : '阴日取支上神'}(${theChosenKe.sky.name})发用";
        } else {
          // 若干上/支上神不在候选中，则按孟仲季规则
          _ProcessedFourClassItem? mengZhongChoice =
              _applyMengZhongRule(sameDepthCandidates);
          if (mengZhongChoice != null) {
            theChosenKe = mengZhongChoice;
            sheHaiDetailBasis +=
                "孟仲法取 ${theChosenKe.sky.name}(${_isMeng(theChosenKe.ground) ? '孟' : (_isZhong(theChosenKe.ground) ? '仲' : '季')})发用";
          } else {
            theChosenKe = _applyZhuiXiaRule(sameDepthCandidates);
            sheHaiDetailBasis += "缀瑕法取 ${theChosenKe.sky.name} 发用";
          }
        }
      }
    } else if (this.sheHaiStrategy == SheHaiStrategy.MENG_PRIORITY) {
      // 孟仲法：严格按孟→仲→季优先级，不取季位
      sheHaiDetailBasis = "; 孟仲法：";
      List<_ProcessedFourClassItem> mengCandidates =
          candidatesForSheHai.where((k) => _isMeng(k.ground)).toList();

      if (mengCandidates.isNotEmpty) {
        sheHaiDetailBasis +=
            "发现孟课(${mengCandidates.map((k) => k.sky.name).join(',')})，";
        if (mengCandidates.length == 1) {
          theChosenKe = mengCandidates.first;
          sheHaiDetailBasis += "唯一孟位(${theChosenKe.sky.name})发用";
        } else {
          // 多个孟位时，取涉害相同则取干上神
          mengCandidates.sort((a, b) => b.sheHaiTimes.compareTo(a.sheHaiTimes));
          int maxDepthInMeng = mengCandidates.first.sheHaiTimes;
          List<_ProcessedFourClassItem> sameDepthMengCandidates = mengCandidates
              .where((k) => k.sheHaiTimes == maxDepthInMeng)
              .toList();

          if (sameDepthMengCandidates.length == 1) {
            theChosenKe = sameDepthMengCandidates.first;
            sheHaiDetailBasis +=
                "孟位中涉害最深者(${theChosenKe.sky.name}, 深${theChosenKe.sheHaiTimes})发用";
          } else {
            // 孟位涉害相同，取干上神
            _ProcessedFourClassItem? ganShangKe =
                sameDepthMengCandidates.firstWhereOrNull((k) => k.order == 0);
            if (ganShangKe != null) {
              theChosenKe = ganShangKe;
              sheHaiDetailBasis += "孟位涉害相同，取干上神(${theChosenKe.sky.name})发用";
            } else {
              theChosenKe = sameDepthMengCandidates.first;
              sheHaiDetailBasis += "孟位涉害相同，取首位孟课(${theChosenKe.sky.name})发用";
            }
          }
        }
      } else {
        // 无孟位，寻找仲位
        List<_ProcessedFourClassItem> zhongCandidates =
            candidatesForSheHai.where((k) => _isZhong(k.ground)).toList();

        if (zhongCandidates.isNotEmpty) {
          sheHaiDetailBasis +=
              "无孟位，发现仲课(${zhongCandidates.map((k) => k.sky.name).join(',')})，";
          if (zhongCandidates.length == 1) {
            theChosenKe = zhongCandidates.first;
            sheHaiDetailBasis += "唯一仲位(${theChosenKe.sky.name})发用";
          } else {
            // 多个仲位时，取距离日干较近者或涉害更深者
            zhongCandidates
                .sort((a, b) => b.sheHaiTimes.compareTo(a.sheHaiTimes));
            theChosenKe = zhongCandidates.first;
            sheHaiDetailBasis += "仲位中取涉害最深者(${theChosenKe.sky.name})发用";
          }
        } else {
          // 无孟无仲，按深浅法处理（但理论上孟仲法不取季位）
          sheHaiDetailBasis += "无孟无仲，仅有季位，按深浅法处理，";
          candidatesForSheHai
              .sort((a, b) => b.sheHaiTimes.compareTo(a.sheHaiTimes));
          theChosenKe = candidatesForSheHai.first;
          sheHaiDetailBasis += "取涉害最深者(${theChosenKe.sky.name})发用";
        }
      }
    } else {
      // SheHaiStrategy.COMBINED_APPROACH - 两法参合：孟仲为纲，深浅为目
      sheHaiDetailBasis = "; 两法参合：";

      // 第一步：孟仲筛选
      List<_ProcessedFourClassItem> mengCandidates =
          candidatesForSheHai.where((k) => _isMeng(k.ground)).toList();
      List<_ProcessedFourClassItem> zhongCandidates =
          candidatesForSheHai.where((k) => _isZhong(k.ground)).toList();

      // 为所有候选计算涉害深度（如果还未计算）
      for (var ke in candidatesForSheHai) {
        if (ke.sheHaiTimes == 0) {
          ke.sheHaiTimes = _calculateSheHaiDepth(
              ke, isCompareRuleAsKe, isFromYaoKe ? _dayGanJiGongDiZhi : null);
        }
      }

      if (mengCandidates.isNotEmpty) {
        // 有孟位候选
        mengCandidates.sort((a, b) => b.sheHaiTimes.compareTo(a.sheHaiTimes));
        int maxMengDepth = mengCandidates.first.sheHaiTimes;

        // 检查仲位是否有显著更深的涉害
        if (zhongCandidates.isNotEmpty) {
          zhongCandidates
              .sort((a, b) => b.sheHaiTimes.compareTo(a.sheHaiTimes));
          int maxZhongDepth = zhongCandidates.first.sheHaiTimes;

          // 如果仲位涉害显著超过孟位（差值≥2），破例取仲位
          if (maxZhongDepth - maxMengDepth >= 2) {
            theChosenKe = zhongCandidates.first;
            sheHaiDetailBasis +=
                "仲位涉害显著超过孟位(${maxZhongDepth} vs ${maxMengDepth})，破例取仲位(${theChosenKe.sky.name})发用";
          } else {
            // 否则仍取孟位
            List<_ProcessedFourClassItem> maxMengCandidates = mengCandidates
                .where((k) => k.sheHaiTimes == maxMengDepth)
                .toList();

            if (maxMengCandidates.length == 1) {
              theChosenKe = maxMengCandidates.first;
              sheHaiDetailBasis +=
                  "孟位涉害足够深(${maxMengDepth})，取孟位(${theChosenKe.sky.name})发用";
            } else {
              // 多个孟位涉害相同，取干上神
              _ProcessedFourClassItem? ganShangKe =
                  maxMengCandidates.firstWhereOrNull((k) => k.order == 0);
              if (ganShangKe != null) {
                theChosenKe = ganShangKe;
                sheHaiDetailBasis +=
                    "多孟位涉害相同(${maxMengDepth})，取干上神(${theChosenKe.sky.name})发用";
              } else {
                theChosenKe = maxMengCandidates.first;
                sheHaiDetailBasis +=
                    "多孟位涉害相同(${maxMengDepth})，取首位孟课(${theChosenKe.sky.name})发用";
              }
            }
          }
        } else {
          // 只有孟位候选
          List<_ProcessedFourClassItem> maxMengCandidates = mengCandidates
              .where((k) => k.sheHaiTimes == maxMengDepth)
              .toList();

          if (maxMengCandidates.length == 1) {
            theChosenKe = maxMengCandidates.first;
            sheHaiDetailBasis +=
                "唯一孟位(${theChosenKe.sky.name}, 深${maxMengDepth})发用";
          } else {
            _ProcessedFourClassItem? ganShangKe =
                maxMengCandidates.firstWhereOrNull((k) => k.order == 0);
            if (ganShangKe != null) {
              theChosenKe = ganShangKe;
              sheHaiDetailBasis += "多孟位涉害相同，取干上神(${theChosenKe.sky.name})发用";
            } else {
              theChosenKe = maxMengCandidates.first;
              sheHaiDetailBasis += "多孟位涉害相同，取首位孟课(${theChosenKe.sky.name})发用";
            }
          }
        }
      } else if (zhongCandidates.isNotEmpty) {
        // 无孟位，有仲位
        zhongCandidates.sort((a, b) => b.sheHaiTimes.compareTo(a.sheHaiTimes));
        theChosenKe = zhongCandidates.first;
        sheHaiDetailBasis +=
            "无孟位，取仲位涉害最深者(${theChosenKe.sky.name}, 深${theChosenKe.sheHaiTimes})发用";
      } else {
        // 无孟无仲，仅有季位，按深浅法
        candidatesForSheHai
            .sort((a, b) => b.sheHaiTimes.compareTo(a.sheHaiTimes));
        theChosenKe = candidatesForSheHai.first;
        sheHaiDetailBasis +=
            "无孟无仲，仅有季位，按深浅法取涉害最深者(${theChosenKe.sky.name}, 深${theChosenKe.sheHaiTimes})发用";
      }
    }

    final threeChuanItems = _createChainThreeChuanItems(theChosenKe.sky);
    String keShiName = "涉害课";
    if (sheHaiDetailBasis.contains("见机") ||
        (_isMeng(theChosenKe.ground) && sheHaiDetailBasis.contains("孟")))
      keShiName = "见机课";
    else if (sheHaiDetailBasis.contains("察微") ||
        (_isZhong(theChosenKe.ground) && sheHaiDetailBasis.contains("仲")))
      keShiName = "察微课";
    else if (sheHaiDetailBasis.contains("缀瑕")) keShiName = "缀瑕课";
    // else if (_isJi(theChosenKe.ground)) keShiName = "涉害课 (季)"; // 可选，如果需要区分季

    return ThreeChuanOutput(
      first: threeChuanItems.item1,
      second: threeChuanItems.item2,
      third: threeChuanItems.item3,
      patternName: [keShiName],
      content: basis + sheHaiDetailBasis,
      nineZongmen: NineZongMen.SHE_HAI,
      // originalThreeChuan: rawPanData.three,
    );
  }

  /// 核心：计算单个课的涉害深度
  int _calculateSheHaiDepth(_ProcessedFourClassItem ke, bool isShangKeXia,
      DiZhi? dayGanJiGongForYaoKe) {
    DiZhi skyGod = ke.sky; // 天盘神
    DiZhi groundCurrentPos = ke.ground; // 天盘神当前落宫，涉害路径从此宫开始
    DiZhi skyGodBenGong = skyGod; // 天盘神的本家地支（地盘本位）

    int depth = 0;
    List<DiZhi> diZhiRing = DiZhi.values; // 确保这是标准的子到亥顺序
    int pathStartIndexInRing = diZhiRing.indexOf(groundCurrentPos);
    if (pathStartIndexInRing == -1)
      throw Exception("地支环中未找到起点: ${groundCurrentPos.name}");

    // 顺行地盘，从当前落宫到天盘神的本家，包含本家这一步
    for (int i = 0; i < 12; i++) {
      DiZhi currentPathDiPan = diZhiRing[(pathStartIndexInRing + i) % 12];
      List<TianGan> jiGansInCurrentPathDiPan =
          _getTianGanJiGongList(currentPathDiPan);

      FiveXing skyGodXing = skyGod.fiveXing;
      FiveXing currentDiPanXing = currentPathDiPan.fiveXing;

      if (isShangKeXia) {
        // 上克下：统计天盘神克地盘的次数
        // 1. 天盘神克地盘五行
        if (FiveXingRelationship.checkRelationship(
                skyGodXing, currentDiPanXing) ==
            FiveXingRelationship.KE) {
          depth++;
        }
        // 2. 天盘神克地盘寄干
        for (TianGan jiGan in jiGansInCurrentPathDiPan) {
          if (FiveXingRelationship.checkRelationship(
                  skyGodXing, jiGan.fiveXing) ==
              FiveXingRelationship.KE) {
            depth++;
          }
        }
      } else {
        // 下贼上：统计地盘克天盘神的次数
        // 1. 地盘五行克天盘神
        if (FiveXingRelationship.checkRelationship(
                currentDiPanXing, skyGodXing) ==
            FiveXingRelationship.KE) {
          depth++;
        }
        // 2. 地盘寄干克天盘神
        for (TianGan jiGan in jiGansInCurrentPathDiPan) {
          if (FiveXingRelationship.checkRelationship(
                  jiGan.fiveXing, skyGodXing) ==
              FiveXingRelationship.KE) {
            depth++;
          }
        }
      }

      // 到达天盘神本家地支后停止计数
      if (currentPathDiPan == skyGodBenGong) {
        break;
      }
    }
    return depth;
  }

  /// 辅助：应用孟仲规则。返回选中的课，或null如果无法唯一确定。
  _ProcessedFourClassItem? _applyMengZhongRule(
      List<_ProcessedFourClassItem> sameDepthCandidates) {
    if (sameDepthCandidates.isEmpty) return null;
    List<_ProcessedFourClassItem> mengKeList =
        sameDepthCandidates.where((k) => _isMeng(k.ground)).toList();
    if (mengKeList.length == 1) return mengKeList.first;
    if (mengKeList.length > 1) return null; // 多个孟，转缀瑕

    List<_ProcessedFourClassItem> zhongKeList =
        sameDepthCandidates.where((k) => _isZhong(k.ground)).toList();
    if (zhongKeList.length == 1) return zhongKeList.first;
    if (zhongKeList.length > 1) return null; // 多个仲，转缀瑕

    return null; // 无孟无仲，或都是季，转缀瑕
  }

  /// 辅助：应用缀瑕规则。
  _ProcessedFourClassItem _applyZhuiXiaRule(
      List<_ProcessedFourClassItem> candidates) {
    if (candidates.isEmpty) throw Exception("缀瑕法错误：候选列表为空。");
    _ProcessedFourClassItem? targetKe;
    // 阳日取第一课(干上阳神), 阴日取第三课(支上阳神)
    // 假设_processedFourClass[0]是第一课，_processedFourClass[2]是第三课
    if (_isDayGanYang) {
      final firstKeOriginal = _processedFourClass
          .firstWhereOrNull((k) => k.order == 0); // 假设第一课order为0
      if (firstKeOriginal != null && candidates.contains(firstKeOriginal)) {
        targetKe = firstKeOriginal;
      }
    } else {
      final thirdKeOriginal = _processedFourClass
          .firstWhereOrNull((k) => k.order == 2); // 假设第三课order为2
      if (thirdKeOriginal != null && candidates.contains(thirdKeOriginal)) {
        targetKe = thirdKeOriginal;
      }
    }
    // 如果目标课不在候选列表，或未找到，则按候选列表中的原始四课顺序取第一个
    if (targetKe != null) return targetKe;
    candidates.sort((a, b) => a.order.compareTo(b.order));
    return candidates.first;
  }

  /// 3. 解析昴星法 (MAO_XING)
  ThreeChuanOutput? _resolveMaoXing() {
    DiZhi chuChuanDiZhi;
    DiZhi zhongChuanDiZhi;
    DiZhi moChuanDiZhi;
    String keShiName;
    String basis;

    DiZhi? diPanWhereTianPanYouIs =
        gong.entries.firstWhereOrNull((entry) => entry.value == DiZhi.YOU)?.key;
    if (diPanWhereTianPanYouIs == null) {
      throw Exception("昴星法错误：天盘中未找到酉 (可能是天地盘数据错误)");
    }

    final firstKeSky = _processedFourClass[0].sky; // 日干上神
    final thirdKeSky = _processedFourClass[2].sky; // 日支上神

    if (_isDayGanYang) {
      chuChuanDiZhi = gong[DiZhi.YOU]!.skyPanDiZhi; // 阳日，初传为地盘酉宫之上的天盘神
      zhongChuanDiZhi = firstKeSky; // 阳日中传=日干上神
      moChuanDiZhi = thirdKeSky; // 阳日末传=日支上神
      keShiName = "虎视转蓬";
      basis =
          "阳日昴星，取地盘酉上神(${chuChuanDiZhi.name})发用；干上(${zhongChuanDiZhi.name})为中，支上(${moChuanDiZhi.name})为末";
    } else {
      chuChuanDiZhi = diPanWhereTianPanYouIs; // 阴日，初传为天盘酉落于的地盘宫位
      zhongChuanDiZhi = thirdKeSky; // 阴日中传=日支上神
      moChuanDiZhi = firstKeSky; // 阴日末传=日干上神
      keShiName = "冬蛇掩目";
      basis =
          "阴日昴星，取天盘酉下神(${chuChuanDiZhi.name})发用；支上(${zhongChuanDiZhi.name})为中，干上(${moChuanDiZhi.name})为末";
    }

    final threeChuanItems = _buildSpecificThreeChuanItems(
        chuChuanDiZhi, zhongChuanDiZhi, moChuanDiZhi);
    return ThreeChuanOutput(
      first: threeChuanItems.item1,
      second: threeChuanItems.item2,
      third: threeChuanItems.item3,
      patternName: [keShiName],
      content: basis,
      nineZongmen: NineZongMen.MAO_XING,
      // originalThreeChuan: rawPanData.three,
    );
  }

  /// 4. 解析别责法 (BIE_ZE)
  ThreeChuanOutput? _resolveBieZe() {
    // 此方法在 _isSiKeBuQuan() 为 true 时被调用
    // 并且是在无贼克、无遥克、无昴星之后
    DiZhi chuChuanDiZhi;
    final dayGanSky = _processedFourClass[0].sky; // 日干上神，用于中末传
    String basis;

    if (_isDayGanYang) {
      TianGan heGan = _getDayGanWuHe(_dayGan);
      DiZhi heGanJiGong = _getTianGanJiGong(heGan);
      chuChuanDiZhi = gong[heGanJiGong]!.skyPanDiZhi; // 合干寄宫之上的天盘神
      basis =
          "阳日别责(四课不全)，取日干之合干(${heGan.name})寄宫(${heGanJiGong.name})上神(${chuChuanDiZhi.name})发用";
    } else {
      DiZhi sanHeNext = _getNextInSanHe(_dayZhi); // 日支三合局的下一位
      chuChuanDiZhi = gong[sanHeNext]!.skyPanDiZhi;
      basis =
          "阴日别责(四课不全)，取日支三合局下一位(${sanHeNext.name})上神(${chuChuanDiZhi.name})发用";
    }

    final threeChuanItems =
        _buildSpecificThreeChuanItems(chuChuanDiZhi, dayGanSky, dayGanSky);
    return ThreeChuanOutput(
      first: threeChuanItems.item1,
      second: threeChuanItems.item2, // 中传为日干上神
      third: threeChuanItems.item3, // 末传为日干上神
      patternName: ["芜淫课"], // 或芜淫课别责课
      content: basis + "; 中末传均为日干上神(${dayGanSky.name})",
      nineZongmen: NineZongMen.BIE_ZE,
      // originalThreeChuan: rawPanData.three,
    );
  }

  /// 5. 解析八专法 (BA_ZHUAN)
  ThreeChuanOutput? _resolveBaZhuan() {
    // 此方法在 _isBaZhuanCondition() 为 true 时被调用
    // 且在无贼克、无遥克、无昴星、非别责（或别责不取）之后
    DiZhi chuChuanDiZhi;
    final dayGanSky = _processedFourClass[0].sky; // 日干上神，用于中末传
    String basis;

    // 构建天盘顺行序列 (地盘子位上的天盘神, 地盘丑位上的天盘神, ...)
    List<DiZhi> tianPanShunXu =
        List.generate(12, (index) => gong[DiZhi.values[index]]!.skyPanDiZhi);

    if (_isDayGanYang) {
      DiZhi startGod = dayGanSky; // 干上神
      int startIndex = tianPanShunXu.indexOf(startGod);
      if (startIndex == -1) throw Exception("八专法错误：干上神未在天盘序列中找到");
      chuChuanDiZhi = tianPanShunXu[(startIndex + 2) % 12]; // 顺数三位
      basis = "阳日八专，从干上神(${startGod.name})顺数三位得(${chuChuanDiZhi.name})发用";
    } else {
      // 方案B阴日：从支上神开始，逆数3位
      DiZhi startGod = _processedFourClass[2].sky; // 支上神
      int startIndex = tianPanShunXu.indexOf(startGod);
      if (startIndex == -1) throw Exception("八专法错误：支上神未在天盘序列中找到");
      chuChuanDiZhi = tianPanShunXu[(startIndex - 2 + 12) % 12]; // 逆数三位
      basis = "阴日八专，从支上神(${startGod.name})逆数三位得(${chuChuanDiZhi.name})发用";
    }

    final threeChuanItems =
        _buildSpecificThreeChuanItems(chuChuanDiZhi, dayGanSky, dayGanSky);
    String keShiName = "八专课";
    if (chuChuanDiZhi == dayGanSky) {
      // 如果初传也等于干上神，三传皆同
      keShiName = "独足课";
    }

    return ThreeChuanOutput(
      first: threeChuanItems.item1,
      second: threeChuanItems.item2, // 中传为日干上神
      third: threeChuanItems.item3, // 末传为日干上神
      patternName: [keShiName],
      content: basis + "; 中末传均为日干上神(${dayGanSky.name})",
      nineZongmen: NineZongMen.BA_ZHUAN,
      // originalThreeChuan: rawPanData.three,
    );
  }

  /// 6. 解析伏吟法 (FU_YIN)
  ThreeChuanOutput? _resolveFuYin() {
    // 此方法在 _isFuYin() 为 true 时调用
    DiZhi firstChuanDiZhi;
    DiZhi secondChuanDiZhi;
    DiZhi thirdChuanDiZhi;
    String keShiName = "伏吟课";
    String basis = "";

    // 判断第一课（干上课）有无贼克
    bool firstKeHasKe = _processedFourClass[0].zeiKeType != ZeiKeType.NONE;
    final dayGanSky = _processedFourClass[0].sky; // 日干上神
    final zhiShangSky = _processedFourClass[2].sky; // 日支上神

    if (firstKeHasKe) {
      basis = "伏吟有克，";
      firstChuanDiZhi = dayGanSky;
      basis += "干上神(${firstChuanDiZhi.name})发用";
      if (!_isSelfXing(firstChuanDiZhi)) {
        secondChuanDiZhi = _getDiZhiXing(firstChuanDiZhi);
        thirdChuanDiZhi = _getDiZhiXing(secondChuanDiZhi);
        basis +=
            ", 初传刑为中(${secondChuanDiZhi.name}), 中传刑为末(${thirdChuanDiZhi.name})";
      } else {
        keShiName = "杜传格 (伏吟有克)";
        secondChuanDiZhi = zhiShangSky;
        basis += ", 初传自刑，支上神(${secondChuanDiZhi.name})为中";
        if (_isSelfXing(secondChuanDiZhi)) {
          thirdChuanDiZhi = _getDiZhiChong(secondChuanDiZhi);
          basis += ", 中亦自刑，冲为末(${thirdChuanDiZhi.name})";
        } else {
          thirdChuanDiZhi = _getDiZhiXing(secondChuanDiZhi);
          basis += ", 中刑为末(${thirdChuanDiZhi.name})";
        }
      }
    } else {
      // 无克 (自任格)
      keShiName = "自任格 (伏吟无克)";
      basis = "伏吟无克(自任)，";
      firstChuanDiZhi = _isDayGanYang ? dayGanSky : zhiShangSky;
      basis += _isDayGanYang
          ? "阳日干上神(${firstChuanDiZhi.name})发用"
          : "阴日支上神(${firstChuanDiZhi.name})发用";
      if (_isSelfXing(firstChuanDiZhi)) {
        keShiName = "杜传格 (伏吟自任初传自刑)";
        secondChuanDiZhi = _isDayGanYang ? zhiShangSky : dayGanSky;
        basis +=
            ", 初传自刑，${_isDayGanYang ? '支上神' : '干上神'}(${secondChuanDiZhi.name})为中";
        if (_isSelfXing(secondChuanDiZhi)) {
          thirdChuanDiZhi = _getDiZhiChong(secondChuanDiZhi);
          basis += ", 中亦自刑，冲为末(${thirdChuanDiZhi.name})";
        } else {
          thirdChuanDiZhi = _getDiZhiXing(secondChuanDiZhi);
          basis += ", 中刑为末(${thirdChuanDiZhi.name})";
        }
      } else {
        secondChuanDiZhi = _getDiZhiXing(firstChuanDiZhi);
        basis += ", 初传刑为中(${secondChuanDiZhi.name})";
        if (_isSelfXing(secondChuanDiZhi)) {
          thirdChuanDiZhi = _getDiZhiChong(secondChuanDiZhi);
          basis += ", 中自刑，冲为末(${thirdChuanDiZhi.name})";
          // 检查 丁/己/辛 卯日特殊情况
          JiaZi currentDay = dayJiaZi;
          if (!_isDayGanYang &&
              {JiaZi.DING_MAO, JiaZi.JI_MAO, JiaZi.XIN_MAO}
                  .contains(currentDay) &&
              firstChuanDiZhi == DiZhi.MAO &&
              secondChuanDiZhi == DiZhi.ZI) {
            thirdChuanDiZhi = DiZhi.WU; // 子卯互刑，末传取冲午
            basis += " (卯日子遥刑特殊规则，末传取午)";
            keShiName = "阴日伏吟子卯遥刑";
          }
        } else {
          thirdChuanDiZhi = _getDiZhiXing(secondChuanDiZhi);
          basis += ", 中刑为末(${thirdChuanDiZhi.name})";
        }
      }
    }

    final threeChuanItems = _buildSpecificThreeChuanItems(
        firstChuanDiZhi, secondChuanDiZhi, thirdChuanDiZhi);
    return ThreeChuanOutput(
      first: threeChuanItems.item1,
      second: threeChuanItems.item2,
      third: threeChuanItems.item3,
      patternName: [keShiName],
      content: basis,
      nineZongmen: NineZongMen.FU_YIN,
      // originalThreeChuan: rawPanData.three
    );
  }

  _isSelfXing(DiZhi diZhi) {
    return [DiZhi.CHEN, DiZhi.WU, DiZhi.YOU, DiZhi.HAI].contains(diZhi);
  }

  _getDiZhiXing(DiZhi diZhi) {
    return DiZhiXing.getOtherDiZhi(diZhi);
  }

  /// 7. 解析反吟法 (FAN_YIN)
  ThreeChuanOutput? _resolveFanYin() {
    // 此方法在 _isFanYin() 为 true 时调用
    DiZhi firstChuanDiZhi;
    DiZhi secondChuanDiZhi;
    DiZhi thirdChuanDiZhi;
    String keShiName = "反吟课";
    String basis = "";

    final dayGanSky = _processedFourClass[0].sky; // 日干上神
    final zhiShangSky = _processedFourClass[2].sky; // 日支上神

    JiaZi currentDay = dayJiaZi;
    if ((currentDay == JiaZi.WU_CHEN || currentDay == JiaZi.WU_XU) &&
        dayGanSky == DiZhi.HAI &&
        (zhiShangSky == DiZhi.XU || zhiShangSky == DiZhi.CHEN)) {
      firstChuanDiZhi = DiZhi.SI;
      secondChuanDiZhi = DiZhi.HAI;
      thirdChuanDiZhi = DiZhi.SI;
      keShiName = "反吟特定格 (戊辰/戊戌)";
      basis = "戊辰/戊戌日，干上亥，支上戌/辰，三传巳亥巳";
    } else {
      // 判断“有克”：这里指四课内部仍存在之前未被取用的“贼”或“克”关系。
      // 因为反吟优先级低，到这里时，强烈的贼克和遥克应该已被处理。
      // 这里的“有克”更像是一种课体不纯粹的表征。
      _ProcessedFourClassItem? residualKe = _processedFourClass
          .firstWhereOrNull((k) => k.zeiKeType == ZeiKeType.ZEI);
      if (residualKe == null) {
        residualKe = _processedFourClass
            .firstWhereOrNull((k) => k.zeiKeType == ZeiKeType.KE);
      }

      if (residualKe != null) {
        // 方案B描述：“有克→ 初传=受克的天盘神”。这比较概括。
        // DaLiuRenKePan.dart 是直接调用 checkByZeiKe，但最终宗门是 FanYin。
        // 作为一个低优先级的判断，这里的“有克”可能不应再启用复杂的贼克涉害链。
        // 我们简单取这个“残余克害”的课上神作为初传。
        firstChuanDiZhi = residualKe.sky;
        basis =
            "反吟有残余课内克害，取优先者(${residualKe.zeiKeType == ZeiKeType.ZEI ? '贼' : '克'})之课上神(${firstChuanDiZhi.name})发用";
        keShiName = "反吟有克";
      } else {
        // 无此类克害，视为“无克”，取日支驿马发用
        DiZhi sanHeMeng = _getSanHeMengShen(_dayZhi);
        firstChuanDiZhi = _getDiZhiChong(sanHeMeng); // 日支驿马
        basis = "反吟无课内克害，取日支(${_dayZhi.name})之驿马(${firstChuanDiZhi.name})发用";
        keShiName = "井栏叉";
      }
      // 反吟课中末传固定：中传=支上神；末传=干上神
      secondChuanDiZhi = zhiShangSky;
      thirdChuanDiZhi = dayGanSky;
    }

    final threeChuanItems = _buildSpecificThreeChuanItems(
        firstChuanDiZhi, secondChuanDiZhi, thirdChuanDiZhi);
    return ThreeChuanOutput(
      first: threeChuanItems.item1,
      second: threeChuanItems.item2,
      third: threeChuanItems.item3,
      patternName: [keShiName],
      content: basis,
      nineZongmen: NineZongMen.FAN_YIN,
      // originalThreeChuan: rawPanData.three
    );
  }

  // ----------------------------------------------------------------------
  // Section: 三传构建的辅助方法
  // ----------------------------------------------------------------------

  /// 根据“链式”规则（如贼克、遥克）构建三传的 `ThreeClassItem` 列表
  /// [firstChuanSkyDiZhi] - 经过宗门判断后确定的初传天盘神
  Tuple3<ThreeClassItem, ThreeClassItem, ThreeClassItem>
      _createChainThreeChuanItems(DiZhi firstChuanSkyDiZhi) {
    // 中传神 = 初传神(作为天盘)落在其自身地盘宫位时，该地盘宫位之上的天盘神。
    // 即：以初传天盘神为Key，去天地盘映射(rawPanData.gong)中查找对应的Value。
    DiZhi secondChuanSkyDiZhi = gong[firstChuanSkyDiZhi]!.skyPanDiZhi;
    DiZhi thirdChuanSkyDiZhi = gong[secondChuanSkyDiZhi]!.skyPanDiZhi;

    return Tuple3(
      ThreeClassItem(
          order: 1,
          diZhi: firstChuanSkyDiZhi,
          liuQin:
              LiuQin.getLiuQinByForTianGanDiZhi(_dayGan, firstChuanSkyDiZhi)),
      ThreeClassItem(
          order: 2,
          diZhi: secondChuanSkyDiZhi,
          liuQin:
              LiuQin.getLiuQinByForTianGanDiZhi(_dayGan, secondChuanSkyDiZhi)),
      ThreeClassItem(
          order: 3,
          diZhi: thirdChuanSkyDiZhi,
          liuQin:
              LiuQin.getLiuQinByForTianGanDiZhi(_dayGan, thirdChuanSkyDiZhi)),
    );
  }

  /// 根据直接指定的三个天盘神构建三传的 `ThreeClassItem` 列表
  Tuple3<ThreeClassItem, ThreeClassItem, ThreeClassItem>
      _buildSpecificThreeChuanItems(
          DiZhi firstDiZhi, DiZhi secondDiZhi, DiZhi thirdDiZhi) {
    return Tuple3(
      ThreeClassItem(
          order: 1,
          diZhi: firstDiZhi,
          liuQin: LiuQin.getLiuQinByForTianGanDiZhi(_dayGan, firstDiZhi)),
      ThreeClassItem(
          order: 2,
          diZhi: secondDiZhi,
          liuQin: LiuQin.getLiuQinByForTianGanDiZhi(_dayGan, secondDiZhi)),
      ThreeClassItem(
          order: 3,
          diZhi: thirdDiZhi,
          liuQin: LiuQin.getLiuQinByForTianGanDiZhi(_dayGan, thirdDiZhi)),
    );
  }

  // ----------------------------------------------------------------------
  // Section: 基础地支属性的辅助方法 (孟仲季)
  // ----------------------------------------------------------------------
  bool _isMeng(DiZhi zhi) =>
      [DiZhi.YIN, DiZhi.SHEN, DiZhi.SI, DiZhi.HAI].contains(zhi);
  bool _isZhong(DiZhi zhi) =>
      [DiZhi.ZI, DiZhi.WU, DiZhi.MAO, DiZhi.YOU].contains(zhi);
  bool _isJi(DiZhi zhi) =>
      [DiZhi.CHEN, DiZhi.XU, DiZhi.CHOU, DiZhi.WEI].contains(zhi);

  TianGan _getDayGanWuHe(TianGan dayGan) {
    return TianGanFiveCombine.getOtherGan(dayGan);
  }

  DiZhi _getNextInSanHe(DiZhi dayZhi) {
    List<DiZhi> _list = DiZhiSanHe.getBySingleDiZhi(dayZhi)!.getOrderedSeq();
    if (_list.first == dayZhi) {
      return _list[1];
    } else if (_list[1] == dayZhi) {
      return _list[2];
    } else {
      return _list.first;
    }
  }

  DiZhi _getDiZhiChong(DiZhi secondChuanDiZhi) {
    return DiZhiChong.getOtherDiZhi(secondChuanDiZhi);
  }

  DiZhi _getSanHeMengShen(DiZhi dayZhi) {
    return DiZhiSanHe.getHorseBySingleDiZhi(dayZhi);
  }

  /// 优化后的昴星判断方法
  bool _isMaoXingOptimized() {
    // final dayJiaZi = rawPanData.day;
    final expectedPositions = NineZongMen.maoXingMapping[dayJiaZi];

    if (expectedPositions == null) {
      return false; // 不在昴星课列表中
    }

    // 检查干上神是否在预期位置
    final ganShangShen = _processedFourClass[0].sky;
    return expectedPositions.contains(ganShangShen);
  }

  /// 优化后的别责判断方法
  bool _isBieZeOptimized() {
    // final dayJiaZi = rawPanData.day;
    final expectedPositions = NineZongMen.bieZeMapping[dayJiaZi];

    if (expectedPositions == null) {
      return false; // 不在别责课列表中
    }

    // 检查是否四课不全
    if (!_isSiKeBuQuan()) {
      return false;
    }

    // 检查干上神是否在预期位置
    final ganShangShen = _processedFourClass[0].sky;
    return expectedPositions.isEmpty ||
        expectedPositions.contains(ganShangShen);
  }

  /// 优化后的昴星解析方法
  ThreeChuanOutput? _resolveMaoXingOptimized() {
    if (!_isMaoXingOptimized()) {
      return null;
    }

    // 使用原有的昴星计算逻辑，但跳过复杂的判断
    return _resolveMaoXing();
  }

  /// 优化后的别责解析方法
  ThreeChuanOutput? _resolveBieZeOptimized() {
    if (!_isBieZeOptimized()) {
      return null;
    }

    // 使用原有的别责计算逻辑
    return _resolveBieZe();
  }
}
