import 'package:common/model/enum_five_xing.dart';

import 'enum_qi_zheng.dart';
import 'enum_stars.dart';

enum TwentyEightStarInn {
  Lou_Jin_Gou("娄", EnumStars.Golden, "狗"), // 娄金狗
  Wei_Tu_Zhi("胃", EnumStars.Soil, "雉"), // 胃土雉
  Mao_Ri_Ji("昴", EnumStars.Sun, "鸡"), // 昴日鸡
  Bi_Yue_Wu("毕", EnumStars.Moon, "乌"), // 毕月乌
  Zi_Huo_Hou("觜", EnumStars.Fire, "猴"), // 觜火猴
  Shen_Shui_Yuan("参", EnumStars.Water, "猿"), // 参水猿
  Jing_Mu_Han("井", EnumStars.Wood, "犴"), // 井木犴

  Gui_Jin_Yang("鬼", EnumStars.Golden, "羊"), // 鬼金羊
  Liu_Tu_Zhang("柳", EnumStars.Soil, "獐"), // 柳土獐
  Xing_Ri_Ma("星", EnumStars.Sun, "马"), // 星日马
  Zhang_Yue_Lu("张", EnumStars.Moon, "鹿"), // 张月鹿
  Yi_Huo_She("翼", EnumStars.Fire, "蛇"), // 翼火蛇
  Zhen_Shui_Yin("轸", EnumStars.Water, "蚓"), // 轸水蚓

  Jiao_Mu_Jiao("角", EnumStars.Wood, "蛟"), // 角木蛟

  Kang_Jin_Long("亢", EnumStars.Golden, "龙"), // 亢金龙
  Di_Tu_Lu("氐", EnumStars.Soil, "骆"), // 氐土骆
  Fang_Ri_Tu("房", EnumStars.Sun, "兔"), // 房日兔
  Xin_Yue_Hu("心", EnumStars.Moon, "兔"), // 心月狐
  Wei_Huo_Hu("尾", EnumStars.Fire, "虎"), // 尾火虎
  Ji_Shui_Bao("箕", EnumStars.Water, "豹"), // 箕水
  Dou_Mu_Jiao("斗", EnumStars.Wood, "獬"), // 斗木獬

  Niu_Jin_Niu("牛", EnumStars.Golden, "牛"), // 牛金牛
  Nv_Tu_Fu("女", EnumStars.Soil, "蝠"), // 女土蝠
  Xu_Ri_Shu("虚", EnumStars.Sun, "鼠"), // 虚日鼠
  Wei_Yue_Yan("危", EnumStars.Moon, "燕"), // 尾月燕
  Shi_Huo_Zhu("室", EnumStars.Fire, "猪"), // 室火猪
  Bi_Shui_Yu("壁", EnumStars.Water, "貐"), // 壁水貐
  Kui_Mu_Lang("奎", EnumStars.Wood, "狼"); // 奎木狼

  final String starName;
  final EnumStars sevenZheng;
  final String animal;

  const TwentyEightStarInn(this.starName, this.sevenZheng, this.animal);
  String get fullname => "$starName${sevenZheng.name}$animal";
}
