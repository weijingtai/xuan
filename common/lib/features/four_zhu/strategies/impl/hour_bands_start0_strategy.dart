import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/features/four_zhu/strategies/hour_pillar_strategy.dart';

/// 整日两小时一支：
/// - 子时: 0:00–1:59, 丑: 2:00–3:59, ..., 亥: 22:00–23:59
/// - 天干依“五鼠遁”由“用于时柱的日干”起算
class HourBandsStart0Strategy implements HourPillarStrategy {
  const HourBandsStart0Strategy();

  @override
  JiaZi decideHourPillar(DateTime dt, JiaZi dayPillar) {
    final Map<TianGan, JiaZi> timeGanToStart = {
      TianGan.JIA: JiaZi.JIA_ZI,
      TianGan.JI: JiaZi.JIA_ZI,
      TianGan.YI: JiaZi.BING_ZI,
      TianGan.GENG: JiaZi.BING_ZI,
      TianGan.BING: JiaZi.WU_ZI,
      TianGan.XIN: JiaZi.WU_ZI,
      TianGan.DING: JiaZi.GENG_ZI,
      TianGan.REN: JiaZi.WU_ZI,
      TianGan.WU: JiaZi.REN_ZI,
      TianGan.GUI: JiaZi.REN_ZI,
    };

    final start = timeGanToStart[dayPillar.tianGan]!;
    // 0..23 -> 0..11 bands with 0:00-1:59 => 0
    final int hour = dt.hour;
    final int branchIndex = (hour ~/ 2) % 12; // 0,1=>0(子), 2,3=>1(丑), ... 22,23=>11(亥)

    var seq = JiaZi.listAll.sublist(start.index);
    if (seq.length < 12) {
      seq = [...seq, ...JiaZi.listAll];
    }
    final twelve = seq.sublist(0, 12);
    return twelve[branchIndex];
  }
}

