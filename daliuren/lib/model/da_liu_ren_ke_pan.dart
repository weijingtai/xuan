import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/enum_nine_zong_men.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:daliuren/model/three_chuan_detail_type.dart';
import 'package:daliuren/model/three_chuan_she_hai.dart';
import 'package:daliuren/model/three_chuan_yao_ke.dart';
import 'package:daliuren/model/three_chuan_zei_ke.dart';
import 'package:daliuren/model/zei_key_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

import 'da_liu_ren_panel.dart';
import 'each_chuan.dart';
import 'each_class.dart';
import 'four_class.dart';

class DaLiuRenKePan extends DaLiuRenPanel {
  DateTime panDateTime;
  String? question;
  String eightChatStr;
  // String monthGeneralStr;
  late final MonthGeneral monthGeneral;
  // late final DiZhi monthGeneral;
  late final JiaZi yearJiaZi;
  late final JiaZi monthJiaZi;
  late final JiaZi dayJiaZi;
  late final JiaZi timeJiaZi;
  late final DiZhi guiRenDiZhi; // 贵人位
  late final bool isDayGuiRen; // 是否是日贵人
  static final TWELVE_GODS_LIST = [
    "贵人",
    "腾蛇",
    "朱雀",
    "六合",
    "勾陈",
    "青龙",
    "天空",
    "白虎",
    "太常",
    "玄武",
    "太阴",
    "天后"
  ];
  late Map<DiZhi, DiZhi> _tianDiPanMapper;
  late Map<DiZhi, GuiRen> _godsMapper;
  late FourClass fourClass;
  late ThreeChuan threeChuan;

  static final Map<TianGan, Tuple2<DiZhi, DiZhi>> dayNightGuiRenMapper = {
    TianGan.JIA: const Tuple2<DiZhi, DiZhi>(DiZhi.CHOU, DiZhi.WEI),
    TianGan.WU: const Tuple2<DiZhi, DiZhi>(DiZhi.CHOU, DiZhi.WEI),
    TianGan.GENG: const Tuple2<DiZhi, DiZhi>(DiZhi.CHOU, DiZhi.WEI),
    TianGan.YI: const Tuple2<DiZhi, DiZhi>(DiZhi.ZI, DiZhi.SHEN),
    TianGan.JI: const Tuple2<DiZhi, DiZhi>(DiZhi.ZI, DiZhi.SHEN),
    TianGan.BING: const Tuple2<DiZhi, DiZhi>(DiZhi.HAI, DiZhi.YOU),
    TianGan.DING: const Tuple2<DiZhi, DiZhi>(DiZhi.HAI, DiZhi.YOU),
    TianGan.REN: const Tuple2<DiZhi, DiZhi>(DiZhi.SI, DiZhi.MAO),
    TianGan.GUI: const Tuple2<DiZhi, DiZhi>(DiZhi.SI, DiZhi.MAO),
    TianGan.XIN: const Tuple2<DiZhi, DiZhi>(DiZhi.WU, DiZhi.YIN),
  };
  late Map<DiZhi, DaLiuRenGong> gongMapper = {};

  // List<String> dayChen = ["卯","辰","巳","午","未","申"];
  static final List<DiZhi> DAY_CHEN = [
    DiZhi.MAO,
    DiZhi.CHEN,
    DiZhi.SI,
    DiZhi.WU,
    DiZhi.WEI,
    DiZhi.SHEN
  ]; // 白天的时辰

  // 反向十干寄宫，根据给定地支（即地支宫位），获取寄居其中的天干
  // NOTICE!!!：四正 没有寄干
  static final Map<DiZhi, List<TianGan>> reversedTenGanJiGongMapper = {
    DiZhi.CHOU: [TianGan.GUI],
    DiZhi.YIN: [TianGan.JIA],
    DiZhi.CHEN: [TianGan.YI],
    DiZhi.SI: [TianGan.BING, TianGan.WU],
    DiZhi.WEI: [TianGan.DING, TianGan.JI],
    DiZhi.SHEN: [TianGan.GENG],
    DiZhi.XU: [TianGan.XIN],
    DiZhi.HAI: [TianGan.REN]
  };

  DaLiuRenKePan({
    required this.panDateTime,
    required this.eightChatStr,
    required this.monthGeneral,
    this.question,
  }) {
    List<String> jiaZiCharList = eightChatStr.split(" ").toList();
    yearJiaZi = JiaZi.getFromGanZhiValue(jiaZiCharList[0])!;
    monthJiaZi = JiaZi.getFromGanZhiValue(jiaZiCharList[1])!;
    dayJiaZi = JiaZi.getFromGanZhiValue(jiaZiCharList[2])!;
    timeJiaZi = JiaZi.getFromGanZhiValue(jiaZiCharList[3])!;
    // monthGeneral = DiZhi.getFromValue(monthGeneralStr.trim())!;

    List<DiZhi> diZhiList = DiZhi.listAll;

    List<DiZhi> diSeq = changeDiZhiSeq(timeJiaZi.diZhi, diZhiList);
    List<DiZhi> monthGeneralSeq =
        changeDiZhiSeq(monthGeneral.generalZhi, diZhiList);

    _tianDiPanMapper = Map<DiZhi, DiZhi>.fromIterables(diSeq, monthGeneralSeq);

    // 计算贵人位
    Tuple2<bool, DiZhi> guiRenResult =
        calculateGuiRenLocationWithFirst(dayJiaZi, timeJiaZi);
    isDayGuiRen = guiRenResult.item1;
    guiRenDiZhi = guiRenResult.item2;

    _godsMapper =
        calculateGodsMapper(timeJiaZi.diZhi, _tianDiPanMapper, guiRenDiZhi);
    // 根据日柱，计算天盘的干支
    var dayXunHeader = dayJiaZi.getXunHeader();
    // print("--------- $dayXunHeader");
    // 当前旬首甲开始的第一个地支
    // var xunFirstDiZhi = dayXunHeader.diZhi;
    // 更加当前的旬首获取当前旬的十甲子干支
    List<JiaZi> currentJiaZiXunList = JiaZi.getTenXunByXunHeader(dayXunHeader);
    // print(currentJiaZiXunList.map((e)=>e.ganZhiStr));
    // 将时旬根据地支为Key 转为Map
    Map<DiZhi, JiaZi> tmpMapper = {};
    for (var jiaZi in currentJiaZiXunList) {
      tmpMapper[jiaZi.diZhi] = jiaZi;
    }
    for (var diZhi in DiZhi.listAll) {
      DiZhi skyDiZhi = _tianDiPanMapper[diZhi]!;
      gongMapper[diZhi] = DaLiuRenGong(
          skyPanDiZhi: skyDiZhi,
          groundPanDiZhi: diZhi,
          guiRen: _godsMapper[diZhi]!,
          tianGan: tmpMapper[skyDiZhi]?.tianGan,
          jiaZi: tmpMapper[diZhi]);
    }

    // 计算四课

    fourClass = calculateFourClass(dayJiaZi, gongMapper);
    threeChuan = calculateThreeChuan(dayJiaZi, fourClass, gongMapper);
  }

  static ThreeChuan calculateThreeChuan(JiaZi dayJiaZi, FourClass fourClass,
      Map<DiZhi, DaLiuRenGong> gongMapper) {
    // 首先进行 伏吟 与 反吟
    // 伏吟
    ThreeChuan? checkFuYinFirstResult =
        checkByFuYin(dayJiaZi, fourClass, gongMapper);
    if (checkFuYinFirstResult != null) {
      return checkFuYinFirstResult;
    }
    // 反吟
    ThreeChuan? checkFanYinFirstResult =
        checkByFanYin(dayJiaZi, fourClass, gongMapper);
    if (checkFanYinFirstResult != null) {
      return checkFanYinFirstResult;
    }

    // 八专 -- 两课
    ThreeChuan? checkBaZhuanFirstResult =
        checkByBaZhuan(dayJiaZi, fourClass, gongMapper);
    // 3.注意：有时会出现八专课与返吟课同体的现象，
    // 如己未日，干上丑，支上丑，又是八专又是返吟。按
    // 返吟法无亲课取未的驿马巳发用；
    // 按八专法，第四课未退三取巳发用，中末传都是丑。
    // 可以看到，无论按哪一种，三传都是一样的。
    if (checkBaZhuanFirstResult != null) {
      return checkBaZhuanFirstResult;
    }
    ThreeChuan? bieZe = checkByBieZe(dayJiaZi, fourClass, gongMapper);
    if (bieZe != null) {
      return bieZe;
    }

    ThreeChuan? zeiKe = checkByZeiKe(dayJiaZi, fourClass, gongMapper);
    if (zeiKe != null) {
      return zeiKe;
    }

    ThreeChuan? yaoKe = checkByYaoKe(dayJiaZi, fourClass, gongMapper);
    if (yaoKe != null) {
      return yaoKe;
    }

    ThreeChuan? checkMaoXingResult =
        checkByMaoXing(dayJiaZi, fourClass, gongMapper);
    if (checkMaoXingResult != null) {
      return checkMaoXingResult;
    }

    throw UnimplementedError("昴星");

    // if (zeiKeIndexAt > -1){
    //   var tuple3 = fourClass.getAsIndex(zeiKeIndexAt);
    //   zeiKeiTop = tuple3.sky;
    // }
    // print("贼克：${zeiKeiTop?.value}");
    // return zeiKeiTop!;
  }

  static ThreeChuan? checkByBieZe(JiaZi dayJiaZi, FourClass fourClass,
      Map<DiZhi, DaLiuRenGong> gongMapper) {
    // 是否为四课齐备
    // bool isFullClass = fourClass.isFullClass;
    if (!fourClass.isThreeClassOnly) {
      // 别责需要四课不备
      return null;
    }
    // 别责有克 按 贼克 比用 涉害 遥克
    if (fourClass.listAllClass.any((e) => e.zeiKeType != null) ||
        fourClass.listAllClass.skip(1).any((e) => e.isSkyKeDayGan != null)) {
      ThreeChuan? threeChuan =
          checkByZeiKe(dayJiaZi, fourClass, gongMapper, callByBieZe: true);
      if (threeChuan != null) {
        return threeChuan;
      }
      return checkByYaoKe(dayJiaZi, fourClass, gongMapper, callByBieZe: true);
    }
    TianGan gan = dayJiaZi.tianGan;
    DiZhi dayGanSkyDiZhi = fourClass.first.sky;
    // DaLiuRenGong dayGanSkyGong = gongMapper.values.firstWhere((g)=>g.skyPanDiZhi == dayGanSkyDiZhi);
    DaLiuRenGong chuChuanGong;
    // 阳日干别责
    if (dayJiaZi.tianGan.isYang) {
      // 取天干五合中另一干
      Tuple2<TianGanFiveCombine, TianGan> combine =
          TianGanFiveCombine.getFiveCombineWithOtherTianGan(gan);
      TianGan otherGan = combine.item2;
      // 找到 otherGan 的寄宫
      DiZhi otherGanJiGong = tenGanJiGongMapper[otherGan]!;
      // 根据otherGanJiGong 找到对应天盘的值作为初传
      chuChuanGong = gongMapper[otherGanJiGong]!;
    } else {
      // 阴日干别责，以日支三合局中下一为初传，干上神为末终传
      // 如： 日支为“寅”，三合局是“寅午戌”，最后以“午”为初传
      DiZhi dayDiZhi = dayJiaZi.diZhi;
      List<String> sanHeStrList =
          DiZhiSanHe.getBySingleDiZhi(dayDiZhi)!.name.split("").toList();
      int index = sanHeStrList.indexOf(dayDiZhi.name);
      String chuChuanDiZhiStr;
      if (index == 2) {
        chuChuanDiZhiStr = sanHeStrList.first;
      } else {
        chuChuanDiZhiStr = sanHeStrList[index + 1];
      }

      DiZhi firstDiZhi = DiZhi.getFromValue(chuChuanDiZhiStr)!;
      chuChuanGong =
          gongMapper.values.firstWhere((e) => e.skyPanDiZhi == firstDiZhi);
    }
    DaLiuRenGong firstGong = gongMapper.values
        .firstWhere((g) => g.skyPanDiZhi == chuChuanGong.skyPanDiZhi);
    DaLiuRenGong secondGong =
        gongMapper.values.firstWhere((g) => g.skyPanDiZhi == dayGanSkyDiZhi);
    DaLiuRenGong thirdGong =
        gongMapper.values.firstWhere((g) => g.skyPanDiZhi == dayGanSkyDiZhi);
    return _buildThreeChuan(
        dayJiaZi, NineZongMen.BIE_ZE, firstGong, secondGong, thirdGong);
  }

  // 伏吟
  static ThreeChuan? checkByFuYin(JiaZi dayJiaZi, FourClass fourClass,
      Map<DiZhi, DaLiuRenGong> gongMapper) {
    // 伏吟的规则为 “寅上寅”，“申上申”
    if (!fourClass.isFuYin) {
      // 当前不是“伏吟”
      return null;
    }
    DiZhi firstChuanDiZhi;
    DiZhi secondChuanDiZhi;
    DiZhi thirdChuanDiZhi;
    // 伏吟分为 有克 与 无克 两种情况
    // 有克，因为是伏吟所以只需判断 第一个 日干 与 日干寄宫上神，第一课是否为存在“贼”与“克”
    if (fourClass.first.zeiKeType != null) {
      // 有克伏吟
      // 日干上神为初传
      firstChuanDiZhi = fourClass.first.sky;

      if (!firstChuanDiZhi.isSelfXing) {
        // 不是地支自刑
        // 初传所刑地支为中传，中传所 刑地支为末传
        secondChuanDiZhi = DiZhiXing.getOtherDiZhi(firstChuanDiZhi);
        thirdChuanDiZhi = DiZhiXing.getOtherDiZhi(secondChuanDiZhi);
      } else {
        // 【杜传格】
        // 为地支自刑,取支上神作为中传
        secondChuanDiZhi = fourClass.third.sky;
        if (secondChuanDiZhi.isSelfXing) {
          // 如果中传也自刑则取中传所冲的地支为末传
          thirdChuanDiZhi = DiZhiChong.getOtherDiZhi(secondChuanDiZhi);
        } else {
          // 中传不是自刑，取中传所刑为 末传
          thirdChuanDiZhi = DiZhiXing.getOtherDiZhi(secondChuanDiZhi);
        }
        // thirdChuanDiZhi = DiZhiChong.getOtherDiZhi(secondChuanDiZhi);
      }
    } else {
      // 【自任格】
      // 无克伏吟， 阳日取干上神，阴日取支上神
      firstChuanDiZhi =
          dayJiaZi.tianGan.isYang ? fourClass.first.sky : fourClass.third.sky;
      // 初传为阴日 三传有无刑都为【自信格】

      //初传或中传 有自刑，兼【杜传格】
      if (firstChuanDiZhi.isSelfXing) {
        // 如果初传为自刑，阴日则取干上神，阳日取支上神，为中传，若中传也自刑，则取中传所冲的地支为末传
        secondChuanDiZhi =
            dayJiaZi.tianGan.isYang ? fourClass.third.sky : fourClass.first.sky;
        if (secondChuanDiZhi.isSelfXing) {
          thirdChuanDiZhi = DiZhiChong.getOtherDiZhi(secondChuanDiZhi);
        } else {
          thirdChuanDiZhi = DiZhiXing.getOtherDiZhi(secondChuanDiZhi);
        }
      } else {
        // 初传不是自刑

        // 初传所刑地支为中传，中传所刑地支为末传
        secondChuanDiZhi = DiZhiXing.getOtherDiZhi(firstChuanDiZhi);
        if (secondChuanDiZhi.isSelfXing) {
          thirdChuanDiZhi = DiZhiChong.getOtherDiZhi(secondChuanDiZhi);
        } else {
          // 非自刑去所刑为末传
          thirdChuanDiZhi = DiZhiXing.getOtherDiZhi(secondChuanDiZhi);
        }
      }
      // 注意 伏吟第一课 无克，逢阴日，【自信格】当中若中传【复刑】，如：丁卯日\己卯日、辛卯日第一局
      // 初传为【卯】，中传为【子】，子卯互刑，则末传取中传之冲，为三传位【卯子午】
      if (dayJiaZi.tianGan.isYin &&
          [JiaZi.DING_MAO, JiaZi.JI_MAO, JiaZi.XIN_MAO].contains(dayJiaZi)) {
        if (firstChuanDiZhi == DiZhi.MAO && secondChuanDiZhi == DiZhi.ZI) {
          thirdChuanDiZhi = DiZhi.WU;
        }
      }
    }
    DaLiuRenGong firstGong =
        gongMapper.values.firstWhere((g) => g.skyPanDiZhi == firstChuanDiZhi);
    DaLiuRenGong secondGong =
        gongMapper.values.firstWhere((g) => g.skyPanDiZhi == secondChuanDiZhi);
    DaLiuRenGong thirdGong =
        gongMapper.values.firstWhere((g) => g.skyPanDiZhi == thirdChuanDiZhi);
    return _buildThreeChuan(
        dayJiaZi, NineZongMen.FU_YIN, firstGong, secondGong, thirdGong);
    // return ThreeChuan(
    //     nineZongMen: NineZongMen.FU_YIN,
    //     first: EachChuan(
    //       order:1,
    //       guiRen:gongMapper.values.firstWhere((g)=>g.skyPanDiZhi == firstChuanDiZhi).guiRen,
    //       liuQin:LiuQin.getLiuQinByForTianGanDiZhi(dayJiaZi.tianGan, firstChuanDiZhi),
    //       diZhi:firstChuanDiZhi),
    //     second: EachChuan(
    //       order:2,
    //       guiRen:gongMapper.values.firstWhere((g)=>g.skyPanDiZhi == secondChuanDiZhi).guiRen,
    //       liuQin:LiuQin.getLiuQinByForTianGanDiZhi(dayJiaZi.tianGan, secondChuanDiZhi),
    //       diZhi:secondChuanDiZhi),
    //     third:  EachChuan(
    //         order:3,
    //         guiRen:gongMapper.values.firstWhere((g)=>g.skyPanDiZhi == thirdChuanDiZhi).guiRen,
    //         liuQin:LiuQin.getLiuQinByForTianGanDiZhi(dayJiaZi.tianGan, thirdChuanDiZhi),
    //         diZhi:thirdChuanDiZhi));
  }

  // 反吟
  static ThreeChuan? checkByFanYin(JiaZi dayJiaZi, FourClass fourClass,
      Map<DiZhi, DaLiuRenGong> gongMapper) {
    if (!fourClass.isFanYin) {
      // 当前不是“反吟”
      return null;
    }
    if ([JiaZi.WU_CHEN, JiaZi.WU_XU].contains(dayJiaZi)) {
      if (fourClass.first.sky == DiZhi.HAI &&
          [DiZhi.XU, DiZhi.CHEN].contains(fourClass.third.sky)) {
        DaLiuRenGong firstGong =
            gongMapper.values.firstWhere((g) => g.skyPanDiZhi == DiZhi.SI);
        DaLiuRenGong secondGong =
            gongMapper.values.firstWhere((g) => g.skyPanDiZhi == DiZhi.HAI);
        DaLiuRenGong thirdGong =
            gongMapper.values.firstWhere((g) => g.skyPanDiZhi == DiZhi.SI);

        return _buildThreeChuan(
            dayJiaZi, NineZongMen.FAN_YIN, firstGong, secondGong, thirdGong);
      }
    }
    if (fourClass.listAllClass.any((e) => e.zeiKeType != null)) {
      // 反吟 有克
      // 按照贼克、比用发

      ThreeChuan? threeChuan = checkByZeiKe(dayJiaZi, fourClass, gongMapper);
      if (threeChuan == null) {
        throw UnimplementedError("反吟有克，但未找到贼克");
      }
      threeChuan.nineZongMen = NineZongMen.FAN_YIN;
      return threeChuan;
    } else {
      // 反吟无克，不分阴阳日，均以驿马发用，日支三合局孟神，所冲者为驿马。支上神做中传，干上神做末传。
      DiZhi dayZhiMengSheng =
          DiZhiSanHe.getBySingleDiZhi(dayJiaZi.diZhi)!.content.first;
      DiZhi firstChuanDiZhi = DiZhiChong.getOtherDiZhi(dayZhiMengSheng);
      DiZhi secondChuanDiZhi = fourClass.third.sky;
      DiZhi thirdChuanDiZhi = fourClass.first.sky;

      DaLiuRenGong firstGong =
          gongMapper.values.firstWhere((g) => g.skyPanDiZhi == firstChuanDiZhi);
      DaLiuRenGong secondGong = gongMapper.values
          .firstWhere((g) => g.skyPanDiZhi == secondChuanDiZhi);
      DaLiuRenGong thirdGong =
          gongMapper.values.firstWhere((g) => g.skyPanDiZhi == thirdChuanDiZhi);

      return _buildThreeChuan(
          dayJiaZi, NineZongMen.FAN_YIN, firstGong, secondGong, thirdGong);
    }
    // 反吟分为 有克 与 无克 两种情况
    // 有克，因为是反吟所以只需判断 第一个 日干 与 日干寄宫上神，第一课是否为存在“贼”与“克”
  }

  static ThreeChuan? _buildThreeChuan(JiaZi dayJiaZi, NineZongMen nineZongMen,
      DaLiuRenGong firstGong, DaLiuRenGong secondGong, DaLiuRenGong thirdGong) {
    EachChuan firstChuan = EachChuan(
        order: 1,
        guiRen: firstGong.guiRen,
        liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
            dayJiaZi.gan, firstGong.skyPanDiZhi),
        diZhi: firstGong.skyPanDiZhi);
    EachChuan secondChuan = EachChuan(
        order: 2,
        guiRen: secondGong.guiRen,
        liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
            dayJiaZi.gan, secondGong.skyPanDiZhi),
        diZhi: secondGong.skyPanDiZhi);
    EachChuan thirdChuan = EachChuan(
        order: 3,
        guiRen: thirdGong.guiRen,
        liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
            dayJiaZi.gan, thirdGong.skyPanDiZhi),
        diZhi: thirdGong.skyPanDiZhi);
    return ThreeChuan(
        nineZongMen: nineZongMen,
        first: firstChuan,
        second: secondChuan,
        third: thirdChuan);
  }

  static ThreeChuan? checkByBaZhuan(JiaZi dayJiaZi, FourClass fourClass,
      Map<DiZhi, DaLiuRenGong> gongMapper) {
    // 1.概念：当干支同位，四课又无克，需要取阳顺三神或阴逆三神为用，曰八专课。
    // 八专日有五，除癸丑日俱有克，无克者甲寅、庚申。刚日从阳，主超进顺布。
    // 己未、丁未柔日主退缩，逆行。中末传俱并日上神。
    // 如甲寅日干上阳神亥，顺数至丑，乃丑亥亥也。
    // 丁未日辰上阴神卯，逆数三辰至丑，乃丑巳巳也。

    // 如甲寅日，干支同寅；庚申日，干支同申；癸丑日，干支同丑；丁未、己未日，干支同未
    // 2.判断是否为八专日
    if (![
      JiaZi.JIA_YIN,
      JiaZi.GENG_SHEN,
      JiaZi.GUI_CHOU,
      JiaZi.DING_WEI,
      JiaZi.JI_WEI
    ].contains(dayJiaZi)) {
      return null;
    }

    // 八专 存在贼克时 使用贼克，但不取“遥克法”
    ThreeChuan? zeiKe = checkByZeiKe(dayJiaZi, fourClass, gongMapper);
    if (zeiKe != null) {
      return zeiKe;
    }

    if (tenGanJiGongMapper[dayJiaZi.tianGan]! != dayJiaZi.diZhi) {
      return null; // 当前并非“八专”
    }
    EachChuan firstChuan;
    DaLiuRenGong firstGong;
    // 之后，才为真的八专
    // 1. 日干为阳，以日干上神在天盘顺时针数3神为初传；
    if (dayJiaZi.gan.isYang) {
      // 以日干上神在天盘顺时针数3神为初传；
      DiZhi dayGanSkyDiZhi = fourClass.first.sky;
      List<DiZhi> clockwiseDiZhiList =
          gongMapper.values.map((e) => e.skyPanDiZhi).toList();
      int index = clockwiseDiZhiList.indexOf(dayGanSkyDiZhi);
      int finalIndex = (index + 2) % clockwiseDiZhiList.length;
      DiZhi chuChuanDiZhi = clockwiseDiZhiList[finalIndex];
      firstGong =
          gongMapper.values.firstWhere((g) => g.skyPanDiZhi == chuChuanDiZhi);
      // firstChuan = EachChuan(
      //     order: 1,
      //     guiRen: gongMapper.values.firstWhere((g)=>g.skyPanDiZhi == chuChuanDiZhi).guiRen,
      //     liuQin: LiuQin.getLiuQinByForTianGanDiZhi(dayJiaZi.tianGan, chuChuanDiZhi),
      //     diZhi: chuChuanDiZhi);
    } else {
      // 2. 日干为阴，以日干上神在天盘逆时针数3神为初传；
      DiZhi dayGanSkyDiZhi = fourClass.fourth.sky;
      List<DiZhi> clockwiseDiZhiList =
          gongMapper.values.map((g) => g.skyPanDiZhi).toList();
      List<DiZhi> antiClockwiseDiZhiList = clockwiseDiZhiList.reversed.toList();

      int index = antiClockwiseDiZhiList.indexOf(dayGanSkyDiZhi);
      int finalIndex = (index + 2) % antiClockwiseDiZhiList.length;
      DiZhi chuChuanDiZhi = antiClockwiseDiZhiList[finalIndex];
      firstGong =
          gongMapper.values.firstWhere((g) => g.skyPanDiZhi == chuChuanDiZhi);
      // firstChuan = EachChuan(
      //     order: 1,
      //     guiRen: gongMapper.values.firstWhere((g)=>g.skyPanDiZhi == chuChuanDiZhi).guiRen,
      //     liuQin: LiuQin.getLiuQinByForTianGanDiZhi(dayJiaZi.tianGan, chuChuanDiZhi),
      //     diZhi: chuChuanDiZhi);
    }
    // 中传末传都用 日干上神
    DiZhi dayGanSkyDiZhi = fourClass.first.sky;
    DaLiuRenGong gong =
        gongMapper.values.firstWhere((g) => g.skyPanDiZhi == dayGanSkyDiZhi);

    // EachChuan secondChuan = EachChuan(
    //     order: 2,
    //     guiRen: gong.guiRen,
    //     liuQin: LiuQin.getLiuQinByForTianGanDiZhi(dayJiaZi.gan, gong.skyPanDiZhi),
    //     diZhi: gong.skyPanDiZhi);
    // EachChuan thirdChuan = EachChuan(
    //     order: 3,
    //     guiRen: gong.guiRen,
    //     liuQin: LiuQin.getLiuQinByForTianGanDiZhi(dayJiaZi.gan, gong.skyPanDiZhi),
    //     diZhi: gong.skyPanDiZhi);

    // return ThreeChuan(nineZongMen: NineZongMen.BA_ZHUAN, first: firstGong, second: gong, third: gong);
    return _buildThreeChuan(
        dayJiaZi, NineZongMen.BA_ZHUAN, firstGong, gong, gong);
  }

  static ThreeChuan? checkByZeiKe(
      JiaZi dayJiaZi, FourClass fourClass, Map<DiZhi, DaLiuRenGong> gongMapper,
      {bool callByBieZe = false}) {
    List<int> keIndexList = []; // 上克下 为顺克， 保存一到四课的index,如何存在“克”则将index此List
    List<int> zeiIndexList = []; // 下克下 为贼克， 保存一到四课的index,如何存在“克”则将index此List
    for (var each in fourClass.listAllClass) {
      if (each.zeiKeType != null) {
        if (each.zeiKeType == EachClassZeiKeType.KE) {
          keIndexList.add(each.order); // 保存index
        } else if (each.zeiKeType == EachClassZeiKeType.ZEI) {
          zeiIndexList.add(each.order); // 保存index
        }
      }
    }

    // print("克：${keIndexList.length}, 贼：${zeiIndexList.length} ${keIndexList.isEmpty && zeiIndexList.isEmpty}");
    if (keIndexList.isEmpty && zeiIndexList.isEmpty) {
      return null;
    }

    int zeiKeIndexAt = -1;
    EachClass? chuChuanZhu;
    NineZongMen? nineZongMenType;
    SheHaiType? sheHaiType;
    ZeiKeType? zeiKeType;
    if (zeiIndexList.isNotEmpty) {
      // 当没有“克”，有贼先论贼
      if (zeiIndexList.length == 1) {
        zeiKeIndexAt = zeiIndexList.first;
        nineZongMenType = NineZongMen.ZEI_KE;
        if (keIndexList.isEmpty) {
          zeiKeType = ZeiKeType.SHI_RU_KE;
        } else {
          zeiKeType = ZeiKeType.CHONG_SHEN_KE;
        }
        // print("重审课（一个贼，一个克，取贼不取克）");
        chuChuanZhu = fourClass.getAsIndex(zeiKeIndexAt);
      } else if (zeiIndexList.length > 1) {
        // 检查两个贼是否是重复的课
        if (zeiIndexList.length == 2) {
          if (zeiIndexList
                  .map((i) => fourClass.getAsIndex(i))
                  .toList()
                  .map((e) => "${e.ground.value}${e.sky.value}")
                  .toSet()
                  .length ==
              1) {
            zeiKeIndexAt = zeiIndexList.first;
            nineZongMenType = NineZongMen.ZEI_KE;
            if (keIndexList.isEmpty) {
              zeiKeType = ZeiKeType.SHI_RU_KE;
            } else {
              zeiKeType = ZeiKeType.CHONG_SHEN_KE;
            }
            // print("重审课（一个贼，一个克，取贼不取克）");
            chuChuanZhu = fourClass.getAsIndex(zeiKeIndexAt);
            Tuple3<EachChuan, EachChuan, EachChuan> chuanTuple3 =
                createEachThreeChuan(dayJiaZi, chuChuanZhu, gongMapper);
            EachChuan firstChuan = chuanTuple3.item1;
            EachChuan secondChuan = chuanTuple3.item2;
            EachChuan thirdChuan = chuanTuple3.item3;
            return ThreeChuanZeiKe(
                type: zeiKeType,
                zeiKeType: chuChuanZhu.zeiKeType!,
                first: firstChuan,
                second: secondChuan,
                third: thirdChuan);
          }
        }
        if (fourClass.isThreeClassOnly) {
          // print("只备三课");
          // 只被三课，需要将重复的课移除
          // 从后向前取，有可能是第四课与第一课重叠，如果从前取，则会移除第四课 影响正常的贼克 比用判断
          EachClass duplicateClass;
          if (fourClass.first.otherSameSkyGroundIndexList != null) {
            duplicateClass = fourClass
                .getAsIndex(fourClass.first.otherSameSkyGroundIndexList!.first);
          } else {
            duplicateClass = fourClass.listAllClass
                .firstWhere((t) => t.otherSameSkyGroundIndexList != null);
          }

          for (var i in duplicateClass.otherSameSkyGroundIndexList!) {
            zeiIndexList.remove(i);
          }
          // 移除后看是否只有一个 如果只有一个则直接返回
          if (zeiIndexList.length == 1) {
            zeiKeIndexAt = zeiIndexList.first;
            nineZongMenType = NineZongMen.ZEI_KE;
            zeiKeType = ZeiKeType.SHI_RU_KE;
            // print("元首课（一个上克下）");
            chuChuanZhu = fourClass.getAsIndex(zeiKeIndexAt);
            Tuple3<EachChuan, EachChuan, EachChuan> chuanTuple3 =
                createEachThreeChuan(dayJiaZi, chuChuanZhu, gongMapper);
            EachChuan firstChuan = chuanTuple3.item1;
            EachChuan secondChuan = chuanTuple3.item2;
            EachChuan thirdChuan = chuanTuple3.item3;
            return ThreeChuanZeiKe(
                type: zeiKeType,
                zeiKeType: chuChuanZhu.zeiKeType!,
                first: firstChuan,
                second: secondChuan,
                third: thirdChuan);
          }
        }
        // 只保留与与日干同阴阳的
        List<EachClass> sameYinYangWithDayGan = [];
        for (var index in zeiIndexList) {
          EachClass each = fourClass.getAsIndex(index);
          if (each.isSkySameYinYangWithDayGan) {
            // 只保留与与日干同阴阳的
            sameYinYangWithDayGan.add(each);
          }
        }
        // print(sameYinYangWithDayGan.length);
        if (sameYinYangWithDayGan.isEmpty) {
          // throw UnimplementedError("贼克 比用法 没有与日干同阴阳的 ok");
          // 不是别责，按照正常的进行涉害
          nineZongMenType = NineZongMen.SHE_HAI;
          Tuple2<SheHaiType, EachClass>? result = sheHai(
              dayJiaZi,
              fourClass,
              zeiIndexList.map((i) => fourClass.getAsIndex(i)).toList(),
              gongMapper,
              false);
          if (result != null) {
            sheHaiType = result.item1;
            chuChuanZhu = result.item2;
          } else {
            return null;
          }
        } else if (sameYinYangWithDayGan.length == 1) {
          nineZongMenType = NineZongMen.BI_YONG;
          chuChuanZhu = sameYinYangWithDayGan.first;
          // 仅有一个上神与日干同阴阳
          // return sameYinYangWithDayGan.first;
        } else {
          // print("是否是别责调用，如果是，需要检查是否有重复的课");
          // 是否是别责调用，如果是，需要检查是否有重复的课
          if (callByBieZe) {
            Set<String> tmpSet =
                sameYinYangWithDayGan.map((e) => "${e.sky}${e.ground}").toSet();
            // 当_tmpSet 只有一个时说明 即将进行涉害法的是两个同样的 “课”。
            // 此时，则不继续涉害操作 直接返回结果
            if (tmpSet.length == 1) {
              nineZongMenType = NineZongMen.BI_YONG;
              chuChuanZhu = sameYinYangWithDayGan.first;
            } else if (tmpSet.length == 2) {
              // 当_tmpSet 有两个时，说明即将进行涉害法的，至少有两个是不同的 “课”。
              if (sameYinYangWithDayGan.length == 3) {
                // 即将进行涉害的三个EachClass中有一个是 与 另外是重复的
                // 需要在进行涉害前去除其中之一。
                // 应当移除 order 大的一个
                int shouldRemovedOrder = -1;
                List<EachClass> newSameYinYangWithDayGan = [];
                for (var e in sameYinYangWithDayGan) {
                  if (e.otherSameSkyGroundIndexList != null) {
                    if (e.order != shouldRemovedOrder) {
                      newSameYinYangWithDayGan.add(e);
                      shouldRemovedOrder = e.otherSameSkyGroundIndexList!.first;
                    }
                  } else {
                    newSameYinYangWithDayGan.add(e);
                  }
                }
                sameYinYangWithDayGan = newSameYinYangWithDayGan;
              }
              // print("不是别责，按照正常的进行涉害");
              // 不是别责，按照正常的进行涉害
              nineZongMenType = NineZongMen.SHE_HAI;
              Tuple2<SheHaiType, EachClass>? result = sheHai(dayJiaZi,
                  fourClass, sameYinYangWithDayGan, gongMapper, false);
              if (result != null) {
                sheHaiType = result.item1;
                chuChuanZhu = result.item2;
              } else {
                return null;
              }
            } else {
              throw UnimplementedError("别责法 涉害出现未知与天干同一样的上神情况");
            }
          } else {
            // print("不是别责，按照正常的进行涉害");
            Set<String> tmpSet =
                sameYinYangWithDayGan.map((e) => "${e.sky}${e.ground}").toSet();
            // 当_tmpSet 只有一个时说明 即将进行涉害法的是两个同样的 “课”。
            // 此时，则不继续涉害操作 直接返回结果
            if (tmpSet.length == 1) {
              nineZongMenType = NineZongMen.BI_YONG;
              chuChuanZhu = sameYinYangWithDayGan.first;
            } else {
              // 不是别责，按照正常的进行涉害
              nineZongMenType = NineZongMen.SHE_HAI;
              Tuple2<SheHaiType, EachClass>? result = sheHai(dayJiaZi,
                  fourClass, sameYinYangWithDayGan, gongMapper, false);
              if (result != null) {
                sheHaiType = result.item1;
                chuChuanZhu = result.item2;
              } else {
                return null;
              }
            }
          }
        }
      }
    } else {
      // 当没有“贼”
      if (keIndexList.length == 1) {
        zeiKeIndexAt = keIndexList.first;
        nineZongMenType = NineZongMen.ZEI_KE;
        zeiKeType = ZeiKeType.YUAN_SHOU_KE;
        // print("元首课（一个上克下）");
        chuChuanZhu = fourClass.getAsIndex(zeiKeIndexAt);
        // return fourClass.getAsIndex(zeiKeIndexAt);
      } else if (keIndexList.length > 1) {
        if (fourClass.isThreeClassOnly) {
          // 只被三课，需要将重复的课移除
          EachClass duplicateClass = fourClass.listAllClass
              .firstWhere((t) => t.otherSameSkyGroundIndexList != null);
          for (var i in duplicateClass.otherSameSkyGroundIndexList!) {
            keIndexList.remove(i);
          }
          // 移除后看是否只有一个 如果只有一个则直接返回
          if (keIndexList.length == 1) {
            zeiKeIndexAt = keIndexList.first;
            nineZongMenType = NineZongMen.ZEI_KE;
            zeiKeType = ZeiKeType.YUAN_SHOU_KE;
            // print("元首课（一个上克下）");
            chuChuanZhu = fourClass.getAsIndex(zeiKeIndexAt);
            Tuple3<EachChuan, EachChuan, EachChuan> chuanTuple3 =
                createEachThreeChuan(dayJiaZi, chuChuanZhu, gongMapper);
            EachChuan firstChuan = chuanTuple3.item1;
            EachChuan secondChuan = chuanTuple3.item2;
            EachChuan thirdChuan = chuanTuple3.item3;
            return ThreeChuanZeiKe(
                type: zeiKeType,
                zeiKeType: chuChuanZhu.zeiKeType!,
                first: firstChuan,
                second: secondChuan,
                third: thirdChuan);
          }
        }
        // 只保留与与日干同阴阳的
        List<EachClass> sameYinYangWithDayGan = [];
        for (var index in keIndexList) {
          EachClass each = fourClass.getAsIndex(index);
          if (each.isSkySameYinYangWithDayGan) {
            // 只保留与与日干同阴阳的
            sameYinYangWithDayGan.add(each);
          }
        }
        if (sameYinYangWithDayGan.isEmpty) {
          // throw UnimplementedError("贼克 比用法 没有与日干同阴阳的 ok");
          // 不是别责，按照正常的进行涉害
          nineZongMenType = NineZongMen.SHE_HAI;
          Tuple2<SheHaiType, EachClass>? result = sheHai(
              dayJiaZi,
              fourClass,
              keIndexList.map((i) => fourClass.getAsIndex(i)).toList(),
              gongMapper,
              true);
          if (result != null) {
            sheHaiType = result.item1;
            chuChuanZhu = result.item2;
          } else {
            return null;
          }
        } else if (sameYinYangWithDayGan.length == 1) {
          nineZongMenType = NineZongMen.BI_YONG;
          chuChuanZhu = sameYinYangWithDayGan.first;
          // 仅有一个上神与日干同阴阳
          // return sameYinYangWithDayGan.first;
        } else {
          // 是否是别责调用，如果是，需要检查是否有重复的课
          if (callByBieZe) {
            Set<String> tmpSet =
                sameYinYangWithDayGan.map((e) => "${e.sky}${e.ground}").toSet();
            // 当_tmpSet 只有一个时说明 即将进行涉害法的是两个同样的 “课”。
            // 此时，则不继续涉害操作 直接返回结果
            if (tmpSet.length == 1) {
              nineZongMenType = NineZongMen.BI_YONG;
              chuChuanZhu = sameYinYangWithDayGan.first;
            } else if (tmpSet.length == 2) {
              // 当_tmpSet 有两个时，说明即将进行涉害法的，至少有两个是不同的 “课”。
              if (sameYinYangWithDayGan.length == 3) {
                // 即将进行涉害的三个EachClass中有一个是 与 另外是重复的
                // 需要在进行涉害前去除其中之一。
                // 应当移除 order 大的一个
                int shouldRemovedOrder = -1;
                List<EachClass> newSameYinYangWithDayGan = [];
                for (var e in sameYinYangWithDayGan) {
                  if (e.otherSameSkyGroundIndexList != null) {
                    if (e.order != shouldRemovedOrder) {
                      newSameYinYangWithDayGan.add(e);
                      shouldRemovedOrder = e.otherSameSkyGroundIndexList!.first;
                    }
                  } else {
                    newSameYinYangWithDayGan.add(e);
                  }
                }
                sameYinYangWithDayGan = newSameYinYangWithDayGan;
              }
            } else {
              throw UnimplementedError("别责法 涉害出现未知与天干同一样的上神情况");
            }
            // print("${keIndexList.length} 是别责，按照正常的进行涉害");
            // 不是别责，按照正常的进行涉害
            nineZongMenType = NineZongMen.SHE_HAI;
            Tuple2<SheHaiType, EachClass>? result = sheHai(
                dayJiaZi, fourClass, sameYinYangWithDayGan, gongMapper, true);
            if (result != null) {
              sheHaiType = result.item1;
              chuChuanZhu = result.item2;
            } else {
              return null;
            }
          } else {
            Set<String> tmpSet =
                sameYinYangWithDayGan.map((e) => "${e.sky}${e.ground}").toSet();
            // 当_tmpSet 只有一个时说明 即将进行涉害法的是两个同样的 “课”。
            // 此时，则不继续涉害操作 直接返回结果
            if (tmpSet.length == 1) {
              nineZongMenType = NineZongMen.BI_YONG;
              chuChuanZhu = sameYinYangWithDayGan.first;
            } else {
              // print("${keIndexList.length} 不是别责，按照正常的进行涉害");
              // 不是别责，按照正常的进行涉害
              nineZongMenType = NineZongMen.SHE_HAI;
              Tuple2<SheHaiType, EachClass>? result = sheHai(
                  dayJiaZi, fourClass, sameYinYangWithDayGan, gongMapper, true);
              if (result != null) {
                sheHaiType = result.item1;
                chuChuanZhu = result.item2;
              } else {
                return null;
              }
            }
          }
        }
      }
    }
    // 构建三传
    if (chuChuanZhu == null) {
      return null;
    }
    Tuple3<EachChuan, EachChuan, EachChuan> chuanTuple3 =
        createEachThreeChuan(dayJiaZi, chuChuanZhu, gongMapper);
    EachChuan firstChuan = chuanTuple3.item1;
    EachChuan secondChuan = chuanTuple3.item2;
    EachChuan thirdChuan = chuanTuple3.item3;
    if (nineZongMenType == NineZongMen.BI_YONG) {
      return ThreeChuan(
          nineZongMen: nineZongMenType!,
          first: firstChuan,
          second: secondChuan,
          third: thirdChuan);
    } else if (nineZongMenType == NineZongMen.SHE_HAI) {
      return ThreeChuanSheHai(
          type: sheHaiType!,
          first: firstChuan,
          second: secondChuan,
          third: thirdChuan);
    } else if (nineZongMenType == NineZongMen.ZEI_KE) {
      return ThreeChuanZeiKe(
          type: zeiKeType!,
          zeiKeType: chuChuanZhu.zeiKeType!,
          first: firstChuan,
          second: secondChuan,
          third: thirdChuan);
    }
    return null;
  }

  @deprecated
  static ThreeChuan? checkByZeiKe2(JiaZi dayJiaZi, FourClass fourClass,
      Map<DiZhi, DaLiuRenGong> gongMapper) {
    List<int> keIndexList = []; // 上克下 为顺克，保存一到四课的index,如何存在“克”则将index此List
    List<int> zeiIndexList = []; // 下克上 为贼克，保存一到四课的index,如何存在“克”则将index此List

    // 1. 遍历四课，确定贼克关系
    for (EachClass each in fourClass.listAllClass) {
      if (each.zeiKeType != null) {
        if (each.zeiKeType == EachClassZeiKeType.KE) {
          keIndexList.add(each.order); // 保存index
        } else if (each.zeiKeType == EachClassZeiKeType.ZEI) {
          zeiIndexList.add(each.order);
        }
      }
    }

    if (keIndexList.isEmpty && zeiIndexList.isEmpty) {
      return null; // 无贼克关系
    }

    // 2. 确定主要课
    int zeiKeIndexAt = -1;
    EachClass? chuChuanZhu;
    NineZongMen? nineZongMenType;
    SheHaiType? sheHaiType;
    ZeiKeType? zeiKeType;

    if (zeiIndexList.isNotEmpty) {
      // 优先考虑贼课
      if (zeiIndexList.length == 1) {
        zeiKeIndexAt = zeiIndexList.first;
        nineZongMenType = NineZongMen.ZEI_KE;
        zeiKeType =
            keIndexList.isEmpty ? ZeiKeType.SHI_RU_KE : ZeiKeType.CHONG_SHEN_KE;
        chuChuanZhu = fourClass.getAsIndex(zeiKeIndexAt);
      } else {
        // chuChuanZhu = _handleMultipleZeiKe(dayJiaZi, fourClass, gongMapper, zeiIndexList, false);
        List<EachClass> sameYinYangWithDayGan = [];
        for (var index in zeiIndexList) {
          EachClass each = fourClass.getAsIndex(index);
          if (each.isSkySameYinYangWithDayGan) {
            // 只保留与与日干同阴阳的
            sameYinYangWithDayGan.add(each);
          }
        }
        if (sameYinYangWithDayGan.isEmpty) {
          throw UnimplementedError("贼克 比用法 没有与日干同阴阳的");
        } else if (sameYinYangWithDayGan.length == 1) {
          nineZongMenType = NineZongMen.BI_YONG;
          chuChuanZhu = sameYinYangWithDayGan.first;
          // 仅有一个上神与日干同阴阳
          // return sameYinYangWithDayGan.first;
        } else {
          nineZongMenType = NineZongMen.SHE_HAI;
          Tuple2<SheHaiType, EachClass>? result = sheHai(
              dayJiaZi, fourClass, sameYinYangWithDayGan, gongMapper, false);
          if (result != null) {
            sheHaiType = result.item1;
            chuChuanZhu = result.item2;
          } else {
            return null;
          }
        }
      }
    } else if (keIndexList.isNotEmpty) {
      // 考虑克课
      if (keIndexList.length == 1) {
        zeiKeIndexAt = keIndexList.first;
        nineZongMenType = NineZongMen.ZEI_KE;
        zeiKeType = ZeiKeType.YUAN_SHOU_KE;
        chuChuanZhu = fourClass.getAsIndex(zeiKeIndexAt);
      } else {
        // chuChuanZhu = _handleMultipleZeiKe(dayJiaZi, fourClass, gongMapper, keIndexList, true);

        List<EachClass> sameYinYangWithDayGan = [];
        for (var index in keIndexList) {
          EachClass each = fourClass.getAsIndex(index);
          if (each.isSkySameYinYangWithDayGan) {
            // 只保留与与日干同阴阳的
            sameYinYangWithDayGan.add(each);
          }
        }
        if (sameYinYangWithDayGan.isEmpty) {
          throw UnimplementedError("贼克 比用法 没有与日干同阴阳的");
        } else if (sameYinYangWithDayGan.length == 1) {
          nineZongMenType = NineZongMen.BI_YONG;
          chuChuanZhu = sameYinYangWithDayGan.first;
          // 仅有一个上神与日干同阴阳
          // return sameYinYangWithDayGan.first;
        } else {
          nineZongMenType = NineZongMen.SHE_HAI;
          Tuple2<SheHaiType, EachClass>? result = sheHai(
              dayJiaZi, fourClass, sameYinYangWithDayGan, gongMapper, false);
          if (result != null) {
            sheHaiType = result.item1;
            chuChuanZhu = result.item2;
          } else {
            return null;
          }
        }
      }
    }

    if (chuChuanZhu == null) {
      return null; // 无法确定主要课
    }

    // 3. 构建三传
    Tuple3<EachChuan, EachChuan, EachChuan> chuanTuple3 =
        createEachThreeChuan(dayJiaZi, chuChuanZhu, gongMapper);
    EachChuan firstChuan = chuanTuple3.item1;
    EachChuan secondChuan = chuanTuple3.item2;
    EachChuan thirdChuan = chuanTuple3.item3;

    switch (nineZongMenType) {
      case NineZongMen.BI_YONG:
        return ThreeChuan(
            nineZongMen: nineZongMenType!,
            first: firstChuan,
            second: secondChuan,
            third: thirdChuan);
      case NineZongMen.SHE_HAI:
        return ThreeChuanSheHai(
            type: sheHaiType!,
            first: firstChuan,
            second: secondChuan,
            third: thirdChuan);
      case NineZongMen.ZEI_KE:
        return ThreeChuanZeiKe(
            type: zeiKeType!,
            zeiKeType: chuChuanZhu.zeiKeType!,
            first: firstChuan,
            second: secondChuan,
            third: thirdChuan);
      default:
        return null; // 不支持的九宗门类型
    }
  }

// 处理多个贼课或克课
  @deprecated
  static EachClass? _handleMultipleZeiKe(JiaZi dayJiaZi, FourClass fourClass,
      Map<DiZhi, DaLiuRenGong> gongMapper, List<int> indexList, bool isKe) {
    List<EachClass> sameYinYangWithDayGan = [];

    for (int index in indexList) {
      EachClass each = fourClass.getAsIndex(index);
      if (each.isSkySameYinYangWithDayGan) {
        sameYinYangWithDayGan.add(each);
      }
    }

    if (sameYinYangWithDayGan.isEmpty) {
      throw UnimplementedError("${isKe ? "克" : "贼"}课 比用法 没有与日干同阴阳的");
    } else if (sameYinYangWithDayGan.length == 1) {
      return sameYinYangWithDayGan.first;
    } else {
      Tuple2<SheHaiType, EachClass>? result =
          sheHai(dayJiaZi, fourClass, sameYinYangWithDayGan, gongMapper, isKe);
      return result?.item2;
    }
  }

  static ThreeChuan? checkByYaoKe(
      JiaZi dayJiaZi, FourClass fourClass, Map<DiZhi, DaLiuRenGong> gongMapper,
      {bool callByBieZe = false}) {
    // 遥克 1：上神克日干
    YaoKeType? yaoKeType;
    EachClass? chuChuanZhu;
    List<EachClass> yaoKeSkyKeDayGanList = fourClass.listAllClass
        .where((each) => each.isSkyKeDayGan != null && each.isSkyKeDayGan!)
        .toList();
    // List<EachClass> yaoKeSkyKeDayGanList = fourClass.listAllClass.where((each)=>each.isSkyKeDayGan != null && each.isSkyKeDayGan!).toList();
    bool? isBiYong;
    SheHaiType? sheHaiType;
    if (yaoKeSkyKeDayGanList.isNotEmpty) {
      // 遥克不为空
      if (yaoKeSkyKeDayGanList.length == 1) {
        yaoKeType = YaoKeType.GAO_SHI_KE;
        chuChuanZhu = yaoKeSkyKeDayGanList.first;
        // 遥克，此上神为初传
      } else {
        // 先检查是否调用方为“别责”，如果是别责 则先看
        if (callByBieZe && yaoKeSkyKeDayGanList.length == 2) {
          // 说明是两个相同的课在进行比较，可以直接返回第一个
          Tuple3<EachChuan, EachChuan, EachChuan> chuanTuple3 =
              createEachThreeChuan(
                  dayJiaZi, yaoKeSkyKeDayGanList.first, gongMapper);
          EachChuan firstChuan = chuanTuple3.item1;
          EachChuan secondChuan = chuanTuple3.item2;
          EachChuan thirdChuan = chuanTuple3.item3;
          return ThreeChuanYaoKe(
              type: yaoKeType,
              first: firstChuan,
              second: secondChuan,
              third: thirdChuan,
              isBiYong: isBiYong,
              sheHaiType: sheHaiType);
        }
        // 遥克多个，取日干相比
        // 如果还有多个则“涉害”
        List<EachClass> sameYinYangWithDayGan = [];
        for (var each in yaoKeSkyKeDayGanList) {
          if (each.isSkySameYinYangWithDayGan) {
            // 只保留与与日干同阴阳的
            sameYinYangWithDayGan.add(each);
          }
        }
        if (sameYinYangWithDayGan.isEmpty) {
          throw UnimplementedError("遥克 没有与日干同阴阳的");
        } else if (sameYinYangWithDayGan.length == 1) {
          // 仅有一个上神与日干同阴阳
          chuChuanZhu = sameYinYangWithDayGan.first;
          isBiYong = true;
        } else {
          // 是否是别责调用，如果是，需要检查是否有重复的课
          if (callByBieZe) {
            Set<String> tmpSet =
                sameYinYangWithDayGan.map((e) => "${e.sky}${e.ground}").toSet();
            // 当_tmpSet 只有一个时说明 即将进行涉害法的是两个同样的 “课”。
            // 此时，则不继续涉害操作 直接返回结果
            if (tmpSet.length == 1) {
              chuChuanZhu = sameYinYangWithDayGan.first;
              isBiYong = true;
            } else if (tmpSet.length == 2) {
              // 当_tmpSet 有两个时，说明即将进行涉害法的，至少有两个是不同的 “课”。
              if (sameYinYangWithDayGan.length == 3) {
                // 即将进行涉害的三个EachClass中有一个是 与 另外是重复的
                // 需要在进行涉害前去除其中之一。
                // 应当移除 order 大的一个
                int shouldRemovedOrder = -1;
                List<EachClass> newSameYinYangWithDayGan = [];
                for (var e in sameYinYangWithDayGan) {
                  if (e.otherSameSkyGroundIndexList != null) {
                    if (e.order != shouldRemovedOrder) {
                      newSameYinYangWithDayGan.add(e);
                      shouldRemovedOrder = e.otherSameSkyGroundIndexList!.first;
                    }
                  } else {
                    newSameYinYangWithDayGan.add(e);
                  }
                }
                sameYinYangWithDayGan = newSameYinYangWithDayGan;
              }
            } else {
              throw UnimplementedError("别责法 涉害出现未知与天干同一样的上神情况");
            }
          }

          Tuple2<SheHaiType, EachClass>? result = sheHai(
              dayJiaZi, fourClass, sameYinYangWithDayGan, gongMapper, true);

          if (result != null) {
            sheHaiType = result.item1;
            chuChuanZhu = result.item2;
          } else {
            return null;
          }
        }
      }
    } else {
      // 遥克 2：没有上神克日干，那么找日干克上神
      List<EachClass> yaoKeDayGanKeSkyList = fourClass.listAllClass
          .where((each) => each.isSkyKeDayGan != null && !each.isSkyKeDayGan!)
          .toList();
      if (yaoKeDayGanKeSkyList.isNotEmpty) {
        // 遥克不为空
        if (yaoKeDayGanKeSkyList.length == 1) {
          // 遥克，此上神为初传
          yaoKeType = YaoKeType.TAN_SHE_KE;
          chuChuanZhu = yaoKeDayGanKeSkyList.first;
        } else {
          // 先检查是否调用方为“别责”，如果是别责 则先看
          if (callByBieZe && yaoKeSkyKeDayGanList.length == 2) {
            // 说明是两个相同的课在进行比较，可以直接返回第一个
            Tuple3<EachChuan, EachChuan, EachChuan> chuanTuple3 =
                createEachThreeChuan(
                    dayJiaZi, yaoKeSkyKeDayGanList.first, gongMapper);
            EachChuan firstChuan = chuanTuple3.item1;
            EachChuan secondChuan = chuanTuple3.item2;
            EachChuan thirdChuan = chuanTuple3.item3;
            return ThreeChuanYaoKe(
                type: yaoKeType,
                first: firstChuan,
                second: secondChuan,
                third: thirdChuan,
                isBiYong: isBiYong,
                sheHaiType: sheHaiType);
          }
          // 遥克多个，取日干相比
          // 如果还有多个则“涉害”
          List<EachClass> sameYinYangWithDayGan = [];
          for (var each in yaoKeDayGanKeSkyList) {
            if (each.isSkySameYinYangWithDayGan) {
              // 只保留与与日干同阴阳的
              sameYinYangWithDayGan.add(each);
            }
          }
          if (sameYinYangWithDayGan.isEmpty) {
            throw UnimplementedError("遥克 没有与日干同阴阳的");
          } else if (sameYinYangWithDayGan.length == 1) {
            isBiYong = true;
            chuChuanZhu = sameYinYangWithDayGan.first;
            // 仅有一个上神与日干同阴阳
          } else {
            // 是否是别责调用，如果是，需要检查是否有重复的课
            if (callByBieZe) {
              Set<String> tmpSet = sameYinYangWithDayGan
                  .map((e) => "${e.sky}${e.ground}")
                  .toSet();
              // 当_tmpSet 只有一个时说明 即将进行涉害法的是两个同样的 “课”。
              // 此时，则不继续涉害操作 直接返回结果
              if (tmpSet.length == 1) {
                chuChuanZhu = sameYinYangWithDayGan.first;
                isBiYong = true;
              } else if (tmpSet.length == 2) {
                // 当_tmpSet 有两个时，说明即将进行涉害法的，至少有两个是不同的 “课”。
                if (sameYinYangWithDayGan.length == 3) {
                  // 即将进行涉害的三个EachClass中有一个是 与 另外是重复的
                  // 需要在进行涉害前去除其中之一。
                  // 应当移除 order 大的一个
                  int shouldRemovedOrder = -1;
                  List<EachClass> newSameYinYangWithDayGan = [];
                  for (var e in sameYinYangWithDayGan) {
                    if (e.otherSameSkyGroundIndexList != null) {
                      if (e.order != shouldRemovedOrder) {
                        newSameYinYangWithDayGan.add(e);
                        shouldRemovedOrder =
                            e.otherSameSkyGroundIndexList!.first;
                      }
                    } else {
                      newSameYinYangWithDayGan.add(e);
                    }
                  }
                  sameYinYangWithDayGan = newSameYinYangWithDayGan;
                }
              } else {
                throw UnimplementedError("别责法 涉害出现未知与天干同一样的上神情况");
              }
            }

            Tuple2<SheHaiType, EachClass>? result = sheHai(
                dayJiaZi, fourClass, sameYinYangWithDayGan, gongMapper, false);

            if (result != null) {
              sheHaiType = result.item1;
              chuChuanZhu = result.item2;
            } else {
              return null;
            }
          }
        }
      }
    }

    if (chuChuanZhu != null) {
      Tuple3<EachChuan, EachChuan, EachChuan> chuanTuple3 =
          createEachThreeChuan(dayJiaZi, chuChuanZhu, gongMapper);
      EachChuan firstChuan = chuanTuple3.item1;
      EachChuan secondChuan = chuanTuple3.item2;
      EachChuan thirdChuan = chuanTuple3.item3;
      return ThreeChuanYaoKe(
          type: yaoKeType,
          first: firstChuan,
          second: secondChuan,
          third: thirdChuan,
          isBiYong: isBiYong,
          sheHaiType: sheHaiType);
    }
    return null;
  }

  // 昴星，前提四课全
  static ThreeChuan? checkByMaoXing(JiaZi dayJiaZi, FourClass fourClass,
      Map<DiZhi, DaLiuRenGong> gongMapper) {
    // currentPanel.forEach((k,v)=>print("${k.value} ${v.value}"));
    // gongMapper.forEach((k,v)=>print("${k.value} ${v.groundPanDiZhi.value} ${v.skyPanDiZhi.value}"));
    DaLiuRenGong chuChuanGong;
    DaLiuRenGong secondChuanGong;
    DaLiuRenGong thirdChuanGong;
    DiZhi chuChuanDiZhi;
    EachChuan first;

    if (dayJiaZi.tianGan.yinYang == YinYang.YANG) {
      // 阳日干取酉上发初传
      chuChuanGong = gongMapper[DiZhi.YOU]!;
      first = EachChuan(
          order: 1,
          diZhi: chuChuanGong.skyPanDiZhi,
          guiRen: chuChuanGong.guiRen,
          liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
              dayJiaZi.tianGan, chuChuanGong.skyPanDiZhi),
          tianGan: chuChuanGong.tianGan);

      // 阳日干 支上神末中传
      secondChuanGong = gongMapper[dayJiaZi.diZhi]!;
      // 阳日干 上神为末传
      thirdChuanGong = gongMapper.values
          .firstWhere((g) => g.skyPanDiZhi == fourClass.first.sky);
    } else {
      // 阴日干取酉下发初传
      DaLiuRenGong underYouFaYongGOng =
          gongMapper.values.firstWhere((g) => g.skyPanDiZhi == DiZhi.YOU);
      chuChuanDiZhi = underYouFaYongGOng.groundPanDiZhi;
      chuChuanGong =
          gongMapper.values.firstWhere((g) => g.skyPanDiZhi == chuChuanDiZhi);

      first = EachChuan(
        order: 1,
        diZhi: chuChuanDiZhi,
        // guiRen:gongMapper.values.firstWhere((g)=>g.skyPanDiZhi == chuChuanDiZhi)!.guiRen,
        guiRen: chuChuanGong.guiRen,
        liuQin:
            LiuQin.getLiuQinByForTianGanDiZhi(dayJiaZi.tianGan, chuChuanDiZhi),
        tianGan: chuChuanGong.tianGan,
      );
      // 阳日干 干上神为中传
      secondChuanGong = gongMapper.values
          .firstWhere((g) => g.skyPanDiZhi == fourClass.first.sky);
      // 阳日干 支上神为末传
      thirdChuanGong = gongMapper[dayJiaZi.diZhi]!;
    }

    var second = EachChuan(
      order: 2,
      diZhi: secondChuanGong.skyPanDiZhi,
      guiRen: secondChuanGong.guiRen,
      liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
          dayJiaZi.tianGan, secondChuanGong.skyPanDiZhi),
      tianGan: secondChuanGong.tianGan,
    );
    var third = EachChuan(
      order: 3,
      diZhi: thirdChuanGong.skyPanDiZhi,
      guiRen: thirdChuanGong.guiRen,
      liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
          dayJiaZi.tianGan, thirdChuanGong.skyPanDiZhi),
      tianGan: thirdChuanGong.tianGan,
    );
    return ThreeChuan(
        nineZongMen: NineZongMen.MAO_XING,
        first: first,
        second: second,
        third: third);

    // return _buildThreeChuan(dayJiaZi,NineZongMen.MAO_XING, chuChuanGong, secondChuanGong, thirdChuanGong);
  }

  // TODO: remove `Map<DiZhi, DiZhi> currentPanel` from arguments
  static Tuple3<EachChuan, EachChuan, EachChuan> createEachThreeChuan(
      JiaZi dayJiaZi,
      EachClass chuChuanZhu,
      Map<DiZhi, DaLiuRenGong> gongMapper) {
    DaLiuRenGong firstChuanGong = gongMapper.values
        .firstWhere((gong) => gong.skyPanDiZhi == chuChuanZhu.sky);
    EachChuan firstChuan = EachChuan(
        order: 1,
        diZhi: firstChuanGong.skyPanDiZhi,
        guiRen: firstChuanGong.guiRen,
        liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
            dayJiaZi.gan, firstChuanGong.skyPanDiZhi),
        tianGan: firstChuanGong.tianGan);
    DaLiuRenGong secondChuanGong = gongMapper[firstChuanGong.skyPanDiZhi]!;
    EachChuan secondChuan = EachChuan(
      order: 2,
      diZhi: secondChuanGong.skyPanDiZhi,
      guiRen: secondChuanGong.guiRen,
      liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
          dayJiaZi.gan, secondChuanGong.skyPanDiZhi),
      tianGan: secondChuanGong.tianGan,
    );
    DaLiuRenGong thirdChuanGong = gongMapper[secondChuanGong.skyPanDiZhi]!;
    EachChuan thirdChuan = EachChuan(
      order: 3,
      diZhi: thirdChuanGong.skyPanDiZhi,
      guiRen: thirdChuanGong.guiRen,
      liuQin: LiuQin.getLiuQinByForTianGanDiZhi(
          dayJiaZi.gan, thirdChuanGong.skyPanDiZhi),
      tianGan: thirdChuanGong.tianGan,
    );
    return Tuple3<EachChuan, EachChuan, EachChuan>(
        firstChuan, secondChuan, thirdChuan);
  }

  static Tuple2<SheHaiType, EachClass> sheHaiZhui(
      JiaZi dayGanZhi, FourClass fourClass) {
    /// 涉害 “缀”， 当日地支为“阳”时返回取日干上神发用，阴性取日支上神发用
    if (dayGanZhi.gan.yinYang == YinYang.YANG) {
      return Tuple2(SheHaiType.ZHUI_XIA, fourClass.first);
    } else {
      return Tuple2(SheHaiType.ZHUI_XIA, fourClass.second);
    }
  }

  static Tuple2<SheHaiType, EachClass>? sheHai(
      JiaZi dayJiaZi,
      FourClass fourClass,
      List<EachClass> allEachClass,
      Map<DiZhi, DaLiuRenGong> gongMapper,
      bool isKe) {
    // 涉害前 使用 “孟仲法”
    Tuple2<SheHaiType, EachClass>? mengZhong =
        sheHaiSameTimesSelectFromList(allEachClass);
    if (mengZhong != null) {
      return mengZhong;
    }
    // 如果是“贼”，则涉害是比较“贼”； 如果是“克”，则涉害时比较“克”

    // 涉害的原则是，当前盘面中“sky”所在宫位顺时针回到原宫位（地盘宫位），克地盘次数，包括克“寄宫”的十干
    // 如，当前sky为“戌”，对应地盘为“子宫”，需要回到原本“戌所在的地支戌宫”，
    // 其中走过地盘：
    //  “子（克）”、“丑（克）”、“寅（不克）”、卯（不克）、辰（不克）、巳（不克）、午（不克）、未（不克）、申（不克）、酉（不克）、戌（不克）
    // WARNING: 其中克地盘丑宫的原因是因为十干中“癸水寄丑宫”
    // 克地盘宫 +1，克寄宫天干也 +1。
    // 当前currentPanel key是地盘，value是天盘

    // 将地盘与天盘分为两个独立的list，
    // DiZhi firstSky = first.item2;
    // DiZhi secondSky = second.item2;

    for (var e in allEachClass) {
      if (isKe) {
        e.sheHaiTimes = sheHaiShenQianTimes(e.sky, gongMapper, isKe = isKe);
      } else {
        e.sheHaiTimes = sheHaiShenQianTimes(e.sky, gongMapper, isKe = isKe);
      }
      // print("${e.sky.value}${e.ground.value}-${e.sheHaiTimes}");
    }
    // 比较allEachClass中sheHaiTimes是否全部相等，如果相等，则使用“缀瑕”规则
    // 且确保 相同次数的sheHaiTimes 不属于 别责

    // print(allEachClass.map((e) => "${e.isFirstClass?(e as FirstClass).tianGan.name:e.ground.name}${e.sky.name}${e.sheHaiTimes ?? ''}").toList());
    if (allEachClass.map((e) => e.sheHaiTimes).toSet().length == 1) {
      // 孟仲法
      Tuple2<SheHaiType, EachClass> zuiResult;
      // Tuple2<SheHaiType,EachClass>? mengZhong = sheHaiSameTimesSelectFromList(allEachClass);
      // if (mengZhong == null){
      // 使用缀瑕
      zuiResult = sheHaiZhui(dayJiaZi, fourClass);
      // }else{
      //   zuiResult = mengZhong;
      // }
      return zuiResult;
    }
    // print(allEachClass.map((e) => "${e.isFirstClass?(e as FirstClass).tianGan.name:e.ground.name}${e.sky.name}${e.sheHaiTimes ?? ''}").toList());
    // 找到 allEachClass 中sheHaiTimes最大的
    EachClass maxSheHai =
        allEachClass.reduce((a, b) => a.sheHaiTimes! > b.sheHaiTimes! ? a : b);
    // print(isKe?"涉害 克":"涉害 贼");
    return Tuple2(SheHaiType.SHEN_QIAN, maxSheHai);
  }

  // TODO: remove `Map<DiZhi, DiZhi> currentPanel` from arguments
  static int sheHaiShenQianTimes(
      DiZhi sky, Map<DiZhi, DaLiuRenGong> gongMapper, bool isKe) {
    // 将地盘与天盘分为两个独立的list
    List<DiZhi> diPanList = [];
    List<DiZhi> tianPanList = [];
    gongMapper.forEach((k, v) {
      diPanList.add(v.groundPanDiZhi);
      tianPanList.add(v.skyPanDiZhi);
    });

    // print("old天：${tianPanList.map((e)=>e.value)}");
    // print("old地：${diPanList.map((e)=>e.value)}");
    // 找到当前sky所在天盘的index
    int atTianPanListIndex = tianPanList.indexOf(sky);
    // print("${atTianPanListIndex} - ${sky.value}");
    // 根据给定的index，将天盘与地盘同时对其，是的天地盘当前所在index位置的天干成为第一个list
    // List<DiZhi> newTianPanList = changeDiZhiSeq(sky, tianPanList);
    // List<DiZhi> newDiPanList = changeDiZhiSeq(diPanList[atTianPanListIndex], diPanList);
    List<DiZhi> newDiPanList =
        changeDiZhiSeq(diPanList[atTianPanListIndex], diPanList);
    // print(sky.value);
    // print("N天：${newTianPanList.map((e)=>e.value)}");
    // print("N地：${newDiPanList.map((e)=>e.value)}");
    // 使用 newDiPanList 进行迭代，当当前值为 firstSky 时则结束涉害次数统计
    int sheHaiCounter = 0; // 涉害计数器
    FiveXing skyFiveXing = sky.fiveXing;
    for (int i = 0; i < newDiPanList.length; i++) {
      DiZhi currentDiPanGongZhi = newDiPanList[i];
      if (isKe) {
        // 统计克宫的次数
        if (FiveXingRelationship.checkRelationship(
                currentDiPanGongZhi.fiveXing, skyFiveXing) ==
            FiveXingRelationship.KE) {
          sheHaiCounter += 1;
          // print("宫${currentDiPanGongZhi.value} 克");
        }
        // 统计克“寄宫天干”次数
        List<TianGan>? jiGanList =
            reversedTenGanJiGongMapper[currentDiPanGongZhi];
        if (jiGanList != null) {
          // 当前地盘宫位存在寄宫天干，一一进行五行生克比对
          for (var e in jiGanList) {
            if (FiveXingRelationship.checkRelationship(
                    e.fiveXing, skyFiveXing) ==
                FiveXingRelationship.KE) {
              sheHaiCounter += 1;
              // print("宫${currentDiPanGongZhi.value} 寄干:${e.value} 克");
            }
          }
        }
      } else {
        DiZhi currentDiPanGongZhi = newDiPanList[i];
        // 统计克宫的次数
        if (FiveXingRelationship.checkRelationship(
                skyFiveXing, currentDiPanGongZhi.fiveXing) ==
            FiveXingRelationship.KE) {
          sheHaiCounter += 1;
          // print("宫${currentDiPanGongZhi.value} 克");
        }
        // 统计克“寄宫天干”次数
        List<TianGan>? jiGanList =
            reversedTenGanJiGongMapper[currentDiPanGongZhi];
        if (jiGanList != null) {
          // 当前地盘宫位存在寄宫天干，一一进行五行生克比对
          for (var e in jiGanList) {
            if (FiveXingRelationship.checkRelationship(
                    skyFiveXing, e.fiveXing) ==
                FiveXingRelationship.KE) {
              sheHaiCounter += 1;
              // print("宫${currentDiPanGongZhi.value} 寄干:${e.value} 克");
            }
          }
        }
      }
      if (currentDiPanGongZhi == sky) {
        // print("total times $sheHai_counter");
        break;
      }
    }
    return sheHaiCounter;
  }

  ///
  /// 这个方法调用的前提是，当涉害次数相同时，需要调用sheHaiSameTimesSelect
  /// 有孟先取孟上神，为仲季
  /// 当深浅一致时，且孟仲无异时，返回
  /// Tuple2.item1 标识为是孟1，还是仲2，还是季3
  /// 当Tuple2 为空 则标识孟仲无异，需要进行“缀”
  /// Tuple2.item2 为所选取的“课”
  static Tuple2<SheHaiType, EachClass>? sheHaiSameTimesSelectFromList(
      List<EachClass> eachClassList,
      {int counter = 1}) {
    List<DiZhi> list = [];
    switch (counter) {
      case 1:
        list = [DiZhi.YIN, DiZhi.SHEN, DiZhi.SI, DiZhi.HAI];
        break;
      case 2:
        list = [DiZhi.ZI, DiZhi.WU, DiZhi.MAO, DiZhi.YOU];
        break;
      case 3:
        // 涉害中不取四季
        list = [DiZhi.CHEN, DiZhi.XU, DiZhi.CHOU, DiZhi.WEI];
        return null;
        break;
      default:
        throw UnimplementedError("涉害次数选取孟仲季多于3次");
    }

    if (eachClassList.length == 2) {
      // 当涉害次数相同时
      // 有孟仲季先取孟
      // 没孟取仲
      EachClass first = eachClassList[0];
      EachClass second = eachClassList[1];

      bool firstIn = list.contains(first.ground);
      bool secondIn = list.contains(second.ground);
      if (firstIn && secondIn) {
        return null;
      } else if (firstIn && !secondIn) {
        return Tuple2(
            counter == 1 ? SheHaiType.JIAN_JI : SheHaiType.CHA_WEI, first);
      } else if (!firstIn && secondIn) {
        return Tuple2(
            counter == 1 ? SheHaiType.JIAN_JI : SheHaiType.CHA_WEI, second);
      } else {
        // 没仲取季
        counter += 1;
        return sheHaiSameTimesSelect(first, second, counter: counter);
      }
    } else if (eachClassList.length == 3) {
      EachClass first = eachClassList[0];
      EachClass second = eachClassList[1];
      EachClass third = eachClassList[2];

      bool firstIn = list.contains(first.ground);
      bool secondIn = list.contains(second.ground);
      bool thirdIn = list.contains(third.ground);
      if (firstIn && secondIn && thirdIn) {
        return null;
      }
      List<EachClass> newCheckList = [];
      if (firstIn) {
        newCheckList.add(first);
      }
      if (secondIn) {
        newCheckList.add(second);
      }
      if (thirdIn) {
        newCheckList.add(third);
      }
      if (newCheckList.length == 1) {
        return Tuple2(counter == 1 ? SheHaiType.JIAN_JI : SheHaiType.CHA_WEI,
            newCheckList[0]);
      } else if (newCheckList.length == 2) {
        counter += 1;
        return sheHaiSameTimesSelect(first, second, counter: counter);
      } else if (newCheckList.length > 2) {
        counter += 1;
        return sheHaiSameTimesSelectFromList(newCheckList, counter: counter);
      }
    } else if (eachClassList.length == 4) {
      EachClass first = eachClassList[0];
      EachClass second = eachClassList[1];
      EachClass third = eachClassList[2];
      EachClass fourth = eachClassList[3];

      bool firstIn = list.contains(first.ground);
      bool secondIn = list.contains(second.ground);
      bool thirdIn = list.contains(third.ground);
      bool fourthIn = list.contains(fourth.ground);
      if (firstIn && secondIn && thirdIn) {
        return null;
      }
      List<EachClass> newCheckList = [];
      if (firstIn) {
        newCheckList.add(first);
      }
      if (secondIn) {
        newCheckList.add(second);
      }
      if (thirdIn) {
        newCheckList.add(third);
      }
      if (fourthIn) {
        newCheckList.add(third);
      }
      if (newCheckList.length == 1) {
        return Tuple2(counter == 1 ? SheHaiType.JIAN_JI : SheHaiType.CHA_WEI,
            newCheckList[0]);
      } else if (newCheckList.length == 2) {
        counter += 1;
        return sheHaiSameTimesSelect(first, second, counter: counter);
      } else if (newCheckList.length > 2) {
        counter += 1;
        return sheHaiSameTimesSelectFromList(newCheckList, counter: counter);
      }
    } else {
      throw ErrorDescription("sheaiSameTimesSelectFromList 涉害次数不等于2");
    }
    return null;
  }

  ///
  /// 这个方法调用的前提是，当涉害次数相同时，需要调用sheHaiSameTimesSelect
  /// 有孟先取孟上神，为仲季
  /// 当深浅一致时，且孟仲无异时，返回
  /// Tuple2.item1 标识为是孟1，还是仲2，还是季3
  /// 当Tuple2 为空 则标识孟仲无异，需要进行“缀”
  /// Tuple2.item2 为所选取的“课”
  static Tuple2<SheHaiType, EachClass>? sheHaiSameTimesSelect(
      EachClass first, EachClass second,
      {int counter = 1}) {
    List<DiZhi> list = [];
    switch (counter) {
      case 1:
        list = [DiZhi.YIN, DiZhi.SHEN, DiZhi.SI, DiZhi.HAI];
        break;
      case 2:
        list = [DiZhi.ZI, DiZhi.WU, DiZhi.MAO, DiZhi.YOU];
        break;
      case 3:
        // 涉害中不取四季
        list = [DiZhi.CHEN, DiZhi.XU, DiZhi.CHOU, DiZhi.WEI];
        return null;
        break;
      default:
        throw UnimplementedError("涉害次数选取孟仲季多于3次");
    }

    // 当涉害次数相同时
    // 有孟仲季先取孟
    // 没孟取仲
    bool firstIn = list.contains(first.ground);
    bool secondIn = list.contains(second.ground);
    if (firstIn && secondIn) {
      return null;
    } else if (firstIn && !secondIn) {
      return Tuple2(
          counter == 1 ? SheHaiType.JIAN_JI : SheHaiType.CHA_WEI, first);
    } else if (!firstIn && secondIn) {
      return Tuple2(
          counter == 1 ? SheHaiType.JIAN_JI : SheHaiType.CHA_WEI, second);
    } else {
      // 没仲取季
      counter += 1;
      return sheHaiSameTimesSelect(first, second, counter: counter);
    }
  }

  // static Map<DiZhi,String> calculateGodsMapper(DiZhi timeDiZhi,DiZhi monthGeneral,DiZhi guiRenDiZhi){
  static Map<DiZhi, GuiRen> calculateGodsMapper(
      DiZhi timeDiZhi, Map<DiZhi, DiZhi> tianDiPanMapper, DiZhi guiRenDiZhi) {
    /// @return: key 是 地盘地支
    Map<DiZhi, DiZhi> skyAsKey = tianDiPanMapper.map((k, v) => MapEntry(v, k));
    // 天盘的顺序
    List<DiZhi> skySeq = skyAsKey.values.toList();
    List<DiZhi> tianSeq4Gods = changeDiZhiSeq(guiRenDiZhi, skySeq);
    // 根据 skyAsKey 以及 diSeq4Gods.first得到对应的 地盘落宫
    DiZhi diPanLuoGong = skyAsKey[tianSeq4Gods.first]!;
    List<DiZhi> diSeq4Gods = changeDiZhiSeq(diPanLuoGong, skySeq);

    // 贵人随天盘转，但顺逆排是根据贵人天盘落宫对应的地盘
    // List<String> twelveGodsList = List.from(TWELVE_GODS_LIST);

    bool isAntiClockedGodsSeq = [
      DiZhi.SI,
      DiZhi.WU,
      DiZhi.WEI,
      DiZhi.SHEN,
      DiZhi.YOU,
      DiZhi.XU
    ].contains(diPanLuoGong);
    if (isAntiClockedGodsSeq) {
      // List<String> antiClockSeq = List.from(twelveGodsList.reversed,growable: true);
      // antiClockSeq = [antiClockSeq.last, ...antiClockSeq.sublist(0,11)];
      return Map<DiZhi, GuiRen>.fromIterables(
          diSeq4Gods, GuiRen.antiClockwiseList);
    } else {
      return Map<DiZhi, GuiRen>.fromIterables(diSeq4Gods, GuiRen.clockwiseList);
    }
  }

  static FourClass calculateFourClass(
      JiaZi dayGanZhi, Map<DiZhi, DaLiuRenGong> eachGongMapper) {
    return FourClass.fastGenerate(
        dayGanZhi: dayGanZhi, eachGongMapper: eachGongMapper);
  }

  static List<DiZhi> changeDiZhiSeq(DiZhi start, List<DiZhi> originalSeq,
      {bool isReversed = false}) {
    List<DiZhi> oldList = List.from(originalSeq);
    if (isReversed) {
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<DiZhi> newDiZhiList =
        oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<DiZhi> appendedList = oldList.sublist(0, timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }

  static List<String> changeStrSeq(String start, List<String> originalSeq,
      {bool isReversed = false}) {
    List<String> oldList = List.from(originalSeq);
    if (isReversed) {
      oldList.reversed;
    }
    var timeZhiIndex = oldList.indexOf(start);
    // print(timeZhiIndex);
    List<String> newDiZhiList =
        oldList.sublist(timeZhiIndex).toList(growable: true);
    // print(newDiZhiList);
    List<String> appendedList = oldList.sublist(0, timeZhiIndex);
    // print(appendedList);
    newDiZhiList.addAll(appendedList);
    return newDiZhiList;
  }

  /// @return item1 为日夜贵人区分，日贵人为true,夜贵人为false
  ///          item2 为贵人地支位置
  @deprecated
  static Tuple2<bool, DiZhi> calculate_gui_ren(
      JiaZi dayGanZhi, JiaZi timeGanZhi) {
    bool isDay = DAY_CHEN.contains(timeGanZhi.diZhi);
    var locationDiZhi = isDay
        ? dayNightGuiRenMapper[dayGanZhi.tianGan]!.item1
        : dayNightGuiRenMapper[dayGanZhi.tianGan]!.item2;
    return Tuple2(isDay, locationDiZhi);
  }

  static Tuple2<bool, DiZhi> calculateGuiRenLocationWithFirst(
      JiaZi dayGanZhi, JiaZi timeGanZhi) {
    /// 根据 “甲戊庚牛羊”进行计算
    /// @return item1 为是否为昼贵人，true为昼，false为夜晚

    bool isDay = DAY_CHEN.contains(timeGanZhi.diZhi);
    var locationDiZhi = isDay
        ? dayNightGuiRenMapper[dayGanZhi.tianGan]!.item1
        : dayNightGuiRenMapper[dayGanZhi.tianGan]!.item2;
    return Tuple2(isDay, locationDiZhi);
  }

  @override
  JiaZi getDayJiaZi() {
    return dayJiaZi;
  }

  @override
  FourClass getFourClass() {
    return fourClass;
  }

  @override
  Map<DiZhi, DaLiuRenGong> getGongMapper() {
    return gongMapper;
  }

  @override
  ThreeChuan getThreeChuan() {
    return threeChuan;
  }
}
