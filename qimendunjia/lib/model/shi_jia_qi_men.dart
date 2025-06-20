import 'package:common/enums.dart';
import 'package:qimendunjia/arrangers/plate_arrangement_result.dart'; // Import for PlateArrangementResult
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/enums/enum_six_geng_ge_ju.dart';
import 'package:qimendunjia/model/each_gong_wang_shuai.dart';
import 'package:qimendunjia/model/pan_arrange_settings.dart';
// import 'package:qimendunjia/utils/change_sequence_utils.dart'; // No longer needed here
import 'package:tuple/tuple.dart';

import '../enums/enum_eight_door.dart';
import '../enums/enum_eight_gods.dart';
import '../enums/enum_most_popular_ge_ju.dart';
import '../enums/enum_nine_stars.dart';
import '../enums/enum_six_bing_ge_ju.dart';
import '../enums/enum_six_jia.dart';
// import '../utils/arrange_plate_utils.dart'; // No longer needed here
import '../utils/nine_yi_utils.dart';
import 'shi_jia_ju.dart';
import 'each_gong.dart';
// import 'package:qimendunjia/enums/enum_center_gong_ji_gong_type.dart'; // No longer needed here as CenterGongJiGongType moved

/// 时家奇门盘面模型。
///
/// 此类封装了一个完整的奇门遁甲盘面信息，包括时家局、排盘设置、
/// 四柱、旬空、值符值使、马星以及通过排盘器计算得到的九宫格具体信息。
class ShiJiaQiMen {
  /// 用户提问的问题字符串，可选。
  final String? question;

  /// 当前盘所依据的时家局信息。
  final ShiJiaJu shiJiaJu;

  /// 盘面常见格局列表。
  late final List<EnumMostPopularGeJu>? panGeJuList;
  /// 六庚所值时格列表。
  late final List<EnumSixGengGeJu> gengGeList;
  /// 六丙所值时格列表。
  late final List<EnumSixBingGeJu> bingGeList;

  /// 年柱干支。
  final JiaZi yearJiaZi;
  /// 年柱旬空。
  final Tuple2<DiZhi, DiZhi> yearXunKong;
  /// 月柱干支。
  final JiaZi monthJiaZi;
  /// 月柱旬空。
  final Tuple2<DiZhi, DiZhi> monthXunKong;
  /// 日柱干支。
  final JiaZi dayJiaZi;
  /// 日柱旬空。
  final Tuple2<DiZhi, DiZhi> dayXunKong;
  /// 时柱干支。
  final JiaZi timeJiaZi;
  /// 时柱旬空。
  final Tuple2<DiZhi, DiZhi> timeXunKong;

  /// 值使门。
  final EightDoorEnum zhiShiDoor;
  /// 值使门所在的宫位。
  final HouTianGua zhiShiDoorAtGong;
  /// 值符星。
  final NineStarsEnum zhiFuStar;
  /// 值符星所在的宫位（寄宫调整前）。
  final HouTianGua zhiFuStarAtGong;
  /// 当前时间所属的六甲旬首。
  final SixJia sixJiaXunHeader;
  /// 是否为六仪击刑。
  late final bool isSixJiXing; // This will be set based on gongMapper content
  /// 驿马星所在的地支。
  final DiZhi horseLocation;

  /// 四柱八字的字符串表示。
  final String eightChatStr;
  /// 值符原始宫位数 (寄宫调整前的宫位数字)。
  final int zhiFuGongNumber;
  /// 中宫的天干 (通常在转盘中为空，飞盘中可能用到)。
  final TianGan ganAtCenterGong;
  /// 值符天干。
  final TianGan zhiFuGan;

  /// 星盘是否伏吟。
  bool isStarFuYin = false;
  /// 星盘是否反吟。
  bool isStarFanYin = false;
  /// 门盘是否伏吟。
  bool isDoorFuYin = false;
  /// 门盘是否反吟。
  bool isDoorFanYin = false;
  /// 天地盘干是否伏吟。
  bool isGanFuYin = false;
  /// 天地盘干是否反吟。
  bool isGanFanYin = false;

  /// 排盘设置。
  final PanArrangeSettings settings;
  /// 盘面类型 (转盘/飞盘)。
  final PlateType plateType;

  /// 获取排盘类型（转盘/飞盘）。
  ArrangeType get arrangeType => settings.arrangeType;
  // CenterGongJiGongType get jiGong => settings.jiGong; // Removed as CenterGongJiGongType enum is moved
  /// 获取九星旺衰判断时，月令采用主气还是纳甲。
  MonthTokenTypeEnum get starMonthTokenType => settings.starMonthTokenType;
  /// 获取九星在四维宫（角宫）判断旺衰时，宫的五行取用方式。
  GongTypeEnum get starFourWeiGongType => settings.starFourWeiGongType;
  /// 获取八门在四维宫（角宫）判断旺衰时，宫的五行取用方式。
  GongTypeEnum get doorFourWeiGongType => settings.doorFourWeiGongType;
  /// 获取八神旺衰判断时，宫的五行取用方式。
  GodWithGongTypeEnum get godWithGongTypeEnum => settings.godWithGongTypeEnum;


  /// 九宫格的具体排列信息。
  final Map<HouTianGua, EachGong> gongMapper;
  /// 九宫格的旺衰分析信息。
  late final Map<HouTianGua, EachGongWangShuai> gongWangShuaiMapper;

  /// 构建一个时家奇门盘面。
  ///
  /// [plateType]: 盘面类型（转盘或飞盘）。
  /// [shiJiaJu]: 当前的时家局信息。
  /// [settings]: 排盘相关的设置。
  /// [arrangementResult]: 由排盘器计算得到的盘面排列结果。
  /// [question]: 用户提问的问题，可选。
  ShiJiaQiMen({
    required this.plateType,
    required this.shiJiaJu,
    required this.settings,
    required PlateArrangementResult arrangementResult, // New parameter
    this.question,
  }) : eightChatStr = shiJiaJu.fourZhuEightChar,
       yearJiaZi = JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[0])!,
       yearXunKong = JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[0])!.getKongWang(),
       monthJiaZi = JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[1])!,
       monthXunKong = JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[1])!.getKongWang(),
       dayJiaZi = JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[2])!,
       dayXunKong = JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[2])!.getKongWang(),
       timeJiaZi = JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[3])!,
       timeXunKong = JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[3])!.getKongWang(),
       sixJiaXunHeader = SixJia.getSixJiaByJiaZi(JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[3])!.xunHeader),
       horseLocation = DiZhiSanHe.getHorseBySingleDiZhi(JiaZi.getFromGanZhiValue(shiJiaJu.fourZhuEightChar.split(" ")[3])!.diZhi),
       // Initialize fields from arrangementResult
       gongMapper = arrangementResult.gongMapper,
       zhiShiDoor = arrangementResult.zhiShiDoor,
       zhiShiDoorAtGong = arrangementResult.zhiShiDoorAtGong,
       zhiFuStar = arrangementResult.zhiFuStar,
       zhiFuStarAtGong = arrangementResult.zhiFuStarAtGong,
       ganAtCenterGong = arrangementResult.ganAtCenterGong,
       zhiFuGan = arrangementResult.zhiFuGan,
       zhiFuGongNumber = arrangementResult.zhiFuGongNumber {

    // Check for 六仪击刑 (Six Yi Striking Punishment)
    // This needs to iterate through gongMapper, so it's done after gongMapper is set.
    bool tempIsSixJiXing = false;
    for (var gongData in gongMapper.values) {
        if (gongData.sixJiaXunHeader != null && gongData.isSixJiXing) {
            tempIsSixJiXing = true;
            break;
        }
    }
    isSixJiXing = tempIsSixJiXing;

    _checkFuFanYin(); // Call instance method
    gongWangShuaiMapper = calculateEachGongWangShuai(gongMapper);
    panGeJuList = EnumMostPopularGeJu.checkDayTimeGeJu(dayJiaZi, timeJiaZi);
    gengGeList = EnumSixGengGeJu.checkGengGeForPanel(this);
    bingGeList = EnumSixBingGeJu.checkBingGeForPanel(this);
  }

  YinYang get yinYangDun => shiJiaJu.yinYangDun;
  int get juNumber => shiJiaJu.juNumber;
  TwentyFourJieQi get jieQi => shiJiaJu.jieQiAt;
  MonthToken get monthToken => MonthToken.fromDiZhi(monthJiaZi.diZhi);
  JiaZi get xunShou => timeJiaZi.xunHeader;
  TianGan get xunHeaderTianGan => sixJiaXunHeader.gan;
  DateTime get panDateTime => shiJiaJu.panDateTime;

  // Removed calculateFeiPan, calculateZhuanPan, arrangeJu,
  // orderDiPanEightGods, orderTianPanAnGan, orderRenPanAnGan, orderYinGan,
  // generateEachGong, settleCenterGongJiGong and its deprecated variants.
  // Removed static sequence lists: zhuanPanSeq, feiPanSeq, siiYiThreeYiList.

  /// 检查盘面是否为伏吟或反吟。
  /// 此方法在构造函数中调用，用于设置相关的伏反吟标志位。
  void _checkFuFanYin() {
    if (gongMapper.isEmpty) return;

    EachGong? kanGong = gongMapper[HouTianGua.Kan];
    if (kanGong == null) return;

    isStarFuYin = kanGong.isStarFuYin;
    isStarFanYin = isStarFuYin ? false : kanGong.isStarFanYin;

    isDoorFuYin = kanGong.isDoorFuYin;
    isDoorFanYin = isDoorFuYin ? false : kanGong.isDoorFanYin;

    isGanFuYin = kanGong.diPan == kanGong.tianPan; // Simplified from diPanJiGan/tianPanJiGan if those are for center only
    if (!isGanFuYin) {
      EachGong? liGong = gongMapper[HouTianGua.Li];
      if (liGong == null) return;
      isGanFanYin = (liGong.tianPan == kanGong.diPan && liGong.diPan == kanGong.tianPan);
    } else {
      isGanFanYin = false;
    }
  }
}

// Removed CenterGongJiGongType enum from here
