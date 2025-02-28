import 'package:qizhengsiyu/enums/enum_twelve_gong.dart';
import 'package:qizhengsiyu/pages/ui_star_model.dart';
import 'package:qizhengsiyu/qi_zheng_si_yu_constant_resources.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_twenty_eight_xing_xiu.dart';
import 'star_xiu_type.dart';

class QizhengsSiYuPanModel {
  /// @return
  /// tuple.item1 入宫
  /// tuple.item2 入宫度数
  static Tuple2<EnumTwelveGong, double> calculateEnterDiZhiGong(
      UIStarModel star) {
    double starAngle = star.angle;
    double enterGongAngle = starAngle.floorToDouble();
    if (enterGongAngle == 0) {
      return Tuple2(EnumTwelveGong.Xu, starAngle);
    }
    int totalPassedGong = enterGongAngle ~/ 30;
    double leftAngle = starAngle - 30 * totalPassedGong;
    return Tuple2(EnumTwelveGong.eclipticSeq[totalPassedGong], leftAngle);
  }

  /// @return
  /// tuple.item1 入宫
  /// tuple.item2 入宫度数
  static Tuple2<TwentyEightStarInn, double> calculateEnterStarInn(
      UIStarModel star,
      StarPanelType type,
      Map<TwentyEightStarInn, StarXiuType> mapper) {
    //
    double starAngle = star.angle;
    double enterGongAngle = starAngle.floorToDouble();
    // if (starAngle <= type.firstAtZeroDegree) {
    // return Tuple2(type.starInnOrder.first, 0);
    // }

    int _tmpStarAngle = ((star.angle + type.firstAtZeroDegree) * 100).floor();

    int previousAngle = _tmpStarAngle;
    for (int i = 0; i < 28; i++) {
      TwentyEightStarInn starInn = type.starInnOrder[i];
      StarXiuType starXiuType = mapper[starInn]!;
      int _angle = previousAngle - (starXiuType.totalDegree * 100).floor();
      if (_angle <= 0) {
        return Tuple2(starInn, (previousAngle * 0.01));
      }
      if (i == 27) {
        if (_angle == 0) {
          return Tuple2(type.starInnOrder.first, 0);
        }
        if (_angle > 0) {
          return Tuple2(type.starInnOrder.first, (_angle * 0.01));
        }
      }
      previousAngle = _angle;
    }

    return Tuple2(type.starInnOrder.first, 0);
  }
}
