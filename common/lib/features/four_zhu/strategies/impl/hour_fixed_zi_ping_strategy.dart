import 'package:common/enums/enum_jia_zi.dart';
import 'package:common/features/four_zhu/strategies/hour_pillar_strategy.dart';

import '../../../../enums.dart';

/// 子平传统派：固定子段“地支为子/丑”，天干按序相续
/// 23:00–00:00 固定为“N子”；00:00–01:00 固定为“(N+1)丑”
/// 其中 N 为按常规（如五鼠遁或既定映射）得到的天干序上的当前值
class HourFixedZiPingStrategy implements HourPillarStrategy {
  const HourFixedZiPingStrategy();

  @override
  JiaZi decideHourPillar(DateTime dt, JiaZi dayPillar) {
    final h = dt.hour;
    // 计算出“子时”的天干 N（基于日干五鼠遁起点），然后输出 N子；
    // “丑时”的天干为 N 的下一个天干（循环），输出 (N+1)丑
    // 为方便实现，复用 hour five-mouse 的起点，但仅取天干并替换地支
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
    // 子时对应起算序列的 index 0；丑时为 index 1
    final seq = _take12(start);
    if (h == 23) {
      final gan = seq[0].tianGan; // N
      return _compose(gan, DiZhi.ZI);
    } else if (h == 0) {
      final gan = seq[1].tianGan; // N+1
      return _compose(gan, DiZhi.CHOU);
    }
    // 非子时段：不应走到此策略，保守回退为以当前时段的 12 序
    final idx = ((h + 1) ~/ 2) % 12;
    final gan = seq[idx].tianGan;
    final zhi = _hourIndexToZhi(idx);
    return _compose(gan, zhi);
  }

  List<JiaZi> _take12(JiaZi start) {
    var seq = JiaZi.listAll.sublist(start.index);
    if (seq.length < 12) seq = [...seq, ...JiaZi.listAll];
    return seq.sublist(0, 12);
  }

  JiaZi _compose(TianGan gan, DiZhi zhi) {
    // 在 60 甲子中查找与目标干支一致的一项
    return JiaZi.listAll
        .firstWhere((jz) => jz.tianGan == gan && jz.diZhi == zhi);
  }

  DiZhi _hourIndexToZhi(int idx) {
    const order = [
      DiZhi.ZI,
      DiZhi.CHOU,
      DiZhi.YIN,
      DiZhi.MAO,
      DiZhi.CHEN,
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU,
      DiZhi.HAI,
    ];
    return order[idx % 12];
  }
}
