import 'package:common/enums.dart';
import 'package:tiebanshenshu/constant/constants.dart' as constants;
import 'package:tiebanshenshu/features/six_yao_gua/enum_6_shou.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/features/six_yao_gua/six_yao_calculator.dart';

/// PureSixYaoGua 扩展：装天干、装地支、装六兽、装六亲、装世应爻
///
/// 约定：
/// - yaoList 的存储顺序为“下→上”（初→上），因此所有装配方法均以“下→上”写入。
/// - 需要“上→下”计算的映射，统一在写入前反转为“下→上”。
extension PureSixYaoGuaExtension on PureSixYaoGua {
  /// 装天干（初→上）。
  /// - yearGan 为空时使用固定纳甲方案；
  /// - yearGan 非空时按年干阴阳切换纳甲方案。
  /// 返回自身以便链式调用。
  PureSixYaoGua zhuangTianGan({TianGan? yearGan}) {
    final List<TianGan> topBottomGan = yearGan != null
        ? SixYaoCalculator.najiaGanZhuangGuaByYearGan(gua, yearGan)
        : SixYaoCalculator.najiaGanZhuangGua(gua);
    final List<TianGan> bottomTopGan = topBottomGan.reversed.toList();

    for (int i = 0; i < yaoList.length && i < bottomTopGan.length; i++) {
      yaoList[i].naJia = bottomTopGan[i];
    }
    return this;
  }

  /// 装地支（初→上）。
  /// 使用双经卦“上→下”的纳支映射，写入前反转为“初→上”。
  /// 返回自身以便链式调用。
  PureSixYaoGua zhuangDiZhi() {
    final List<DiZhi> topBottomZhi = SixYaoCalculator.najiaZhuangGua(gua);
    final List<DiZhi> bottomTopZhi = topBottomZhi.reversed.toList();

    for (int i = 0; i < yaoList.length && i < bottomTopZhi.length; i++) {
      yaoList[i].naZhi = bottomTopZhi[i];
    }
    return this;
  }

  /// 装六兽（初→上）。
  /// - 依据日干 dayGan 计算六兽排位，按“初→上”写入。
  /// 返回自身以便链式调用。
  PureSixYaoGua zhuangLiuShou(TianGan dayGan) {
    final sixShouBottomTop = SixYaoCalculator.sixShouByTianGan(dayGan);
    for (int i = 0; i < yaoList.length && i < sixShouBottomTop.length; i++) {
      yaoList[i].sixShou = sixShouBottomTop[i];
    }
    return this;
  }

  /// 装六亲（初→上）。
  /// - 依据所属宫五行与各爻地支五行进行比对，按“初→上”写入。
  /// - 若当前爻尚未装地支，将使用双经卦纳支结果作为回填，并同步写入地支。
  /// 返回自身以便链式调用。
  PureSixYaoGua zhuangLiuQin() {
    final Enum8Gua gong = SixYaoCalculator.getGuagongByBenname(gua);
    final FiveXing selfFiveXing = gong.toHouTianGua().fiveXing;
    final Map<FiveXing, LiuQin> mapper4Self =
        constants.fiveXingSixQingMapper[selfFiveXing]!;

    // 预备“下→上”的地支回填列表
    final List<DiZhi> fallbackBottomTopZhi = SixYaoCalculator.najiaZhuangGua(
      gua,
    ).reversed.toList();

    for (int i = 0; i < yaoList.length; i++) {
      final DiZhi? currentZhi = yaoList[i].naZhi;
      final DiZhi effectiveZhi = currentZhi ?? fallbackBottomTopZhi[i];
      // 若未装地支则回填
      if (currentZhi == null) {
        yaoList[i].naZhi = effectiveZhi;
      }
      // 写入六亲
      yaoList[i].liuQin = mapper4Self[effectiveZhi.fiveXing]!;
    }
    return this;
  }

  /// 装世应爻（初→上）。
  /// - 根据八宫序确定世应位置，写入标记。
  /// 返回自身以便链式调用。
  PureSixYaoGua zhuangShiYing() {
    SixYaoCalculator.markShiYaoAndYingYao(this);
    return this;
  }
}
