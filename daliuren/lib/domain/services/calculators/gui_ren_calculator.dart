import 'package:common/enums.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:tuple/tuple.dart';
import 'base_calculator.dart';

/// 贵人计算器
///
/// 负责计算贵人位置和十二神将排列
class GuiRenCalculator extends BaseCalculator {
  @override
  String get name => 'GuiRenCalculator';

  /// 白天的时辰(卯、辰、巳、午、未、申)
  static const List<DiZhi> DAY_CHEN = [
    DiZhi.MAO,
    DiZhi.CHEN,
    DiZhi.SI,
    DiZhi.WU,
    DiZhi.WEI,
    DiZhi.SHEN,
  ];

  /// 昼夜贵人映射表
  ///
  /// 口诀: "甲戊庚牛羊、乙己鼠猴乡、丙丁猪鸡位、壬癸兔蛇藏、六辛逢马虎"
  /// - item1: 昼贵人地支
  /// - item2: 夜贵人地支
  static final Map<TianGan, Tuple2<DiZhi, DiZhi>> dayNightGuiRenMapper = {
    TianGan.JIA: const Tuple2<DiZhi, DiZhi>(DiZhi.CHOU, DiZhi.WEI), // 甲 → 牛羊(丑未)
    TianGan.WU: const Tuple2<DiZhi, DiZhi>(DiZhi.CHOU, DiZhi.WEI), // 戊 → 牛羊(丑未)
    TianGan.GENG: const Tuple2<DiZhi, DiZhi>(DiZhi.CHOU, DiZhi.WEI), // 庚 → 牛羊(丑未)
    TianGan.YI: const Tuple2<DiZhi, DiZhi>(DiZhi.ZI, DiZhi.SHEN), // 乙 → 鼠猴(子申)
    TianGan.JI: const Tuple2<DiZhi, DiZhi>(DiZhi.ZI, DiZhi.SHEN), // 己 → 鼠猴(子申)
    TianGan.BING: const Tuple2<DiZhi, DiZhi>(DiZhi.HAI, DiZhi.YOU), // 丙 → 猪鸡(亥酉)
    TianGan.DING: const Tuple2<DiZhi, DiZhi>(DiZhi.HAI, DiZhi.YOU), // 丁 → 猪鸡(亥酉)
    TianGan.REN: const Tuple2<DiZhi, DiZhi>(DiZhi.SI, DiZhi.MAO), // 壬 → 蛇兔(巳卯)
    TianGan.GUI: const Tuple2<DiZhi, DiZhi>(DiZhi.SI, DiZhi.MAO), // 癸 → 蛇兔(巳卯)
    TianGan.XIN: const Tuple2<DiZhi, DiZhi>(DiZhi.WU, DiZhi.YIN), // 辛 → 马虎(午寅)
  };

  /// 计算贵人位置
  ///
  /// 根据日干和时辰判断昼贵人或夜贵人的地支位置
  ///
  /// [dayJiaZi] 日柱干支
  /// [timeJiaZi] 时柱干支
  /// Returns: Tuple2<是否为昼贵人, 贵人地支位置>
  ///   - item1: true表示昼贵人, false表示夜贵人
  ///   - item2: 贵人所在的地支位置
  ///
  /// Example:
  /// ```dart
  /// final result = calculator.calculateGuiRenLocation(
  ///   JiaZi.JIA_ZI,  // 甲子日
  ///   JiaZi.WU_WU    // 午时
  /// );
  /// // 甲戊庚牛羊: 甲日昼贵人在丑
  /// // result: (true, DiZhi.CHOU)
  /// ```
  Tuple2<bool, DiZhi> calculateGuiRenLocation(
    JiaZi dayJiaZi,
    JiaZi timeJiaZi,
  ) {
    try {
      // 判断是否为白天时辰
      final isDay = DAY_CHEN.contains(timeJiaZi.diZhi);

      // 根据日干和昼夜获取贵人地支
      final guiRenTuple = dayNightGuiRenMapper[dayJiaZi.tianGan]!;
      final locationDiZhi = isDay ? guiRenTuple.item1 : guiRenTuple.item2;

      return Tuple2(isDay, locationDiZhi);
    } catch (e) {
      throw Exception('Failed to calculate GuiRen location: $e');
    }
  }

  /// 计算十二神将映射
  ///
  /// 根据贵人位置和天地盘确定十二神将的排列
  ///
  /// 排列规则:
  /// - 贵人落地盘巳-戌(巳、午、未、申、酉、戌)为顺排
  /// - 贵人落地盘亥-辰(亥、子、丑、寅、卯、辰)为逆排
  ///
  /// 十二神将: 贵人、腾蛇、朱雀、六合、勾陈、青龙、天空、白虎、太常、玄武、太阴、天后
  ///
  /// [timeDiZhi] 时辰地支
  /// [tianDiPanMapper] 天地盘映射
  /// [guiRenDiZhi] 贵人地支位置
  /// Returns: 神将映射 Map<地盘地支, 神将>
  Map<DiZhi, GuiRen> calculateGodsMapper(
    DiZhi timeDiZhi,
    Map<DiZhi, DiZhi> tianDiPanMapper,
    DiZhi guiRenDiZhi,
  ) {
    try {
      // 将天地盘映射反转: Map<天盘地支, 地盘地支>
      final skyAsKey = tianDiPanMapper.map((k, v) => MapEntry(v, k));

      // 天盘的顺序
      final skySeq = skyAsKey.values.toList();

      // 以贵人地支为起点调整天盘序列
      final tianSeq4Gods = _changeDiZhiSeq(guiRenDiZhi, skySeq);

      // 根据贵人天盘落宫,找到对应的地盘位置
      final diPanLuoGong = skyAsKey[tianSeq4Gods.first]!;

      // 以地盘落宫为起点调整地盘序列
      final diSeq4Gods = _changeDiZhiSeq(diPanLuoGong, skySeq);

      // 判断是否为逆时针排列神将
      // 贵人随天盘转,但顺逆排是根据贵人天盘落宫对应的地盘
      final isAntiClockwiseGodsSeq = [
        DiZhi.SI,
        DiZhi.WU,
        DiZhi.WEI,
        DiZhi.SHEN,
        DiZhi.YOU,
        DiZhi.XU,
      ].contains(diPanLuoGong);

      if (isAntiClockwiseGodsSeq) {
        // 逆时针排列
        return Map<DiZhi, GuiRen>.fromIterables(
          diSeq4Gods,
          GuiRen.antiClockwiseList,
        );
      } else {
        // 顺时针排列
        return Map<DiZhi, GuiRen>.fromIterables(
          diSeq4Gods,
          GuiRen.clockwiseList,
        );
      }
    } catch (e) {
      throw Exception('Failed to calculate Gods mapper: $e');
    }
  }

  /// 改变地支序列的起始位置
  ///
  /// 将指定地支作为序列的第一个元素,后续元素顺序保持
  ///
  /// [start] 起始地支
  /// [originalSeq] 原始地支序列
  /// [isReversed] 是否反转序列
  /// Returns: 调整后的地支序列
  List<DiZhi> _changeDiZhiSeq(
    DiZhi start,
    List<DiZhi> originalSeq, {
    bool isReversed = false,
  }) {
    List<DiZhi> oldList = List.from(originalSeq);

    if (isReversed) {
      oldList = oldList.reversed.toList();
    }

    final timeZhiIndex = oldList.indexOf(start);
    final newDiZhiList = oldList.sublist(timeZhiIndex).toList(growable: true);
    final appendedList = oldList.sublist(0, timeZhiIndex);
    newDiZhiList.addAll(appendedList);

    return newDiZhiList;
  }
}
