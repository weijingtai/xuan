import 'dart:math';

import 'package:common/enums.dart';

import '../enums/enum_twelve_gong.dart';
import '../models/zhou_tian_model.dart';
import '../xing_xian/gong_constellation_mapping.dart';

// --- 计算逻辑 ---
class ZhouTianCalculator {
  // --- 工具函数 ---
  static const double EPSILON_RAW = 1e-6; // 用于原始浮点数比较
  static const int DEGREE_MULTIPLIER = 1000; // 用于将度数转为整数计算
  static const double EPSILON_INT = 0.1; // 用于整数比较 (相当于原始的 0.001 度)
  static const double EPSILON_INT_COMPARISON_THRESHOLD =
      0.5; // 用于整数比较时的容错 (0.5 / MULTIPLIER)

  final ZhouTianModel zhouTianModel;
  final int totalDegreesInt;

  ZhouTianCalculator({required this.zhouTianModel})
      : totalDegreesInt =
            (zhouTianModel.totalDegree * DEGREE_MULTIPLIER).round();
// 规范化角度到 [0, TOTAL_CELESTIAL_DEGREES_INT)
  static int normalizeAngleInt(int angle, int totalDegreesInt) {
    int normalized = angle % totalDegreesInt;
    return normalized < 0 ? normalized + totalDegreesInt : normalized;
  }

// 规范化角度到 [0, TOTAL_CELESTIAL_DEGREES)
  static double normalizeAngle(double angle, double totalDegrees) {
    double normalized = angle % totalDegrees;
    return normalized < 0 ? normalized + totalDegrees : normalized;
  }

  Map<EnumTwelveGong, CelestialObject<EnumTwelveGong>>
      _calculatePalaceAngles() {
    final List<EnumTwelveGong> palaceOrder = zhouTianModel.gongOrder;
    if (palaceOrder.isEmpty) throw ArgumentError("宫位顺序列表 (gongOrder) 不能为空");

    final Map<EnumTwelveGong, int> palaceWidthsInt = {};
    if (zhouTianModel.gongDegreeSeq.isNotEmpty &&
        zhouTianModel.gongDegreeSeq.length == palaceOrder.length) {
      for (int i = 0; i < palaceOrder.length; i++) {
        palaceWidthsInt[palaceOrder[i]] =
            (zhouTianModel.gongDegreeSeq[i].degree * DEGREE_MULTIPLIER).round();
      }
    } else {
      print("警告: gongDegreeSeq 提供不完整或为空，假设为等宫制。");
      int defaultPalaceWidthInt =
          (totalDegreesInt / palaceOrder.length).round();
      for (var gong in palaceOrder) {
        palaceWidthsInt[gong] = defaultPalaceWidthInt;
      }
    }

    final EnumTwelveGong alignmentGongName =
        zhouTianModel.alignmentPointAtGong.gong;
    final int palaceAlignmentOffsetInt =
        (zhouTianModel.alignmentPointAtGong.degree * DEGREE_MULTIPLIER).round();
    final int celestialZeroPointInt = 0; // 天文0点

    Map<EnumTwelveGong, CelestialObject<EnumTwelveGong>> palaceAngles = {};
    // 起始宫的连续绝对起始点 (可能为负或大于totalDegreesInt)
    int currentPalaceabsStartInt =
        celestialZeroPointInt - palaceAlignmentOffsetInt;

    int alignmentGongIndex = palaceOrder.indexOf(alignmentGongName);
    if (alignmentGongIndex == -1) {
      throw ArgumentError("对齐宫位 ${alignmentGongName.name} 不在 gongOrder 中。");
    }

    for (int i = 0; i < palaceOrder.length; i++) {
      int effectiveIndex = (alignmentGongIndex + i) % palaceOrder.length;
      EnumTwelveGong pName = palaceOrder[effectiveIndex];
      int pWidthInt = palaceWidthsInt[pName]!;

      int pabsEndInt = currentPalaceabsStartInt + pWidthInt;

      palaceAngles[pName] = CelestialObject<EnumTwelveGong>(
          pName, // 直接使用枚举值而不是name
          currentPalaceabsStartInt / DEGREE_MULTIPLIER,
          pabsEndInt / DEGREE_MULTIPLIER,
          pWidthInt / DEGREE_MULTIPLIER);
      currentPalaceabsStartInt = pabsEndInt;
    }
    return palaceAngles;
  }

  Map<Enum28Constellations, CelestialObject<Enum28Constellations>>
      _calculateConstellationAngles() {
    final List<Enum28Constellations> constellationOrder =
        zhouTianModel.starInnOrder;
    if (constellationOrder.isEmpty)
      throw ArgumentError("星宿顺序列表 (starInnOrder) 不能为空");

    final Map<Enum28Constellations, int> constellationWidthsInt = {};
    if (zhouTianModel.starInnDegreeSeq.isNotEmpty &&
        zhouTianModel.starInnDegreeSeq.length == constellationOrder.length) {
      for (int i = 0; i < constellationOrder.length; i++) {
        // 假设starInnDegreeSeq与starInnOrder顺序对应
        constellationWidthsInt[constellationOrder[i]] =
            (zhouTianModel.starInnDegreeSeq[i].degree * DEGREE_MULTIPLIER)
                .round();
      }
    } else {
      throw ArgumentError("starInnDegreeSeq 提供不完整或与 starInnOrder 不匹配。");
    }

    final Enum28Constellations alignmentConstellationName =
        zhouTianModel.alignmentPointAtConstellation.constellation;
    final int constellationAlignmentOffsetInt =
        (zhouTianModel.alignmentPointAtConstellation.degree * DEGREE_MULTIPLIER)
            .round();
    final int celestialZeroPointInt = 0;

    Map<Enum28Constellations, CelestialObject<Enum28Constellations>>
        constellationAngles = {};
    // 起始星宿的连续绝对起始点
    int currentConstellationabsStartInt =
        celestialZeroPointInt - constellationAlignmentOffsetInt;

    int alignmentConstellationIndex =
        constellationOrder.indexOf(alignmentConstellationName);
    if (alignmentConstellationIndex == -1) {
      throw ArgumentError(
          "对齐星宿 ${alignmentConstellationName.name} 不在 starInnOrder 中。");
    }

    for (int i = 0; i < constellationOrder.length; i++) {
      int effectiveIndex =
          (alignmentConstellationIndex + i) % constellationOrder.length;
      Enum28Constellations cName = constellationOrder[effectiveIndex];
      int cWidthInt = constellationWidthsInt[cName]!;

      int cabsEndInt = currentConstellationabsStartInt + cWidthInt;

      constellationAngles[cName] = CelestialObject<Enum28Constellations>(
          cName, // 直接使用枚举值而不是name
          currentConstellationabsStartInt / DEGREE_MULTIPLIER,
          cabsEndInt / DEGREE_MULTIPLIER,
          cWidthInt / DEGREE_MULTIPLIER);
      currentConstellationabsStartInt = cabsEndInt;
    }
    return constellationAngles;
  }

  List<ConstellationMappingResult> mapConstellationsToPalaces() {
    final Map<EnumTwelveGong, CelestialObject<EnumTwelveGong>> palacesData =
        _calculatePalaceAngles();
    final Map<Enum28Constellations, CelestialObject<Enum28Constellations>>
        constellationsData = _calculateConstellationAngles();

    List<ConstellationMappingResult> results = [];

    List<CelestialObject<EnumTwelveGong>> sortedPalaces =
        palacesData.values.toList();
    // 排序时使用规范化后的起始点，以确保正确的查找顺序
    sortedPalaces.sort((a, b) => normalizeAngle(
            a.absStartContinuous, zhouTianModel.totalDegree)
        .compareTo(
            normalizeAngle(b.absStartContinuous, zhouTianModel.totalDegree)));

    for (Enum28Constellations cName in zhouTianModel.starInnOrder) {
      CelestialObject<Enum28Constellations> constellation =
          constellationsData[cName]!;

      // 将星宿的原始double值转为整数进行计算
      int constellationStartContInt =
          (constellation.absStartContinuous * DEGREE_MULTIPLIER).round();
      int constellationWidthInt =
          (constellation.width * DEGREE_MULTIPLIER).round();
      int constellationEndContInt =
          constellationStartContInt + constellationWidthInt;

      List<ConstellationSegment> segments = [];
      int constellationProcessedDegreesInt = 0; // 这是相对于星宿自身0度的已处理部分
      int currentAbsPosOverallInt = constellationStartContInt; // 当前处理的连续绝对位置

      while (constellationProcessedDegreesInt <
          constellationWidthInt - EPSILON_INT_COMPARISON_THRESHOLD.round()) {
        int currentAbsPosInCycleInt =
            normalizeAngleInt(currentAbsPosOverallInt, totalDegreesInt);

        CelestialObject? currentPalaceFound;
        for (CelestialObject p in sortedPalaces) {
          int pStartContInt =
              (p.absStartContinuous * DEGREE_MULTIPLIER).round();
          int pEndContInt = (p.absEndContinuous * DEGREE_MULTIPLIER)
              .round(); // p.absStart + p.width

          // 关键：我们需要找到一个宫位 P，使得 currentAbsPosOverallInt 落在 P 的 [P_start_cont, P_end_cont) 区间内
          // 为了正确处理跨越多个周天的情况，我们需要找到宫位在 currentAbsPosOverallInt 附近的那个“实例”
          int pStartEffective = pStartContInt;
          while (pStartEffective + (p.width * DEGREE_MULTIPLIER).round() <=
              currentAbsPosOverallInt -
                  EPSILON_INT_COMPARISON_THRESHOLD.round()) {
            pStartEffective += totalDegreesInt;
          }
          while (pStartEffective >
              currentAbsPosOverallInt +
                  EPSILON_INT_COMPARISON_THRESHOLD.round()) {
            pStartEffective -= totalDegreesInt;
          }
          int pEndEffective =
              pStartEffective + (p.width * DEGREE_MULTIPLIER).round();

          if (currentAbsPosOverallInt >=
                  pStartEffective - EPSILON_INT_COMPARISON_THRESHOLD.round() &&
              currentAbsPosOverallInt <
                  pEndEffective - EPSILON_INT_COMPARISON_THRESHOLD.round()) {
            currentPalaceFound = p; // p 存储的是原始的double值对象
            break;
          }
        }

        if (currentPalaceFound == null) {
          throw Exception(
              '宫位未找到! 星宿: ${constellation.name}, 当前绝对位置(int): $currentAbsPosOverallInt, 规范化后: $currentAbsPosInCycleInt');
        }
        CelestialObject currentPalace = currentPalaceFound;
        int palaceStartContInt =
            (currentPalace.absStartContinuous * DEGREE_MULTIPLIER).round();
        int palaceWidthInt = (currentPalace.width * DEGREE_MULTIPLIER).round();
        int palaceEndContInt = palaceStartContInt + palaceWidthInt;

        // 找到宫位在当前绝对位置附近的那个“实例”的起始点
        int palaceStartEffectiveInt = palaceStartContInt;
        while (palaceStartEffectiveInt + palaceWidthInt <=
            currentAbsPosOverallInt -
                EPSILON_INT_COMPARISON_THRESHOLD.round()) {
          palaceStartEffectiveInt += totalDegreesInt;
        }
        while (palaceStartEffectiveInt >
            currentAbsPosOverallInt +
                EPSILON_INT_COMPARISON_THRESHOLD.round()) {
          palaceStartEffectiveInt -= totalDegreesInt;
        }
        int palaceEndEffectiveInt = palaceStartEffectiveInt + palaceWidthInt;

        // 段在宫内的起始度数 = 当前绝对位置 - 宫位有效实例的起始位置
        int segmentStartInPalaceInt =
            currentAbsPosOverallInt - palaceStartEffectiveInt;

        int remainingInConstellationInt =
            constellationWidthInt - constellationProcessedDegreesInt;
        int remainingInPalaceInt =
            palaceEndEffectiveInt - currentAbsPosOverallInt;

        int segmentLengthInt =
            min(remainingInConstellationInt, remainingInPalaceInt);

        if (segmentLengthInt < 1 && remainingInConstellationInt > 0) {
          // 避免长度为0卡死
          print(
              "警告: segmentLengthInt 为0或负 ($segmentLengthInt), 但星宿 ${constellation.name} 尚余 $remainingInConstellationInt. 强制推进1单位.");
          segmentLengthInt = 1; // 推进最小单位
          if (segmentLengthInt > remainingInConstellationInt)
            segmentLengthInt = remainingInConstellationInt;
          if (segmentLengthInt > remainingInPalaceInt)
            segmentLengthInt = remainingInPalaceInt;
        }
        if (segmentLengthInt <= 0 &&
            constellationProcessedDegreesInt >=
                constellationWidthInt -
                    EPSILON_INT_COMPARISON_THRESHOLD.round()) {
          break;
        }
        if (segmentLengthInt <= 0) {
          throw Exception(
              "错误: segmentLengthInt <= 0 ($segmentLengthInt) 在星宿 ${constellation.name} 未完成时。");
        }

        int segmentEndInConstellationInt =
            constellationProcessedDegreesInt + segmentLengthInt;
        // 段在宫内的结束度数 = 段在宫内起始 + 段长
        int segmentEndInPalaceInt = segmentStartInPalaceInt + segmentLengthInt;

        double? crossPoint = null;
        if ((palaceEndEffectiveInt - currentAbsPosOverallInt - segmentLengthInt)
                    .abs() <
                EPSILON_INT_COMPARISON_THRESHOLD.round() &&
            remainingInConstellationInt >
                segmentLengthInt + EPSILON_INT_COMPARISON_THRESHOLD.round()) {
          crossPoint = segmentEndInConstellationInt / DEGREE_MULTIPLIER;
        }

        // 在创建ConstellationSegment时使用枚举值
        segments.add(ConstellationSegment(
          palaceName: currentPalace.name, // 现在是EnumTwelveGong类型
          startInPalaceDeg: segmentStartInPalaceInt / DEGREE_MULTIPLIER,
          endInPalaceDeg: segmentEndInPalaceInt / DEGREE_MULTIPLIER,
          startInConstellationDeg:
              constellationProcessedDegreesInt / DEGREE_MULTIPLIER,
          endInConstellationDeg:
              segmentEndInConstellationInt / DEGREE_MULTIPLIER,
          segmentLengthDeg: segmentLengthInt / DEGREE_MULTIPLIER,
          crossesPalaceAtConstellationDeg: crossPoint,
        ));

        constellationProcessedDegreesInt +=
            segmentLengthInt; // 正确累加相对于星宿自身的已处理度数
        currentAbsPosOverallInt += segmentLengthInt;
      }
      results.add(ConstellationMappingResult(
        constellationName: constellation.name, // 现在是Enum28Constellations类型
        absStartDeg: normalizeAngle(
            constellation.absStartContinuous, zhouTianModel.totalDegree),
        absEndDeg: normalizeAngle(
            constellation.absEndContinuous, zhouTianModel.totalDegree),
        totalWidthDeg: constellation.width,
        segments: segments,
      ));
    }
    return results;
  }
}
