import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';

/// 决定时柱干支的策略
abstract class HourPillarStrategy {
  /// 基于时间与“生效日柱”决定时柱干支
  /// dayPillar 为根据日界线策略得到的当日/次日的“日柱”
  JiaZi decideHourPillar(DateTime dt, JiaZi dayPillar);
}
