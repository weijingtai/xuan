import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:flutter_test/flutter_test.dart';

import 'da_liu_ren_test.dart';

void main() {
  group("create daliuren with 昴星", () {
    List<DiZhi> diZhiList = DiZhi.listAll;
    DiZhi timeZhi = DiZhi.SHEN;
    DiZhi monthGeneral = DiZhi.WEI;
    // List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi,diZhiList);
    // List<DiZhi> monthGeneralSeq = DaLiuRenKePan.changeDiZhiSeq(monthGeneral, diZhiList);
    // Map<DiZhi,DiZhi> currentPan = Map<DiZhi,DiZhi>.fromIterables(diSeq, monthGeneralSeq);

    List<DiZhi> dipanlistDev =
        "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
    List<DiZhi> tianpanlistDev =
        "戌亥子丑寅卯辰巳午未申酉".split("").map((e) => DiZhi.getFromValue(e)!).toList();
    JiaZi dayJiaZi = JiaZi.WU_CHEN;

    List<DiZhi> diSeq = DaLiuRenKePan.changeDiZhiSeq(timeZhi, dipanlistDev);
    // List<DiZhi> monthGeneralSeq = DaLiuRenKePan.changeDiZhiSeq(monthGeneral, diZhiList);
    List<DiZhi> monthGeneralSeq = tianpanlistDev;

    // List<String> godsNameList = ["贵人","腾蛇","朱雀","六合","勾陈","青龙","天空","白虎","太常","玄武","太阴","天后"];
    List<GuiRen> godsNameList = GuiRen.clockwiseList;

    // Map<DiZhi,DiZhi> currentTianDiMapper = Map<DiZhi,DiZhi>.fromIterables(diSeq, monthGeneralSeq);
    Map<DiZhi, DiZhi> currentTianDiMapper =
        Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, monthGeneralSeq);
    Map<DiZhi, GuiRen> currentDiGodsMapper =
        Map<DiZhi, GuiRen>.fromIterables(diSeq, godsNameList);
    Map<DiZhi, DaLiuRenGong> currentPanWithGods = {};
    for (var di in diSeq) {
      currentPanWithGods[di] = DaLiuRenGong(
          guiRen: currentDiGodsMapper[di]!,
          skyPanDiZhi: currentTianDiMapper[di]!,
          groundPanDiZhi: di);
    }

    test("昴星 戊申日 卯时", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "丑寅卯辰巳午未申酉戌亥子".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      // currentTianDiMapper.forEach((k,v)=>print("${k.value} - ${v.value}"));
      for (var di in dipanlistDev) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // currentPanWithGods.forEach((k,v)=>print("${k.value} ${v.groundPanDiZhi.value}=${v.skyPanDiZhi.value}"));
      // 两个贼 2  --- 涉害 1
      String first = "午戊";
      String second = "未午"; // 妻财
      String third = "酉申"; // 官鬼
      String fourth = "戌酉"; // 官鬼
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      // String fourClassString = "$first $second $third $fourth";
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      expect(fourClass.first.isSkyKeDayGan, null);
      expect(fourClass.second.isSkyKeDayGan, null);
      expect(fourClass.third.isSkyKeDayGan, null);
      expect(fourClass.fourth.isSkyKeDayGan, null);
      ThreeChuan? maoXing =
          DaLiuRenKePan.checkByMaoXing(dayJiaZi, fourClass, currentPanWithGods);
      expect(maoXing, isNotNull);
      expect(maoXing!.first.diZhi, DiZhi.getFromValue("戌"));
      expect(maoXing.second.diZhi, DiZhi.getFromValue("酉"));
      expect(maoXing.third.diZhi, DiZhi.getFromValue("午"));
    });
    test("昴星 丁丑日 辰时", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "酉戌亥子丑寅卯辰巳午未申".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      // currentTianDiMapper.forEach((k,v)=>print("${k.value} - ${v.value}"));
      for (var di in dipanlistDev) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // currentPanWithGods.forEach((k,v)=>print("${k.value} ${v.groundPanDiZhi.value}=${v.skyPanDiZhi.value}"));
      // 两个贼 2  --- 涉害 1
      String first = "辰丁";
      String second = "丑辰"; // 妻财
      String third = "戌丑"; // 官鬼
      String fourth = "未戌"; // 官鬼
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      // String fourClassString = "$first $second $third $fourth";
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      expect(fourClass.first.isSkyKeDayGan, null);
      expect(fourClass.second.isSkyKeDayGan, null);
      expect(fourClass.third.isSkyKeDayGan, null);
      expect(fourClass.fourth.isSkyKeDayGan, null);
      ThreeChuan? maoXing =
          DaLiuRenKePan.checkByMaoXing(dayJiaZi, fourClass, currentPanWithGods);
      expect(maoXing, isNotNull);
      expect(maoXing!.first.diZhi, DiZhi.getFromValue("子"));
      expect(maoXing.second.diZhi, DiZhi.getFromValue("辰"));
      expect(maoXing.third.diZhi, DiZhi.getFromValue("戌"));
    });
  });
}
