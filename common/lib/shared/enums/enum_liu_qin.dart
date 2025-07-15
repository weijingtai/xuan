import 'package:json_annotation/json_annotation.dart';

import 'enum_di_zhi.dart';
import 'enum_five_xing_relationship.dart';
import 'enum_tian_gan.dart';

enum LiuQin {
  @JsonValue("己身")
  JI_SHEN("己身"),

  @JsonValue("兄弟")
  XIONG_DI("兄弟"),

  @JsonValue("父母")
  FU_MU("父母"),

  @JsonValue("妻财")
  QI_CAI("妻财"),

  @JsonValue("官鬼")
  GUAN_GUI("官鬼"),

  @JsonValue("子孙")
  ZI_SUN("子孙");

  final String name;
  const LiuQin(this.name);

  static LiuQin getLiuQinByForTianGanDiZhi(TianGan tianGan, DiZhi diZhi) {
    FiveXingRelationship fiveXing = FiveXingRelationship.checkRelationship(
        tianGan.fiveXing, diZhi.fiveXing)!;
    if (fiveXing == FiveXingRelationship.KE) {
      return LiuQin.GUAN_GUI;
    } else if (fiveXing == FiveXingRelationship.TONG) {
      return LiuQin.XIONG_DI;
    } else if (fiveXing == FiveXingRelationship.SHENG) {
      return LiuQin.FU_MU;
    } else if (fiveXing == FiveXingRelationship.XIE) {
      return LiuQin.ZI_SUN;
    } else if (fiveXing == FiveXingRelationship.HAO) {
      return LiuQin.QI_CAI;
    }
    return LiuQin.JI_SHEN;
  }

  static LiuQin getLiuQinBySingleName(String singleName) {
    switch (singleName) {
      case '兄':
      case '弟':
        return LiuQin.XIONG_DI;
      case '子':
      case '孙':
        return LiuQin.ZI_SUN;
      case '官':
      case '鬼':
        return LiuQin.GUAN_GUI;
      case '父':
      case '母':
        return LiuQin.FU_MU;
      case '妻':
      case '财':
        return LiuQin.QI_CAI;
      default:
        return LiuQin.JI_SHEN;
    }
  }
}
