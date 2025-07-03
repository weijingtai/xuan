import 'package:common/enums.dart';
import 'package:qimendunjia/model/each_gong.dart';
import 'package:qimendunjia/model/jia_zi.dart';
import 'package:qimendunjia/model/pan_arrange_settings.dart';
import 'package:qimendunjia/model/shi_jia_ju.dart';
import 'package:qimendunjia/model/six_jia.dart';
import 'package:qimendunjia/model/tian_gan.dart';
import 'package:qimendunjia/utils/change_sequence_utils.dart';
import 'plate_arrangement_result.dart';
import 'plate_arranger.dart';
import 'package:qimendunjia/utils/arrange_plate_utils.dart'; // For getXunShouByJiaZi

/// 飞盘奇门排盘器。
class FeiPanArranger extends QiMenPlateArranger {
  static final List<int> _feiPanSeq = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  // Re-declare siiYiThreeYiList or import from a shared constants file if it exists
  // For now, re-declaring to keep it self-contained as per instructions for zhuan_pan_arranger
  static final List<TianGan> _siiYiThreeYiList = [
    TianGan.WU, TianGan.JI, TianGan.GENG, TianGan.XIN, TianGan.REN,
    TianGan.GUI, TianGan.DING, TianGan.BING, TianGan.YI
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
    // In FeiPan, ZhiFu star and ZhiShi door's original palace is directly from XunShou's palace number,
    // JiGong is applied later when they land in center.
    EightDoorEnum zhiShiDoor = EightDoorEnum.mapNumberToEnum[zhiFuGongNumber]!;
    NineStarsEnum zhiFuStar = NineStarsEnum.mapNumberToEnum[zhiFuGongNumber]!;

    // ZhiFu star's landing palace is where the zhiFuGan (time stem or its replacement) lands.
    int zhiFuStarLandingGongNumber = currentJunGanGongMapper[zhiFuGan]!;
    HouTianGua zhiFuStarAtGong = HouTianGua.getGua(zhiFuStarLandingGongNumber); // Initial, before JiGong

    // FeiPan star distribution starts from zhiFuStarLandingGongNumber with zhiFuStar
    List<int> feiPanStarSeq = ChangeSequenceUtils.changeNumberSeq(
        zhiFuStarLandingGongNumber,
        currentPanYinYang.isYang ? _feiPanSeq : _feiPanSeq.reversed.toList()
    );
    List<NineStarsEnum> starsInFeiPanOrder = ChangeSequenceUtils.changeNineStarsSeq(
        zhiFuStar, NineStarsEnum.listFeiPanOrderedByGongNumber // FeiPan uses its own star order
    );
    Map<int, NineStarsEnum> nineStarsGongNumberMapper = Map.fromIterables(feiPanStarSeq, starsInFeiPanOrder);

    // TianPan Gods (Eight Gods) in FeiPan also fly from zhiFuStarLandingGongNumber
    Map<int, EightGodsEnum> tianPanGodsGongNumberMapper = Map.fromIterables(
        feiPanStarSeq, // Gods follow the same path as stars in FeiPan
        currentPanYinYang.isYang
            ? EightGodsEnum.feiPanYangDunList // FeiPan has specific god orders
            : EightGodsEnum.feiPanYinDunList);

    // ZhiShi Door's landing palace calculation
    int totalStep = timeJiaZi.number - sixJiaXunHeader.jiaZi.number;
    int xunShouAtGongNumber = currentJunGanGongMapper[sixJiaXunHeader.gan]!;
    int zhiShiDoorLandingGongNumber;

    List<int> doorPathBase = List.generate(9, (i) => i + 1); //宫位序号1-9
    List<int> doorPath = ChangeSequenceUtils.changeNumberSeq(xunShouAtGongNumber, doorPathBase);
    if(currentPanYinYang.isYin) { //阴遁逆飞
        doorPath = [doorPath.first, ...doorPath.skip(1).toList().reversed];
    }
    // Ensure the path is long enough for steps by repeating if necessary
    List<int> fullDoorPath = [];
    while(fullDoorPath.length <= totalStep) {
        fullDoorPath.addAll(doorPath);
    }
    zhiShiDoorLandingGongNumber = fullDoorPath[totalStep];

    HouTianGua zhiShiDoorAtGong = HouTianGua.getGua(zhiShiDoorLandingGongNumber);

    // FeiPan door distribution
    List<int> feiPanDoorSeq = ChangeSequenceUtils.changeNumberSeq(
        zhiShiDoorLandingGongNumber,
        currentPanYinYang.isYang ? _feiPanSeq : _feiPanSeq.reversed.toList()
    );
    List<EightDoorEnum> doorsInFeiPanOrder = ChangeSequenceUtils.changeDoorSeq(
        zhiShiDoor, EightDoorEnum.listOrderedByGongNumber // Standard door order
    );
    Map<int, EightDoorEnum> feiPanEigthDoorMapper = Map.fromIterables(feiPanDoorSeq, doorsInFeiPanOrder);

    Map<int, TianGan> diPanGanWithGongMapper = Map.fromEntries(
        currentJunGanGongMapper.entries.map((e) => MapEntry(e.value, e.key)));

    // TianPan Gan in FeiPan: Each DiPan Gan flies to its respective star's palace
    Map<int, TianGan> tianPanTianGanMapper = {};
    for(int i=1; i<=9; i++) {
        TianGan diGan = diPanGanWithGongMapper[i]!;
        NineStarsEnum starOnDiGanPalace = NineStarsEnum.mapNumberToEnum[i]!; // Star originally in this palace

        // Find where this star (starOnDiGanPalace) has flown to in the current plate
        int starFlownToGong = nineStarsGongNumberMapper.entries.firstWhere((entry) => entry.value == starOnDiGanPalace).key;
        tianPanTianGanMapper[starFlownToGong] = diGan;
    }

    // DiPan Gods in FeiPan (地盘八神) - usually fixed based on original palace structure or follows a specific FeiPan rule
    // This part might need more specific FeiPan rules if it's different from TianPan gods.
    // For now, assuming a simpler fixed mapping or using a placeholder.
    // Let's assume DiPan Gods are fixed to their original palaces for simplicity in this step.
    Map<int, EightGodsEnum> diGodsGongNumberMapper = {};
     for(int i=1; i<=9; i++){
        // A common way is to fix DiPan gods or use a specific sequence.
        // Here, using a simple sequence for placeholder. Replace with actual FeiPan DiGod logic.
        diGodsGongNumberMapper[i] = EightGodsEnum.getGodByFixedOrder(i, currentPanYinYang.isYang);
     }


    Map<int, TianGan> tianPanAnGanMapper = _orderTianPanAnGan(nineStarsGongNumberMapper, diPanGanWithGongMapper);
    Map<int, TianGan> renPanAnGanMapper = _orderRenPanAnGan(feiPanEigthDoorMapper, diPanGanWithGongMapper);
    Map<int, TianGan> yinGanMapper = _orderYinGan(
        timeJiaZi.tianGan,
        zhiShiDoorAtGong, // Landing palace of ZhiShi
        zhiFuStarAtGong,  // Landing palace of ZhiFu Star
        currentPanYinYang,
        sixJiaXunHeader,
        ganAtCenterGong,
        diPanGanWithGongMapper[zhiShiDoorAtGong.houTianOrder]!
    );

    Map<HouTianGua, EachGong> gongRes = {};
    for (int i = 1; i <= 9; i++) {
      gongRes[HouTianGua.getGua(i)] = _generateEachGong(
          i: i,
          nineStarsGongNumberMapper: nineStarsGongNumberMapper,
          zhuanPanEigthDoorMapper: feiPanEigthDoorMapper, // Use FeiPan door mapper
          eightGodsGongNumberMapper: tianPanGodsGongNumberMapper, // TianPan Gods
          tianPanTianGanMapper: tianPanTianGanMapper,
          tianPanAnGanMapper: tianPanAnGanMapper,
          renPanAnGanMapper: renPanAnGanMapper,
          yinGanMapper: yinGanMapper,
          houGuaNumberGanMapper: diPanGanWithGongMapper,
          diPanEightGodsMapper: diGodsGongNumberMapper, // DiPan Gods
          sixJiaXunHeader: sixJiaXunHeader
      );
    }

    // FeiPan JiGong: If star or door lands in center, it's hosted by Kun (or other based on settings)
    // This needs to be carefully adapted for FeiPan.
    // If zhiFuStarAtGong (initial landing before this function call) was center, it would use JiGong.
    // If nineStarsGongNumberMapper[5] (star in center after flying) is the ZhiFu star, its anGan etc. might be affected.
    // If feiPanEigthDoorMapper[5] (door in center after flying) is ZhiShi, its anGan etc. might be affected.

    // Placeholder for actual JiGong logic in FeiPan, which is complex
    // For now, the primary entities (Star, Door, Gan) are placed. JiGong for anGan might need specific handling.
    // The PlateArrangementResult does not explicitly carry JiGong info for elements *within* the center palace,
    // but rather the original zhiFuGongNumber and where zhiFuStar/zhiShiDoor ended up.

    return PlateArrangementResult(
        gongMapper: gongRes,
        zhiShiDoor: zhiShiDoor,
        zhiShiDoorAtGong: zhiShiDoorAtGong, // Final landing palace
        zhiFuStar: zhiFuStar,
        zhiFuStarAtGong: zhiFuStarAtGong, // Final landing palace (could be center)
        ganAtCenterGong: ganAtCenterGong, // DiPan Gan in center
        zhiFuGan: zhiFuGan,
        zhiFuGongNumber: zhiFuGongNumber // Original palace number of XunShou
    );
  }

  // Helper methods (can be identical to ZhuanPan if logic is shared, or specialized for FeiPan)
   Map<int, TianGan> _orderRenPanAnGan(
      Map<int, EightDoorEnum> doorsMapper, Map<int, TianGan> diPanGanMapper) {
    Map<int, TianGan> result = {};
    for (var k in doorsMapper.keys) {
      EightDoorEnum door = doorsMapper[k]!;
      // RenPan AnGan uses the DiPan Gan of the door's *original* palace
      result[k] = diPanGanMapper[door.originalGong.houTianOrder]!;
    }
    return result;
  }

  Map<int, TianGan> _orderTianPanAnGan(Map<int, NineStarsEnum> nineStarMapper,
      Map<int, TianGan> diPanGanMapper) {
    Map<int, TianGan> result = {};
    for (var k in nineStarMapper.keys) {
      NineStarsEnum star = nineStarMapper[k]!;
      // TianPan AnGan uses the DiPan Gan of the star's *original* palace
      result[k] = diPanGanMapper[star.originalGong.houTianOrder]!;
    }
    return result;
  }

   Map<int, TianGan> _orderYinGan(
      TianGan timeTianGan,
      HouTianGua zhiShiDoorLandingGong, // Actual landing palace of ZhiShi
      HouTianGua zhiFuStarLandingGong,  // Actual landing palace of ZhiFu Star
      YinYang yinYangDun,
      SixJia sixJiaXunHeader,
      TianGan ganAtCenterGongDiPan, // DiPan Gan in center palace
      TianGan zhiShiDoorPalaceDiPanGan // DiPan Gan of the palace where ZhiShi door landed
      ) {
    List<int> nineGongSeq = [];
    int startAtGongNumber = zhiShiDoorLandingGong.houTianOrder;
    TianGan currentTianGan = timeTianGan;

    if (currentTianGan == TianGan.JIA) {
      currentTianGan = sixJiaXunHeader.gan;
      // If Jia (as Xunshou) is not same as DiPan Gan in Center, YinGan starts from Center
      if (currentTianGan != ganAtCenterGongDiPan) {
        startAtGongNumber = 5;
      }
    }
    // If ZhiFu and ZhiShi land in the same palace, YinGan starts from Center
    if (zhiShiDoorLandingGong == zhiFuStarLandingGong) {
      startAtGongNumber = 5;
    }
    // If starting palace is not Center AND DiPan Gan of ZhiShi landing palace is same as currentTianGan (after Jia conversion)
    // then YinGan starts from Center to avoid FuYin of YinGan with DiPan Gan.
    if (startAtGongNumber != 5 && zhiShiDoorPalaceDiPanGan == currentTianGan) {
      startAtGongNumber = 5;
    }

    if (yinYangDun.isYang) {
      nineGongSeq = ChangeSequenceUtils.changeNumberSeq(
          startAtGongNumber, List.generate(9, (i) => i + 1));
    } else {
      List<int> baseSeq = List.generate(9, (i) => i + 1).reversed.toList();
      int indexOfStart = baseSeq.indexOf(startAtGongNumber);
      nineGongSeq = [...baseSeq.sublist(indexOfStart), ...baseSeq.sublist(0, indexOfStart)];
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
      required Map<int, EightDoorEnum> zhuanPanEigthDoorMapper, // Named zhuanPan for consistency, but holds FeiPan doors
      required Map<int, EightGodsEnum> eightGodsGongNumberMapper, // TianPan Gods
      required Map<int, EightGodsEnum> diPanEightGodsMapper,    // DiPan Gods
      required Map<int, TianGan> tianPanTianGanMapper,
      required Map<int, TianGan> tianPanAnGanMapper,
      required Map<int, TianGan> renPanAnGanMapper,
      required Map<int, TianGan> yinGanMapper,
      required Map<int, TianGan> houGuaNumberGanMapper, // DiPan Gan
      required SixJia sixJiaXunHeader
      }) {
    return EachGong(
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
      sixJiaXunHeader: houGuaNumberGanMapper[i]! == sixJiaXunHeader.gan ? sixJiaXunHeader : null,
    );
  }
}
