import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';

/// 三传计算策略接口
///
/// 九宗门策略的抽象基类,每个宗门对应一个策略实现
abstract class ThreeChuanStrategy {
  /// 策略名称(对应九宗门名称)
  String get name;

  /// 计算三传
  ///
  /// [dayJiaZi] 日柱干支
  /// [fourClass] 已计算的四课
  /// [gongMapper] 宫位映射
  /// Returns: 三传结果,如果当前策略不适用则返回null
  ThreeChuan? calculate(
    JiaZi dayJiaZi,
    FourClass fourClass,
    Map<DiZhi, DaLiuRenGong> gongMapper,
  );

  /// 验证策略是否适用
  ///
  /// 子类可以重写此方法实现快速判断
  /// Returns: true表示适用, false表示不适用
  bool isApplicable(JiaZi dayJiaZi, FourClass fourClass) {
    return true;
  }
}
