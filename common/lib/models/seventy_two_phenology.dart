import 'package:json_annotation/json_annotation.dart';

import 'package:common/enums.dart';

part 'seventy_two_phenology.g.dart';

@JsonSerializable()
class Phenology {
  final String name;
  final String description;
  final TwentyFourJieQi jieqi;
  final int order;

  Phenology(
      {required this.name,
      required this.jieqi,
      required this.description,
      required this.order});
  static final List<Phenology> phenologyList = [
    // 冬至
    Phenology(
        name: "蚯蚓结",
        description: "蚯蚓缩成团状",
        jieqi: TwentyFourJieQi.DONG_ZHI,
        order: 1),
    Phenology(
        name: "麋角解",
        description: "麋鹿的角开始脱落",
        jieqi: TwentyFourJieQi.DONG_ZHI,
        order: 2),
    Phenology(
        name: "水泉动",
        description: "地下水开始涌动",
        jieqi: TwentyFourJieQi.DONG_ZHI,
        order: 3),

    // 小寒
    Phenology(
        name: "雁北乡",
        description: "大雁向北飞",
        jieqi: TwentyFourJieQi.XIAO_HAN,
        order: 4),
    Phenology(
        name: "鹊始巢",
        description: "喜鹊开始筑巢",
        jieqi: TwentyFourJieQi.XIAO_HAN,
        order: 5),
    Phenology(
        name: "雉雊",
        description: "野鸡开始鸣叫",
        jieqi: TwentyFourJieQi.XIAO_HAN,
        order: 6),

    // 大寒
    Phenology(
        name: "鸡始乳",
        description: "母鸡开始孵蛋",
        jieqi: TwentyFourJieQi.DA_HAN,
        order: 7),
    Phenology(
        name: "征鸟厉疾",
        description: "候鸟飞行速度加快",
        jieqi: TwentyFourJieQi.DA_HAN,
        order: 8),
    Phenology(
        name: "水泽腹坚",
        description: "水塘结冰更加厚实",
        jieqi: TwentyFourJieQi.DA_HAN,
        order: 9),

    // 立春
    Phenology(
        name: "东风解冻",
        description: "东风开始吹拂，冰雪融化",
        jieqi: TwentyFourJieQi.LI_CHUN,
        order: 10),
    Phenology(
        name: "蛰虫始振",
        description: "冬眠的昆虫开始活动",
        jieqi: TwentyFourJieQi.LI_CHUN,
        order: 11),
    Phenology(
        name: "鱼上冰",
        description: "鱼在冰下开始活动",
        jieqi: TwentyFourJieQi.LI_CHUN,
        order: 12),

    // 雨水
    Phenology(
        name: "獭祭鱼",
        description: "水獭开始捕鱼",
        jieqi: TwentyFourJieQi.YU_SHUI,
        order: 13),
    Phenology(
        name: "候雁北",
        description: "候鸟开始北迁",
        jieqi: TwentyFourJieQi.YU_SHUI,
        order: 14),
    Phenology(
        name: "草木萌动",
        description: "植物开始发芽",
        jieqi: TwentyFourJieQi.YU_SHUI,
        order: 15),

    // 惊蛰
    Phenology(
        name: "桃始华",
        description: "桃花开始绽放",
        jieqi: TwentyFourJieQi.JING_ZHE,
        order: 16),
    Phenology(
        name: "仓庚鸣",
        description: "黄鹂鸟开始鸣叫",
        jieqi: TwentyFourJieQi.JING_ZHE,
        order: 17),
    Phenology(
        name: "鹰化为鸠",
        description: "鹰停止捕食，像鸽子一样温顺",
        jieqi: TwentyFourJieQi.JING_ZHE,
        order: 18),

    // 春分
    Phenology(
        name: "玄鸟至",
        description: "燕子从南方飞来",
        jieqi: TwentyFourJieQi.CHUN_FEN,
        order: 19),
    Phenology(
        name: "雷乃发声",
        description: "开始打雷",
        jieqi: TwentyFourJieQi.CHUN_FEN,
        order: 20),
    Phenology(
        name: "始电",
        description: "开始有闪电",
        jieqi: TwentyFourJieQi.CHUN_FEN,
        order: 21),

    // 清明
    Phenology(
        name: "桐始华",
        description: "梧桐树开始开花",
        jieqi: TwentyFourJieQi.QING_MING,
        order: 22),
    Phenology(
        name: "田鼠化为鴽",
        description: "田鼠进入休眠状态",
        jieqi: TwentyFourJieQi.QING_MING,
        order: 23),
    Phenology(
        name: "虹始见",
        description: "开始出现彩虹",
        jieqi: TwentyFourJieQi.QING_MING,
        order: 24),

    // 谷雨
    Phenology(
        name: "萍始生",
        description: "浮萍开始生长",
        jieqi: TwentyFourJieQi.GU_YU,
        order: 25),
    Phenology(
        name: "鸣鸠拂奇羽",
        description: "斑鸠开始梳理羽毛",
        jieqi: TwentyFourJieQi.GU_YU,
        order: 26),
    Phenology(
        name: "戴胜降于桑",
        description: "戴胜鸟栖息在桑树上",
        jieqi: TwentyFourJieQi.GU_YU,
        order: 27),

    // 立夏
    Phenology(
        name: "蝼蝈鸣",
        description: "蟋蟀开始鸣叫",
        jieqi: TwentyFourJieQi.LI_XIA,
        order: 28),
    Phenology(
        name: "蚯蚓出",
        description: "蚯蚓出现在地表",
        jieqi: TwentyFourJieQi.LI_XIA,
        order: 29),
    Phenology(
        name: "王瓜生",
        description: "王瓜开始生长",
        jieqi: TwentyFourJieQi.LI_XIA,
        order: 30),

    // 小满
    Phenology(
        name: "苦菜秀",
        description: "苦菜开始茂盛",
        jieqi: TwentyFourJieQi.XIAO_MAN,
        order: 31),
    Phenology(
        name: "靡草死",
        description: "靡草开始枯萎",
        jieqi: TwentyFourJieQi.XIAO_MAN,
        order: 32),
    Phenology(
        name: "麦秋至",
        description: "麦子开始成熟",
        jieqi: TwentyFourJieQi.XIAO_MAN,
        order: 33),

    // 芒种
    Phenology(
        name: "螳螂生",
        description: "螳螂开始出现",
        jieqi: TwentyFourJieQi.MANG_ZHONG,
        order: 34),
    Phenology(
        name: "鵙始鸣",
        description: "伯劳鸟开始鸣叫",
        jieqi: TwentyFourJieQi.MANG_ZHONG,
        order: 35),
    Phenology(
        name: "反舌无声",
        description: "百舌鸟停止鸣叫",
        jieqi: TwentyFourJieQi.MANG_ZHONG,
        order: 36),

    // 夏至
    Phenology(
        name: "鹿角解",
        description: "鹿角开始脱落",
        jieqi: TwentyFourJieQi.XIA_ZHI,
        order: 37),
    Phenology(
        name: "蜩始鸣",
        description: "蝉开始鸣叫",
        jieqi: TwentyFourJieQi.XIA_ZHI,
        order: 38),
    Phenology(
        name: "半夏生",
        description: "半夏草开始生长",
        jieqi: TwentyFourJieQi.XIA_ZHI,
        order: 39),

    // 小暑
    Phenology(
        name: "温风至",
        description: "开始吹温暖的风",
        jieqi: TwentyFourJieQi.XIAO_SHU,
        order: 40),
    Phenology(
        name: "蟋蟀居壁",
        description: "蟋蟀躲在墙缝中",
        jieqi: TwentyFourJieQi.XIAO_SHU,
        order: 41),
    Phenology(
        name: "鹰始挚",
        description: "鹰开始学飞",
        jieqi: TwentyFourJieQi.XIAO_SHU,
        order: 42),

    // 大暑
    Phenology(
        name: "腐草为萤",
        description: "腐烂的草化为萤火虫",
        jieqi: TwentyFourJieQi.DA_SHU,
        order: 43),
    Phenology(
        name: "土润溽暑",
        description: "土地潮湿，天气闷热",
        jieqi: TwentyFourJieQi.DA_SHU,
        order: 44),
    Phenology(
        name: "大雨时行",
        description: "常有大雨",
        jieqi: TwentyFourJieQi.DA_SHU,
        order: 45),

    // 立秋
    Phenology(
        name: "凉风至",
        description: "开始吹凉爽的风",
        jieqi: TwentyFourJieQi.LI_QIU,
        order: 46),
    Phenology(
        name: "白露降",
        description: "开始出现白露",
        jieqi: TwentyFourJieQi.LI_QIU,
        order: 47),
    Phenology(
        name: "寒蝉鸣",
        description: "寒蝉开始鸣叫",
        jieqi: TwentyFourJieQi.LI_QIU,
        order: 48),

    // 处暑
    Phenology(
        name: "鹰乃祭鸟",
        description: "鹰开始捕食小鸟",
        jieqi: TwentyFourJieQi.CHU_SHU,
        order: 49),
    Phenology(
        name: "天地始肃",
        description: "天地开始变得肃穆",
        jieqi: TwentyFourJieQi.CHU_SHU,
        order: 50),
    // 处暑
    Phenology(
        name: "禾乃登",
        description: "稻谷开始成熟",
        jieqi: TwentyFourJieQi.CHU_SHU,
        order: 51),

// 白露
    Phenology(
        name: "鸿雁来",
        description: "大雁从北方飞来",
        jieqi: TwentyFourJieQi.BAI_LU,
        order: 52),
    Phenology(
        name: "玄鸟归",
        description: "燕子开始南归",
        jieqi: TwentyFourJieQi.BAI_LU,
        order: 53),
    Phenology(
        name: "群鸟养羞",
        description: "鸟类开始贮存食物",
        jieqi: TwentyFourJieQi.BAI_LU,
        order: 54),

// 秋分
    Phenology(
        name: "雷始收声",
        description: "雷声开始减少",
        jieqi: TwentyFourJieQi.QIU_FEN,
        order: 55),
    Phenology(
        name: "蛰虫坯户",
        description: "昆虫开始寻找冬眠的地方",
        jieqi: TwentyFourJieQi.QIU_FEN,
        order: 56),
    Phenology(
        name: "水始涸",
        description: "小水洼开始干涸",
        jieqi: TwentyFourJieQi.QIU_FEN,
        order: 57),

// 寒露
    Phenology(
        name: "鸿雁来宾",
        description: "大雁排成人字形飞来",
        jieqi: TwentyFourJieQi.HAN_LU,
        order: 58),
    Phenology(
        name: "雀入大水为蛤",
        description: "麻雀进入水中变成蛤蜊（古人误解）",
        jieqi: TwentyFourJieQi.HAN_LU,
        order: 59),
    Phenology(
        name: "菊有黄华",
        description: "菊花开始开放",
        jieqi: TwentyFourJieQi.HAN_LU,
        order: 60),

// 霜降
    Phenology(
        name: "豺乃祭兽",
        description: "豺狼开始捕食动物",
        jieqi: TwentyFourJieQi.SHUANG_JIANG,
        order: 61),
    Phenology(
        name: "草木黄落",
        description: "草木开始枯黄脱落",
        jieqi: TwentyFourJieQi.SHUANG_JIANG,
        order: 62),
    Phenology(
        name: "蛰虫咸俯",
        description: "昆虫开始进入冬眠",
        jieqi: TwentyFourJieQi.SHUANG_JIANG,
        order: 63),
// 立冬
    Phenology(
        name: "水始冰",
        description: "水面开始结冰",
        jieqi: TwentyFourJieQi.LI_DONG,
        order: 64),
    Phenology(
        name: "地始冻",
        description: "地面开始冻结",
        jieqi: TwentyFourJieQi.LI_DONG,
        order: 65),
    Phenology(
        name: "雉入大水为蜃",
        description: "野鸡进入水中变成蜃（古人误解）",
        jieqi: TwentyFourJieQi.LI_DONG,
        order: 66),

// 小雪
    Phenology(
        name: "虹藏不见",
        description: "彩虹不再出现",
        jieqi: TwentyFourJieQi.XIAO_XUE,
        order: 67),
    Phenology(
        name: "天气上升地气下降",
        description: "天气变冷，地面寒气上升",
        jieqi: TwentyFourJieQi.XIAO_XUE,
        order: 68),
    Phenology(
        name: "闭塞而成冬",
        description: "万物闭藏，冬天形成",
        jieqi: TwentyFourJieQi.XIAO_XUE,
        order: 69),

// 大雪
    Phenology(
        name: "鹖鴠不鸣",
        description: "鹖鴠鸟停止鸣叫",
        jieqi: TwentyFourJieQi.DA_XUE,
        order: 70),
    Phenology(
        name: "虎始交",
        description: "老虎开始交配",
        jieqi: TwentyFourJieQi.DA_XUE,
        order: 71),
    Phenology(
        name: "荔挺出",
        description: "荔枝树开始发芽",
        jieqi: TwentyFourJieQi.DA_XUE,
        order: 72)
  ];

  Map<String, dynamic> toJson() => _$PhenologyToJson(this);
  factory Phenology.fromJson(Map<String, dynamic> json) =>
      _$PhenologyFromJson(json);
}
