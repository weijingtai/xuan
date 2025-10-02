import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:flutter_test/flutter_test.dart';

import 'da_liu_ren_test.dart';

void main() {
  group("create daliuren with 遥克", () {
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
    // Map<DiZhi,DiZhi> currentPan = Map.fromIterables(diPanList_dev, tianPanList_dev);
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

    test("遥克 一个日干妻财， 两个日干官鬼 --- 日干：甲", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "戌亥子丑寅卯辰巳未申酉午".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // 两个贼 2  --- 涉害 1
      String first = "亥甲";
      String second = "申亥"; // 妻财
      String third = "丑辰"; // 官鬼
      String fourth = "戌丑"; // 官鬼
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      // String fourClassString = "$first $second $third $fourth";
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      expect(fourClass.first.isSkyKeDayGan, null);
      expect(fourClass.second.isSkyKeDayGan, true);
      expect(fourClass.third.isSkyKeDayGan, false);
      expect(fourClass.fourth.isSkyKeDayGan, false);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByYaoKe(dayJiaZi, fourClass, currentPanWithGods);
      expect(yaoKe, isNotNull);
      // expect(yaoKe, )
      expect(yaoKe!.first.diZhi, DiZhi.getFromValue("申"));
    });
    test("遥克  1个日干官鬼 --- 日干：庚", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "戌亥子丑寅卯辰巳未申酉午".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // 两个贼 2  --- 涉害 1
      String first = "亥庚";
      String second = "寅亥"; // 官鬼
      String third = "丑辰"; //
      String fourth = "戌丑"; //
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      // String fourClassString = "$first $second $third $fourth";
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      expect(fourClass.first.isSkyKeDayGan, null);
      expect(fourClass.second.isSkyKeDayGan, false);
      expect(fourClass.third.isSkyKeDayGan, null);
      expect(fourClass.fourth.isSkyKeDayGan, null);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByYaoKe(dayJiaZi, fourClass, currentPanWithGods);
      // expect(yaoKe, )
      expect(yaoKe!.first.diZhi, DiZhi.getFromValue("寅"));
    });
    test("遥克 1个日干妻财 2个日干官鬼 --- 日干：壬", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "戌亥子丑寅卯辰巳未申酉午".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // 两个贼 2  --- 涉害 1
      String first = "寅壬";
      String second = "巳寅"; // 妻财
      String third = "未辰"; // 官鬼
      String fourth = "戌未"; // 官鬼
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      // String fourClassString = "$first $second $third $fourth";
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      expect(fourClass.first.isSkyKeDayGan, null);
      expect(fourClass.second.isSkyKeDayGan, false);
      expect(fourClass.third.isSkyKeDayGan, true);
      expect(fourClass.fourth.isSkyKeDayGan, true);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByYaoKe(dayJiaZi, fourClass, currentPanWithGods);
      // expect(yaoKe, )
      expect(yaoKe!.first.diZhi, DiZhi.getFromValue("戌"));
    });
    test("遥克 2个日干妻财--- 日干：壬", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "戌亥子丑寅卯辰巳未申酉午".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      // 两个贼 2  --- 涉害 1
      String first = "寅壬";
      String second = "巳寅"; // 妻财
      String third = "卯子"; // 官鬼
      String fourth = "午卯"; // 官鬼
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      // String fourClassString = "$first $second $third $fourth";
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      // EachClass chuChuanDiZhi = DaLiuRenKePan.calculateThreeChuan(dayJiaZi,fourClass,currentTianDiMapper);
      expect(fourClass.first.isSkyKeDayGan, null);
      expect(fourClass.second.isSkyKeDayGan, false);
      expect(fourClass.third.isSkyKeDayGan, null);
      expect(fourClass.fourth.isSkyKeDayGan, false);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByYaoKe(dayJiaZi, fourClass, currentPanWithGods);
      // expect(yaoKe, )
      expect(yaoKe!.first.diZhi, DiZhi.getFromValue("午"));
    });
  });
}
