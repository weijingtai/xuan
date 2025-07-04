import 'package:common/enums.dart';
import 'package:qimendunjia/model/each_gong.dart';
import 'package:qimendunjia/model/jia_zi.dart';
import 'package:qimendunjia/model/pan_arrange_settings.dart';
import 'package:qimendunjia/model/shi_jia_ju.dart';
import 'package:qimendunjia/model/six_jia.dart';
import 'package:qimendunjia/model/tian_gan.dart';
import 'package:qimendunjia/utils/arrange_plate_utils.dart';
import 'package:qimendunjia/utils/change_sequence_utils.dart';
import 'package:qimendunjia/enums/enum_center_gong_ji_gong_type.dart';
import 'plate_arrangement_result.dart';
import 'plate_arranger.dart';

/// 转盘奇门排盘器。
class ZhuanPanArranger extends QiMenPlateArranger {
  // 转盘奇门 顺时针顺序与后天八卦宫, 0 index 是 坎一宫
  static final List<int> _zhuanPanSeq = [1, 8, 3, 4, 9, 2, 7, 6];
  static final List<TianGan> _siiYiThreeYiList = [
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

  @override
  PlateArrangementResult arrangePlate(
    ShiJiaJu shiJiaJu,
    PanArrangeSettings settings,
    JiaZi timeJiaZi,
    SixJia sixJiaXunHeader,
  ) {
    YinYang currentPanYinYang = shiJiaJu.yinYangDun;
    Map<TianGan, int> currentJunGanGongMapper =
        arrangeJu(shiJiaJu.juNumber, currentPanYinYang);

    TianGan ganAtCenterGong =
        currentJunGanGongMapper.entries.firstWhere((e) => e.value == 5).key;

    TianGan zhiFuGan = timeJiaZi.gan;
    if (zhiFuGan == TianGan.JIA) {
      zhiFuGan = sixJiaXunHeader.gan;
    }

    int zhiFuGongNumber = currentJunGanGongMapper[sixJiaXunHeader.gan]!;
    int findZhiFuGongNumberForStarAndDoor = zhiFuGongNumber;
    if (findZhiFuGongNumberForStarAndDoor == 5) {
      findZhiFuGongNumberForStarAndDoor = settings.jiGong.getJiGong(currentPanYinYang, shiJiaJu.jieQiAt).houTianOrder;
    }
    EightDoorEnum zhiShiDoor = EightDoorEnum.mapNumberToEnum[findZhiFuGongNumberForStarAndDoor]!;
    NineStarsEnum zhiFuStar = NineStarsEnum.mapNumberToEnum[findZhiFuGongNumberForStarAndDoor]!;

    int zhiFuAtGongNumber = currentJunGanGongMapper[zhiFuGan]!;
    HouTianGua zhiFuStarAtGong;
    if (zhiFuAtGongNumber == 5) {
      zhiFuStarAtGong = settings.jiGong.getJiGong(currentPanYinYang, shiJiaJu.jieQiAt);
      zhiFuAtGongNumber = zhiFuStarAtGong.houTianOrder;
    } else {
      zhiFuStarAtGong = HouTianGua.getGua(zhiFuAtGongNumber);
    }

    var zhuanPanSeqNew =
        ChangeSequenceUtils.changeNumberSeq(zhiFuAtGongNumber, _zhuanPanSeq);

    List<NineStarsEnum> forCurrentPanSeq =
        ChangeSequenceUtils.changeNineStarsSeq(
            zhiFuStar, NineStarsEnum.listOrderedByClockwiseWithoutYing);
    Map<int, NineStarsEnum> nineStarsGongNumberMapper =
        Map.fromIterables(zhuanPanSeqNew, forCurrentPanSeq);
    Map<int, EightGodsEnum> tianPanGodsGongNumberMapper = Map.fromIterables(
        zhuanPanSeqNew,
        currentPanYinYang.isYang
            ? EightGodsEnum.yangDunList
            : EightGodsEnum.yinDunList);

    int totalStep = timeJiaZi.number - sixJiaXunHeader.jiaZi.number;
    int xunShouAtGongNumber = currentJunGanGongMapper[sixJiaXunHeader.gan]!;
    int zhiShiDoorAtGongNumberCalc = 0;

    if (currentPanYinYang.isYang) {
      var res = ChangeSequenceUtils.changeNumberSeq(
          xunShouAtGongNumber, List.generate(9, (i) => i + 1));
      res = [...res, res.first];
      zhiShiDoorAtGongNumberCalc = res[totalStep];
    } else {
      var res = ChangeSequenceUtils.changeNumberSeq(
          xunShouAtGongNumber, List.generate(9, (i) => i + 1));
      res = [res.first, ...res.skip(1).toList().reversed, res.first];
      zhiShiDoorAtGongNumberCalc = res[totalStep];
    }

    HouTianGua zhiShiDoorAtGong;
    if (zhiShiDoorAtGongNumberCalc == 5) {
      zhiShiDoorAtGong = settings.jiGong.getJiGong(currentPanYinYang, shiJiaJu.jieQiAt);
      zhiShiDoorAtGongNumberCalc = zhiShiDoorAtGong.houTianOrder;
    } else {
      zhiShiDoorAtGong = HouTianGua.getGua(zhiShiDoorAtGongNumberCalc);
    }

    List<int> zhuanPanDaoSeq = ChangeSequenceUtils.changeNumberSeq(
        zhiShiDoorAtGongNumberCalc, zhuanPanSeqNew);
    List<EightDoorEnum> currentEightDoorSeq = ChangeSequenceUtils.changeDoorSeq(
        zhiShiDoor, EightDoorEnum.listOrderedByClockedwiseWithoutCenter);
    Map<int, EightDoorEnum> zhuanPanEigthDoorMapper =
        Map.fromIterables(zhuanPanDaoSeq, currentEightDoorSeq);

    Map<int, TianGan> diPanGanWithGongMapper = Map.fromEntries(
        currentJunGanGongMapper.entries.map((e) => MapEntry(e.value, e.key)));

    int xunShouAtGongForTianPan = currentJunGanGongMapper[sixJiaXunHeader.gan]!;
    if (xunShouAtGongForTianPan == 5) {
       // If xunShou is in center, its actual position for TianPan calculation is zhiFu's original palace before JiGong
      xunShouAtGongForTianPan = zhiFuGongNumber == 5 ? findZhiFuGongNumberForStarAndDoor : zhiFuGongNumber;
    }

    List<int> diPanTianGanZhuanIndexSeq = ChangeSequenceUtils.changeNumberSeq(
        xunShouAtGongForTianPan, zhuanPanSeqNew);
    List<TianGan> tianPanTianGanSeq = [];
    for (var i = 0; i < diPanTianGanZhuanIndexSeq.length; i++) {
      tianPanTianGanSeq
          .add(diPanGanWithGongMapper[diPanTianGanZhuanIndexSeq[i]]!);
    }
    Map<int, TianGan> tianPanTianGanMapper =
        Map.fromIterables(zhuanPanSeqNew, tianPanTianGanSeq);

    Map<int, EightGodsEnum> diGodsGongNumberMapper =
        _orderDiPanEightGods(diPanGanWithGongMapper, sixJiaXunHeader.gan, currentPanYinYang, shiJiaJu.jieQiAt, settings.jiGong);
    Map<int, TianGan> tianPanAnGanMapper =
        _orderTianPanAnGan(nineStarsGongNumberMapper, diPanGanWithGongMapper);
    Map<int, TianGan> renPanAnGanMapper =
        _orderRenPanAnGan(zhuanPanEigthDoorMapper, diPanGanWithGongMapper);
    Map<int, TianGan> yinGanMapper = _orderYinGan(
        timeJiaZi.tianGan,
        zhiShiDoorAtGong,
        zhiFuStarAtGong,
        currentPanYinYang,
        sixJiaXunHeader,
        ganAtCenterGong,
        diPanGanWithGongMapper[zhiShiDoorAtGong.houTianOrder]!
        );

    Map<HouTianGua, EachGong> gongRes = {};
    for (int i = 1; i < 10; i++) {
      if (i == 5) continue; // Skip center palace for now
      gongRes[HouTianGua.getGua(i)] = _generateEachGong(
          i: i,
          nineStarsGongNumberMapper: nineStarsGongNumberMapper,
          zhuanPanEigthDoorMapper: zhuanPanEigthDoorMapper,
          eightGodsGongNumberMapper: tianPanGodsGongNumberMapper,
          tianPanTianGanMapper: tianPanTianGanMapper,
          tianPanAnGanMapper: tianPanAnGanMapper,
          renPanAnGanMapper: renPanAnGanMapper,
          yinGanMapper: yinGanMapper,
          houGuaNumberGanMapper: diPanGanWithGongMapper,
          diPanEightGodsMapper: diGodsGongNumberMapper,
          sixJiaXunHeader: sixJiaXunHeader);
    }

    gongRes = _settleCenterGongJiGong(
        gongRes, diPanGanWithGongMapper, diPanGanWithGongMapper[5]!, currentPanYinYang, shiJiaJu.jieQiAt, settings.jiGong);

    return PlateArrangementResult(
        gongMapper: gongRes,
        zhiShiDoor: zhiShiDoor,
        zhiShiDoorAtGong: zhiShiDoorAtGong,
        zhiFuStar: zhiFuStar,
        zhiFuStarAtGong: zhiFuStarAtGong, // This is already adjusted for JiGong if zhiFuAtGongNumber was 5
        ganAtCenterGong: ganAtCenterGong,
        zhiFuGan: zhiFuGan,
        zhiFuGongNumber: zhiFuGongNumber // Original palace number of ZhiFu before JiGong
    );
  }

  Map<int, EightGodsEnum> _orderDiPanEightGods(
      Map<int, TianGan> diPanGanWithGongNumber, TianGan xunHeaderTianGan, YinYang yinYangDun, TwentyFourJieQi jieQi, CenterGongJiGongType jiGongType) {
    int diZiFuGodAtGongIndex = diPanGanWithGongNumber.entries
        .firstWhere((entry) => entry.value == xunHeaderTianGan)
        .key;
    if (diZiFuGodAtGongIndex == 5) {
      diZiFuGodAtGongIndex = jiGongType.getJiGong(yinYangDun, jieQi).houTianOrder;
    }
    List<int> diGodAtGongSeq =
        ChangeSequenceUtils.changeNumberSeq(diZiFuGodAtGongIndex, _zhuanPanSeq);
    return Map.fromIterables(
        diGodAtGongSeq,
        yinYangDun.isYang
            ? EightGodsEnum.yangDunList
            : EightGodsEnum.yinDunList);
  }

  Map<int, TianGan> _orderRenPanAnGan(
      Map<int, EightDoorEnum> doorsMapper, Map<int, TianGan> diPanGanMapper) {
    Map<int, TianGan> result = {};
    for (var k in doorsMapper.keys) {
      EightDoorEnum god = doorsMapper[k]!;
      result[k] = diPanGanMapper[god.originalGong.houTianOrder]!;
    }
    return result;
  }

  Map<int, TianGan> _orderTianPanAnGan(Map<int, NineStarsEnum> nineStarMapper,
      Map<int, TianGan> diPanGanMapper) {
    Map<int, TianGan> result = {};
    for (var k in nineStarMapper.keys) {
      NineStarsEnum god = nineStarMapper[k]!;
      result[k] = diPanGanMapper[god.originalGong.houTianOrder]!;
    }
    return result;
  }

  Map<int, TianGan> _orderYinGan(
      TianGan timeTianGan,
      HouTianGua zhiShiDoorAtGong,
      HouTianGua zhiFuStarAtGong,
      YinYang yinYangDun,
      SixJia sixJiaXunHeader,
      TianGan ganAtCenterGong,
      TianGan zhiShiDoorPalaceDiPanGan
      ) {
    List<int> nineGongSeq = [];
    int startAtGongNumber = zhiShiDoorAtGong.houTianOrder;
    TianGan currentTianGan = timeTianGan;

    if (currentTianGan == TianGan.JIA) {
      currentTianGan = sixJiaXunHeader.gan;
      if (currentTianGan != ganAtCenterGong) {
        startAtGongNumber = 5;
      }
    }
    if (zhiShiDoorAtGong == zhiFuStarAtGong) {
      startAtGongNumber = 5;
    }
    if (startAtGongNumber != 5 && zhiShiDoorPalaceDiPanGan == currentTianGan) {
      startAtGongNumber = 5;
    }

    if (yinYangDun.isYang) {
      nineGongSeq = ChangeSequenceUtils.changeNumberSeq(
          startAtGongNumber, List.generate(9, (i) => i + 1));
      nineGongSeq = [...nineGongSeq, nineGongSeq.first];
    } else {
      nineGongSeq = ChangeSequenceUtils.changeNumberSeq(
          startAtGongNumber, List.generate(9, (i) => i + 1));
      nineGongSeq = [
        nineGongSeq.first,
        ...nineGongSeq.skip(1).toList().reversed,
        nineGongSeq.first
      ];
    }
    List<TianGan> newList =
        ChangeSequenceUtils.changeThreeQiXiYiSeq(currentTianGan, _siiYiThreeYiList);

    Map<int, TianGan> result = {};
    for (var i = 0; i < newList.length; i++) {
      result[nineGongSeq[i]] = newList[i];
    }
    return result;
  }

  EachGong _generateEachGong(
      {required int i,
      required Map<int, NineStarsEnum> nineStarsGongNumberMapper,
      required Map<int, EightDoorEnum> zhuanPanEigthDoorMapper,
      required Map<int, EightGodsEnum> eightGodsGongNumberMapper,
      required Map<int, EightGodsEnum> diPanEightGodsMapper,
      required Map<int, TianGan> tianPanTianGanMapper,
      required Map<int, TianGan> tianPanAnGanMapper,
      required Map<int, TianGan> renPanAnGanMapper,
      required Map<int, TianGan> yinGanMapper,
      required Map<int, TianGan> houGuaNumberGanMapper,
      required SixJia sixJiaXunHeader}) {
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
      sixJiaXunHeader: houGuaNumberGanMapper[i]! == sixJiaXunHeader.gan
          ? sixJiaXunHeader
          : null,
    );
    // isSixJiXing check might need to be done outside if it's a global pan property
    return result;
  }

  Map<HouTianGua, EachGong> _settleCenterGongJiGong(
      Map<HouTianGua, EachGong> gongRes,
      Map<int, TianGan> houGuaNumberGanMapper,
      TianGan ganAtCenterGongActual, // This is the DiPan Gan that was in center
      YinYang yinYangDun,
      TwentyFourJieQi jieQi,
      CenterGongJiGongType jiGongType
      ) {
    HouTianGua settleAtGong = jiGongType.getJiGong(yinYangDun, jieQi);
    var diPanJiGongTarget = gongRes[settleAtGong];

    if (diPanJiGongTarget != null) {
       // Create a new EachGong with the JiGan property set
      gongRes[settleAtGong] = diPanJiGongTarget.copyWith(diPanJiGan: ganAtCenterGongActual);

      // TianPan JiGong logic: find the palace where the TianPan Gan is the same as the DiPan Gan of the JiGong target palace.
      // The DiPan Gan of the JiGong target palace is `diPanJiGongTarget.diPan`.
      // The Gan that was originally in the center and now needs to be "hosted" on the TianPan is `ganAtCenterGongActual`.
      EachGong? tianPanJiGongHostPalace = gongRes.values.firstWhere(
            (gong) => gong.tianPan == diPanJiGongTarget.diPan,
            orElse: () => EachGong.empty(), // Should not happen in a valid plate
      );
      if (tianPanJiGongHostPalace.gongNumber != 0 ) { // Check if a valid palace was found
         gongRes[tianPanJiGongHostPalace.gongGua] = tianPanJiGongHostPalace.copyWith(tianPanJiGan: ganAtCenterGongActual, isJiTianQin: true);
      }
    }
    return gongRes;
  }
}
