import 'package:common/enums.dart';
import 'package:daliuren/model/da_liu_ren_gong.dart';
import 'package:daliuren/model/da_liu_ren_ke_pan.dart';
import 'package:daliuren/model/enum_gui_ren.dart';
import 'package:daliuren/model/four_class.dart';
import 'package:daliuren/model/three_chuan.dart';
import 'package:flutter_test/flutter_test.dart';

import 'da_liu_ren_test.dart';

void main() {
  group("create daliuren with 反吟", () {
    DiZhi timeZhi = DiZhi.SHEN;

    List<DiZhi> dipanlistDev =
        "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
    List<DiZhi> tianpanlistDev =
        "午未申酉戌亥子丑寅卯辰巳".split("").map((e) => DiZhi.getFromValue(e)!).toList();
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

    test("反吟 无克", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "午未申酉戌亥子丑寅卯辰巳".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      String first = "辰辛";
      String second = "戌辰";
      String third = "丑未";
      String fourth = "未丑";
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByFanYin(dayJiaZi, fourClass, currentPanWithGods);
      print(
          "${yaoKe!.first.diZhi.value},${yaoKe.second.diZhi.value},${yaoKe.third.diZhi.value}");
      expect(yaoKe.first.diZhi, DiZhi.getFromValue("巳"));
      expect(yaoKe.second.diZhi, DiZhi.getFromValue("丑"));
      expect(yaoKe.third.diZhi, DiZhi.getFromValue("辰"));
    });
    test("反吟 有克", () {
      List<DiZhi> dipanlistDev =
          "子丑寅卯辰巳午未申酉戌亥".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      List<DiZhi> tianpanlistDev =
          "午未申酉戌亥子丑寅卯辰巳".split("").map((e) => DiZhi.getFromValue(e)!).toList();
      Map<DiZhi, DiZhi> currentTianDiMapper =
          Map<DiZhi, DiZhi>.fromIterables(dipanlistDev, tianpanlistDev);
      for (var di in diSeq) {
        currentPanWithGods[di] = DaLiuRenGong(
            guiRen: currentDiGodsMapper[di]!,
            skyPanDiZhi: currentTianDiMapper[di]!,
            groundPanDiZhi: di);
      }
      String first = "亥丙";
      String second = "巳亥";
      String third = "寅申";
      String fourth = "申寅";
      dayJiaZi = JiaZi.getFromGanZhiValue(
          "${first.split("").last}${third.split("").last}")!;
      FourClass fourClass = createFourClass(
          dayJiaZi, first, second, third, fourth, currentPanWithGods);
      ThreeChuan? yaoKe =
          DaLiuRenKePan.checkByFanYin(dayJiaZi, fourClass, currentPanWithGods);
      print(
          "${yaoKe!.first.diZhi.value},${yaoKe.second.diZhi.value},${yaoKe.third.diZhi.value}");
      expect(yaoKe.first.diZhi, DiZhi.getFromValue("寅"));
      expect(yaoKe.second.diZhi, DiZhi.getFromValue("申"));
      expect(yaoKe.third.diZhi, DiZhi.getFromValue("寅"));
    });
  });
}
