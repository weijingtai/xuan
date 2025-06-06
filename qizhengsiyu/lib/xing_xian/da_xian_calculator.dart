// --- (假设之前的 ZhouTianCalculator 和其数据结构已存在) ---
// --- (假设 YearMonth, CelestialObject 等辅助类已存在) ---

import 'dart:math';

import 'package:common/enums.dart';
import 'package:common/module.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/managers/zhou_tian_model_manager.dart';

import '../enums/enum_panel_system_type.dart';
import '../enums/enum_twelve_gong.dart';
import '../managers/zhou_tian_calculator.dart';
import '../models/zhou_tian_model.dart';
import 'da_xian_constellation_passage_info.dart';
import 'da_xian_palace_info.dart';
import 'gong_constellation_mapping.dart';

class DongWeiDaXianCalculator {
  final ZhouTianModel zhouTianModel;
  // final Map<EnumTwelveGong, CelestialObject> palacesStaticInfo;
  // final Map<Enum28Constellations, CelestialObject> constellationsStaticInfo;
  final DateTime birthTime;
  final List<EnumTwelveGong> daxianPalaceOrder;
  final Map<EnumTwelveGong, YearMonth> daxianPalaceDurations; // 改为YearMonth

  final int totalDegreesInt;
  // 判断是否为逆行（这里需要根据实际的逆行判断逻辑）
  bool isRetrograde = true;

  DongWeiDaXianCalculator({
    required this.zhouTianModel,
    required this.birthTime,
    required this.daxianPalaceOrder,
    required this.daxianPalaceDurations, // 现在接受YearMonth类型
    this.isRetrograde = true,
  }) : totalDegreesInt =
            (zhouTianModel.totalDegree * ZhouTianCalculator.DEGREE_MULTIPLIER)
                .round();
  // 在 DongWeiDaXianCalculator 类中添加修正后的方法
  /// 基于已有的宫位星宿映射结果计算大限
  /// [mapping] 来自 ZhouTianCalculator.mapConstellationsToPalaces() 的结果
  List<DaXianPalaceInfo> calculateDaXian(
      List<ConstellationMappingResult> mapping,
      Map<EnumTwelveGong, CelestialObject> palacesStaticInfo) {
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
      ));

      currentEventTime = daxianEndTime;
      currentEventAge = daxianEndAge;
    }

    return results;
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

// 用于大限计算的星宿段信息
class ConstellationSegmentForDaXian {
  final Enum28Constellations constellation;
  final double segmentStartInPalace;
  final double segmentEndInPalace;
  final double degreeStartInConstellation;
  final double degreeEndInConstellation;
  final double segmentLengthDeg;

  ConstellationSegmentForDaXian({
    required this.constellation,
    required this.segmentStartInPalace,
    required this.segmentEndInPalace,
    required this.degreeStartInConstellation,
    required this.degreeEndInConstellation,
    required this.segmentLengthDeg,
  });

  @override
  String toString() {
    return 'ConstellationSegmentForDaXian{constellation: $constellation, segmentStartInPalace: $segmentStartInPalace, segmentEndInPalace: $segmentEndInPalace, degreeStartInConstellation: $degreeStartInConstellation, degreeEndInConstellation: $degreeEndInConstellation, segmentLengthDeg: $segmentLengthDeg}';
  }
}
