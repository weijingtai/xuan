import 'package:common/enums.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:qizhengsiyu/models/star_enter_info.dart';
import 'package:qizhengsiyu/xing_xian/base_xian_palace.dart';

import '../enums/enum_twelve_gong.dart';
import '../enums/enum_xing_xian_type.dart';
import 'package:common/models/year_month.dart';
import '../models/zhou_tian_model.dart';
import 'da_xian_palace_info.dart';
import 'da_xian_constellation_passage_info.dart';
import 'fei_xian_detail_palace.dart';
import 'base_xian_calculator.dart';
import 'star_influence_model.dart';

enum FeiXianGongType {
  @JsonValue("本宫")
  current,
  @JsonValue("对宫")
  opposite,
  @JsonValue("阳三合")
  yang_triangle,
  @JsonValue("阴三合")
  yin_triangle,
}

class FeiXianPalace {
  int order;

  YearMonth durationYears;
  EnumTwelveGong palace;
  EnumDestinyTwelveGong destinyPalace;
  List<FeiXianDetailPalace> orderedPalaces;

  FeiXianPalace({
    required this.order,
    required this.durationYears,
    required this.palace,
    required this.destinyPalace,
    required this.orderedPalaces,
  });
}

/// 洞微飞限计算器
class FeiXianCalculator extends BaseXianCalculator {
  FeiXianCalculator({
    required super.zhouTianModel,
    required super.basePanel,
    required super.observerPosition,
    required super.daxianPalaceOrder,
    required super.daxianPalaceDurations,
    super.isRetrograde = true,
    super.luoRangeDegree = 1.0,
    super.dingRangeDegree = 1.0,
  });

  List<FeiXianDetailPalace> calculateEach(BaseXianPalace daXianPalace) {
    EnumTwelveGong currentGong = daXianPalace.palace;
    bool isYangGong = _isYangGong(currentGong); // 阳宫顺取三合，阴宫逆取三合
    List<DiZhi> sanHeDiZhiList = isYangGong
        ? DiZhiSanHe.getBySingleDiZhi(currentGong.zhi)!.getOrderedSeq()
        : DiZhiSanHe.getBySingleDiZhi(currentGong.zhi)!.getReversedSeq();
    // remove currentGong
    sanHeDiZhiList.remove(currentGong.zhi);
    // 取前两个
    FeiXianGongType triangleType = isYangGong
        ? FeiXianGongType.yang_triangle
        : FeiXianGongType.yin_triangle;

    DateTime startTime = daXianPalace.startTime;
    YearMonth startAge = daXianPalace.startAge;

    // 本宫2年
    YearMonth currentDuration = YearMonth.fromYear(2);
    YearMonth oppositeDuration = YearMonth.fromYear(2);
    YearMonth triangleDuration = YearMonth.oneYear();

    int pointer = 0; // 0为本宫，1为对宫，2为三合宫第一，3为三合宫第二
    YearMonth _tmp = daXianPalace.durationYears;
    List<FeiXianDetailPalace> result = [];
    YearMonth _tmpDuration = oppositeDuration;
    double totalGongDegree = daXianPalace.totalGongDegreee;
    while (_tmp.year > 0 || _tmp.month > 0) {
      var feiGongPalace;
      var _tmpFeiGongPointer = pointer % 4;
      EnumTwelveGong currentPalace;

      if (_tmpFeiGongPointer == 0) {
        _tmpDuration = currentDuration;
        if (_tmp.toTotalMonths() < currentDuration.toTotalMonths()) {
          _tmpDuration = YearMonth.fromMonths(_tmp.toTotalMonths());
        }
        currentPalace = currentGong;

        // 计算新增字段
        List<DaXianConstellationPassageInfo> constellationPassages =
            _calculateConstellationPassages(
                currentPalace, startTime, _tmpDuration);
        StarGongInfluence? starGongInfluence = calculateStarInfluences(
          targetPalace: currentPalace,
          starsEnterInfo: starsEnterInfo,
        );
        // Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper =
        //     _calculateDingStarMapper(
        //         currentPalace, starGongInfluence, startTime, _tmpDuration);

        feiGongPalace = FeiXianDetailPalace(
          order: pointer,
          palace: currentPalace,
          startAge: startAge,
          endAge: startAge + _tmpDuration,
          startTime: startTime,
          durationYears: _tmpDuration,
          feiXianGongType: FeiXianGongType.current,
          endTime: startTime.add(Duration(hours: _tmpDuration.toDaysInHour())),
          constellationPassages: constellationPassages,
          totalGongDegreee: totalGongDegree,
          // dingStarMapper: dingStarMapper,
        );
      } else if (_tmpFeiGongPointer == 1) {
        _tmpDuration = oppositeDuration;
        if (_tmp.toTotalMonths() < oppositeDuration.toTotalMonths()) {
          _tmpDuration = YearMonth.fromMonths(_tmp.toTotalMonths());
        }
        currentPalace = currentGong.opposite;

        // 计算新增字段
        List<DaXianConstellationPassageInfo> constellationPassages =
            _calculateConstellationPassages(
                currentPalace, startTime, _tmpDuration);
        // double totalGongDegree = daXianPalace.totalGongDegreee;
        StarGongInfluence? starGongInfluence = calculateStarInfluences(
          targetPalace: currentPalace,
          starsEnterInfo: starsEnterInfo,
        );
        // Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper =
        //     _calculateDingStarMapper(
        //         currentPalace, starGongInfluence, startTime, _tmpDuration);

        feiGongPalace = FeiXianDetailPalace(
          order: pointer,
          palace: currentPalace,
          startAge: startAge,
          endAge: startAge + _tmpDuration,
          startTime: startTime,
          durationYears: _tmpDuration,
          feiXianGongType: FeiXianGongType.opposite,
          endTime: startTime.add(Duration(hours: _tmpDuration.toDaysInHour())),
          constellationPassages: constellationPassages,
          totalGongDegreee: totalGongDegree,
          // dingStarMapper: dingStarMapper,
        );
      } else if (_tmpFeiGongPointer == 2) {
        _tmpDuration = triangleDuration;
        if (_tmp.year < 1 && _tmp.month > 0) {
          _tmpDuration = YearMonth.fromMonths(_tmp.month);
        }
        currentPalace =
            EnumTwelveGong.getEnumTwelveGongByZhi(sanHeDiZhiList.first);

        // 计算新增字段
        List<DaXianConstellationPassageInfo> constellationPassages =
            _calculateConstellationPassages(
                currentPalace, startTime, _tmpDuration);
        // double totalGongDegree = daXianPalace.totalGongDegreee;
        StarGongInfluence? starGongInfluence = calculateStarInfluences(
          targetPalace: currentPalace,
          starsEnterInfo: starsEnterInfo,
        );
        feiGongPalace = FeiXianDetailPalace(
          order: pointer,
          palace: currentPalace,
          startAge: startAge,
          endAge: startAge + _tmpDuration,
          startTime: startTime,
          durationYears: _tmpDuration,
          feiXianGongType: triangleType,
          triangleIndex: 0,
          endTime: startTime.add(Duration(hours: _tmpDuration.toDaysInHour())),
          constellationPassages: constellationPassages,
          totalGongDegreee: totalGongDegree,
          // dingStarMapper: dingStarMapper,
        );
      } else {
        _tmpDuration = triangleDuration;
        if (_tmp.year < 1 && _tmp.month > 0) {
          _tmpDuration = YearMonth.fromMonths(_tmp.month);
        }
        currentPalace =
            EnumTwelveGong.getEnumTwelveGongByZhi(sanHeDiZhiList.last);

        // 计算新增字段
        List<DaXianConstellationPassageInfo> constellationPassages =
            _calculateConstellationPassages(
                currentPalace, startTime, _tmpDuration);
        // double totalGongDegree = daXianPalace.totalGongDegreee;
        StarGongInfluence? starGongInfluence = calculateStarInfluences(
          targetPalace: currentPalace,
          starsEnterInfo: starsEnterInfo,
        );

        // Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper =
        //     calculateDingStar(
        //         currentPalace, starGongInfluence, startTime, _tmpDuration);

        feiGongPalace = FeiXianDetailPalace(
          order: pointer,
          palace: currentPalace,
          startAge: startAge,
          endAge: startAge + _tmpDuration,
          startTime: startTime,
          durationYears: _tmpDuration,
          feiXianGongType: triangleType,
          triangleIndex: 1,
          endTime: startTime.add(Duration(hours: _tmpDuration.toDaysInHour())),
          constellationPassages: constellationPassages,
          totalGongDegreee: totalGongDegree,
          // dingStarMapper: dingStarMapper,
        );
        // Map<EnumInfluenceType, List<DingStarInfluenceModel>>? dingStarMapper =
        //     calculateDingStar(feiGongPalace);
        // feiGongPalace.dingStarMapper = dingStarMapper;
      }
      startTime = feiGongPalace.endTime;
      startAge = feiGongPalace.endAge;
      result.add(feiGongPalace);
      _tmp = _tmp - feiGongPalace.durationYears;
      pointer++;
    }

    return result;
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
    // daXianPassageGong.totalGongDegreee / daXianPassageGong.durationYears;

    YearMonth ratePerDegree = YearMonth.fromTotalDays(
        (daXianPassageGong.totalGongDegreee /
                daXianPassageGong.durationYears.toTotalDays())
            .round());
    // (daXianPassageGong as DaXianPalaceInfo).rateYearsPerDegree;

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

  // 添加辅助计算方法
  List<DaXianConstellationPassageInfo> _calculateConstellationPassages(
      EnumTwelveGong palace, DateTime startTime, YearMonth duration) {
    // 根据宫位和时间范围计算星宿过限信息
    // 这里需要根据具体的星宿计算逻辑来实现
    return [];
  }

  // double _calculateTotalGongDegree(EnumTwelveGong palace) {
  //   // 每个宫位固定30度
  //   return 30.0;
  // }

  /// 判断宫位是否为阳宫
  bool _isYangGong(EnumTwelveGong gong) {
    return gong.yinYangGong == YinYang.YANG;
    // 阳宫：子、寅、辰、午、申、戌
  }

  /// 获取对宫
  EnumTwelveGong _getOppositeGong(EnumTwelveGong gong) {
    return gong.opposite;
  }

  /// 获取三合宫位
  List<EnumTwelveGong> _getTriangleGongs(EnumTwelveGong gong) {
    // 获取三合宫位（不包括本宫）
    List<EnumTwelveGong> triangleGongs = gong.otherTringleGongList;
    return triangleGongs;
  }

  /// 根据阴阳宫位规则获取流转顺序
  List<EnumTwelveGong> _getFlowOrder(EnumTwelveGong mingGong) {
    bool isYang = _isYangGong(mingGong);
    EnumTwelveGong oppositeGong = _getOppositeGong(mingGong);
    List<EnumTwelveGong> triangleGongs = _getTriangleGongs(mingGong);

    List<EnumTwelveGong> flowOrder = [];

    if (isYang) {
      // 阳宫：逆取三合宫位，但顺行流转
      // 命宫 -> 对宫 -> 三合宫（按顺行顺序）
      flowOrder.add(mingGong); // 命宫
      flowOrder.add(oppositeGong); // 对宫

      // 三合宫按顺行顺序添加
      // 需要根据命宫位置确定三合宫的顺行顺序
      List<EnumTwelveGong> sortedTriangleGongs =
          _sortTriangleGongsForYang(mingGong, triangleGongs);
      flowOrder.addAll(sortedTriangleGongs);
    } else {
      // 阴宫：顺取三合宫位，但逆行流转
      // 命宫 -> 对宫 -> 三合宫（按逆行顺序）
      flowOrder.add(mingGong); // 命宫
      flowOrder.add(oppositeGong); // 对宫

      // 三合宫按逆行顺序添加
      List<EnumTwelveGong> sortedTriangleGongs =
          _sortTriangleGongsForYin(mingGong, triangleGongs);
      flowOrder.addAll(sortedTriangleGongs);
    }

    return flowOrder;
  }

  /// 为阳宫排序三合宫（顺行）
  List<EnumTwelveGong> _sortTriangleGongsForYang(
      EnumTwelveGong mingGong, List<EnumTwelveGong> triangleGongs) {
    // 按照地支顺序排序，然后按顺行方向
    List<EnumTwelveGong> sorted = List.from(triangleGongs);
    sorted.sort((a, b) => a.index.compareTo(b.index));

    // 找到命宫在三合中的位置，然后按顺行顺序排列
    int mingIndex = mingGong.index;
    List<EnumTwelveGong> result = [];

    // 从命宫的下一个三合宫开始，按顺行顺序
    for (EnumTwelveGong gong in sorted) {
      if (gong.index > mingIndex) {
        result.add(gong);
      }
    }
    for (EnumTwelveGong gong in sorted) {
      if (gong.index < mingIndex) {
        result.add(gong);
      }
    }

    return result;
  }

  /// 为阴宫排序三合宫（逆行）
  List<EnumTwelveGong> _sortTriangleGongsForYin(
      EnumTwelveGong mingGong, List<EnumTwelveGong> triangleGongs) {
    // 按照地支顺序排序，然后按逆行方向
    List<EnumTwelveGong> sorted = List.from(triangleGongs);
    sorted.sort((a, b) => b.index.compareTo(a.index)); // 逆序

    // 找到命宫在三合中的位置，然后按逆行顺序排列
    int mingIndex = mingGong.index;
    List<EnumTwelveGong> result = [];

    // 从命宫的上一个三合宫开始，按逆行顺序
    for (EnumTwelveGong gong in sorted) {
      if (gong.index < mingIndex) {
        result.add(gong);
      }
    }
    for (EnumTwelveGong gong in sorted) {
      if (gong.index > mingIndex) {
        result.add(gong);
      }
    }

    return result;
  }

  /// 计算飞限宫位的星体影响
  /// 可以复用基类的 calculateStarInfluences 方法
  StarGongInfluence? calculateFeiXianStarInfluences({
    required EnumTwelveGong targetPalace,
  }) {
    return calculateStarInfluences(
      targetPalace: targetPalace,
      starsEnterInfo: starsEnterInfo,
    );
  }
}
