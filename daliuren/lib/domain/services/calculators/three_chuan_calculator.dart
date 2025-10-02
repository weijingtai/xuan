import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'base_calculator.dart';

/// 三传计算器
///
/// 负责根据九宗门法推导三传(初传、中传、末传)
///
/// 九宗门依次为:
/// 1. 伏吟门
/// 2. 反吟门
/// 3. 八专门
/// 4. 贼克门(元首、蒿矢、重审)
/// 5. 比用门
/// 6. 涉害门
/// 7. 遥克门
/// 8. 别责门
/// 9. 昴星门
///
/// 计算流程: 按九宗门顺序依次判断,首个匹配的宗门确定三传
class ThreeChuanCalculator extends BaseCalculator {
  @override
  String get name => 'ThreeChuanCalculator';

  /// 计算三传
  ///
  /// 按九宗门顺序依次判断,返回首个匹配的三传结果
  ///
  /// [dayJiaZi] 日柱干支
  /// [fourClass] 已计算的四课
  /// [gongMapper] 宫位映射
  /// Returns: 三传结果
  /// Throws: Exception如果所有九宗门都无法匹配
  ///
  /// Example:
  /// ```dart
  /// final threeChuan = calculator.calculate(
  ///   JiaZi.JIA_ZI,
  ///   fourClass,
  ///   gongMapper
  /// );
  /// print(threeChuan.nineZongMenType); // 输出匹配的宗门类型
  /// ```
  ThreeChuan calculate(
    JiaZi dayJiaZi,
    FourClass fourClass,
    Map<DiZhi, DaLiuRenGong> gongMapper,
  ) {
    try {
      // 使用现有的DaLiuRenKePan静态方法进行计算
      // TODO: 未来可以逐步重构为独立的策略类
      return DaLiuRenKePan.calculateThreeChuan(
        dayJiaZi,
        fourClass,
        gongMapper,
      );
    } catch (e) {
      throw Exception('Failed to calculate ThreeChuan: $e');
    }
  }
}
