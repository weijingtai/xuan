import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/four_class.dart';
import 'base_calculator.dart';

/// 四课计算器
///
/// 负责计算大六壬的四课(日课、日神课、支课、支神课)
///
/// 四课是大六壬占卜的核心计算,包括:
/// - 第一课(日课): 日干寄宫的天盘地支
/// - 第二课(日神课): 第一课天盘地支对应的天盘地支
/// - 第三课(支课): 日支对应的天盘地支
/// - 第四课(支神课): 第三课天盘地支对应的天盘地支
class FourClassCalculator extends BaseCalculator {
  @override
  String get name => 'FourClassCalculator';

  /// 计算四课
  ///
  /// 使用FourClass.fastGenerate方法快速生成四课
  ///
  /// [dayJiaZi] 日柱干支
  /// [gongMapper] 宫位映射
  /// Returns: 四课结果
  ///
  /// 四课特殊格局判断:
  /// - 伏吟: 天盘与地盘相同(如寅上寅、申上申)
  /// - 反吟: 天盘与地盘相冲(如寅上申、申上寅)
  /// - 别责: 四课中有重复,实际只有三课或两课
  ///
  /// Example:
  /// ```dart
  /// final fourClass = calculator.calculate(JiaZi.JIA_ZI, gongMapper);
  /// print(fourClass.isFuYin);  // 是否伏吟
  /// print(fourClass.isFanYin); // 是否反吟
  /// ```
  FourClass calculate(
    JiaZi dayJiaZi,
    Map<DiZhi, DaLiuRenGong> gongMapper,
  ) {
    try {
      return FourClass.fastGenerate(
        dayGanZhi: dayJiaZi,
        eachGongMapper: gongMapper,
      );
    } catch (e) {
      throw Exception('Failed to calculate FourClass: $e');
    }
  }
}
