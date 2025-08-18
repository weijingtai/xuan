// --- (假设之前的 ZhouTianCalculator 和其数据结构已存在) ---
// --- (假设 YearMonth, CelestialObject 等辅助类已存在) ---

import 'dart:math';

import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';

import '../domain/entities/models/star_enter_info.dart';
import '../domain/managers/zhou_tian_calculator.dart';
import '../enums/enum_panel_system_type.dart';
import '../enums/enum_twelve_gong.dart';
import 'base_xian_palace.dart';
import 'da_xian_constellation_passage_info.dart';
import 'da_xian_palace_info.dart';
import 'gong_constellation_mapping.dart';
import 'star_influence_model.dart';
import 'base_xian_calculator.dart';

class DongWeiDaXianCalculator extends BaseXianCalculator {
  DongWeiDaXianCalculator({
    required super.zhouTianModel,
    required super.basePanel,
    required super.observerPosition,
    required super.daxianPalaceOrder,
    required super.daxianPalaceDurations,
    super.isRetrograde = true,
    super.luoRangeDegree = 1.0,
    super.dingRangeDegree = 1.0,
  });

  Map<EnumTwelveGong, DaXianPalaceInfo> calculate(
      List<ConstellationMappingResult> mapping,
      Map<EnumTwelveGong, CelestialObject> palacesStaticInfo) {
    // 1. 首先调用 calculateDaXian 获取 List<DaXianPalaceInfo>
    List<DaXianPalaceInfo> daXianList =
        calculateDaXianV1(mapping, palacesStaticInfo, starsEnterInfo);

    // 2. 为每个大限宫位计算星体影响并更新到 List<DaXianPalaceInfo>
    for (int i = 0; i < daXianList.length; i++) {
      DaXianPalaceInfo daXianInfo = daXianList[i];

      // 调用基类的 calculateStarInfluences 方法
      StarGongInfluence? starInfluence = calculateStarInfluences(
        targetPalace: daXianInfo.palace,
        starsEnterInfo: starsEnterInfo,
      );

      // 更新星体影响到大限宫位信息
      daXianList[i] = daXianInfo.copyWith(
        starGongInfluence: starInfluence,
      );
    }

    // 3. 为每个大限宫位计算丁度星体影响并更新到 List<DaXianPalaceInfo>
    for (int i = 0; i < daXianList.length; i++) {
      DaXianPalaceInfo daXianInfo = daXianList[i];

      // 调用 calculateDingStar 计算丁度影响
      Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper =
          calculateDingStar(daXianInfo);

      // 更新丁度影响到大限宫位信息
      daXianList[i] = daXianInfo.copyWith(
        dingStarMapper: dingStarMapper,
      );
    }

    // 4. 最后生成 Map<EnumTwelveGong, DaXianPalaceInfo> 并返回
    Map<EnumTwelveGong, DaXianPalaceInfo> result = {};
    for (DaXianPalaceInfo daXianInfo in daXianList) {
      result[daXianInfo.palace] = daXianInfo;
    }

    return result;
  }

  // 在 DongWeiDaXianCalculator 类中添加修正后的方法
  /// 基于宫位星宿映射结果计算大限
  /// [palaceMapping] 来自 ZhouTianCalculator.mapPalacesToConstellations() 的结果
  List<DaXianPalaceInfo> calculateDaXian(
    List<PalaceMappingResult> palaceMapping,
    Map<EnumTwelveGong, CelestialObject> palacesStaticInfo,
    // Map<EnumStars, EnteredInfo> starsEnterInfo,
  ) {
    List<DaXianPalaceInfo> results = [];
    DateTime currentEventTime = birthTime;
    YearMonth currentEventAge = YearMonth(0, 0);
    int daxianOrder = 0;

    // 遍历大限宫位顺序
    for (EnumTwelveGong currentPalaceKey in daxianPalaceOrder) {
      daxianOrder++;
      YearMonth palaceDaxianDuration = daxianPalaceDurations[currentPalaceKey]!;

      DateTime daxianStartTime = currentEventTime;
      YearMonth daxianStartAge = currentEventAge;
      DateTime daxianEndTime = TimeUtils.addYearMonthToDateTime(
          daxianStartTime, palaceDaxianDuration);
      YearMonth daxianEndAge = daxianStartAge + palaceDaxianDuration;

      // 获取宫位信息
      CelestialObject palaceStatic = palacesStaticInfo[currentPalaceKey]!;
      double palaceWidthDegrees = palaceStatic.width;

      if (palaceWidthDegrees < ZhouTianCalculator.EPSILON_RAW) {
        if (palaceDaxianDuration.toTotalMonths() == 0) {
          List<DaXianConstellationPassageInfo> passages = [];
          results.add(DaXianPalaceInfo(
            order: daxianOrder,
            palace: currentPalaceKey,
            durationYears: palaceDaxianDuration,
            startTime: daxianStartTime,
            endTime: daxianEndTime,
            startAge: daxianStartAge,
            endAge: daxianEndAge,
            rateYearsPerDegree: YearMonth.zero(),
            constellationPassages: passages,
            totalGongDegreee: palaceWidthDegrees,
          ));
          currentEventTime = daxianEndTime;
          currentEventAge = daxianEndAge;
          continue;
        }
        throw Exception("宫位 ${palaceStatic.name} 宽度为0但大限时长不为0");
      }

      // 计算时间分配
      int totalDays = palaceDaxianDuration.toTotalDays();
      double daysPerDegree = totalDays / palaceWidthDegrees;
      YearMonth rateYearsPerDegree =
          YearMonth.fromTotalDays(daysPerDegree.round());

      // 调用提取的方法计算行限星宿信息
      List<DaXianConstellationPassageInfo> passages =
          calculateXingXianStarPassages(
        targetPalaceMapping:
            palaceMapping.firstWhere((t) => t.palaceName == currentPalaceKey),
        daxianDuration: palaceDaxianDuration,
        daxianStartTime: daxianStartTime,
        daxianStartAge: daxianStartAge,
        isRetrograde: isRetrograde,
      );

      results.add(DaXianPalaceInfo(
        order: daxianOrder,
        palace: currentPalaceKey,
        durationYears: palaceDaxianDuration,
        startTime: daxianStartTime,
        endTime: daxianEndTime,
        startAge: daxianStartAge,
        endAge: daxianEndAge,
        rateYearsPerDegree: rateYearsPerDegree,
        constellationPassages: passages,
        totalGongDegreee: palaceWidthDegrees,
      ));

      currentEventTime = daxianEndTime;
      currentEventAge = daxianEndAge;
    }

    return results;
  }

  // 在 DongWeiDaXianCalculator 类中添加修正后的方法
  /// 基于已有的宫位星宿映射结果计算大限
  /// [mapping] 来自 ZhouTianCalculator.mapConstellationsToPalaces() 的结果
  @Deprecated('Use calculateDaXian instead')
  List<DaXianPalaceInfo> calculateDaXianV1(
    List<ConstellationMappingResult> mapping,
    Map<EnumTwelveGong, CelestialObject> palacesStaticInfo,
    Map<EnumStars, EnteredInfo> starsEnterInfo,
  ) {
    List<DaXianPalaceInfo> results = [];
    DateTime currentEventTime = birthTime;
    YearMonth currentEventAge = YearMonth(0, 0);
    int daxianOrder = 0;

    // 创建宫位到星宿段的映射
    Map<EnumTwelveGong, List<ConstellationSegmentForDaXian>> palaceToSegments =
        {};

    // 初始化所有宫位的空列表
    for (EnumTwelveGong palace in daxianPalaceOrder) {
      palaceToSegments[palace] = [];
    }

    // 从映射结果中提取每个宫位的星宿段
    for (ConstellationMappingResult constellationResult in mapping) {
      for (ConstellationSegment segment in constellationResult.segments) {
        if (palaceToSegments.containsKey(segment.palaceName)) {
          palaceToSegments[segment.palaceName]!.add(
            ConstellationSegmentForDaXian(
              constellation: constellationResult.constellationName,
              segmentStartInPalace: segment.startInPalaceDeg,
              segmentEndInPalace: segment.endInPalaceDeg,
              degreeStartInConstellation: segment.startInConstellationDeg,
              degreeEndInConstellation: segment.endInConstellationDeg,
              segmentLengthDeg: segment.segmentLengthDeg,
            ),
          );
        }
      }
    }

    // 对每个宫位的星宿段进行排序
    for (EnumTwelveGong palace in palaceToSegments.keys) {
      List<ConstellationSegmentForDaXian> segments = palaceToSegments[palace]!;
      if (isRetrograde) {
        // 逆行：从高度数到低度数
        segments.sort(
            (a, b) => b.segmentEndInPalace.compareTo(a.segmentEndInPalace));
      } else {
        // 正行：从低度数到高度数
        segments.sort(
            (a, b) => a.segmentStartInPalace.compareTo(b.segmentStartInPalace));
      }
    }

    // 遍历大限宫位顺序
    for (EnumTwelveGong currentPalaceKey in daxianPalaceOrder) {
      daxianOrder++;
      YearMonth palaceDaxianDuration = daxianPalaceDurations[currentPalaceKey]!;

      DateTime daxianStartTime = currentEventTime;
      YearMonth daxianStartAge = currentEventAge;
      DateTime daxianEndTime = TimeUtils.addYearMonthToDateTime(
          daxianStartTime, palaceDaxianDuration);
      YearMonth daxianEndAge = daxianStartAge + palaceDaxianDuration;

      // 获取宫位信息
      CelestialObject palaceStatic = palacesStaticInfo[currentPalaceKey]!;
      double palaceWidthDegrees = palaceStatic.width;

      if (palaceWidthDegrees < ZhouTianCalculator.EPSILON_RAW) {
        if (palaceDaxianDuration.toTotalMonths() == 0) {
          List<DaXianConstellationPassageInfo> passages = [];
          results.add(DaXianPalaceInfo(
            order: daxianOrder,
            palace: currentPalaceKey,
            durationYears: palaceDaxianDuration,
            startTime: daxianStartTime,
            endTime: daxianEndTime,
            startAge: daxianStartAge,
            endAge: daxianEndAge,
            rateYearsPerDegree: YearMonth.zero(),
            constellationPassages: passages,
            totalGongDegreee: palaceWidthDegrees,
          ));
          currentEventTime = daxianEndTime;
          currentEventAge = daxianEndAge;
          continue;
        }
        throw Exception("宫位 ${palaceStatic.name} 宽度为0但大限时长不为0");
      }

      // 计算时间分配
      int totalDays = palaceDaxianDuration.toTotalDays();
      double daysPerDegree = totalDays / palaceWidthDegrees;
      YearMonth rateYearsPerDegree =
          YearMonth.fromTotalDays(daysPerDegree.round());

      List<DaXianConstellationPassageInfo> passages = [];
      int accumulatedDaysInThisDaxian = 0;

      // 处理该宫位中的所有星宿段
      List<ConstellationSegmentForDaXian> segmentsInPalace =
          palaceToSegments[currentPalaceKey]!;

      for (ConstellationSegmentForDaXian segment in segmentsInPalace) {
        double currentSegmentSpanDegrees = segment.segmentLengthDeg;

        // 计算持续时间
        int passageDurationDays =
            (currentSegmentSpanDegrees * daysPerDegree).round();
        YearMonth passageDurationYears =
            YearMonth.fromTotalDays(passageDurationDays);

        DateTime passageEntryTime =
            daxianStartTime.add(Duration(days: accumulatedDaysInThisDaxian));
        YearMonth passageEntryAge = daxianStartAge +
            YearMonth.fromTotalDays(accumulatedDaysInThisDaxian);

        accumulatedDaysInThisDaxian += passageDurationDays;

        // 确保不超过宫位总时长
        if (accumulatedDaysInThisDaxian > totalDays) {
          accumulatedDaysInThisDaxian = totalDays;
        }

        DateTime passageExitTime =
            daxianStartTime.add(Duration(days: accumulatedDaysInThisDaxian));
        YearMonth passageExitAge = daxianStartAge +
            YearMonth.fromTotalDays(accumulatedDaysInThisDaxian);

        // 计算星宿影响
        List<ConstellationStarInfluenceModel>? constellationStarInfluences =
            calculateConstellationStarInfluences(
          targetConstellation: segment.constellation,
          starsEnterInfo: starsEnterInfo,
        );

        passages.add(DaXianConstellationPassageInfo(
          constellation: segment.constellation,
          // 处理逆行时的度数方向
          startDegreeInConstellation: isRetrograde
              ? segment.degreeEndInConstellation
              : segment.degreeStartInConstellation,
          endDegreeInConstellation: isRetrograde
              ? segment.degreeStartInConstellation
              : segment.degreeEndInConstellation,
          segmentAngularSpanDegrees: currentSegmentSpanDegrees,
          passageDurationYears: passageDurationYears,
          entryTime: passageEntryTime,
          exitTime: passageExitTime,
          entryAge: passageEntryAge,
          exitAge: passageExitAge,
        ));
      }

      results.add(DaXianPalaceInfo(
        order: daxianOrder,
        palace: currentPalaceKey,
        durationYears: palaceDaxianDuration,
        startTime: daxianStartTime,
        endTime: daxianEndTime,
        startAge: daxianStartAge,
        endAge: daxianEndAge,
        rateYearsPerDegree: rateYearsPerDegree,
        constellationPassages: passages,
        totalGongDegreee: palaceWidthDegrees,
      ));

      currentEventTime = daxianEndTime;
      currentEventAge = daxianEndAge;
    }

    return results;
  }

  // 计算指定宫位的星体影响信息
  /// [targetPalace] 目标宫位
  /// [starsEnterInfo] 所有星体的入宫入宿信息
  /// [daxianStartTime] 大限开始时间
  /// [daxianEndTime] 大限结束时间
  /// [daxianStartAge] 大限开始年龄
  /// [rateYearsPerDegree] 每度对应的年月数
  /// 计算指定宫位的星体影响信息（简化版）
  @Deprecated('此方法已过时，建议使用 calculateStarInfluences方法。')
  StarGongInfluence? calculateStarInfluences_v1({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    List<PalaceStarInfluenceModel> sameGongInfluence = [];
    List<PalaceStarInfluenceModel> oppositeGongInfluence = [];
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> triangleGongInfluence =
        {};
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> squareGongInfluence =
        {};
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> sameLuoInfluence = {};

    // 获取目标宫位的关系宫位
    EnumTwelveGong oppositePalace = targetPalace.opposite;
    List<EnumTwelveGong> trianglePalaces = targetPalace.otherTringleGongList;
    List<EnumTwelveGong> squarePalaces = targetPalace.otherSquareGongList;

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 同宫影响
      if (starInfo.gong == targetPalace) {
        sameGongInfluence.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.same,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }

      // 对宫影响
      else if (starInfo.gong == oppositePalace) {
        oppositeGongInfluence.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.opposite,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }

      // 三方影响
      else if (trianglePalaces.contains(starInfo.gong)) {
        if (!triangleGongInfluence.containsKey(starInfo.gong)) {
          triangleGongInfluence[starInfo.gong] = [];
        }
        triangleGongInfluence[starInfo.gong]!.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.triangle,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }

      // 四正影响
      else if (squarePalaces.contains(starInfo.gong)) {
        if (!squareGongInfluence.containsKey(starInfo.gong)) {
          squareGongInfluence[starInfo.gong] = [];
        }
        squareGongInfluence[starInfo.gong]!.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.square,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }

      // 同络影响（需要检查度数差异）
      _calculateSameLuoInfluence(
        targetPalace: targetPalace,
        star: star,
        starInfo: starInfo,
        starsEnterInfo: starsEnterInfo,
        sameLuoInfluence: sameLuoInfluence,
      );
    }

    // 检查是否所有影响列表都为空
    if (sameGongInfluence.isEmpty &&
        oppositeGongInfluence.isEmpty &&
        triangleGongInfluence.isEmpty &&
        squareGongInfluence.isEmpty &&
        sameLuoInfluence.isEmpty) {
      return null;
    }

    return StarGongInfluence(
      sameGongInfluence: sameGongInfluence.isEmpty ? null : sameGongInfluence,
      oppositeGongInfluence:
          oppositeGongInfluence.isEmpty ? null : oppositeGongInfluence,
      triangleGongInfluence:
          triangleGongInfluence.isEmpty ? null : triangleGongInfluence,
      squareGongInfluence:
          squareGongInfluence.isEmpty ? null : squareGongInfluence,
      sameLuoInfluence: sameLuoInfluence.isEmpty ? null : sameLuoInfluence,
    );
  }

  List<ConstellationStarInfluenceModel>? calculateConstellationStarInfluences(
      {required Enum28Constellations targetConstellation,
      required Map<EnumStars, EnteredInfo> starsEnterInfo,
      EnumStars? starToExclude}) {
    List<ConstellationStarInfluenceModel> influences = [];

    List<MapEntry<EnumStars, EnteredInfo>> sameJingConstell = starsEnterInfo
        .entries
        .where(
            (en) => en.value.inn.sevenZheng == targetConstellation.sevenZheng)
        .toList();

    if (sameJingConstell.isEmpty) {
      return null;
    }
    if (starToExclude != null) {
      sameJingConstell.removeWhere((en) => en.key == starToExclude);
    }
    if (sameJingConstell.isEmpty) {
      return null;
    }

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 同经影响（同一星宿）
      if (starInfo.enterInnInfo.constellation == targetConstellation) {
        influences.add(ConstellationStarInfluenceModel(
          influenceType: EnumInfluenceType.jing,
          star: star,
          location: starInfo.enterInnInfo.constellation,
          entryDegree: starInfo.enterInnInfo.degree,
          inSameConstellation: true,
        ));
      } else {
        influences.add(ConstellationStarInfluenceModel(
          influenceType: EnumInfluenceType.jing,
          star: star,
          location: starInfo.enterInnInfo.constellation,
          entryDegree: starInfo.enterInnInfo.degree,
          inSameConstellation: false,
        ));
      }
    }

    return influences;
  }

  /// 计算同络影响（简化版）
  void _calculateSameLuoInfluence({
    required EnumTwelveGong targetPalace,
    required EnumStars star,
    required EnteredInfo starInfo,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
    required Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>
        sameLuoInfluence,
  }) {
    // 查找目标宫位中的星体
    EnteredInfo? targetPalaceStarInfo;
    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      if (entry.value.gong == targetPalace) {
        targetPalaceStarInfo = entry.value;
        break;
      }
    }

    if (targetPalaceStarInfo == null) return;

    // 检查度数差异（同络的判断标准，通常在0.5-1度内）
    double degreeDiff =
        (starInfo.atGongDegree - targetPalaceStarInfo.atGongDegree).abs();
    if (degreeDiff <= luoRangeDegree && starInfo.gong != targetPalace) {
      if (!sameLuoInfluence.containsKey(starInfo.gong)) {
        sameLuoInfluence[starInfo.gong] = [];
      }
      sameLuoInfluence[starInfo.gong]!.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.luo,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
          degreeDiff: degreeDiff,
          defaultRangeDegree: luoRangeDegree));
    }
  }

  /// 计算同宫影响
  List<PalaceStarInfluenceModel> _calculateSameGongInfluence({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    List<PalaceStarInfluenceModel> sameGongInfluence = [];

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 同宫影响
      if (starInfo.gong == targetPalace) {
        sameGongInfluence.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.same,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }
    }

    return sameGongInfluence;
  }

  /// 计算对宫影响
  List<PalaceStarInfluenceModel> _calculateOppositeGongInfluence({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    List<PalaceStarInfluenceModel> oppositeGongInfluence = [];
    EnumTwelveGong oppositePalace = targetPalace.opposite;

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 对宫影响
      if (starInfo.gong == oppositePalace) {
        oppositeGongInfluence.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.opposite,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }
    }

    return oppositeGongInfluence;
  }

  /// 计算三方影响
  Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>
      _calculateTriangleGongInfluence({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> triangleGongInfluence =
        {};
    List<EnumTwelveGong> trianglePalaces = targetPalace.otherTringleGongList;

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 三方影响
      if (trianglePalaces.contains(starInfo.gong)) {
        if (!triangleGongInfluence.containsKey(starInfo.gong)) {
          triangleGongInfluence[starInfo.gong] = [];
        }
        triangleGongInfluence[starInfo.gong]!.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.triangle,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }
    }

    return triangleGongInfluence;
  }

  /// 计算四正影响
  Map<EnumTwelveGong, List<PalaceStarInfluenceModel>>
      _calculateSquareGongInfluence({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> squareGongInfluence =
        {};
    List<EnumTwelveGong> squarePalaces = targetPalace.otherSquareGongList;

    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      // 四正影响
      if (squarePalaces.contains(starInfo.gong)) {
        if (!squareGongInfluence.containsKey(starInfo.gong)) {
          squareGongInfluence[starInfo.gong] = [];
        }
        squareGongInfluence[starInfo.gong]!.add(PalaceStarInfluenceModel(
          influenceType: EnumInfluenceType.square,
          star: star,
          location: starInfo.gong,
          entryDegree: starInfo.atGongDegree,
        ));
      }
    }

    return squareGongInfluence;
  }

  /// 重构后的 calculateStarInfluences 方法
  @Deprecated("请使用父类的 calculateStarInfluences")
  StarGongInfluence? calculateStarInfluencesV2({
    required EnumTwelveGong targetPalace,
    required Map<EnumStars, EnteredInfo> starsEnterInfo,
  }) {
    // 使用独立函数计算各种影响
    List<PalaceStarInfluenceModel> sameGongInfluence =
        _calculateSameGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    List<PalaceStarInfluenceModel> oppositeGongInfluence =
        _calculateOppositeGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> triangleGongInfluence =
        _calculateTriangleGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> squareGongInfluence =
        _calculateSquareGongInfluence(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );

    // 计算同络影响（保持原有逻辑）
    Map<EnumTwelveGong, List<PalaceStarInfluenceModel>> sameLuoInfluence = {};
    for (MapEntry<EnumStars, EnteredInfo> entry in starsEnterInfo.entries) {
      EnumStars star = entry.key;
      EnteredInfo starInfo = entry.value;

      _calculateSameLuoInfluence(
        targetPalace: targetPalace,
        star: star,
        starInfo: starInfo,
        starsEnterInfo: starsEnterInfo,
        sameLuoInfluence: sameLuoInfluence,
      );
    }

    // 检查是否所有影响列表都为空
    if (sameGongInfluence.isEmpty &&
        oppositeGongInfluence.isEmpty &&
        triangleGongInfluence.isEmpty &&
        squareGongInfluence.isEmpty &&
        sameLuoInfluence.isEmpty) {
      return null;
    }

    return StarGongInfluence(
      sameGongInfluence: sameGongInfluence.isEmpty ? null : sameGongInfluence,
      oppositeGongInfluence:
          oppositeGongInfluence.isEmpty ? null : oppositeGongInfluence,
      triangleGongInfluence:
          triangleGongInfluence.isEmpty ? null : triangleGongInfluence,
      squareGongInfluence:
          squareGongInfluence.isEmpty ? null : squareGongInfluence,
      sameLuoInfluence: sameLuoInfluence.isEmpty ? null : sameLuoInfluence,
    );
  }

  /// 创建丁度星体影响模型的辅助方法
  @override
  DingStarInfluenceModel createDingStarInfluence(
    PalaceStarInfluenceModel starInfluence,
    BaseXianPalace daXianPassageGong,
    EnumInfluenceType influenceType,
  ) {
    // 根据星体入宫度数和大限时间信息计算丁度的起止时间
    double entryDegree = starInfluence.entryDegree;

    // YearMonth ratePerDegree = daXianPassageGong.rateYearsPerDegree;
    YearMonth ratePerDegree =
        (daXianPassageGong as DaXianPalaceInfo).rateYearsPerDegree;

    // 计算星体影响的时间范围（基于度数差和丁度范围）
    double startDegree = entryDegree - dingRangeDegree;
    double endDegree = entryDegree + dingRangeDegree;

    // 确保度数在宫位范围内
    startDegree = startDegree.clamp(0.0, daXianPassageGong.totalGongDegreee);
    endDegree = endDegree.clamp(0.0, daXianPassageGong.totalGongDegreee);

    // 计算相对于大限开始的时间偏移
    int startDaysOffset = (startDegree * ratePerDegree.toTotalDays()).round();
    int endDaysOffset = (endDegree * ratePerDegree.toTotalDays()).round();

    // 计算实际的开始和结束时间
    DateTime actualStartTime =
        daXianPassageGong.startTime.add(Duration(days: startDaysOffset));
    DateTime actualEndTime =
        daXianPassageGong.startTime.add(Duration(days: endDaysOffset));

    // 计算对应的年龄
    YearMonth startAge = daXianPassageGong.startAge +
        YearMonth.fromTotalDays(startDaysOffset.toInt());
    YearMonth endAge = daXianPassageGong.startAge +
        YearMonth.fromTotalDays(endDaysOffset.toInt());

    return DingStarInfluenceModel(
      influenceType: influenceType,
      star: starInfluence.star,
      location: starInfluence.location,
      entryDegree: entryDegree,
      startTime: actualStartTime,
      endTime: actualEndTime,
      startAge: startAge,
      endAge: endAge,
      degreeDiff: dingRangeDegree,
      defaultRangeDegree: dingRangeDegree,
    );
  }
}

// 辅助类
class ConstellationSegmentInPalace {
  final CelestialObject constellation;
  final double segmentStartInPalace;
  final double segmentEndInPalace;
  final double degreeStartInConstellation;
  final double degreeEndInConstellation;

  ConstellationSegmentInPalace({
    required this.constellation,
    required this.segmentStartInPalace,
    required this.segmentEndInPalace,
    required this.degreeStartInConstellation,
    required this.degreeEndInConstellation,
  });

  @override
  String toString() {
    return 'ConstellationSegmentInPalace{constellation: $constellation, segmentStartInPalace: $segmentStartInPalace, segmentEndInPalace: $segmentEndInPalace, degreeStartInConstellation: $degreeStartInConstellation, degreeEndInConstellation: $degreeEndInConstellation}';
  }
}

class TimeUtils {
  static DateTime addYearMonthToDateTime(DateTime start, YearMonth duration) {
    // 最准确的方式是转换为总天数再加
    int daysToAdd = duration.toTotalDays();
    return start.add(Duration(days: daysToAdd));
  }

  static DateTime addDecimalYearsToDateTime(DateTime start, double years) {
    int daysToAdd = (years * YearMonth.avgDaysInYear).round();
    return start.add(Duration(days: daysToAdd));
  }

  static YearMonth addDecimalYearsToYearMonth(YearMonth start, double years) {
    int daysToAdd = (years * YearMonth.avgDaysInYear).round();
    return start.addDays(daysToAdd);
  }
}

