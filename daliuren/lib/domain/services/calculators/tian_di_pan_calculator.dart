import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'base_calculator.dart';

/// 天地盘计算器
///
/// 负责生成天地盘映射和宫位映射
class TianDiPanCalculator extends BaseCalculator {
  @override
  String get name => 'TianDiPanCalculator';

  /// 生成天地盘映射
  ///
  /// 天地盘计算规则: 以月将加时辰,顺时针布局
  /// - 地盘: 十二地支固定排列(子丑寅卯辰巳午未申酉戌亥)
  /// - 天盘: 根据时辰和月将旋转生成
  ///
  /// [timeZhi] 时辰地支
  /// [monthGeneral] 月将
  /// Returns: 天地盘映射 Map<地盘地支, 天盘地支>
  ///
  /// Example:
  /// ```dart
  /// final mapper = calculator.generateTianDiPanMapper(
  ///   DiZhi.ZI,
  ///   MonthGeneral.ZI_SHEN_HOU
  /// );
  /// ```
  Map<DiZhi, DiZhi> generateTianDiPanMapper(
    DiZhi timeZhi,
    MonthGeneral monthGeneral,
  ) {
    try {
      final diZhiList = DiZhi.listAll;

      // 以时辰为起点调整地支序列
      final diSeq = _changeDiZhiSeq(timeZhi, diZhiList);

      // 以月将为起点调整地支序列
      final monthGeneralSeq = _changeDiZhiSeq(monthGeneral.generalZhi, diZhiList);

      // 地盘与天盘对应映射
      return Map<DiZhi, DiZhi>.fromIterables(diSeq, monthGeneralSeq);
    } catch (e) {
      throw Exception('Failed to generate TianDiPan mapper: $e');
    }
  }

  /// 生成宫位映射
  ///
  /// 为每个地支宫位生成完整的宫位信息(天盘、地盘、神将、天干、甲子)
  ///
  /// [tianDiPanMapper] 天地盘映射
  /// [godsMapper] 十二神将映射
  /// [dayJiaZi] 日柱干支
  /// Returns: 宫位映射 Map<地盘地支, DaLiuRenGong>
  Map<DiZhi, DaLiuRenGong> generateGongMapper(
    Map<DiZhi, DiZhi> tianDiPanMapper,
    Map<DiZhi, GuiRen> godsMapper,
    JiaZi dayJiaZi,
  ) {
    try {
      // 获取当前旬的旬首
      final dayXunHeader = dayJiaZi.getXunHeader();

      // 获取当前旬的十甲子干支
      final currentJiaZiXunList = JiaZi.getTenXunByXunHeader(dayXunHeader);

      // 将旬内干支按地支为Key转为Map
      final tmpMapper = <DiZhi, JiaZi>{};
      for (var jiaZi in currentJiaZiXunList) {
        tmpMapper[jiaZi.diZhi] = jiaZi;
      }

      // 为每个地支生成宫位信息
      final gongMapper = <DiZhi, DaLiuRenGong>{};
      for (var diZhi in DiZhi.listAll) {
        final skyDiZhi = tianDiPanMapper[diZhi]!;
        gongMapper[diZhi] = DaLiuRenGong(
          skyPanDiZhi: skyDiZhi,
          groundPanDiZhi: diZhi,
          guiRen: godsMapper[diZhi]!,
          tianGan: tmpMapper[skyDiZhi]?.tianGan,
          jiaZi: tmpMapper[diZhi],
        );
      }

      return gongMapper;
    } catch (e) {
      throw Exception('Failed to generate Gong mapper: $e');
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
  ///
  /// Example:
  /// ```dart
  /// // 原序列: [子, 丑, 寅, 卯, 辰, 巳, 午, 未, 申, 酉, 戌, 亥]
  /// // 以寅为起点: [寅, 卯, 辰, 巳, 午, 未, 申, 酉, 戌, 亥, 子, 丑]
  /// final newSeq = _changeDiZhiSeq(DiZhi.YIN, DiZhi.listAll);
  /// ```
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
