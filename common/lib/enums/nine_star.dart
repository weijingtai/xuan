import 'enum_five_xing.dart';
import 'enum_hou_tian_gua.dart';

/// 九星枚举
/// 对应三元九运中的九颗星，每一运对应一颗星
enum NineStarEnum {
  /// 一白贪狼星（水）
  first(
    number: 1,
    houTianGua: HouTianGua.Kan,
    colorName: '白',
    dunJiaName: "天蓬",
    godName: "太一",
    fiveXing: FiveXing.SHUI,
    ephemerisName: '天枢',
    xuanKongName: '贪狼',
  ),

  /// 二黑巨门星（土）
  second(
    number: 2,
    houTianGua: HouTianGua.Kun,
    colorName: '黑',
    dunJiaName: "天芮",
    godName: "摄提",
    fiveXing: FiveXing.TU,
    ephemerisName: '天璇',
    xuanKongName: '巨门',
  ),

  /// 三碧禄存星（木）
  third(
    number: 3,
    houTianGua: HouTianGua.Zhen,
    colorName: '碧',
    dunJiaName: "天冲",
    godName: "轩辕",
    fiveXing: FiveXing.MU,
    ephemerisName: '天玑',
    xuanKongName: '禄存',
  ),

  /// 四绿文曲星（木）
  fourth(
    number: 4,
    houTianGua: HouTianGua.Xun,
    colorName: '绿',
    dunJiaName: "天辅",
    godName: "招摇",
    fiveXing: FiveXing.MU,
    ephemerisName: '天权',
    xuanKongName: '文曲',
  ),

  /// 五黄廉贞星（土）
  fifth(
    number: 5,
    houTianGua: HouTianGua.Li, // 注意：五宫在中央，但对应离卦
    colorName: '黄',
    dunJiaName: "天禽",
    godName: "天符",
    fiveXing: FiveXing.TU,
    ephemerisName: '玉衡',
    xuanKongName: '廉贞',
  ),

  /// 六白武曲星（金）
  sixth(
    number: 6,
    houTianGua: HouTianGua.Qian,
    colorName: '白', // 注意：这里是白色，不是玄色
    dunJiaName: "天心",
    godName: "青龙",
    fiveXing: FiveXing.JIN,
    ephemerisName: '开阳',
    xuanKongName: '武曲',
  ),

  /// 七赤破军星（金）
  seventh(
    number: 7,
    houTianGua: HouTianGua.Dui,
    colorName: '赤',
    dunJiaName: "天柱",
    godName: "咸池",
    fiveXing: FiveXing.JIN,
    ephemerisName: '摇光',
    xuanKongName: '破军',
  ),

  /// 八白左辅星（土）
  eighth(
    number: 8,
    houTianGua: HouTianGua.Gen,
    colorName: '白',
    dunJiaName: "天任",
    godName: "太阴",
    fiveXing: FiveXing.TU,
    ephemerisName: '招摇',
    xuanKongName: '左辅',
  ),

  /// 九紫右弼星（火）
  ninth(
    number: 9,
    houTianGua: HouTianGua.Li,
    colorName: '紫',
    dunJiaName: "天英",
    godName: "太一",
    fiveXing: FiveXing.HUO,
    ephemerisName: '玄戈',
    xuanKongName: '右弼',
  );

  const NineStarEnum({
    required this.number,
    required this.houTianGua,
    required this.colorName,
    required this.dunJiaName,
    required this.godName,
    required this.fiveXing,
    required this.ephemerisName,
    required this.xuanKongName,
  });

  /// 运数（1-9）
  final int number;

  /// 后天八卦
  final HouTianGua houTianGua;

  /// 颜色名称
  final String colorName;

  /// 遁甲名称
  final String dunJiaName;

  /// 九宫神名
  final String godName;

  /// 五行属性
  final FiveXing fiveXing;

  /// 星历名称（北斗七星+招摇、玄戈）
  final String ephemerisName;

  /// 玄空名称
  final String xuanKongName;

  /// 获取五行字符串
  String get element => fiveXing.name;

  /// 获取完整描述
  String get fullDescription => '$name（$element）';

  /// 根据运数获取对应的九星
  static NineStarEnum? fromNumber(int number) {
    try {
      return NineStarEnum.values.firstWhere((star) => star.number == number);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有九星的映射表
  static Map<int, String> get starMap {
    return {
      for (var star in NineStarEnum.values) star.number: star.fullDescription
    };
  }

  /// 根据五行属性获取对应的九星列表
  static List<NineStarEnum> getStarsByElement(FiveXing element) {
    return NineStarEnum.values
        .where((star) => star.fiveXing == element)
        .toList();
  }

  /// 根据颜色获取对应的九星列表
  static List<NineStarEnum> getStarsByColor(String color) {
    return NineStarEnum.values
        .where((star) => star.colorName == color)
        .toList();
  }

  /// 根据遁甲名称获取九星
  static NineStarEnum? fromDunJiaName(String dunJiaName) {
    try {
      return NineStarEnum.values
          .firstWhere((star) => star.dunJiaName == dunJiaName);
    } catch (e) {
      return null;
    }
  }

  /// 根据玄空名称获取九星
  static NineStarEnum? fromXuanKongName(String xuanKongName) {
    try {
      return NineStarEnum.values
          .firstWhere((star) => star.xuanKongName == xuanKongName);
    } catch (e) {
      return null;
    }
  }
}
