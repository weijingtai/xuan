import 'package:common/enums.dart';
import 'package:tiebanshenshu/features/six_yao_gua/pure_six_yao_gua.dart';
import 'package:tiebanshenshu/constant/constants.dart' as constants;
import 'package:tiebanshenshu/features/six_yao_gua/enum_6_shou.dart';

import 'enum_8_gong_gua.dart';

/// 六爻计算器：纳支、纳甲、六亲与八宫辅助
class SixYaoCalculator {
  /// 双经卦纳支（上→下），返回6个地支汉字
  static List<DiZhi> najiaZhuangGua(Enum64Gua guaName) {
    final Map<Enum8Gua, List<DiZhi>> uponGuaMapper = {
      Enum8Gua.Qian: "戌申午"
          .split('')
          .map((e) => DiZhi.getFromValue(e)!)
          .toList(),
      Enum8Gua.Dui: "未酉亥".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Li: "巳未酉".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Zhen: "戌申午"
          .split('')
          .map((e) => DiZhi.getFromValue(e)!)
          .toList(),
      Enum8Gua.Xun: "卯巳未".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Kan: "子戌申".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Gen: "寅子戌".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Kun: "酉亥丑".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
    };

    final Map<Enum8Gua, List<DiZhi>> underGuaMapper = {
      Enum8Gua.Qian: "辰寅子"
          .split('')
          .map((e) => DiZhi.getFromValue(e)!)
          .toList(),
      Enum8Gua.Dui: "丑卯巳".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Li: "亥丑卯".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Zhen: "辰寅子"
          .split('')
          .map((e) => DiZhi.getFromValue(e)!)
          .toList(),
      Enum8Gua.Xun: "酉亥丑".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Kan: "午辰寅".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Gen: "申午辰".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
      Enum8Gua.Kun: "卯巳未".split('').map((e) => DiZhi.getFromValue(e)!).toList(),
    };

    final Enum8Gua uponGua = guaName.top;
    final Enum8Gua underGua = guaName.bottom;

    final List<DiZhi> uponZhi = uponGuaMapper[uponGua]!;
    final List<DiZhi> underZhi = underGuaMapper[underGua]!;
    return [...uponZhi, ...underZhi];
  }

  /// 双经卦纳甲（上→下），返回6个天干汉字
  static List<TianGan> najiaGanZhuangGua(Enum64Gua guaName) {
    final Map<Enum8Gua, List<TianGan>> uponGuaMapper = {
      Enum8Gua.Qian: [TianGan.REN, TianGan.REN, TianGan.REN],
      Enum8Gua.Dui: [TianGan.DING, TianGan.DING, TianGan.DING],
      Enum8Gua.Li: [TianGan.JI, TianGan.JI, TianGan.JI],
      Enum8Gua.Zhen: [TianGan.GENG, TianGan.GENG, TianGan.GENG],
      Enum8Gua.Xun: [TianGan.XIN, TianGan.XIN, TianGan.XIN],
      Enum8Gua.Kan: [TianGan.WU, TianGan.WU, TianGan.WU],
      Enum8Gua.Gen: [TianGan.BING, TianGan.BING, TianGan.BING],
      Enum8Gua.Kun: [TianGan.GUI, TianGan.GUI, TianGan.GUI],
    };

    final Map<Enum8Gua, List<TianGan>> underGuaMapper = {
      Enum8Gua.Qian: [TianGan.JIA, TianGan.JIA, TianGan.JIA],
      Enum8Gua.Dui: [TianGan.DING, TianGan.DING, TianGan.DING],
      Enum8Gua.Li: [TianGan.JI, TianGan.JI, TianGan.JI],
      Enum8Gua.Zhen: [TianGan.GENG, TianGan.GENG, TianGan.GENG],
      Enum8Gua.Xun: [TianGan.XIN, TianGan.XIN, TianGan.XIN],
      Enum8Gua.Kan: [TianGan.WU, TianGan.WU, TianGan.WU],
      Enum8Gua.Gen: [TianGan.BING, TianGan.BING, TianGan.BING],
      Enum8Gua.Kun: [TianGan.YI, TianGan.YI, TianGan.YI],
    };

    final Enum8Gua uponGua = guaName.top;
    final Enum8Gua underGua = guaName.bottom;

    final List<TianGan> uponGan = uponGuaMapper[uponGua]!;
    final List<TianGan> underGan = underGuaMapper[underGua]!;
    return [...uponGan, ...underGan];
  }

  /// 按“年干阴阳”切换纳甲方案（上→下），返回6个天干
  /// - yearYinYang 为 YinYang.YANG 时，使用 "yangGuaYaoTianGan" 映射
  /// - yearYinYang 为 YinYang.YIN 时，使用 "yinGuaYaoTianGan" 映射
  static List<TianGan> najiaGanZhuangGuaByYearYinYang(
    Enum64Gua guaName,
    YinYang yearYinYang,
  ) {
    final Enum8Gua upon = guaName.top;
    final Enum8Gua under = guaName.bottom;

    final Map<Enum8Gua, List<TianGan>> mapper = yearYinYang == YinYang.YANG
        ? constants.yangGuaYaoTianGan
        : constants.yinGuaYaoTianGan;

    final List<TianGan> uponGuaGan = mapper[upon] ?? [];
    final List<TianGan> underGuaGan = mapper[under] ?? [];

    return [...uponGuaGan, ...underGuaGan];
  }

  /// 按“年干阴阳”切换纳甲方案（上→下），返回6个天干
  /// - yearGan.isYang 为真时，使用 "yangGuaYaoTianGan" 映射
  /// - yearGan.isYang 为假时，使用 "yinGuaYaoTianGan" 映射
  static List<TianGan> najiaGanZhuangGuaByYearGan(
    Enum64Gua guaName,
    TianGan yearGan,
  ) {
    return najiaGanZhuangGuaByYearYinYang(
      guaName,
      yearGan.isYang ? YinYang.YANG : YinYang.YIN,
    );
  }

  /// 基于“年干阴阳纳甲方案”的爻位干支组合（上→下），返回6个甲子
  static List<JiaZi> composeYaoGanZhiByYearYinYang(
    Enum64Gua guaName,
    YinYang yearYinYang,
  ) {
    final ganList = najiaGanZhuangGuaByYearYinYang(guaName, yearYinYang);
    final diZhiList = najiaZhuangGua(guaName);
    if (ganList.length != 6 || diZhiList.length != 6) return [];

    return List<JiaZi>.generate(
      6,
      (i) => JiaZi.getFromGanZhiEnum(ganList[i], diZhiList[i]),
    );
  }

  /// 基于“年干阴阳纳甲方案”的爻位干支组合（上→下），返回6个甲子
  static List<JiaZi> composeYaoGanZhiByYearGan(
    Enum64Gua guaName,
    TianGan yearGan,
  ) {
    return composeYaoGanZhiByYearYinYang(
      guaName,
      yearGan.isYang ? YinYang.YANG : YinYang.YIN,
    );
  }

  /// 六兽排位（初→上），根据天干返回 6 个 Enum6Shou（下→上）
  static List<Enum6Shou> sixShouByTianGan(TianGan tianGan) {
    final mapper = constants.ganSixShouMapper[tianGan];
    if (mapper == null) {
      throw ArgumentError('无效的天干：${tianGan.name}');
    }
    return [
      mapper[EnumYaoOrder.init]!,
      mapper[EnumYaoOrder.second]!,
      mapper[EnumYaoOrder.third]!,
      mapper[EnumYaoOrder.fourth]!,
      mapper[EnumYaoOrder.fifth]!,
      mapper[EnumYaoOrder.top]!,
    ];
  }

  /// 根据卦本名确定所属宫（返回宫名汉字）
  static Enum8Gua getGuagongByBenname(Enum64Gua benGuaName) {
    for (final entry in constants.eightGongGuaListMapper.entries) {
      if (entry.value.contains(benGuaName)) {
        return entry.key; // 返回宫枚举（Enum8Gua）
      }
    }
    throw ArgumentError("找不到卦名 $benGuaName 对应的宫");
  }

  /// 六亲装卦（初→上），输入双经卦名如“乾坤”和6个干支字符串，返回枚举型六亲
  static List<LiuQin> liuqinZhuanggua(
    Enum64Gua benGua,
    List<JiaZi> yaoGanZhiListBottomTop,
  ) {
    // 解析上下卦
    // final Enum8Gua top = Enum8Gua.fromValue(doubleEightGuaName[0]);
    // final Enum8Gua bottom =
    // Enum8Gua.fromValue(doubleEightGuaName[doubleEightGuaName.length - 1]);
    // final Enum64Gua benGua = Enum64Gua.getBy8Gua(top, bottom);

    // 确定所属宫并取宫五行
    Enum8Gua? gong;
    for (final entry in constants.eightGongGuaListMapper.entries) {
      if (entry.value.contains(benGua)) {
        gong = entry.key;
        break;
      }
    }
    if (gong == null) {
      throw ArgumentError('未能确认「${benGua.fullname}」所属宫');
    }
    final FiveXing selfFiveXing = gong.toHouTianGua().fiveXing;

    final List<LiuQin> result = [];
    final Map<FiveXing, LiuQin> mapper4Self =
        constants.fiveXingSixQingMapper[selfFiveXing]!;

    // 为统一下→上（初→上）输出，若传入上→下列表则反转
    for (final gz in yaoGanZhiListBottomTop) {
      // final String zStr = gz.zhi.name; // 地支
      final DiZhi z = gz.zhi;
      final FiveXing otherFiveXing = z.fiveXing;
      result.add(mapper4Self[otherFiveXing]!);
    }

    return result;
  }

  /// 获取八宫序名（如：本卦、一世、二世...）
  static Enum8GongGuaName getEightOrderByGuaname(Enum64Gua target) {
    for (final entry in constants.eightGongGuaListMapper.entries) {
      final int index = entry.value.indexOf(target);
      if (index != -1) {
        return Enum8GongGuaName.getByOrder(index);
      }
    }
    throw Exception('「${target.fullname}」未找到该卦名在八宫的位置');
  }

  /// 获取八宫序索引（0~7）
  static int getEightOrderIndex(Enum64Gua target) {
    for (final entry in constants.eightGongGuaListMapper.entries) {
      final int index = entry.value.indexOf(target);
      if (index != -1) {
        return index;
      }
    }
    throw Exception('「${target.fullname}」未找到该卦名在八宫的位置');
  }

  /// 获取世爻（返回 EnumYaoOrder）。
  /// 注意：项目的 EnumYaoOrder.indexAtYaoList 是从下到上（0=初、5=上），
  /// 而常量 shiYao 的索引定义为从上到下（0=上、5=初）。需转换成 bottom-to-top 索引：indexBT = 5 - indexTT。
  static EnumYaoOrder getShiYaoOrder(Enum64Gua target) {
    final int orderIndex = getEightOrderIndex(target);
    final int indexTopToBottom = constants.shiYao[orderIndex];
    final int indexBottomToTop = 5 - indexTopToBottom;
    return EnumYaoOrder.fromIndex(indexBottomToTop);
  }

  /// 获取应爻（返回 EnumYaoOrder）。
  static EnumYaoOrder getYingYaoOrder(Enum64Gua target) {
    final int orderIndex = getEightOrderIndex(target);
    final int indexTopToBottom = constants.yiYao[orderIndex];
    final int indexBottomToTop = 5 - indexTopToBottom;
    return EnumYaoOrder.fromIndex(indexBottomToTop);
  }

  /// 标注世爻、应爻到给定卦的爻列表（下→上）
  /// 会将 `gua.yaoList[shi.indexAtYaoList].isShiYao` 与
  /// `gua.yaoList[ying.indexAtYaoList].isYingYao` 设为 true。
  static void markShiYaoAndYingYao(PureSixYaoGua gua) {
    final EnumYaoOrder shi = getShiYaoOrder(gua.gua);
    final EnumYaoOrder ying = getYingYaoOrder(gua.gua);
    gua.yaoList[shi.indexAtYaoList].isShiYao = true;
    gua.yaoList[ying.indexAtYaoList].isYingYao = true;
  }

  /// 组合干支列表（上→下），返回每爻对应的甲子枚举
  static List<JiaZi> composeYaoGanZhi(Enum64Gua guaName) {
    final List<TianGan> gan = najiaGanZhuangGua(guaName);
    final List<DiZhi> zhi = najiaZhuangGua(guaName);
    final List<JiaZi> res = [];
    for (int i = 0; i < 6; i++) {
      final String gzStr = '${gan[i].name}${zhi[i].name}';
      res.add(JiaZi.getFromGanZhiValue(gzStr)!);
    }
    return res;
  }
}
