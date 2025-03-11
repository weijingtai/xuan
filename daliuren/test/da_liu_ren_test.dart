import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("create daliuren with zeike(贼克)", () {
    // List<DiZhi> diZhiList = DiZhi.listAll;
    // DiZhi timeZhi =DiZhi.SHEN;
    // DiZhi monthGeneral = DiZhi.WEI;
    // List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi,diZhiList);
    // List<DiZhi> monthGeneralSeq = DaLiuRenKePan.changeDiZhiSeq(monthGeneral, diZhiList);
    // JiaZi dayJiaZi = JiaZi.JIA_ZI;
    // Map<DiZhi,DiZhi> currentPan = Map<DiZhi,DiZhi>.fromIterables(diSeq, monthGeneralSeq);
    //

    List<DiZhi> diZhiList = DiZhi.listAll;
    DiZhi timeZhi = DiZhi.SHEN;
    DiZhi monthGeneral = DiZhi.WEI;
    List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi, diZhiList);
    List<DiZhi> monthGeneralSeq =
        DaLiuRenKePan.changeDiZhiSeq(monthGeneral, diZhiList);
    // List<GuiRen> guiRenNameList = ["贵人","腾蛇","朱雀","六合","勾陈","青龙","天空","白虎","太常","玄武","太阴","天后"];
    // List<String> revGodsNameList = ["贵人","天后","太阴","玄武","太常","白虎","天空","青龙","勾陈","六合","朱雀","腾蛇"];
    List<GuiRen> guiRenNameList = GuiRen.clockwiseList;
    List<GuiRen> revGodsNameList = GuiRen.antiClockwiseList;
    // "贵腾朱合勾龙空虎常玄阴后"
    // "贵后阴玄常虎空龙勾合朱腾"
    // "甲乙丙丁戊己庚辛壬癸"

    // JiaZi dayJiaZi = JiaZi.JIA_ZI;
    Map<DiZhi, DiZhi> currentTianDiMapper =
        Map<DiZhi, DiZhi>.fromIterables(diSeq, monthGeneralSeq);
    Map<DiZhi, GuiRen> currentDiGodsMapper =
        Map<DiZhi, GuiRen>.fromIterables(diSeq, guiRenNameList);
    Map<DiZhi, DaLiuRenGong> currentPanWithGods = {};
    for (var di in diSeq) {
      currentPanWithGods[di] = DaLiuRenGong(
          guiRen: currentDiGodsMapper[di]!,
          skyPanDiZhi: currentTianDiMapper[di]!,
          groundPanDiZhi: di);
    }

    test("戊申月 丁巳日 辛丑 巳将", () {
      JiaZi dayJiaZi = JiaZi.getFromGanZhiValue("丁巳")!;
      DiZhi monthGeneral = DiZhi.getFromValue("巳")!;
      List<DiZhi> diPanSeq =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianPanSeq =
          "辰巳午未申酉戌亥子丑寅卯".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<GuiRen> godsSeq = "龙勾合雀腾贵后阴玄常虎空"
          .split("")
          .map((g) => GuiRen.getBySingleName(g))
          .toList();
      List<TianGan> tianGanSeq = "丙丁戊己庚辛壬癸○○甲乙"
          .split("")
          .map((e) => TianGan.getFromValue(e) ?? TianGan.KONG_WANG)
          .toList();
      Map<DiZhi, DaLiuRenGong> mapper = {};
      for (int i = 0; i < diPanSeq.length; i++) {
        mapper[diPanSeq[i]] = DaLiuRenGong(
            guiRen: godsSeq[i],
            skyPanDiZhi: tianPanSeq[i],
            groundPanDiZhi: diPanSeq[i],
            tianGan: tianGanSeq[i]);
      }
      expect(tianPanSeq.first, mapper[DiZhi.ZI]!.skyPanDiZhi);
      expect(diPanSeq.first, mapper[DiZhi.ZI]!.groundPanDiZhi);
      expect(godsSeq.first, mapper[DiZhi.ZI]!.guiRen.name);
      expect(tianGanSeq.first, mapper[DiZhi.ZI]!.tianGan);

      // 四课
      FourClass theFour =
          FourClass.fastGenerate(dayGanZhi: dayJiaZi, eachGongMapper: mapper);
      expect("阴", theFour.first.guiRen.name);
      expect("空", theFour.second.guiRen.name);
      expect("贵", theFour.third.guiRen.name);
      expect("常", theFour.fourth.guiRen.name);

      expect(DiZhi.HAI, theFour.first.sky);
      expect(DiZhi.MAO, theFour.second.sky);
      expect(DiZhi.YOU, theFour.third.sky);
      expect(DiZhi.CHOU, theFour.fourth.sky);

      expect(TianGan.DING, theFour.first.tianGan);
      expect(DiZhi.HAI, theFour.second.ground);
      expect(DiZhi.SI, theFour.third.ground);
      expect(DiZhi.YOU, theFour.fourth.ground);

      ThreeChuan threeChuan =
          DaLiuRenKePan.calculateThreeChuan(dayJiaZi, theFour, mapper);

      expect('贵', threeChuan.first.guiRen.name);
      expect('常', threeChuan.second.guiRen.name);
      expect('勾', threeChuan.third.guiRen.name);

      expect(DiZhi.YOU, threeChuan.first.diZhi);
      expect(DiZhi.CHOU, threeChuan.second.diZhi);
      expect(DiZhi.SI, threeChuan.third.diZhi);

      expect(TianGan.XIN, threeChuan.first.tianGan);
      expect(null, threeChuan.second.tianGan);
      expect(TianGan.DING, threeChuan.third.tianGan);

      // print(tianGanSeq.map((e)=>e==TianGan.KONG_WANG ? "○" : e.value));
      // print(godsSeq.map((e)=>e));
      // print(tianPanSeq.map((e)=>e.value));
      // print(diPanSeq.map((e)=>e.value));

      // String first = "亥癸";
      // String second = "午申"; // 克
      // String third = "卯巳";
      // String fourth= "辰酉";
      // JiaZi dayJiaZi = JiaZi.getFromGanZhiValue("${first.split("").last}${third.split("").last}")!;
      // // String fourClassString = "$first $second $third $fourth";
      // FourClass fourClass = createFourClass(dayJiaZi,first,second,third,fourth,currentPanWithGods);
      // ThreeChuan? chuChuanDiZhi = DaLiuRenKePan.checkByZeiKe(dayJiaZi,fourClass,currentPanWithGods);
      // expect(chuChuanDiZhi, isNotNull);
      // expect(chuChuanDiZhi!.first.diZhi, DiZhi.getFromValue("午"));
    });
  });
}

/// "<四> <三> <二> <一>"
FourClass createFourClass(JiaZi dayJiaZi, String first, String second,
    String third, String fourth, Map<DiZhi, DaLiuRenGong> eachGongMapper) {
  // List<String> each = fourClassString.split(" ").toList();
  //
  // String first = each[3];
  // String second = each[2];
  // String third = each[1];
  // String fourth = each[0];

  return FourClass.generate(
      firstGround: TianGan.getFromValue(first.split("").last)!,
      firstSky: DiZhi.getFromValue(first.split("").first)!,
      secondSky: DiZhi.getFromValue(second.split("").first)!,
      secondGround: DiZhi.getFromValue(second.split("").last)!,
      thirdSky: DiZhi.getFromValue(third.split("").first)!,
      thirdGround: DiZhi.getFromValue(third.split("").last)!,
      fourthSky: DiZhi.getFromValue(fourth.split("").first)!,
      fourthGround: DiZhi.getFromValue(fourth.split("").last)!,
      // dayGanZhi:JiaZi.getFromGanZhiValue("${first.split("").last}${DiZhi.getFromValue(third.split("").last)!}")!,
      dayGanZhi: dayJiaZi,
      eachGongMapper: eachGongMapper);
}
