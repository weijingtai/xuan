import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/enums/enum_tian_gan.dart';
import 'package:common/features/four_zhu/strategies/hour_pillar_strategy.dart';

/// 五鼠遁：依据“采用的日干”起时干
class HourFiveMouseDunStrategy implements HourPillarStrategy {
  const HourFiveMouseDunStrategy();

  @override
  JiaZi decideHourPillar(DateTime dt, JiaZi dayPillar) {
    // 复用 eight_chars_input_card.dart 中 timeGanToStart 的逻辑映射
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
    // 将 12 地支子、丑、... 对应到两个小时段，这里简化为：
    // 计算当前时辰 index（0..11），然后从起始干支顺推 index 得到结果
    final int hour = dt.hour; // 0..23
    final int branchIndex = ((hour + 1) ~/ 2) % 12; // 子时=23..0→index 0，丑时=1..2→index 1 ...

    // 从 60 甲子列表中截取 12 连续项，并取 branchIndex
    var seq = JiaZi.listAll.sublist(start.index);
    if (seq.length < 12) {
      seq = [...seq, ...JiaZi.listAll];
    }
    final twelve = seq.sublist(0, 12);
    return twelve[branchIndex];
  }
}
