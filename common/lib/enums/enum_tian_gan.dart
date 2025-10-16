import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

import 'enum_five_xing.dart'; // Assuming you have the FiveXing enum in a separate file
import 'enum_five_xing_relationship.dart';
import 'enum_ten_gods.dart';
import 'enum_yin_yang.dart'; // Assuming you have the YinYang enum in a separate file

enum TianGan {
  @JsonValue("甲")
  JIA("甲", "乾"),
  @JsonValue("乙")
  YI("乙", "坤"),
  @JsonValue("丙")
  BING("丙", "艮"),
  @JsonValue("丁")
  DING("丁", "兑"),
  @JsonValue("戊")
  WU("戊", "坎"),
  @JsonValue("己")
  JI("己", "离"),
  @JsonValue("庚")
  GENG("庚", "震"),
  @JsonValue("辛")
  XIN("辛", "巽"),
  @JsonValue("壬")
  REN("壬", "乾"),
  @JsonValue("癸")
  GUI("癸", "坤"),
  @JsonValue("空亡")
  KONG_WANG("空亡", "无");

  final String value;
  final String naJiaGua;
  const TianGan(this.value, this.naJiaGua);
  String get name => value;
  bool get isThreeQi =>
      [TianGan.YI, TianGan, TianGan.BING, TianGan.DING].contains(this);
  bool get isSixQi => [
        TianGan.WU,
        TianGan.JI,
        TianGan.GENG,
        TianGan.XIN,
        TianGan.REN,
        TianGan.GUI
      ].contains(this);

  static TianGan? getFromValue(String value) {
    for (var element in TianGan.values) {
      if (element.value == value) {
        return element;
      }
    }
    return null;
  }

  TianGan getFiveTiger() {
    /// 五虎遁
    /// 甲己之年丙作首，乙庚之岁戊为头。丙辛必定寻庚起，丁壬壬位顺行流。
    /// 更有戊癸何方觅，甲寅之上好追求。
    switch (this) {
      case TianGan.JIA:
      case TianGan.JI:
        return TianGan.BING;
      case TianGan.YI:
      case TianGan.GENG:
        return TianGan.WU;
      case TianGan.BING:
      case TianGan.XIN:
        return TianGan.GENG;
      case TianGan.DING:
      case TianGan.REN:
        return TianGan.REN;
      case TianGan.WU:
      case TianGan.GUI:
        return TianGan.JIA;
      default:
        throw Exception("五虎不存在");
    }
  }

  FiveXing get fiveXing {
    switch (this) {
      case TianGan.JIA:
      case TianGan.YI:
        return FiveXing.MU;
      case TianGan.BING:
      case TianGan.DING:
        return FiveXing.HUO;
      case TianGan.WU:
      case TianGan.JI:
        return FiveXing.TU;
      case TianGan.GENG:
      case TianGan.XIN:
        return FiveXing.JIN;
      case TianGan.REN:
      case TianGan.GUI:
        return FiveXing.SHUI;
      case TianGan.KONG_WANG:
        return FiveXing.TU;
    }
  }

  bool get isYang {
    return yinYang == YinYang.YANG;
  }

  bool get isYin {
    return yinYang == YinYang.YIN;
  }

  YinYang get yinYang {
    if (['甲', '丙', '戊', '庚', '壬'].contains(value)) {
      return YinYang.YANG;
    } else {
      return YinYang.YIN;
    }
  }

  TianGan getOtherTianGanFiveCombine() {
    /// 返回天干五合中的另一天干

    switch (this) {
      case TianGan.JIA: // 甲
        return TianGan.JI; // 己
      case TianGan.JI:
        return TianGan.JIA;
      case TianGan.YI: // 乙
        return TianGan.GENG; // 庚
      case TianGan.GENG:
        return TianGan.YI;
      case TianGan.BING:
        return TianGan.XIN;
      case TianGan.XIN:
        return TianGan.BING;

      case TianGan.WU:
        return TianGan.GUI;
      case TianGan.GUI:
        return TianGan.WU;
      case TianGan.DING:
        return TianGan.REN;
      case TianGan.REN:
        return TianGan.DING;
      case TianGan.KONG_WANG:
        throw Exception("空亡没有天干五合");
    }
  }

  bool isChong(TianGan other) {
    // 甲庚冲、乙辛冲、丙壬冲、丁癸冲
    var test = {this, other};
    if ({JIA, GENG}.containsAll(test)) {
      return true;
    } else if ({YI, XIN}.containsAll(test)) {
      return true;
    } else if ({BING, REN}.containsAll(test)) {
      return true;
    } else if ({DING, GUI}.containsAll(test)) {
      return true;
    }
    return false;
  }

  (FiveXing, YinYang) get yinYangFiveXing {
    return (fiveXing, yinYang);
  }

  static List<TianGan> get listAll {
    return [JIA, YI, BING, DING, WU, JI, GENG, XIN, REN, GUI];
  }

  EnumTenGods getTenGods(TianGan dayMaster) {
    final relationship =
        FiveXingRelationship.checkRelationship(dayMaster.fiveXing, fiveXing);
    final samePolarity = dayMaster.yinYang == yinYang;

    switch (relationship) {
      case FiveXingRelationship.TONG: // Same element
        return samePolarity ? EnumTenGods.BiJian : EnumTenGods.JieCai;
      case FiveXingRelationship.XIE: // Day master produces other
        return samePolarity ? EnumTenGods.ShiShen : EnumTenGods.ShangGuan;
      case FiveXingRelationship.HAO: // Day master controls other
        return samePolarity ? EnumTenGods.PanCai : EnumTenGods.ZhenCai;
      case FiveXingRelationship.KE: // Day master is controlled by other
        return samePolarity ? EnumTenGods.PanGuan : EnumTenGods.ZhengGuan;
      case FiveXingRelationship.SHENG: // Day master is produced by other
        return samePolarity ? EnumTenGods.PanYin : EnumTenGods.ZhengYin;
      default:
        throw Exception("Unknown relationship for Ten Gods calculation");
    }
  }
}

enum TianGanFiveCombine {
  /// tuple中的第一个元素是阳天干，第二个元素是阴天干
  JIA_JI(combine: Tuple2(TianGan.BING, TianGan.JI), fiveXing: FiveXing.TU),
  GENG_YI(combine: Tuple2(TianGan.GENG, TianGan.JI), fiveXing: FiveXing.JIN),
  BING_XIN(combine: Tuple2(TianGan.BING, TianGan.XIN), fiveXing: FiveXing.SHUI),
  WU_GUI(combine: Tuple2(TianGan.WU, TianGan.GUI), fiveXing: FiveXing.HUO),
  REN_DING(combine: Tuple2(TianGan.REN, TianGan.DING), fiveXing: FiveXing.MU);

  final Tuple2<TianGan, TianGan> combine;
  final FiveXing fiveXing;
  const TianGanFiveCombine({
    required this.combine,
    required this.fiveXing,
  });
  static Tuple2<TianGanFiveCombine, TianGan> getFiveCombineWithOtherTianGan(
      TianGan tianGan) {
    /// tuple.item2 为另一个天干
    TianGanFiveCombine combine = getFiveCombineByTianGan(tianGan);
    if (tianGan.yinYang == YinYang.YANG) {
      return Tuple2(combine, combine.combine.item2);
    } else {
      return Tuple2(combine, combine.combine.item1);
    }
  }

  static TianGan getOtherGan(TianGan tianGan) {
    /// tuple.item2 为另一个天干
    TianGanFiveCombine combine = getFiveCombineByTianGan(tianGan);
    return combine.combine.item1 == tianGan
        ? combine.combine.item2
        : combine.combine.item1;
  }

  static TianGanFiveCombine getFiveCombineByTianGan(TianGan tianGan) {
    switch (tianGan) {
      case TianGan.JIA:
      case TianGan.JI:
        return TianGanFiveCombine.JIA_JI;
      case TianGan.YI:
      case TianGan.GENG:
        return TianGanFiveCombine.GENG_YI;
      case TianGan.BING:
      case TianGan.XIN:
        return TianGanFiveCombine.BING_XIN;
      case TianGan.WU:
      case TianGan.GUI:
        return TianGanFiveCombine.WU_GUI;
      case TianGan.DING:
      case TianGan.REN:
        return TianGanFiveCombine.REN_DING;
      case TianGan.KONG_WANG:
        throw Exception("空亡没有天干五合");
    }
  }

  static TianGanFiveCombine getFiveCombineByFiveXing(FiveXing fiveXing) {
    switch (fiveXing) {
      case FiveXing.MU:
        return TianGanFiveCombine.REN_DING;
      case FiveXing.HUO:
        return TianGanFiveCombine.WU_GUI;
      case FiveXing.TU:
        return TianGanFiveCombine.JIA_JI;
      case FiveXing.JIN:
        return TianGanFiveCombine.GENG_YI;
      case FiveXing.SHUI:
        return TianGanFiveCombine.BING_XIN;
    }
  }

  static TianGanFiveCombine? getFiveCombine(
      TianGan tianGan1, TianGan tianGan2) {
    /// 返回null时表示两者不存在五合的情况
    // 天干五合都为阴阳之合，如果两个天干阴阳相同，一定不是
    if (tianGan1.yinYang == tianGan2.yinYang) {
      return null;
    }
    // 获取两个参数中的阳天干
    TianGan yangTianGan =
        tianGan1.yinYang == YinYang.YANG ? tianGan1 : tianGan2;
    TianGan yinTianGan = tianGan1.yinYang == YinYang.YIN ? tianGan1 : tianGan2;
    // 使用阳天干获取“五合”
    TianGanFiveCombine combine = getFiveCombineByTianGan(yangTianGan);
    // 使用combine.item2 也就是阴天干，与参数中的另一个阴天干比较，如果是同一个则是五合
    return combine.combine.item2 == yinTianGan ? combine : null;
  }

  static bool isCombine(TianGan tianGan1, TianGan tianGan2) {
    // 天干五合都为阴阳之合，如果两个天干阴阳相同，一定不是
    if (tianGan1.yinYang == tianGan2.yinYang) {
      return false;
    }
    // 获取两个参数中的阳天干
    TianGan yangTianGan =
        tianGan1.yinYang == YinYang.YANG ? tianGan1 : tianGan2;
    TianGan yinTianGan = tianGan1.yinYang == YinYang.YIN ? tianGan1 : tianGan2;
    // 使用阳天干获取“五合”
    TianGanFiveCombine combine = getFiveCombineByTianGan(yangTianGan);
    // 使用combine.item2 也就是阴天干，与参数中的另一个阴天干比较，如果是同一个则是五合
    return combine.combine.item2 == yinTianGan;
  }
}
