import 'package:common/enums.dart';
import 'package:qimendunjia/enums/enum_arrange_plate_type.dart';
import 'package:qimendunjia/enums/enum_six_geng_ge_ju.dart';
import 'package:qimendunjia/model/each_gong_wang_shuai.dart';
import 'package:qimendunjia/model/pan_arrange_settings.dart';
import 'package:qimendunjia/utils/change_sequence_utils.dart';
import 'package:tuple/tuple.dart';

import '../enums/enum_eight_door.dart';
import '../enums/enum_eight_gods.dart';
import '../enums/enum_most_popular_ge_ju.dart';
import '../enums/enum_nine_stars.dart';
import '../enums/enum_six_bing_ge_ju.dart';
import '../enums/enum_six_jia.dart';
import '../utils/arrange_plate_utils.dart';
import '../utils/nine_yi_utils.dart';
import 'shi_jia_ju.dart';
import 'each_gong.dart';

class ShiJiaQiMen {
  String? question;

  ShiJiaJu shiJiaJu;
  List<EnumMostPopularGeJu>? panGeJuList;
  late final List<EnumSixGengGeJu> gengGeList;
  late final List<EnumSixBingGeJu> bingGeList;

  late final JiaZi yearJiaZi;
  late final Tuple2<DiZhi, DiZhi> yearXunKong;
  late final JiaZi monthJiaZi;
  late final Tuple2<DiZhi, DiZhi> monthXunKong;
  late final JiaZi dayJiaZi;
  late final Tuple2<DiZhi, DiZhi> dayXunKong;
  late final JiaZi timeJiaZi;
  late final Tuple2<DiZhi, DiZhi> timeXunKong;

  // late final TianGan xunHeaderTianGan;
  late final EightDoorEnum zhiShiDoor; // 值使门
  late final HouTianGua zhiShiDoorAtGong;
  late final NineStarsEnum zhiFuStar; // 值符星
  late final HouTianGua zhiFuStarAtGong; // 值符天干
  late final SixJia sixJiaXunHeader; // 六甲，旬首
  late final bool isSixJiXing;
  late final DiZhi horseLocation; // 马星

  late final String eightChatStr;
  late final int zhiFuGongNumber;
  late final TianGan ganAtCenterGong;

  late TianGan zhiFuGan;

  bool isStarFuYin = false;
  bool isStarFanYin = false;
  bool isDoorFuYin = false;
  bool isDoorFanYin = false;
  bool isGanFuYin = false;
  bool isGanFanYin = false;

  late final PanArrangeSettings settings;

  PlateType plateType;
  ArrangeType get arrangeType => settings.arrangeType;
  CenterGongJiGongType get jiGong => settings.jiGong;
  MonthTokenTypeEnum get starMonthTokenType => settings.starMonthTokenType;
  GongTypeEnum get starFourWeiGongType => settings.starFourWeiGongType;
  GongTypeEnum get doorFourWeiGongType => settings.doorFourWeiGongType;
  GodWithGongTypeEnum get godWithGongTypeEnum => settings.godWithGongTypeEnum;

  // GongAndDoorRelationship doorGongRelationship;

  late final Map<HouTianGua, EachGong> gongMapper;
  late final Map<HouTianGua, EachGongWangShuai> gongWangShuaiMapper;
  ShiJiaQiMen({
    required this.plateType,
    required this.shiJiaJu,
    required this.settings,
    this.question,
  }) {
    eightChatStr = shiJiaJu.fourZhuEightChar;
    List<String> jiaZiCharList = eightChatStr.split(" ").toList();

    yearJiaZi = JiaZi.getFromGanZhiValue(jiaZiCharList[0])!;
    yearXunKong = yearJiaZi.getKongWang();
    monthJiaZi = JiaZi.getFromGanZhiValue(jiaZiCharList[1])!;
    monthXunKong = monthJiaZi.getKongWang();
    dayJiaZi = JiaZi.getFromGanZhiValue(jiaZiCharList[2])!;
    dayXunKong = dayJiaZi.getKongWang();
    timeJiaZi = JiaZi.getFromGanZhiValue(jiaZiCharList[3])!;
    timeXunKong = timeJiaZi.getKongWang();
    sixJiaXunHeader = SixJia.getSixJiaByJiaZi(timeJiaZi.xunHeader); // 六甲 旬首
    horseLocation = DiZhiSanHe.getHorseBySingleDiZhi(timeJiaZi.diZhi);

    // 确定“值符”落宫，值符跟随时干
    zhiFuGan = timeJiaZi.gan;
    // 如果时干为“甲” 则以甲所遁的三奇六仪天干
    if (zhiFuGan == TianGan.JIA) {
      zhiFuGan = xunHeaderTianGan;
    }

    // yinYangDun = jieQi.yinYangDun;

    if (plateType == PlateType.ZHUAN_PAN) {
      gongMapper = calculateZhuanPan();
    } else if (plateType == PlateType.FEI_PAN) {
      gongMapper = calculateFeiPan();
    }
    checkFuFanYin(this);
    gongWangShuaiMapper = calculateEachGongWangShuai(gongMapper);
    panGeJuList = EnumMostPopularGeJu.checkDayTimeGeJu(dayJiaZi, timeJiaZi);
    gengGeList = EnumSixGengGeJu.checkGengGeForPanel(this);
    bingGeList = EnumSixBingGeJu.checkBingGeForPanel(this);
  }
  // 转盘奇门 顺时针顺序与后天八卦宫, 0 index 是 坎一宫
  static final List<int> zhuanPanSeq = [1, 8, 3, 4, 9, 2, 7, 6];

  static final List<int> feiPanSeq = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  static final List<TianGan> siiYiThreeYiList = [
    TianGan.WU,
    TianGan.JI,
    TianGan.GENG,
    TianGan.XIN,
    TianGan.REN,
    TianGan.GUI,
    TianGan.DING,
    TianGan.BING,
    TianGan.YI
  ];
  YinYang get yinYangDun => shiJiaJu.yinYangDun;
  int get juNumber => shiJiaJu.juNumber;
  TwentyFourJieQi get jieQi => shiJiaJu.jieQiAt;
  MonthToken get monthToken => MonthToken.fromDiZhi(monthJiaZi.diZhi);
  JiaZi get xunShou => timeJiaZi.xunHeader;
  TianGan get xunHeaderTianGan => sixJiaXunHeader.gan;
  DateTime get panDateTime => shiJiaJu.panDateTime;
  // 飞盘奇门
  Map<HouTianGua, EachGong> calculateFeiPan() {
    YinYang currentPanYinYang = yinYangDun;
    JiaZi shiJiaZi = timeJiaZi;
    Map<TianGan, int> currentJunGanGongMapper =
        arrangeJu(juNumber, currentPanYinYang);

    ganAtCenterGong =
        currentJunGanGongMapper.entries.firstWhere((e) => e.value == 5).key;
    print("当前中宫天干 ${ganAtCenterGong.name}");
    // print(currentJunGanGongMapper.entries.map((e)=>"${e.key.name}${e.value}").toList().join(" "));
    // 3. 根据天干统帅找到对应的后天八卦宫数
    // 确定天干统帅所在宫位
    print("当前为${yinYangDun.isYang ? "阳" : "阴"} $juNumber局");
    zhiFuGongNumber = currentJunGanGongMapper[xunHeaderTianGan]!;
    int findZhiFuGongNumber = zhiFuGongNumber;
    print("天干统帅所在宫位 $zhiFuGongNumber");
    // 根据宫位找到对应的"值使门"
    zhiShiDoor = EightDoorEnum.mapNumberToEnum[findZhiFuGongNumber]!;

    print("值使门 ${zhiShiDoor.name}");
    // 根据宫位找到对应的“九星”
    zhiFuStar = NineStarsEnum.mapNumberToEnum[findZhiFuGongNumber]!;
    print("值符星 ${zhiFuStar.name}");
    // print("${zhiFuStar.name} -- ${nineStar.name}");
    print(zhiFuGan.name);
    int zhiFuAtGongNumber = currentJunGanGongMapper[zhiFuGan]!;
    print("值符落宫 $zhiFuAtGongNumber 宫");
    zhiFuStarAtGong = HouTianGua.getGua(zhiFuAtGongNumber);

    // 根据制度落宫找到转盘的八神开始的位置
    // int currentJuZhuanPanStartIndex = zhuanPanSeq.indexOf(zhiFuAtGongNumber);
    // print("$zhuanPanSeq  $zhiFuAtGongNumber $currentJuZhuanPanStartIndex");
    var zhuanPanSeqNew = ChangeSequenceUtils.changeNumberSeq(zhiFuAtGongNumber,
        yinYangDun.isYang ? feiPanSeq : feiPanSeq.reversed.toList());
    print("---- $zhuanPanSeqNew");
    // print("当前局转盘开始位置 ${currentJuZhuanPanStartIndex}");
    // 调整 zhuanPanSeq 的顺序使得 zhiFuAtGongNumber 在第一个
    // var per = zhuanPanSeq.sublist(0,currentJuZhuanPanStartIndex);
    // per = per.reversed.toList();
    // var next = zhuanPanSeq.sublist(currentJuZhuanPanStartIndex);
    // zhuanPanSeqNew =  List.from(next)..addAll(per);
    // print("---- $zhuanPanSeqNew");
    // print(zhuanPanSeqNew);

    // print("${zhiFuAtGongNumber} ${zhuanPanSeqNew}");
    // print(zhiFuStar.name);
    // print(NineStarsEnum.listFeiPanOrderedByGongNumber.map((e)=>e.name));
    // NineStarsEnum star = zhiFuStar;
    List<NineStarsEnum> forCurrentPanSeq =
        ChangeSequenceUtils.changeNineStarsSeq(
            zhiFuStar, NineStarsEnum.listFeiPanOrderedByGongNumber);
    // print(star.name);
    print(forCurrentPanSeq.map((e) => e.name).toList());
    Map<int, NineStarsEnum> nineStarsGongNumberMapper =
        Map.fromIterables(zhuanPanSeqNew, forCurrentPanSeq);
    print(nineStarsGongNumberMapper.entries
        .map((e) => "${e.key}${e.value.name}"));
    Map<int, EightGodsEnum> tianPanGodsGongNumberMapper = Map.fromIterables(
        zhuanPanSeqNew,
        currentPanYinYang.isYang
            ? EightGodsEnum.feiPanYangDunList
            : EightGodsEnum.feiPanYinDunList);
    print(tianPanGodsGongNumberMapper.entries
        .map((e) => "${e.key}${e.value.name}"));
    // 根据当前是时辰干支与六甲旬首间隔的顺序，再根据阳顺阴逆从天干统帅，顺后天八卦宫顺序确定值使门位置
    int totalStep = shiJiaZi.number - xunShou.number;
    // 旬首所在后天八卦宫位
    int xunShouAtGongNumber = currentJunGanGongMapper[xunHeaderTianGan]!;
    // print(xunShouAtGongNumber);
    int zhiShiDoorAtGongNumber = 0;
    if (currentPanYinYang.isYang) {
      var res = ChangeSequenceUtils.changeNumberSeq(
          xunShouAtGongNumber, List.generate(9, (i) => i + 1));
      res = [...res, res.first];
      zhiShiDoorAtGongNumber = res[totalStep];
    } else {
      // 阴遁
      var res = ChangeSequenceUtils.changeNumberSeq(
          xunShouAtGongNumber, List.generate(9, (i) => i + 1));
      res = [res.first, ...res.skip(1).toList().reversed, res.first];
      print(res);
      print("totalStep $totalStep");
      zhiShiDoorAtGongNumber = res[totalStep];
      // zhiShiDoorAtGongNumber = xunShouAtGongNumber - totalStep;
    }
    print("值使门落宫 $zhiShiDoorAtGongNumber ${zhiShiDoor.name}");
    if (zhiShiDoorAtGongNumber == 5) {
      // print("值使门落在中五宫，需要寄宫到坤二");
      // 根据寄宫策略 选择对应的寄宫
      zhiShiDoorAtGong = jiGong.getJiGong(yinYangDun, jieQi);
      zhiShiDoorAtGongNumber = zhiShiDoorAtGong.houTianOrder;
    } else {
      zhiShiDoorAtGong = HouTianGua.getGua(zhiShiDoorAtGongNumber);
    }
    List<int> zhuanPanDaoSeq = ChangeSequenceUtils.changeNumberSeq(
        zhiShiDoorAtGongNumber, zhuanPanSeqNew);
    List<EightDoorEnum> currentEightDoorSeq = ChangeSequenceUtils.changeDoorSeq(
        zhiShiDoor, EightDoorEnum.listOrderedByGongNumber);
    Map<int, EightDoorEnum> zhuanPanEigthDoorMapper =
        Map.fromIterables(zhuanPanDaoSeq, currentEightDoorSeq);
    print(
        zhuanPanEigthDoorMapper.entries.map((e) => "${e.key}${e.value.name}"));

    // 确定地盘天干
    // currentJunMapper key 变 value， value 变 key
    Map<int, TianGan> diPanGanWithGongMapper = Map.fromEntries(
        currentJunGanGongMapper.entries.map((e) => MapEntry(e.value, e.key)));
    print(
        "地盘：${diPanGanWithGongMapper.entries.map((e) => "${e.key}${e.value.name}")}");
    // TianGan ganAtCenterGong = _diPanGanWithGongMapper[5]!;

    // 确定天盘天干
    // 将统帅天干放置在值符所在后天， 随后按照顺时针排、地盘天干顺序排布

    // 确定地盘天干顺序，并将天干统帅作为第一个
    // 根据转盘奇门，地盘天干在盘中顺时针顺序
    print("旬首所在宫$xunShouAtGongNumber");
    if (xunShouAtGongNumber == 5) {
      xunShouAtGongNumber = findZhiFuGongNumber;
    }
    List<int> diPanTianGanZhuanIndexSeq = ChangeSequenceUtils.changeNumberSeq(
        xunShouAtGongNumber, zhuanPanSeqNew);
    List<TianGan> tianPanTianGanSeq = [];
    for (var i = 0; i < diPanTianGanZhuanIndexSeq.length; i++) {
      tianPanTianGanSeq
          .add(diPanGanWithGongMapper[diPanTianGanZhuanIndexSeq[i]]!);
    }
    // print(tianPanTianGanSeq.map((e)=>e.name));
    Map<int, TianGan> tianPanTianGanMapper =
        Map.fromIterables(zhuanPanSeqNew, tianPanTianGanSeq);
    print(
        "天盘：${tianPanTianGanMapper.entries.map((e) => "${e.key}${e.value.name}")}");
    // 隐干： 布局后，值使门落宫，把起局时间天干作为本门的隐干头，并由此按照三奇六仪进行九宫八卦顺序排布
    // 如：壬申时，阳遁1局，休门值使，落离九，休门隐干为“壬”：坎宫隐干为癸，坤宫隐干为丁

    // 地盘八神，地盘值符神加临在地盘旬首所落的宫位上

    int diZiFuGodAtGongIndex = diPanGanWithGongMapper.entries
        .firstWhere((entry) => entry.value == xunHeaderTianGan)
        .key;
    List<int> diGodAtGongSeq =
        ChangeSequenceUtils.changeNumberSeq(diZiFuGodAtGongIndex, feiPanSeq);
    if (yinYangDun.isYin) {
      diGodAtGongSeq = [
        diGodAtGongSeq.first,
        ...diGodAtGongSeq.skip(1).toList().reversed
      ];
    }
    // 八神
    Map<int, EightGodsEnum> diGodsGongNumberMapper = Map.fromIterables(
        diGodAtGongSeq,
        yinYangDun.isYang
            ? EightGodsEnum.feiPanYangDunList
            : EightGodsEnum.feiPanYinDunList);
    print(
        "地盘神：${diGodsGongNumberMapper.entries.map((e) => "${e.key}${e.value.name}")}");

    // 天盘隐干
    Map<int, TianGan> tianPanAnGanMapper =
        orderTianPanAnGan(nineStarsGongNumberMapper, diPanGanWithGongMapper);
    print(
        "天盘隐干：${tianPanAnGanMapper.entries.map((e) => "${e.key}${e.value.name}")}");
    // 人盘隐干
    Map<int, TianGan> renPanAnGanMapper =
        orderRenPanAnGan(zhuanPanEigthDoorMapper, diPanGanWithGongMapper);
    print(
        "人盘隐干：${renPanAnGanMapper.entries.map((e) => "${e.key}${e.value.name}")}");

    Map<int, TianGan> yinGanMapper = orderYinGan(diPanGanWithGongMapper);
    print("隐干：${yinGanMapper.entries.map((e) => "${e.key}${e.value.name}")}");

    Map<HouTianGua, EachGong> gongRes = {};

    for (int i = 1; i < 10; i++) {
      // if (i == 5){
      //   continue;
      // }
      gongRes[HouTianGua.getGua(i)] = generateEachGong(
          i: i,
          nineStarsGongNumberMapper: nineStarsGongNumberMapper,
          zhuanPanEigthDoorMapper: zhuanPanEigthDoorMapper,
          eightGodsGongNumberMapper: tianPanGodsGongNumberMapper,
          tianPanTianGanMapper: tianPanTianGanMapper,
          tianPanAnGanMapper: tianPanAnGanMapper,
          renPanAnGanMapper: renPanAnGanMapper,
          yinGanMapper: yinGanMapper,
          houGuaNumberGanMapper: diPanGanWithGongMapper,
          diPanEightGodsMapper: diGodsGongNumberMapper);
    }

    // 中五宫 寄宫
    // gongRes = settleCenterGongJiGong(gongRes, _diPanGanWithGongMapper,TianGan.YI);
    // gongRes = settleCenterGongJiGong(gongRes, _diPanGanWithGongMapper,_diPanGanWithGongMapper[5]!);

    return gongRes;
  }

  // 转盘奇门
  Map<HouTianGua, EachGong> calculateZhuanPan() {
    YinYang currentPanYinYang = yinYangDun;
    JiaZi shiJiaZi = timeJiaZi;
    Map<TianGan, int> currentJunGanGongMapper =
        arrangeJu(juNumber, currentPanYinYang);

    ganAtCenterGong =
        currentJunGanGongMapper.entries.firstWhere((e) => e.value == 5).key;
    // 3. 根据天干统帅找到对应的后天八卦宫数
    // 确定天干统帅所在宫位
    zhiFuGongNumber = currentJunGanGongMapper[xunHeaderTianGan]!;
    int findZhiFuGongNumber = zhiFuGongNumber;
    if (findZhiFuGongNumber == 5) {
      // 中五宫需要寄宫
      findZhiFuGongNumber = jiGong.getJiGong(yinYangDun, jieQi).houTianOrder;
    }
    // 根据宫位找到对应的"值使门"
    zhiShiDoor = EightDoorEnum.mapNumberToEnum[findZhiFuGongNumber]!;
    // 根据宫位找到对应的“九星”
    zhiFuStar = NineStarsEnum.mapNumberToEnum[findZhiFuGongNumber]!;

    int zhiFuAtGongNumber = currentJunGanGongMapper[zhiFuGan]!;
    if (zhiFuAtGongNumber == 5) {
      zhiFuStarAtGong = jiGong.getJiGong(yinYangDun, jieQi);
      zhiFuAtGongNumber = zhiFuStarAtGong.houTianOrder;
    } else {
      zhiFuStarAtGong = HouTianGua.getGua(zhiFuAtGongNumber);
    }

    // 根据制度落宫找到转盘的八神开始的位置
    var zhuanPanSeqNew =
        ChangeSequenceUtils.changeNumberSeq(zhiFuAtGongNumber, zhuanPanSeq);

    NineStarsEnum star = zhiFuStar;
    List<NineStarsEnum> forCurrentPanSeq =
        ChangeSequenceUtils.changeNineStarsSeq(
            star, NineStarsEnum.listOrderedByClockwiseWithoutYing);
    Map<int, NineStarsEnum> nineStarsGongNumberMapper =
        Map.fromIterables(zhuanPanSeqNew, forCurrentPanSeq);
    Map<int, EightGodsEnum> tianPanGodsGongNumberMapper = Map.fromIterables(
        zhuanPanSeqNew,
        currentPanYinYang.isYang
            ? EightGodsEnum.yangDunList
            : EightGodsEnum.yinDunList);
    // 根据当前是时辰干支与六甲旬首间隔的顺序，再根据阳顺阴逆从天干统帅，顺后天八卦宫顺序确定值使门位置
    int totalStep = shiJiaZi.number - xunShou.number;
    // 旬首所在后天八卦宫位
    int xunShouAtGongNumber = currentJunGanGongMapper[xunHeaderTianGan]!;
    int zhiShiDoorAtGongNumber = 0;
    if (currentPanYinYang.isYang) {
      var res = ChangeSequenceUtils.changeNumberSeq(
          xunShouAtGongNumber, List.generate(9, (i) => i + 1));
      res = [...res, res.first];
      zhiShiDoorAtGongNumber = res[totalStep];
    } else {
      // 阴遁
      var res = ChangeSequenceUtils.changeNumberSeq(
          xunShouAtGongNumber, List.generate(9, (i) => i + 1));
      res = [res.first, ...res.skip(1).toList().reversed, res.first];
      zhiShiDoorAtGongNumber = res[totalStep];
    }
    if (zhiShiDoorAtGongNumber == 5) {
      // 根据寄宫策略 选择对应的寄宫
      zhiShiDoorAtGong = jiGong.getJiGong(yinYangDun, jieQi);
      zhiShiDoorAtGongNumber = zhiShiDoorAtGong.houTianOrder;
    } else {
      zhiShiDoorAtGong = HouTianGua.getGua(zhiShiDoorAtGongNumber);
    }
    List<int> zhuanPanDaoSeq = ChangeSequenceUtils.changeNumberSeq(
        zhiShiDoorAtGongNumber, zhuanPanSeqNew);
    List<EightDoorEnum> currentEightDoorSeq = ChangeSequenceUtils.changeDoorSeq(
        zhiShiDoor, EightDoorEnum.listOrderedByClockedwiseWithoutCenter);
    Map<int, EightDoorEnum> zhuanPanEigthDoorMapper =
        Map.fromIterables(zhuanPanDaoSeq, currentEightDoorSeq);

    // 确定地盘天干
    // currentJunMapper key 变 value， value 变 key
    Map<int, TianGan> diPanGanWithGongMapper = Map.fromEntries(
        currentJunGanGongMapper.entries.map((e) => MapEntry(e.value, e.key)));

    // 确定天盘天干
    // 将统帅天干放置在值符所在后天， 随后按照顺时针排、地盘天干顺序排布

    // 确定地盘天干顺序，并将天干统帅作为第一个
    // 根据转盘奇门，地盘天干在盘中顺时针顺序
    if (xunShouAtGongNumber == 5) {
      xunShouAtGongNumber = findZhiFuGongNumber;
    }
    List<int> diPanTianGanZhuanIndexSeq = ChangeSequenceUtils.changeNumberSeq(
        xunShouAtGongNumber, zhuanPanSeqNew);
    List<TianGan> tianPanTianGanSeq = [];
    for (var i = 0; i < diPanTianGanZhuanIndexSeq.length; i++) {
      tianPanTianGanSeq
          .add(diPanGanWithGongMapper[diPanTianGanZhuanIndexSeq[i]]!);
    }
    Map<int, TianGan> tianPanTianGanMapper =
        Map.fromIterables(zhuanPanSeqNew, tianPanTianGanSeq);
    // 隐干： 布局后，值使门落宫，把起局时间天干作为本门的隐干头，并由此按照三奇六仪进行九宫八卦顺序排布
    // 如：壬申时，阳遁1局，休门值使，落离九，休门隐干为“壬”：坎宫隐干为癸，坤宫隐干为丁

    // 地盘八神，地盘值符神加临在地盘旬首所落的宫位上
    Map<int, EightGodsEnum> diGodsGongNumberMapper =
        orderDiPanEightGods(diPanGanWithGongMapper);

    // 天盘隐干
    Map<int, TianGan> tianPanAnGanMapper =
        orderTianPanAnGan(nineStarsGongNumberMapper, diPanGanWithGongMapper);
    // 人盘隐干
    Map<int, TianGan> renPanAnGanMapper =
        orderRenPanAnGan(zhuanPanEigthDoorMapper, diPanGanWithGongMapper);
    Map<int, TianGan> yinGanMapper = orderYinGan(diPanGanWithGongMapper);

    Map<HouTianGua, EachGong> gongRes = {};

    for (int i = 1; i < 10; i++) {
      if (i == 5) {
        continue;
      }
      gongRes[HouTianGua.getGua(i)] = generateEachGong(
          i: i,
          nineStarsGongNumberMapper: nineStarsGongNumberMapper,
          zhuanPanEigthDoorMapper: zhuanPanEigthDoorMapper,
          eightGodsGongNumberMapper: tianPanGodsGongNumberMapper,
          tianPanTianGanMapper: tianPanTianGanMapper,
          tianPanAnGanMapper: tianPanAnGanMapper,
          renPanAnGanMapper: renPanAnGanMapper,
          yinGanMapper: yinGanMapper,
          houGuaNumberGanMapper: diPanGanWithGongMapper,
          diPanEightGodsMapper: diGodsGongNumberMapper);
    }

    // 中五宫 寄宫
    // gongRes = settleCenterGongJiGong(gongRes, _diPanGanWithGongMapper,TianGan.YI);
    gongRes = settleCenterGongJiGong(
        gongRes, diPanGanWithGongMapper, diPanGanWithGongMapper[5]!);

    return gongRes;
  }

  /// 人盘暗干
  /// 人盘八门原始宫位，在当前盘中有的“地盘干”
  Map<int, TianGan> orderRenPanAnGan(
      Map<int, EightDoorEnum> doorsMapper, Map<int, TianGan> diPanGanMapper) {
    Map<int, TianGan> result = {};
    for (var k in doorsMapper.keys) {
      EightDoorEnum god = doorsMapper[k]!;
      result[k] = diPanGanMapper[god.originalGong.houTianOrder]!;
    }
    return result;
  }

  /// 天盘暗干
  /// 天盘九星原始宫位，在当前盘中有的“地盘干”
  Map<int, TianGan> orderTianPanAnGan(Map<int, NineStarsEnum> nineStarMapper,
      Map<int, TianGan> diPanGanMapper) {
    Map<int, TianGan> result = {};
    for (var k in nineStarMapper.keys) {
      NineStarsEnum god = nineStarMapper[k]!;
      result[k] = diPanGanMapper[god.originalGong.houTianOrder]!;
    }
    return result;
  }

  /// 隐干
  /// 奇门盘时辰干支的天干落值使门所在宫，并按三奇六仪阳顺阴逆排布到九宫
  Map<int, TianGan> orderYinGan(Map<int, TianGan> diPanGanMapper) {
    // 阳遁 三奇六仪 顺序
    List<int> nineGongSeq = [];
    int startAtGongNumber = zhiShiDoorAtGong.houTianOrder;
    TianGan tianGan = timeJiaZi.tianGan;
    // 1. 当六甲之时，甲隐遁在三奇六仪之下，此时放置在中午宫，而不是值使门所在宫位
    if (tianGan == TianGan.JIA) {
      tianGan = ArrangePlateUtils.getXunShouByJiaZi(timeJiaZi);
      // 有一点需要注意的是，如果六甲旬首与中宫地盘干相同，则旬首暗干不从中宫开始，而是从值使门落宫
      // 能避免暗干与地盘干形成伏吟
      if (tianGan != ganAtCenterGong) {
        startAtGongNumber = 5;
      }
    }
    // 2. 当值符、值使门同宫时，时干也不从值使宫开始，而是从中宫。这样避免暗干与地盘干伏吟
    if (zhiShiDoorAtGong == zhiFuStarAtGong) {
      startAtGongNumber = 5;
    }
    if (startAtGongNumber != 5 && diPanGanMapper[zhiShiDoor] == tianGan) {
      //暗干与值使门落宫的地盘奇仪相同
      // 将时干入中宫，按照阳顺阴逆的宫序飞布“戊己庚辛壬癸丁丙乙”，
      startAtGongNumber = 5;
    }
    if (yinYangDun.isYang) {
      nineGongSeq = ChangeSequenceUtils.changeNumberSeq(
          startAtGongNumber, List.generate(9, (i) => i + 1));
      nineGongSeq = [...nineGongSeq, nineGongSeq.first];
    } else {
      // 阴遁
      nineGongSeq = ChangeSequenceUtils.changeNumberSeq(
          startAtGongNumber, List.generate(9, (i) => i + 1));
      nineGongSeq = [
        nineGongSeq.first,
        ...nineGongSeq.skip(1).toList().reversed,
        nineGongSeq.first
      ];
    }
    // 戊己庚辛壬癸丁丙乙
    List<TianGan> newList =
        ChangeSequenceUtils.changeThreeQiXiYiSeq(tianGan, siiYiThreeYiList);

    Map<int, TianGan> result = {};
    for (var i = 0; i < newList.length; i++) {
      result[nineGongSeq[i]] = newList[i];
    }
    return result;
  }

  /// 排地盘八神
  Map<int, EightGodsEnum> orderDiPanEightGods(
      Map<int, TianGan> diPanGanWithGongNumber) {
    int diZiFuGodAtGongIndex = diPanGanWithGongNumber.entries
        .firstWhere((entry) => entry.value == xunHeaderTianGan)
        .key;
    if (diZiFuGodAtGongIndex == 5) {
      diZiFuGodAtGongIndex = jiGong.getJiGong(yinYangDun, jieQi).index;
    }
    List<int> diGodAtGongSeq =
        ChangeSequenceUtils.changeNumberSeq(diZiFuGodAtGongIndex, zhuanPanSeq);
    // 八神
    return Map.fromIterables(
        diGodAtGongSeq,
        yinYangDun.isYang
            ? EightGodsEnum.yangDunList
            : EightGodsEnum.yinDunList);
  }

  EachGong generateEachGong(
      {required int i,
      required Map<int, NineStarsEnum> nineStarsGongNumberMapper,
      required Map<int, EightDoorEnum> zhuanPanEigthDoorMapper,
      required Map<int, EightGodsEnum> eightGodsGongNumberMapper,
      required Map<int, EightGodsEnum> diPanEightGodsMapper,
      required Map<int, TianGan> tianPanTianGanMapper,
      required Map<int, TianGan> tianPanAnGanMapper,
      required Map<int, TianGan> renPanAnGanMapper,
      required Map<int, TianGan> yinGanMapper,
      required Map<int, TianGan> houGuaNumberGanMapper}) {
    EachGong result = EachGong(
      gongNumber: i,
      star: nineStarsGongNumberMapper[i]!,
      door: zhuanPanEigthDoorMapper[i]!,
      god: eightGodsGongNumberMapper[i]!,
      diGod: diPanEightGodsMapper[i]!,
      gongGua: HouTianGua.getGua(i),
      diPan: houGuaNumberGanMapper[i]!,
      tianPan: tianPanTianGanMapper[i]!,
      tianPanAnGan: tianPanAnGanMapper[i]!,
      renPanAnGan: renPanAnGanMapper[i]!,
      yinGan: yinGanMapper[i]!,
      sixJiaXunHeader: houGuaNumberGanMapper[i]! == xunHeaderTianGan
          ? sixJiaXunHeader
          : null,
    );
    if (houGuaNumberGanMapper[i]! == xunHeaderTianGan) {
      isSixJiXing = result.isSixJiXing;
    }
    return result;
  }

  Map<HouTianGua, EachGongWangShuai> calculateEachGongWangShuai(
      Map<HouTianGua, EachGong> gongRes) {
    // 一、不包括伏吟、反吟的情况
    // 门：Y在月令中月令主气五行与八门的五行论生克。月令生门为门旺、与门比和为门相。克泄耗门时为衰弱无气；G在宫内与宫卦五行论，宫卦生门为旺、两者比和为相，克泄耗门时为衰弱无气。
    // 星：Y在月令中将主气的天干纳甲换成八卦五行而论，如子月的主气是癸，癸纳于坤卦，用坤土与星的五行来论。九星的旺衰标准是星生卦时为旺，与卦比和为相，其余为休囚废无气状态；G星在宫内与宫内地支的主气五行论。
    // 干：Y在月令中论十二长生表状态，处于长生、沐浴、冠带、临官、帝旺五个状态时为旺相有气，处于衰、病、死、墓、绝、胎、养七个状态时为衰弱无气；G天干在宫内与地盘干来论生克比和，天盘干受地盘干生为旺、与地盘干比和为相，天地盘干若相合，视其能否合化成功而定。其余时无气而弱。地盘干中逢时旬首之遁干以甲木论。4
    // 神：八神只在宫内有旺衰。G以地盘干的纳卦五行来论，地盘干的纳卦生八神时为旺，与八神比和为相，其余时无气而弱。

    // 二、伏吟局
    // 八门伏吟：Y用月令中主气干的五行来论与八门生克比和；G用宫内地支主气干的五行来论与八门生克比和。
    // 九星伏吟：Y用月令本气干纳甲卦五行来与九星论生克比和；G用宫内地支的本气干纳卦五行来与九星论生克比和。
    // 天干伏吟：Y在月令中的十二长生状态表旺衰；G在宫内地支中的十二长生状态表旺衰。
    // 八神：G用宫内地盘干的五行与八神论生克比和。

    // 三、反吟局
    // 九星反吟：Y用月令的主气五行来与星生克比和；G用宫内地支主气干纳甲卦五行与星生克比和。
    // 天干反吟：Y用月令主气干五行与天干论生克比和；G天干在宫内地支中的十二长生状态表旺衰。
    // 八神：G直接用宫卦五行与神生克比和。
    // 四、半伏、半反吟局
    //
    // 哪个伏吟或反吟哪个就按上述伏或反吟局的旺衰分析方法计旺衰。
    return Map.fromEntries(gongRes.entries.map(
        (e) => MapEntry(e.key, generateEachGongWangShuai(e.key, e.value))));
  }

  EachGongWangShuai generateEachGongWangShuai(
      HouTianGua gongGua, EachGong each) {
    // 当地盘干为旬首天干时 需要使用“遁干甲”作为地盘干与天盘干进行关系的比较
    bool isDiPanXunShou = each.diPan == xunHeaderTianGan;
    // 当天盘干为旬首天干时，需要使用“遁干甲”作为天盘干看待
    bool isTianPanXunShou = each.tianPan == xunHeaderTianGan;
    return EachGongWangShuai(
      gongNumber: each.gongNumber,

      starFuFanYin: each.star.checkFuFanYinByGong(gongGua),
      starMonthWangShuai: starMonthTokenType == MonthTokenTypeEnum.ZHU_QI_NA_GUA
          ? each.star.checkWithMonthTokenNaGua(monthToken)
          : each.star.checkWithMonthToken(monthToken),
      starMonthTokenType: starMonthTokenType,
      starGongWangShuai: starFourWeiGongType == GongTypeEnum.GONG_GUA
          ? each.star.checkWithGongGua(gongGua)
          : each.star.checkWithGongNeiDiZhi(
              gongGua, yinYangDun, timeJiaZi, starFourWeiGongType),
      starFourWeiGongType: starFourWeiGongType,

      doorFuFanYin: each.door.checkFuFanYinByGong(gongGua),
      doorMonthWangShuai:
          each.door.checkWithMonthToken(monthToken), // 固定使用月令主气五行
      doorGongWangShuai: each.door.checkWithGong(gongGua), // 有不同的方式进行
      doorFourWeiGongType: doorFourWeiGongType,
      doorGongRelationship:
          GongAndDoorRelationship.getRelationship(each.door, gongGua),
      isDoorRuMu: NineYiUtils.isDoorRuMu(each.door, gongGua),
      godGongWangShuai: godWithGongTypeEnum == GodWithGongTypeEnum.GONG_GUA_ONLY
          ? each.god.checkWangShuaiWithGongGua(gongGua)
          : each.god.checkWangShuaiWithDiPanGanNaGua(each.diPan),
      godWithGongType: godWithGongTypeEnum,

      diPanMonthZhangSheng: TwelveZhangSheng.getZhangShengByTianGanDiZhi(
          isDiPanXunShou ? TianGan.JIA : each.diPan, monthToken.diZhi),
      tianDiPanGanRelationship: FiveXingRelationship.checkRelationship(
          isTianPanXunShou ? TianGan.JIA.fiveXing : each.tianPan.fiveXing,
          isDiPanXunShou
              ? TianGan.JIA.fiveXing
              : each.diPan.fiveXing)!, // 地盘干与天盘干
      tianPanMonthZhangSheng: TwelveZhangSheng.getZhangShengByTianGanDiZhi(
          isTianPanXunShou ? TianGan.JIA : each.tianPan, monthToken.diZhi),
      tianPanJiGanMonthZhangSheng: each.tianPanJiGan == null
          ? null
          : TwelveZhangSheng.getZhangShengByTianGanDiZhi(
              isTianPanXunShou ? TianGan.JIA : each.tianPanJiGan!,
              monthToken.diZhi),
      diPanJiGanMonthZhangSheng: each.diPanJiGan == null
          ? null
          : TwelveZhangSheng.getZhangShengByTianGanDiZhi(
              isTianPanXunShou ? TianGan.JIA : each.diPanJiGan!,
              monthToken.diZhi),
      tianPanAnGanMonthZhangSheng: TwelveZhangSheng.getZhangShengByTianGanDiZhi(
          each.tianPanAnGan, monthToken.diZhi),
      renPanAnGanMonthZhangSheng: TwelveZhangSheng.getZhangShengByTianGanDiZhi(
          each.renPanAnGan, monthToken.diZhi),
      yinGanMonthZhangSheng: TwelveZhangSheng.getZhangShengByTianGanDiZhi(
          each.yinGan, monthToken.diZhi),

      tianPanGongZhangSheng: NineYiUtils.qiYiZhangSheng(
          timeJiaZi, each.tianPan, gongGua, yinYangDun, settings.ganGongType),

      tianPanAnGanGongZhangSheng: NineYiUtils.qiYiZhangSheng(timeJiaZi,
          each.tianPanAnGan, gongGua, yinYangDun, settings.ganGongType),
      diPanGongZhangSheng: NineYiUtils.qiYiZhangSheng(
          timeJiaZi, each.diPan, gongGua, yinYangDun, settings.ganGongType),
      renPanAnGanGongZhangSheng: NineYiUtils.qiYiZhangSheng(timeJiaZi,
          each.renPanAnGan, gongGua, yinYangDun, settings.ganGongType),
      yinGanGongZhangSheng: NineYiUtils.qiYiZhangSheng(
          timeJiaZi, each.yinGan, gongGua, yinYangDun, settings.ganGongType),
      tianPanJiGanGongZhangSheng: each.tianPanJiGan == null
          ? null
          : NineYiUtils.qiYiZhangSheng(timeJiaZi, each.tianPanJiGan!, gongGua,
              yinYangDun, settings.ganGongType),
      diPanJiGanGongZhangSheng: each.diPanJiGan == null
          ? null
          : NineYiUtils.qiYiZhangSheng(timeJiaZi, each.diPanJiGan!, gongGua,
              yinYangDun, settings.ganGongType),

      diPanJiGanGongIsMuOrKu: each.diPanJiGan == null
          ? null
          : NineYiUtils.checkMuOrKu(monthToken, each.diPanJiGan!, gongGua),
      tianPanJiGanGongIsMuOrKu: each.tianPanJiGan == null
          ? null
          : NineYiUtils.checkMuOrKu(monthToken, each.tianPanJiGan!, gongGua),
      diPanGongIsMuOrKu:
          NineYiUtils.checkMuOrKu(monthToken, each.diPan, gongGua),
      tianPanGongIsMuOrKu:
          NineYiUtils.checkMuOrKu(monthToken, each.tianPan, gongGua),
      tianPanAnGanIsMuOrKu:
          NineYiUtils.checkMuOrKu(monthToken, each.tianPanAnGan, gongGua),
      renPanAnGanIsMuOrKu:
          NineYiUtils.checkMuOrKu(monthToken, each.renPanAnGan, gongGua),
      yinPanAnGanIsMuOrKu:
          NineYiUtils.checkMuOrKu(monthToken, each.yinGan, gongGua),
    );
  }

  Map<HouTianGua, EachGong> settleCenterGongJiGong(
      Map<HouTianGua, EachGong> gongRes,
      Map<int, TianGan> houGuaNumberGanMapper,
      TianGan ganAtCenterGong) {
    return _settle(
        gongRes, houGuaNumberGanMapper, jiGong.getJiGong(yinYangDun, jieQi));
  }

  @Deprecated("使用CenterGongJiGong 内方法代替")

  /// 只寄坤二
  Map<HouTianGua, EachGong> settleAtKun(Map<HouTianGua, EachGong> gongRes,
      Map<int, TianGan> houGuaNumberGanMapper) {
    return _settle(gongRes, houGuaNumberGanMapper, HouTianGua.Kun);
  }

  /// 寄坤二，寄艮八 根据阴阳遁寄宫
  @Deprecated("使用CenterGongJiGong 内方法代替")
  Map<HouTianGua, EachGong> settleAtKunGen(Map<HouTianGua, EachGong> gongRes,
      Map<int, TianGan> houGuaNumberGanMapper, YinYang yinYangDun) {
    HouTianGua atGong = yinYangDun.isYang ? HouTianGua.Gen : HouTianGua.Kun;
    return _settle(gongRes, houGuaNumberGanMapper, atGong);
  }

  @Deprecated("使用CenterGongJiGong 内方法代替")
  Map<HouTianGua, EachGong> settleAtFourWei(Map<HouTianGua, EachGong> gongRes,
      Map<int, TianGan> houGuaNumberGanMapper) {
    HouTianGua atGong;
    switch (jieQi.season) {
      case FourSeasons.SPRING:
        atGong = HouTianGua.Gen;
        break;
      case FourSeasons.SUMMER:
        atGong = HouTianGua.Xun;
        break;
      case FourSeasons.AUTUMN:
        atGong = HouTianGua.Kun;
        break;
      default:
        atGong = HouTianGua.Qian;
        break;
    }
    return _settle(gongRes, houGuaNumberGanMapper, atGong);
  }

  @Deprecated("使用CenterGongJiGong 内方法代替")
  Map<HouTianGua, EachGong> settleAtEightGong(Map<HouTianGua, EachGong> gongRes,
      Map<int, TianGan> houGuaNumberGanMapper) {
    HouTianGua atGong;
    switch (jieQi) {
      case TwentyFourJieQi.LI_CHUN:
        atGong = HouTianGua.Gen;
        break;
      case TwentyFourJieQi.CHUN_FEN:
        atGong = HouTianGua.Zhen;
        break;
      case TwentyFourJieQi.LI_XIA:
        atGong = HouTianGua.Xun;
        break;
      case TwentyFourJieQi.XIA_ZHI:
        atGong = HouTianGua.Li;
        break;
      case TwentyFourJieQi.LI_QIU:
        atGong = HouTianGua.Kun;
        break;
      case TwentyFourJieQi.QIU_FEN:
        atGong = HouTianGua.Dui;
        break;
      case TwentyFourJieQi.LI_DONG:
        atGong = HouTianGua.Qian;
        break;
      default:
        atGong = HouTianGua.Kan;
        break;
    }
    return _settle(gongRes, houGuaNumberGanMapper, atGong);
  }

  Map<HouTianGua, EachGong> _settle(Map<HouTianGua, EachGong> gongRes,
      Map<int, TianGan> houGuaNumberGanMapper, HouTianGua settleAtGong) {
    var diPanJiGong = gongRes[settleAtGong]!;
    diPanJiGong.diPanJiGan = houGuaNumberGanMapper[5]!;
    // 天盘寄宫，根据地盘寄宫的地盘天干找到天盘所在位置
    var jiGong =
        gongRes.values.firstWhere((g) => g.tianPan == diPanJiGong.diPan);
    jiGong.tianPanJiGan = diPanJiGong.diPanJiGan;
    jiGong.isJiTianQin = true;

    return gongRes;
  }

  /// @arguments
  ///   numberJu局数
  ///   阴阳遁
  /// @return key 是天干，value 是后天八卦宫数
  Map<TianGan, int> arrangeJu(int numberJu, YinYang yinYangDun) {
    List<int> originalSeq = [1, 2, 3, 4, 5, 6, 7, 8, 9];
    // 确定三奇六仪顺序
    // 阳遁 戊己庚辛壬癸丁丙乙
    List<TianGan> yangDun = const [
      TianGan.WU,
      TianGan.JI,
      TianGan.GENG,
      TianGan.XIN,
      TianGan.REN,
      TianGan.GUI,
      TianGan.DING,
      TianGan.BING,
      TianGan.YI
    ];
    // 阴遁 戊乙丙丁癸壬辛庚己
    List<TianGan> yinDun = const [
      TianGan.WU,
      TianGan.YI,
      TianGan.BING,
      TianGan.DING,
      TianGan.GUI,
      TianGan.REN,
      TianGan.XIN,
      TianGan.GENG,
      TianGan.JI
    ];
    var tianGanSeq =
        yinYangDun.isYang ? yangDun.map((e) => e) : yinDun.map((e) => e);
    // 构建以numberJu为第一个元素的list,最大数值为9，并将小于numberJu的数字加到后面
    var gongNumberSeq =
        List.generate(10 - numberJu, (index) => index + numberJu).toList()
          ..addAll(originalSeq.sublist(0, numberJu - 1));
    // 构建以天干为Key 宫number为value的map

    return Map.fromIterables(tianGanSeq, gongNumberSeq);
  }

  // 检查是否为付反吟
  // 使用坎一宫作为检查的宫位
  static void checkFuFanYin(ShiJiaQiMen pan) {
    EachGong kanGong = pan.gongMapper[HouTianGua.Kan]!;
    // 先检查星伏吟
    pan.isStarFuYin = kanGong.isStarFuYin;
    // 伏吟时一定不会是反吟
    pan.isStarFanYin = pan.isStarFuYin ? false : kanGong.isStarFanYin;

    // 再检查门伏吟
    pan.isDoorFuYin = kanGong.isDoorFuYin;
    // 伏吟时一定不会是反吟
    pan.isDoorFanYin = pan.isDoorFuYin ? false : kanGong.isDoorFanYin;

    // 检查 天地盘干是否相同，相同为伏吟
    pan.isGanFuYin = kanGong.diPanJiGan == kanGong.tianPanJiGan;
    if (!pan.isGanFuYin) {
      // 只有当干不是伏吟时才有可能为反吟
      // 干反吟是指，天地盘干 与 “对宫”天地盘干 正好上下相反
      // 当前应道是坎一宫 对应为为离九宫
      TianGan duiGongTian = pan.gongMapper[HouTianGua.Li]!.tianPan;
      TianGan duiGongDi = pan.gongMapper[HouTianGua.Li]!.diPan;
      pan.isGanFanYin =
          duiGongTian == kanGong.diPan && duiGongDi == kanGong.tianPan;
    }
  }
}

enum CenterGongJiGongType {
  ONLY_KUN_GONG("坤宫"), // 只在坤宫
  KUN_GEN_GONG("艮坤"), // 坤艮宫，阴遁坤二宫，阳遁艮八宫
  FOUR_WEI_GONG("四维"), // 四维宫，立春（春）在艮八，立夏（夏）在巽四，立秋（秋）在坤二，立冬（冬）在前六
  EIGTH_GONG("八宫");

  final String name;
  const CenterGongJiGongType(this.name);
  // 根据八节寄宫：
  // 立春、雨水、惊蛰（艮八宫），
  // 春分、清明、谷雨（震三宫），
  // 立夏、小满、芒种（巽四宫），
  // 夏至、小暑、大暑（离九宫），
  // 立秋、处暑、白露（坤二宫），
  // 秋分、寒露、霜降（兑七宫），
  // 立冬、小雪、大雪（乾六宫），
  // 冬至、小寒、大寒（坎一宫）

  HouTianGua getJiGong(YinYang yinYangDun, TwentyFourJieQi jieQi) {
    switch (this) {
      case KUN_GEN_GONG:
        return atKunGen(yinYangDun);
      case FOUR_WEI_GONG:
        return atFourWei(jieQi);
      case EIGTH_GONG:
        return atEightGong(jieQi);
      default:
        return atKun();
    }
  }

  /// 只寄坤二
  HouTianGua atKun() {
    return HouTianGua.Kun;
  }

  /// 寄坤二，寄艮八 根据阴阳遁寄宫
  HouTianGua atKunGen(YinYang yinYangDun) {
    return yinYangDun.isYang ? HouTianGua.Gen : HouTianGua.Kun;
  }

  HouTianGua atFourWei(TwentyFourJieQi jieQi) {
    HouTianGua atGong;
    switch (jieQi.season) {
      case FourSeasons.SPRING:
        atGong = HouTianGua.Gen;
        break;
      case FourSeasons.SUMMER:
        atGong = HouTianGua.Xun;
        break;
      case FourSeasons.AUTUMN:
        atGong = HouTianGua.Kun;
        break;
      default:
        atGong = HouTianGua.Qian;
        break;
    }
    return atGong;
  }

  HouTianGua atEightGong(TwentyFourJieQi jieQi) {
    HouTianGua atGong;
    switch (jieQi) {
      case TwentyFourJieQi.LI_CHUN:
        atGong = HouTianGua.Gen;
        break;
      case TwentyFourJieQi.CHUN_FEN:
        atGong = HouTianGua.Zhen;
        break;
      case TwentyFourJieQi.LI_XIA:
        atGong = HouTianGua.Xun;
        break;
      case TwentyFourJieQi.XIA_ZHI:
        atGong = HouTianGua.Li;
        break;
      case TwentyFourJieQi.LI_QIU:
        atGong = HouTianGua.Kun;
        break;
      case TwentyFourJieQi.QIU_FEN:
        atGong = HouTianGua.Dui;
        break;
      case TwentyFourJieQi.LI_DONG:
        atGong = HouTianGua.Qian;
        break;
      default:
        atGong = HouTianGua.Kan;
        break;
    }
    return atGong;
  }
}
