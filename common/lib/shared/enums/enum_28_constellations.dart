import 'package:json_annotation/json_annotation.dart';

import 'enum_stars.dart';

enum Enum28Constellations {
  @JsonValue("娄")
  @JsonKey(name: "娄")
  Lou_Jin_Gou("娄", EnumStars.Venus, "狗"), // 娄金狗
  @JsonValue("胃")
  @JsonKey(name: "胃")
  Wei_Tu_Zhi("胃", EnumStars.Saturn, "雉"), // 胃土雉
  @JsonValue("昴")
  @JsonKey(name: "昴")
  Mao_Ri_Ji("昴", EnumStars.Sun, "鸡"), // 昴日鸡
  @JsonValue("毕")
  @JsonKey(name: "毕")
  Bi_Yue_Wu("毕", EnumStars.Moon, "乌"), // 毕月乌
  @JsonValue("觜")
  @JsonKey(name: "觜")
  Zi_Huo_Hou("觜", EnumStars.Mars, "猴"), // 觜火猴
  @JsonValue("参")
  @JsonKey(name: "参")
  Shen_Shui_Yuan("参", EnumStars.Mercury, "猿"), // 参水猿
  @JsonValue("井")
  @JsonKey(name: "井")
  Jing_Mu_Han("井", EnumStars.Jupiter, "犴"), // 井木犴

  @JsonValue("鬼")
  @JsonKey(name: "鬼")
  Gui_Jin_Yang("鬼", EnumStars.Venus, "羊"), // 鬼金羊
  @JsonValue("柳")
  @JsonKey(name: "柳")
  Liu_Tu_Zhang("柳", EnumStars.Saturn, "獐"), // 柳土獐
  @JsonValue("星")
  @JsonKey(name: "星")
  Xing_Ri_Ma("星", EnumStars.Sun, "马"), // 星日马
  @JsonValue("张")
  @JsonKey(name: "张")
  Zhang_Yue_Lu("张", EnumStars.Moon, "鹿"), // 张月鹿
  @JsonValue("翼")
  @JsonKey(name: "翼")
  Yi_Huo_She("翼", EnumStars.Mars, "蛇"), // 翼火蛇
  @JsonValue("轸")
  @JsonKey(name: "轸")
  Zhen_Shui_Yin("轸", EnumStars.Mercury, "蚓"), // 轸水蚓

  @JsonValue("角")
  @JsonKey(name: "角")
  Jiao_Mu_Jiao("角", EnumStars.Jupiter, "蛟"), // 角木蛟

  @JsonValue("亢")
  @JsonKey(name: "亢")
  Kang_Jin_Long("亢", EnumStars.Venus, "龙"), // 亢金龙
  @JsonValue("氐")
  @JsonKey(name: "氐")
  Di_Tu_Lu("氐", EnumStars.Saturn, "骆"), // 氐土骆
  @JsonValue("房")
  @JsonKey(name: "房")
  Fang_Ri_Tu("房", EnumStars.Sun, "兔"), // 房日兔
  @JsonValue("心")
  @JsonKey(name: "心")
  Xin_Yue_Hu("心", EnumStars.Moon, "兔"), // 心月狐
  @JsonValue("尾")
  @JsonKey(name: "尾")
  Wei_Huo_Hu("尾", EnumStars.Mars, "虎"), // 尾火虎
  @JsonValue("箕")
  @JsonKey(name: "箕")
  Ji_Shui_Bao("箕", EnumStars.Mercury, "豹"), // 箕水
  @JsonValue("斗")
  @JsonKey(name: "斗")
  Dou_Mu_Xie("斗", EnumStars.Jupiter, "獬"), // 斗木獬

  @JsonValue("牛")
  @JsonKey(name: "牛")
  Niu_Jin_Niu("牛", EnumStars.Venus, "牛"), // 牛金牛
  @JsonValue("女")
  @JsonKey(name: "女")
  Nv_Tu_Fu("女", EnumStars.Saturn, "蝠"), // 女土蝠
  @JsonValue("虚")
  @JsonKey(name: "虚")
  Xu_Ri_Shu("虚", EnumStars.Sun, "鼠"), // 虚日鼠
  @JsonValue("危")
  @JsonKey(name: "危")
  Wei_Yue_Yan("危", EnumStars.Moon, "燕"), // 尾月燕
  @JsonValue("室")
  @JsonKey(name: "室")
  Shi_Huo_Zhu("室", EnumStars.Mars, "猪"), // 室火猪
  @JsonValue("壁")
  @JsonKey(name: "壁")
  Bi_Shui_Yu("壁", EnumStars.Mercury, "貐"), // 壁水貐
  @JsonValue("奎")
  @JsonKey(name: "奎")
  Kui_Mu_Lang("奎", EnumStars.Jupiter, "狼"); // 奎木狼

  final String starName;
  final EnumStars sevenZheng;
  final String animal;

  const Enum28Constellations(this.starName, this.sevenZheng, this.animal);
  String get fullname => "$starName${sevenZheng.singleName}$animal";
  String get name => starName;

  static Enum28Constellations fromStarName(String starName) {
    return Enum28Constellations.values
        .firstWhere((element) => element.starName == starName);
  }
}
